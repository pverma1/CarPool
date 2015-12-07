//
//  MasterViewController.swift
//  CarPool
//
//  Created by Prachi Verma on 01/12/15.
//  Copyright © 2015 Prachi Verma. All rights reserved.
//

import UIKit

class MasterViewController: UIViewController {

    var detailViewController: DetailViewController? = nil
    var objects = [AnyObject]()


    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
       
    }
    
    override func viewDidAppear(animated: Bool) {
        let userDefault = NSUserDefaults.standardUserDefaults();
        if(userDefault.objectForKey("isLoggedin") as? Bool == false || userDefault.objectForKey("isLoggedin") as? Bool == nil){
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("LoginView") as! LoginView
        self.presentViewController(vc, animated: true, completion: nil)
        }
        super.viewDidAppear(animated)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func selectedIMDriving(sender: UIButton){
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("DetailViewController") as! DetailViewController
        navigationController?.pushViewController(vc, animated: true )
    
    }

    @IBAction func selectedNeedARide(sender: UIButton){
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("DetailViewController") as! DetailViewController
        vc.needARide = true;
        navigationController?.pushViewController(vc, animated: true )
        
    }
    // MARK: - Segues

   
    // MARK: - Table View
/*
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)

        let object = objects[indexPath.row] as! NSDate
        cell.textLabel!.text = object.description
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            objects.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
*/

}

