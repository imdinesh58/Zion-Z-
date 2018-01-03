//
//  ViewController.swift
//  zionSwiftLearning
//
//  Created by Apple-1 on 3/1/17.
//  Copyright © 2017 Apple-1. All rights reserved.
//

import UIKit
import Foundation

class ViewController: UIViewController {
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var lbl1: UILabel!
    @IBOutlet weak var loginBtn: UIButton!
    
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        
        ///check AUth Token Exists or not
        
        let defaults = UserDefaults.standard
        if let name = defaults.string(forKey: "AccessToken")
        {
            if name != "" {
                print(" TOKEN is Already there ... so go directly to DASHBOARD ||||||  ")
                //print("TOKEN is Already There " , name)
                self.switchScreen()
            } else{
                print(" No TOKEN Stay in sign in ||||||  ")
            }
        }
        
        
        //text border
        let myColor : UIColor = UIColor.white
        username.layer.borderColor = myColor.cgColor
        username.layer.borderWidth = 1
        password.layer.borderColor = myColor.cgColor
        password.layer.borderWidth = 1
        //lbl font
        lbl1.font = UIFont.boldSystemFont(ofSize: 20.0)
        //image view logo
    }
    
    @IBAction func LoginButtonClick(_ sender: Any) {
        self.LoginButtonFunction()
    }
    
    func LoginButtonFunction() {
        
        //Start API Service call login - POST
        
        if let text = self.username.text, text.isEmpty
        {
            let alert = UIAlertController(title: "Alert", message: "Enter Username", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        } else if let text = self.password.text, text.isEmpty {
            let alert = UIAlertController(title: "Alert", message: "Enter Password", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else{
            
            print("Login button clicked")
            
            ///loading bar
            OperationQueue.main.addOperation {
                self.activityIndicator.center = self.view.center
                self.activityIndicator.hidesWhenStopped = true
                self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
                self.activityIndicator.frame = CGRect(x: 118, y: 548, width: 60, height: 60);
                self.activityIndicator.color = UIColor.blue
                let text = UILabel(frame: CGRect(x: 165, y: 570, width: 20, height: 20))
                text.text = "Please wait..."
                text.font = text.font.withSize(13)
                text.sizeToFit()
                self.view.addSubview(self.activityIndicator)
                self.view.addSubview(text)
                self.activityIndicator.startAnimating()
                UIApplication.shared.beginIgnoringInteractionEvents()
            }
            
            var request = URLRequest(url: URL(string: "https://ss-t.vspl.net/zion.web.fsit2/token")!)
            request.httpMethod = "POST"
            let postString = "username="+self.username.text! + "&password="+self.password.text!;
            request.httpBody = postString.data(using: .utf8)
            request.httpBody = postString.data(using: String.Encoding.utf8);
            
            let task = URLSession.shared.dataTask(with: request) {
                data, response, error in
                guard error == nil && data != nil else {     // check for fundamental networking error
                    //print("Error 1 =\(error)")
                    OperationQueue.main.addOperation{ //hide activity bar
                        self.activityIndicator.stopAnimating()
                        UIApplication.shared.endIgnoringInteractionEvents()
                        let alert = UIAlertController(title: "Alert", message: "Network Issue... try again", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                    return
                }
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                    //check for http error code
                    print("StatusCode should be 200, but is \(httpStatus.statusCode)")
                    //print("Response = \(response)")
                    OperationQueue.main.addOperation{
                        //hide activity bar
                        self.activityIndicator.stopAnimating()
                        UIApplication.shared.endIgnoringInteractionEvents()
                        let alert = UIAlertController(title: "Alert", message: "Error during login... try again", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode == 200 {
                    //no errors //status ok
                    print("StatusCode should be 200 === \(httpStatus.statusCode)")
                    //print("Response = \(response)")
                    let responseString = String(data: data!, encoding: String.Encoding.utf8)
                    //print("ResponseString = \(responseString)")
                    print("ResponseString = " +     responseString!)
                    self.convertStringToDictionary(text: responseString!)
                }
                
            } // end of task response
            task.resume()
            
        }  //End of else
        
    }  //end of LoginButtonFunction
    
    
    func convertStringToDictionary(text: String) -> [String:AnyObject]? {
        if let data = text.data(using: String.Encoding.utf8) {
            do {
                let json=try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject]
                
                OperationQueue.main.addOperation {  // run in main thread
                    //hide activity indicator
                    self.activityIndicator.stopAnimating()
                    UIApplication.shared.endIgnoringInteractionEvents()
                    
                    ///parsing json
                    if  let blogs4 = json!["message"] {
                        print( " Error TOKEN %%%% " + (blogs4 as! String))
                        self.username.text = ""
                        self.password.text = ""
                        let alert = UIAlertController(title: "Alert", message: (blogs4 as! String), preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
                
                if  let blogs = json!["successMessage"] {
                    //print( " Created TOKEN %%%% " + (blogs as! String))
                    
                    let defaults = UserDefaults.standard
                    defaults.set((blogs as! String), forKey: "AccessToken")
                    
                    self.switchScreen()
                }
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject]
                
            } catch let error as NSError {
                print(error)
            }
        }
        return nil
    }
    
    func switchScreen() {
        OperationQueue.main.addOperation {  // run in main thread
            self.dismiss(animated: false, completion: nil) //hide loading bar
            let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let vc : UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "DashboardViewController") as UIViewController
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func readJSONObject(object: [String: AnyObject]) {
        let tok = object["token"] as? String
        print("token " + tok!);
        
    }
    
    //func setTimeout(delay:TimeInterval, block:@escaping ()->Void) -> Timer {
    //   return Timer.scheduledTimeretimeInterval;: lay, target: BlockOperation(block: block), selector: #selector(Operation.main), userInfo: nil, repeats: //false)
    //}
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

