//
//  ViewController.swift
//  forNiiSokb
//
//  Created by Roman Spirichkin on 02/02/16.
//  Copyright © 2016 rs. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class RSTitlesVC: UITableViewController {

    @IBOutlet var RSActivity: UIActivityIndicatorView!
    var msgID = Int()   // number of current title (& images)
    let NIIUrl = "http://private-db05-jsontest111.apiary-mock.com/androids"
    
    // MARK: ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        // add button refresh
        self.navigationItem.rightBarButtonItem =
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "refreshTableVC:")
        self.RSActivity.center = CGPoint(x: self.view.bounds.width/2, y: (self.view.bounds.height-60)/2)
        
        // dowload messages
        self.refreshTableVC(UIButton())
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        // orientation for activityIndicator
        self.RSActivity.center = CGPoint(x: (self.view.bounds.height)/2, y: self.view.bounds.width/2)
    }
    
    
    // MARK: HTTP Request
    func HTTPRequest(url: String) {
        self.navigationItem.rightBarButtonItem?.enabled = false     // disable refresh button
        // remove current JSON
        messages.removeAll()
        self.tableView.reloadData()
        // downloading new JSON
        Alamofire.request(.GET, url).responseJSON { response in
            if let dummyData = response.data {
                let dummyJSON = JSON(data: dummyData)
                for (_, subJSON) in dummyJSON {
                    let newMessages = Message(title: subJSON["title"].stringValue, urlImage: subJSON["img"].stringValue)
                    messages.append(newMessages)
                }
            } else { print("No-No-No ;(") }
            // show titles
            dispatch_async(dispatch_get_main_queue()) {
                self.tableView.reloadData()
                self.RSActivity.removeFromSuperview()
                self.navigationItem.rightBarButtonItem?.enabled = true
            }
        }
    }
    
    
    // MARK: TableView
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return messages.count }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("RSTableCell")
        cell?.textLabel?.text = messages[indexPath.row].title
        cell?.textLabel?.textAlignment = NSTextAlignment.Justified
        return cell!
    }
    
    
    // MARK: Refresh Table
    func refreshTableVC(button: UIButton) {
        // add activity indicator
        self.view.addSubview(RSActivity)
        self.RSActivity.startAnimating()
        GlobalRefreshID++
        dispatch_async(dispatch_get_main_queue()) {
            self.HTTPRequest(self.NIIUrl)
        }
    }
    
    
    // MARK: Segue
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.cellForRowAtIndexPath(indexPath)!.selectionStyle = UITableViewCellSelectionStyle.None
        self.msgID = indexPath.row
        self.performSegueWithIdentifier("RSSegue2Image", sender: self)
    }
    override func prepareForSegue(segue:(UIStoryboardSegue!), sender:AnyObject!)
    {
        if segue.identifier == "RSSegue2Image" {
            (segue.destinationViewController as! RSPageBackgroundVC).msgIDpage = self.msgID
        }
    }
}

