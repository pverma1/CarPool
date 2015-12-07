//
//  LoginView.swift
//  CarPool
//
//  Created by Prachi Verma on 01/12/15.
//  Copyright © 2015 Prachi Verma. All rights reserved.
//

import UIKit

class LoginView: UIViewController {
    
    var userName : NSString = "test"
    var password : NSString = "test@123"
    
    @IBOutlet weak var userNameTxtfld: UITextField!
    @IBOutlet weak var passwordTxtFld : UITextField!



    override func viewDidLoad() {
        super.viewDidLoad()
        

        // Do any additional setup after loading the view.
    }
    
    @IBAction func login(sender: UIButton) {
        
        if(userNameTxtfld.text == userName && passwordTxtFld.text == password){
            self.dismissViewControllerAnimated(false, completion: nil)
            let userDefault = NSUserDefaults.standardUserDefaults();
            userDefault.setBool(true, forKey:"isLoggedin");
        }
        else{
            let alertController = UIAlertController(title: "Invalid Credentials", message:
                "Please enter valid credentials!", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "ok", style: UIAlertActionStyle.Default,handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
