//
//  ViewController.swift
//  instagram2
//
//  Created by Vincent Le on 1/28/16.
//  Copyright © 2016 Vincent Le. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD


class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
    
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var urlHolder: NSURL?
    var feed: [NSDictionary]?
    var isMoreDataLoading = false
    var loadingMoreView: InfiniteView?
    var photosCount: Int = 20
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView.dataSource = self
        tableView.delegate = self
        
        let refreshControl = UIRefreshControl()
        
        let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteView.defaultHeight)
        loadingMoreView = InfiniteView(frame: frame)
        loadingMoreView!.hidden = true
        tableView.addSubview(loadingMoreView!)
        
        var insets = tableView.contentInset;
        insets.bottom += InfiniteView.defaultHeight;
        tableView.contentInset = insets
        
        loadDataFromNetwork()
        
        
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        let clientId = "e05c462ebd86446ea48a5af73769b602"
        let url = NSURL(string:"https://api.instagram.com/v1/media/popular?client_id=\(clientId)")
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            
                            MBProgressHUD.hideHUDForView(self.view, animated: true)
                            self.feed = responseDictionary["data"] as? [NSDictionary]
                            //print(responseDictionary["data"])
                            self.tableView.reloadData()
                            refreshControl.endRefreshing()
                            
                            
                    }
                }
        });
        task.resume()
    }
    
    func loadDataFromNetwork() {
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        let clientId = "e05c462ebd86446ea48a5af73769b602"
        let url = NSURL(string:"https://api.instagram.com/v1/media/popular?client_id=\(clientId)")
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            
                            MBProgressHUD.hideHUDForView(self.view, animated: true)
                            self.feed = responseDictionary["data"] as? [NSDictionary]
                            //print(responseDictionary["data"])
                            
                            
                    }
                }
        });
        task.resume()
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)  {
        //var vc = segue.destinationViewController as PhotoDetailsViewController
        //var indexPath = tableView.indexPathForCell(sender as UITableViewCell)
        if segue.identifier == "toPhotoDetail" {
            let cell = sender as! UITableViewCell
            if let indexPath = tableView.indexPathForCell(cell) {
                let vc = segue.destinationViewController as! PhotoDetailsViewController
                let photo = feed?[indexPath.row]
                
                let path = photo!.valueForKeyPath("images.low_resolution.url") as? String
                let url = NSURL(string: path!)
                vc.photoURL = url
                
                
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
            }
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated:true)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photosCount
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("FeedCell", forIndexPath: indexPath) as! FeedCell
        
        
        /*
        let image = photo["response"] as? NSDictionary
        let counter =  image!["standard_resolution"]!["url"] as! String
        */
        if let photo = feed?[indexPath.row]{
            let path = photo.valueForKeyPath("images.low_resolution.url") as? String
            let url = NSURL(string: path!)
            cell.photoView.setImageWithURL(url!)
        }
        else {
            //print(feed?[indexPath.row])
        }
        
 

        return cell
    }
    
    
    func loadMoreData() {
        
        let clientId = "e05c462ebd86446ea48a5af73769b602"
        let url = NSURL(string:"https://api.instagram.com/v1/media/popular?client_id=\(clientId)")
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                self.isMoreDataLoading = false;
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            if(self.feed != nil) {
                                self.feed = self.feed! + (responseDictionary["data"] as! [NSDictionary]);
                                self.photosCount += 20
                            } else {
                                self.feed = responseDictionary["data"] as? [NSDictionary];
                            }
                            self.tableView.reloadData();
                    }
                }
                self.loadingMoreView!.stopAnimating()
                
        });
        task.resume()
    }

    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.dragging) {
                isMoreDataLoading = true
                
                // Update position of loadingMoreView, and start loading indicator
                let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()
                
                // Code to load more results
                loadMoreData()		
            }
        }
    }
}
