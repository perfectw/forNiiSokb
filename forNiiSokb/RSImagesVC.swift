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


// MARK: RSPageBackgroundVC
class RSPageBackgroundVC: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    var pageViewController: UIPageViewController!
    var msgIDpage = Int() // for pageVC
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // init PageView and set first Image
        self.navigationItem.title = messages[self.msgIDpage].title
        let startVC = self.viewControllerAtIndex(msgIDpage) as RSImagesVC
        startVC.msgID = self.msgIDpage
        let viewControllers = NSArray(object: startVC)
        self.pageViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PageViewController") as! UIPageViewController
        self.pageViewController.setViewControllers(viewControllers as? [UIViewController], direction: .Forward, animated: true, completion: nil)
        self.pageViewController.view.frame = CGRectMake(0, 30, self.view.frame.width, self.view.frame.size.height - 30)
        self.addChildViewController(self.pageViewController)
        self.view.addSubview(self.pageViewController.view)
        self.pageViewController.didMoveToParentViewController(self)
        self.pageViewController.dataSource = self
        self.pageViewController.delegate  = self
        
        
    }
    
    // 'init' new image
    func viewControllerAtIndex(ID: Int) -> RSImagesVC
    {
        let vc: RSImagesVC = self.storyboard?.instantiateViewControllerWithIdentifier("RSImagesVC") as! RSImagesVC
        vc.msgID = ID
        return vc
    }
    
    
    // MARK: PageView   DataSource
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        if self.msgIDpage == 0  { return nil }
        return self.viewControllerAtIndex(self.msgIDpage - 1)
    }
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        if self.msgIDpage == messages.count-1  { return nil }
        return self.viewControllerAtIndex(self.msgIDpage + 1)
    }
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int
    { return messages.count }
    
    
    // MARK: PageView   Delegate
    func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [UIViewController]) {
        if let itemController = pendingViewControllers[0] as? RSImagesVC {
            self.msgIDpage = itemController.msgID
            self.navigationItem.title = messages[self.msgIDpage].title
        }
    }
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if (completed) {
            if let vc = pageViewController.viewControllers![0] as? RSImagesVC {
                self.msgIDpage = vc.msgID
                self.navigationItem.title = messages[self.msgIDpage].title
            }
        }
    }
}


// MARK: RSImageVC
class RSImagesVC: UIViewController {
    @IBOutlet weak var RSImageView: UIImageView!
    @IBOutlet var RSActivity: UIActivityIndicatorView!
    
    var msgID = Int()   // number of current image
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.RSActivity.center = CGPoint(x: self.RSImageView.bounds.width/2, y: (self.RSImageView.bounds.height)/2)
        if let img = messages[msgID].image {
            // if image is ok
            self.RSImageView.image = img
            self.RSActivity.removeFromSuperview()
        } else {
            // if any problem
            self.RSActivity.startAnimating()
            if messages[msgID].isImageDataBroken == true {
                // if image adress from url is broken
                self.RSImageView.image = UIImage(named: "noimg.png")
                self.RSActivity.removeFromSuperview()
            } else {
                // if don't loaded
                dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
                    let currentRefreshID = GlobalRefreshID
                    Alamofire.request(.GET, messages[self.msgID].urlImage).responseJSON { response in
                        // loading
                        if currentRefreshID == GlobalRefreshID { //if the same one session
                        if let imgData = response.data {
                            messages[self.msgID].image = UIImage(data: imgData)
                            // asunc show
                            dispatch_async(dispatch_get_main_queue()) {
                            self.RSImageView.image = messages[self.msgID].image
                            // if image adress from url is broken
                            if self.RSImageView.image == nil {
                                messages[self.msgID].isImageDataBroken = true
                                self.RSImageView.image = UIImage(named: "noimg.png")
                                }
                            }
                        }
                        }
                        self.RSActivity.removeFromSuperview()
                            
                    }
                }
            }
        }
    }
}
