
//
//  Created by Apple-1 on 3/1/17.
//  Copyright © 2017 Apple-1. All rights reserved.
//

import UIKit

class Form1: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    var formName : String  = ""
    var sectionTitleLists:String = ""
    var categoryName:String = ""
    //general
    var SectionsListsArray:[String] = []
    var FieldsNamesListsArray = [[String:String]]()
    var siteTypesArray:[String] = []
    var NBNTypesArray:[String] = []
    var shelterTypesArray:[String] = []
    var obstructionTypesArray:[String] = []
    //design items
    var DesignFieldsNamesListsArray = [[String:String]]()
    //Power
    var PowerFieldsNamesListsArray = [[String:String]]()
    var OHSTypesArray:[String] = []
    var SpecialSiteTypesArray:[String] = []
    //Sketch
    var SketchFieldsNamesListsArray = [[String:String]]()
    //prepared by
    var PreparedByFieldsNamesListsArray = [[String:String]]()
    
    @IBOutlet var form1TableView: UITableView!
    
    @IBOutlet weak var back: UIButton!
    
    @IBOutlet weak var fN: UILabel!
    
    @IBOutlet var saveButton: UIButton!
    
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    
    var arrayOfTextFields:[UITextField] = []
    
    @IBAction func saveButtonClick(_ sender: Any) {
//        for textField1 in arrayOfTextFields{
//            print("SAVING  ",textField1.text as Any)
//        }
        //loading bar
        OperationQueue.main.addOperation {
            self.activityIndicator.center = self.view.center
            self.activityIndicator.hidesWhenStopped = true
            self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
            self.activityIndicator.frame = CGRect(x: 150, y: 290, width: 60, height: 60);
            self.activityIndicator.color = UIColor.red
            let text = UILabel(frame: CGRect(x: 65, y: 270, width: 20, height: 20))
            text.text = ""
            text.font = text.font.withSize(13)
            text.sizeToFit()
            self.view.addSubview(self.activityIndicator)
            self.view.addSubview(text)
            self.activityIndicator.startAnimating()
            UIApplication.shared.beginIgnoringInteractionEvents()
        }
        
        self.FormStagingPOSTAPIcall()
        
        gobacktoDashBoard()
    }
    
    func FormStagingPOSTAPIcall() {
        OperationQueue.main.addOperation{
            //STAGING POST CALL
            // create the request & respons
            var request = URLRequest(url: URL(string: "https://ss-t.vspl.net/zion.api.fsit2/Form/SaveStaging")!)
            request.httpMethod = "POST"
            //read Auth Token
            let defaults = UserDefaults.standard
            let Token = defaults.string(forKey: "AccessToken")
            if (Token != nil)
            {
                print("RETRIEVED TOKEN --- DASHBOARD SCREEN ||||||  ")
                //print(Token)
            }
            let setAuthToken = "bearer " + Token!
            //print("AUTHORIZATION  " + setAuthToken)
            request.setValue(setAuthToken, forHTTPHeaderField: "authorization")
            let postString = "{\"formId\":\"183b7e1f-7098-4fc1-98bb-a404009af0e1\",\"name\":\"Stage 2 Site DC Checklist\",\"projectID\":\"d444f503-3354-40df-8021-f4c9e99074b6\", \"siteID\": \"3643\", \"state\": \"InProgress\", \"type\": \"SITE DOCUMENTS\",\"conductedBy\": \"testusrepe\", \"categoryId\": 21, \"conductedOn\": \"2016-08-30T09:18:10.626+0530\"}"
            //print("    ", postString)
            request.httpBody = postString.data(using: String.Encoding.utf8);

            let task = URLSession.shared.dataTask(with: request) {
                data, response, error in
                
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                    //check for http error code
                    print("StatusCode should be 200, but is \(httpStatus.statusCode)")
                    let responseString = String(data: data!, encoding: String.Encoding.utf8)
                    print("ResponseString Failure = " +     responseString!)
                    OperationQueue.main.addOperation{
                        //hide activity bar
                        self.activityIndicator.stopAnimating()
                        UIApplication.shared.endIgnoringInteractionEvents()
                        let alert = UIAlertController(title: "Alert", message: "Error during Save... try again", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
                OperationQueue.main.addOperation{
                    if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode == 200 {
                        //no errors //status ok
                        print("StatusCode should be 200 === \(httpStatus.statusCode)")
                        let responseString = String(data: data!, encoding: String.Encoding.utf8)
                        //print("ResponseString Success = " +     responseString!)
                        self.convertStringToDictionary2(text: responseString!)
                    }
                }
                
            } // end of task response
            task.resume()
        }
    }

    func convertStringToDictionary2(text: String) -> [String:AnyObject]? {
        
        if let data = text.data(using: String.Encoding.utf8) {
            do {
                let json=try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject]
                
                OperationQueue.main.addOperation {  // run in main thread
                    //hide activity indicator
                    self.activityIndicator.stopAnimating()
                    UIApplication.shared.endIgnoringInteractionEvents()
                }
                
                if  let blogs = json!["stagingDataId"] {
                    print( " ******* Genearted  STAGING ID ********  ===   " + (blogs as! String))
                    
                    let defaults = UserDefaults.standard
                    defaults.set((blogs as! String), forKey: "stagingID")
                    
                    self.gobacktoDashBoard()
                }
                
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject]
                
            } catch let error as NSError {
                print(error)
            }
        }
        return nil
    }

    func gobacktoDashBoard() {
        //close Form1 Window
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "DashboardViewController")
        self.present(vc, animated: true, completion: nil)
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refresh"), object: nil)
        
        //call othewr window function
        //let OO = DashboardViewController()
    }

    @IBAction func goBack() {
        // go back to sign in screen
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "DashboardViewController")
        self.present(vc, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        fN.text = formName
        
        FieldsNamesListsArray.removeAll()
        siteTypesArray.removeAll()
        NBNTypesArray.removeAll()
        shelterTypesArray.removeAll()
        obstructionTypesArray.removeAll()
        DesignFieldsNamesListsArray.removeAll()
        PowerFieldsNamesListsArray.removeAll()
        OHSTypesArray.removeAll()
        SpecialSiteTypesArray.removeAll()
        SketchFieldsNamesListsArray.removeAll()
        PreparedByFieldsNamesListsArray.removeAll()
        
        let defaults = UserDefaults.standard
        if let receivedJson = defaults.string(forKey: "MainJSON")
        {
            if receivedJson != "" {
                self.convertStringToDictionary(text: receivedJson)
                //print("receivedJson >>> " , receivedJson)
            } else{
                print(" No received Json ||||||  ")
            }
        }
    } //viewDidLoad close

    func convertStringToDictionary(text: String) -> [String:AnyObject]? {
        DispatchQueue.main.async(){
            if let data_ = text.data(using: String.Encoding.utf8) {
                do {
                    self.FieldsNamesListsArray.removeAll()
                    let jsonObj = try JSONSerialization.jsonObject(with: data_, options: [])
                    
                    for anItem in jsonObj as! [Dictionary<String, AnyObject>] {
                        
                        let Templates = anItem["form"]?["formName"] as! String
                        //print("Templates  " , Templates)
                        if(Templates == "Stage 2 Site DC Checklist"){
                            let category = anItem["form"]?["category"] as! String
                            
                            self.categoryName = category
                            
                            let sectionsArray = anItem["form"]?["sections"] as! NSArray
                            
                            //print("sectionstitleArray  zero  " , sectionsArray)
                            
                            //for items in sectionsArray {
                            //  print("sectionFields  loop  " , items)
                            //}
                            
                            for sectionstitleArray in sectionsArray as! [Dictionary<String, AnyObject>] {
                                let sectionTitle = sectionstitleArray["title"] as! String
                                
                                self.SectionsListsArray.append(sectionTitle)
                                
                                //print("sectionTitle  ><><><> " , sectionTitle)
                                
                                //general
                                if(sectionTitle == "General"){
                                    let sectionFields = sectionstitleArray["fields"] as! NSArray
                                    //print("sectionFields Array " , sectionFields)
                                    
                                    for sectionFieldsLists in sectionFields as! [Dictionary<String, AnyObject>] {
                                        let sectionFieldsNames = sectionFieldsLists["fieldName"] as! String
                                        //print("sectionTitles  " , sectionFieldsNames)
                                        let dict  = ["FieldsNames":sectionFieldsNames]
                                        self.FieldsNamesListsArray.append(dict as [String : String])
                                        
                                        //site Type
                                        if sectionFieldsNames == "Site Type" {
                                            let siteTypes = sectionFieldsLists["listItems"] as! NSArray
                                            self.siteTypesArray = siteTypes as! [String]
                                            //print("listItems listItems $$ $ " , siteTypes)
                                            //for siteTypesLists in siteTypes  {
                                            //  print("siteTypesLists  >>>>><<<<<<   " , siteTypesLists)
                                            //}
                                        }
                                        //NBN Site Type
                                        if sectionFieldsNames == "NBN Site Type" {
                                            let siteTypes2 = sectionFieldsLists["listItems"] as? NSArray
                                            if siteTypes2 != nil {
                                                self.NBNTypesArray = siteTypes2 as! [String]
                                                //print("NBNTypesArray $$ $ " , siteTypes2)
                                                //for siteTypesLists in siteTypes  {
                                                //  print("siteTypesLists  >>>>><<<<<<   " , siteTypesLists)
                                                //}
                                            }
                                        }
                                        //shelterTypesArray
                                        if sectionFieldsNames == "Available space for NBN Shelter or ODC if CoLo" {
                                            let siteTypes3 = sectionFieldsLists["listItems"] as! NSArray
                                            self.shelterTypesArray = siteTypes3 as! [String]
                                            //print("listItems listItems $$ $ " , siteTypes)
                                            //for siteTypesLists in siteTypes  {
                                            //  print("siteTypesLists  >>>>><<<<<<   " , siteTypesLists)
                                            //}
                                        }
                                        //obstruction array
                                        if sectionFieldsNames == "Obstructions" {
                                            let siteTypes4 = sectionFieldsLists["listItems"] as! NSArray
                                            self.obstructionTypesArray = siteTypes4 as! [String]
                                            //print("listItems listItems $$ $ " , siteTypes)
                                            //for siteTypesLists in siteTypes  {
                                            //  print("siteTypesLists  >>>>><<<<<<   " , siteTypesLists)
                                            //}
                                        }
                                    }
                                }
                                //Design Items
                                if(sectionTitle == "Design Items"){
                                    let sectionFields = sectionstitleArray["fields"] as! NSArray
                                    //print("sectionFields Array " , sectionFields)
                                    
                                    for sectionFieldsLists in sectionFields as! [Dictionary<String, AnyObject>] {
                                        let sectionFieldsNames = sectionFieldsLists["fieldName"] as! String
                                        //print("sectionTitles  " , sectionFieldsNames)
                                        let dict  = ["FieldsNames":sectionFieldsNames]
                                        self.DesignFieldsNamesListsArray.append(dict as [String : String])
                                    }
                                }
                                //Power
                                if(sectionTitle == "Power"){
                                    let sectionFields = sectionstitleArray["fields"] as! NSArray
                                    //print("sectionFields Array " , sectionFields)
                                    
                                    for sectionFieldsLists in sectionFields as! [Dictionary<String, AnyObject>] {
                                        let sectionFieldsNames = sectionFieldsLists["fieldName"] as! String
                                        //print("sectionTitles  " , sectionFieldsNames)
                                        let dict  = ["FieldsNames":sectionFieldsNames]
                                        self.PowerFieldsNamesListsArray.append(dict as [String : String])
                                        
                                        //// ||| \\\\
                                        //OHSTypesArray
                                        if sectionFieldsNames == "OH&S Assessment (inc. issues which have occurred from third party or additional installs" {
                                            let siteTypes = sectionFieldsLists["listItems"] as! NSArray
                                            self.OHSTypesArray = siteTypes as! [String]
                                            //print("listItems listItems $$ $ " , siteTypes)
                                            //for siteTypesLists in siteTypes  {
                                            //  print("siteTypesLists  >>>>><<<<<<   " , siteTypesLists)
                                            //}
                                        }
                                        //SpecialSiteTypesArray
                                        if sectionFieldsNames == "Specialised Site specific designs/Engineering solutions required" {
                                            let siteTypes = sectionFieldsLists["listItems"] as! NSArray
                                            self.SpecialSiteTypesArray = siteTypes as! [String]
                                            //print("listItems listItems $$ $ " , siteTypes)
                                            //for siteTypesLists in siteTypes  {
                                            //  print("siteTypesLists  >>>>><<<<<<   " , siteTypesLists)
                                            //}
                                        }
                                    }
                                }
                                //Sketch
                                if(sectionTitle == "Sketch"){
                                    let sectionFields = sectionstitleArray["fields"] as! NSArray
                                    //print("sectionFields Array " , sectionFields)
                                    
                                    for sectionFieldsLists in sectionFields as! [Dictionary<String, AnyObject>] {
                                        let sectionFieldsNames = sectionFieldsLists["fieldName"] as! String
                                        //print("sectionTitles  " , sectionFieldsNames)
                                        let dict  = ["FieldsNames":sectionFieldsNames]
                                        self.SketchFieldsNamesListsArray.append(dict as [String : String])
                                    }
                                }
                                //Prepared By
                                if(sectionTitle == "Prepared By"){
                                    let sectionFields = sectionstitleArray["fields"] as! NSArray
                                    //print("sectionFields Array " , sectionFields)
                                    
                                    for sectionFieldsLists in sectionFields as! [Dictionary<String, AnyObject>] {
                                        let sectionFieldsNames = sectionFieldsLists["fieldName"] as! String
                                        //print("sectionTitles  " , sectionFieldsNames)
                                        let dict  = ["FieldsNames":sectionFieldsNames]
                                        self.PreparedByFieldsNamesListsArray.append(dict as [String : String])
                                    }
                                }
                                
                                
                            }
                        }
                    }
                    
                } catch {
                    // Catch any other errors
                }
            }
        }
        return nil
    }
    
    //dont add this
    func numberOfSections(in tableView: UITableView) -> Int {
        return SectionsListsArray.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        // print("SectionsListsArray   " , SectionsListsArray)
        return SectionsListsArray[section] //SectionsListsArray[section]
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        (view as! UITableViewHeaderFooterView).backgroundView?.backgroundColor =  UIColor(red: 39/255, green: 21/255, blue: 11/255, alpha: 1)
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.white
        header.textLabel?.backgroundColor = UIColor(red: 39/255, green: 21/255, blue: 11/255, alpha: 1)
        header.textLabel?.font = UIFont(name: "Futura", size: 15)!
        header.textLabel?.textAlignment = NSTextAlignment.center
    }
    
    //for side header
    //        func sectionIndexTitles(for tableView: UITableView) -> [String]? {
    //            return SectionsListsArray
    //        }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if indexPath.row == 0 || indexPath.row == 1 || indexPath.row == 2 {
                return 60
            } else  if indexPath.row == 3 || indexPath.row == 16 || indexPath.row == 26 {
                return 150
            } else if indexPath.row == 35 || indexPath.row == 36 || indexPath.row == 37 {
                return 120
            } else  if indexPath.row == 4 || indexPath.row == 5 {
                return 60
            } else if indexPath.row == 9 || indexPath.row == 12 || indexPath.row == 13 || indexPath.row == 14
                || indexPath.row == 33  {
                return 120
            } else if indexPath.row == 15 {
                return 0
            }
            else if indexPath.row == 20 || indexPath.row == 27 || indexPath.row == 31 || indexPath.row == 32 || indexPath.row == 38 {
                return 50
            }
            else  if indexPath.row == 6 || indexPath.row == 7 || indexPath.row == 8 || indexPath.row == 10 || indexPath.row == 11 {
                return 150
            } else  if indexPath.row == 17 || indexPath.row == 18 || indexPath.row == 19 || indexPath.row == 21 || indexPath.row == 22
                || indexPath.row == 23 || indexPath.row == 24 || indexPath.row == 25 || indexPath.row == 28 || indexPath.row == 29
                || indexPath.row == 30 || indexPath.row == 34 {
                return 60
            } else  if indexPath.row == 39 {
                return 40
            } else if indexPath.row == 40 || indexPath.row == 41 {
                return 100
            }
                // design
            else if indexPath.row == 43 || indexPath.row == 44 || indexPath.row == 45   || indexPath.row == 55 || indexPath.row == 56 || indexPath.row == 57 || indexPath.row == 58
                || indexPath.row == 59 || indexPath.row == 60  || indexPath.row == 62  || indexPath.row == 67 || indexPath.row == 77 || indexPath.row == 78 || indexPath.row == 79 || indexPath.row == 80 || indexPath.row == 82 || indexPath.row == 83 || indexPath.row == 84 || indexPath.row == 85 || indexPath.row == 86 || indexPath.row == 90 || indexPath.row == 91 || indexPath.row == 96
                ||  indexPath.row == 97 || indexPath.row == 101 || indexPath.row == 102 || indexPath.row == 106 || indexPath.row == 107
                || indexPath.row == 108 || indexPath.row == 109 || indexPath.row == 110 {
                return 120
            } else if indexPath.row == 48 ||  indexPath.row == 49 || indexPath.row == 50 || indexPath.row == 53 || indexPath.row == 54 || indexPath.row == 61 || indexPath.row == 63 || indexPath.row == 64 || indexPath.row == 65 || indexPath.row == 73 || indexPath.row == 74 || indexPath.row == 87 || indexPath.row == 88 || indexPath.row == 89 || indexPath.row == 92 || indexPath.row == 94 || indexPath.row == 98 {
                return 60
            }
            else if indexPath.row == 93 || indexPath.row == 99 {
                return 120
            } else if indexPath.row == 75 {
                return 120
            }
                //not 55 4wd //indexPath.row == 77
            else if  indexPath.row == 70 || indexPath.row == 71 || indexPath.row == 72
                || indexPath.row == 111 || indexPath.row == 112 || indexPath.row == 113 || indexPath.row == 114 ||
                indexPath.row == 115 || indexPath.row == 116{
                return 350
            } else if indexPath.row == 102 || indexPath.row == 103 || indexPath.row == 104 {
                return 130
            }
            else if indexPath.row == 46 {
                return 60
            }
        }
        return 40; //// Default Size  //UITableViewAutomaticDimension
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var concatedArray =  FieldsNamesListsArray + DesignFieldsNamesListsArray + PowerFieldsNamesListsArray + SketchFieldsNamesListsArray + PreparedByFieldsNamesListsArray
        
        return concatedArray.count
    }
    
    let candidateTextField : [UITextField] = []
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:form1TableViewCell = tableView.dequeueReusableCell(withIdentifier: "form1TableViewCell") as! form1TableViewCell
        //        cell.textLabel?.text = object["FieldsNames"] as? String
        //        cell.textLabel?.font = UIFont(name: "Futura", size: 10)!
        //        cell.textLabel?.frame.origin.x = 13
        //        cell.textLabel?.frame.origin.y = -20
        //        cell.textLabel?.baselineAdjustment = .alignCenters
        //        cell.textLabel?.numberOfLines = 0`
        //        cell.textLabel?.frame.size.width = 300
        //        cell.textLabel?.frame = CGRect(x: CGFloat(100.0), y: CGFloat(-20.0), width: CGFloat(300.0), height: CGFloat(150.0))
        //        cell.sizeToFit()
        
        var concatedARray =  FieldsNamesListsArray + DesignFieldsNamesListsArray + PowerFieldsNamesListsArray + SketchFieldsNamesListsArray + PreparedByFieldsNamesListsArray
        
        let object = concatedARray[indexPath.item] as NSDictionary
        
        for newLabel in cell.subviews
        {
            if newLabel.tag == 1000
            {
                newLabel.removeFromSuperview()
            }
        }
        
        var newLabel = UILabel(frame: CGRect(x: 15, y: -50, width: 300.0, height: 150.0))
        newLabel.text = object["FieldsNames"] as? String
        newLabel.textColor = UIColor.blue
        newLabel.tag = 1000
        newLabel.clearsContextBeforeDrawing = true
        newLabel.frame.size.width = 300
        newLabel.clearsContextBeforeDrawing = true
        newLabel.baselineAdjustment = .alignCenters
        newLabel.font = UIFont(name: "Futura", size: 10)!
        newLabel.numberOfLines = 0
        cell.addSubview(newLabel)
        
        for candidateTextField in cell.subviews
        {
            if candidateTextField.tag == 1001
            {
                candidateTextField.removeFromSuperview()
            }
        }
        
        for commonTextArea in cell.subviews
        {
            if commonTextArea.tag == 1004
            {
                commonTextArea.removeFromSuperview()
            }
        }
        
        for customSegmentedControl in cell.subviews
        {
            if customSegmentedControl.tag == 1010
            {
                customSegmentedControl.removeFromSuperview()
            }
        }
        
        for customSegmentedControl2 in cell.subviews
        {
            if customSegmentedControl2.tag == 1011
            {
                customSegmentedControl2.removeFromSuperview()
            }
        }
        
        for customSegmentedControl3 in cell.subviews
        {
            if customSegmentedControl3.tag == 1012
            {
                customSegmentedControl3.removeFromSuperview()
            }
        }
        
        for customSegmentedControl4 in cell.subviews
        {
            if customSegmentedControl4.tag == 1013
            {
                customSegmentedControl4.removeFromSuperview()
            }
        }
        
        for customSegmentedControl5 in cell.subviews
        {
            if customSegmentedControl5.tag == 1020
            {
                customSegmentedControl5.removeFromSuperview()
            }
        }
        for customSegmentedControl6 in cell.subviews
        {
            if customSegmentedControl6.tag == 1040
            {
                customSegmentedControl6.removeFromSuperview()
            }
        }
        for customSegmentedControl7 in cell.subviews
        {
            if customSegmentedControl7.tag == 1041
            {
                customSegmentedControl7.removeFromSuperview()
            }
        }
        for designTextField in cell.subviews
        {
            if designTextField.tag == 1050
            {
                designTextField.removeFromSuperview()
            }
        }
        
        if newLabel.text == "Candidate" || newLabel.text == "Time" || newLabel.text == "If CoLo Other, please specify" || newLabel.text == "Keys required" || newLabel.text == "# Sectors" || newLabel.text == "# and size of parabolic antenna" || newLabel.text == "Lattice Tower – Proposed Height" || newLabel.text == "Lat (dec deg)" ||
            newLabel.text == "Long (dec deg)" || newLabel.text == "Elevation (m)" || newLabel.text == "Owner/Carrier Site"
            || newLabel.text == "RFNSA Site No" || newLabel.text == "Type" || newLabel.text == "Manufacturer" ||
            newLabel.text == "Model and Height"  || newLabel.text == "Height (m)" || newLabel.text == "Comment" || newLabel.text == "Distance of new NBN ACCESS track (m)" || newLabel.text == "Bridge rating (T) or unknown" || newLabel.text == "If single lane bridge width?" || newLabel.text == "Number" || newLabel.text == "Number of Culverts" || newLabel.text == "Other" || newLabel.text == "Slope Ratio Site Compound" || newLabel.text == "Slope Ratio Access Track" || newLabel.text == "Distance Meter 1 (m)" || newLabel.text == "Distance Meter 2 (m)" || newLabel.text == "Distance Meter 3 (m)" || newLabel.text == "If Other, please specify" || newLabel.text == "Approximate change in elevation. (m)"{
            var candidateTextField: UITextField =  UITextField(frame: CGRect(x: 220, y: 10, width: 140, height: 40))
            candidateTextField.placeholder = " "
            candidateTextField.tag = 1001
            candidateTextField.font = UIFont.systemFont(ofSize: 15)
            candidateTextField.borderStyle = UITextBorderStyle.roundedRect
            candidateTextField.backgroundColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1)
            candidateTextField.autocorrectionType = UITextAutocorrectionType.no
            //candidateTextField.keyboardType = UIKeyboardType.default
            candidateTextField.returnKeyType = UIReturnKeyType.done
            candidateTextField.font = UIFont(name: "Futura", size: 9)!
            candidateTextField.clearButtonMode = UITextFieldViewMode.whileEditing;
            candidateTextField.contentVerticalAlignment = UIControlContentVerticalAlignment.center
            self.arrayOfTextFields.append(candidateTextField)
            cell.addSubview(candidateTextField)
            
            candidateTextField.addTarget(self, action: #selector(textFieldDidChange1(_:)), for: .editingChanged)
            
        } else if newLabel.text == "Distance to nearest Co-site telco structure in meters. (min 50m)" || newLabel.text == "Proposed position does not obstruct existing Telco or NBN mW Paths (OK)  (NA if no Telco Structure)" {
            var designTextField = UITextField(frame: CGRect(x: 220, y: 40, width: 140, height: 40))
            designTextField.placeholder = " "
            designTextField.tag = 1050
            designTextField.font = UIFont.systemFont(ofSize: 15)
            designTextField.borderStyle = UITextBorderStyle.roundedRect
            designTextField.backgroundColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1)
            designTextField.autocorrectionType = UITextAutocorrectionType.no
            designTextField.keyboardType = UIKeyboardType.default
            designTextField.returnKeyType = UIReturnKeyType.done
            designTextField.font = UIFont(name: "Futura", size: 9)!
            designTextField.clearButtonMode = UITextFieldViewMode.whileEditing;
            designTextField.contentVerticalAlignment = UIControlContentVerticalAlignment.center
            cell.addSubview(designTextField)
        } else if newLabel.text == "Site Inductions or any other specific access requirements" || newLabel.text == "General Description of Site (Surrounding area/Carrier/Structure type, Proposed NBN panel and Parabolic heights)" || newLabel.text == "Special issues and/or high cost items pertaining to the site (e.g. Tower/Pole extension, Pole swap-out, Limited access or poor security, Expensive build for access track etc.)" || newLabel.text == "Land Owner comments and Requests pertaining to Design or Construction" || newLabel.text == "Comments" || newLabel.text == "Comment (retaining wall required or cut & fill etc.)" || newLabel.text == "Comments" || newLabel.text == "Comments on 3rd Party installs that compromise access or lease area"{
            var commonTextArea = UITextField(frame: CGRect(x: 15, y: 50, width: 340, height: 80))
            commonTextArea.placeholder = " "
            commonTextArea.tag = 1004
            commonTextArea.font = UIFont.systemFont(ofSize: 15)
            commonTextArea.borderStyle = UITextBorderStyle.roundedRect
            commonTextArea.backgroundColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1)
            commonTextArea.autocorrectionType = UITextAutocorrectionType.no
            commonTextArea.keyboardType = UIKeyboardType.default
            commonTextArea.returnKeyType = UIReturnKeyType.done
            commonTextArea.font = UIFont(name: "Futura", size: 9)!
            commonTextArea.clearButtonMode = UITextFieldViewMode.whileEditing;
            commonTextArea.contentVerticalAlignment = UIControlContentVerticalAlignment.center
            cell.addSubview(commonTextArea)
            
        } else if newLabel.text == "Site Type" {
            //print("self.siteTypesArray ><>< " , self.siteTypesArray)
            var customSegmentedControl = UISegmentedControl (items: self.siteTypesArray)
            customSegmentedControl.frame = CGRect(x: 13, y: 60, width: 360, height: 50)
            customSegmentedControl.selectedSegmentIndex = UISegmentedControlNoSegment
            customSegmentedControl.tintColor = UIColor.black
            customSegmentedControl.tag = 1010
            customSegmentedControl.backgroundColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1)
            customSegmentedControl.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.white], for: .selected)
            let attributedSegmentFont = NSDictionary(object: UIFont(name: "Futura", size: 8.0)!, forKey: NSFontAttributeName as NSCopying)
            customSegmentedControl.setTitleTextAttributes(attributedSegmentFont as [NSObject : AnyObject], for: .normal)
            customSegmentedControl.apportionsSegmentWidthsByContent = true
            customSegmentedControl.autoresizesSubviews = true
            //customSegmentedControl.addTarget(self, action: Selector(("segmentedValueChanged:")), for: .valueChanged)
            cell.addSubview(customSegmentedControl)
        } else if newLabel.text == "NBN Site Type" {
            //print("NBNTypesArray ><>< " , self.NBNTypesArray)
            var customSegmentedControl2 = UISegmentedControl (items: self.NBNTypesArray)
            customSegmentedControl2.frame = CGRect(x: 13, y: 60, width: 360, height: 50)
            customSegmentedControl2.selectedSegmentIndex = UISegmentedControlNoSegment
            customSegmentedControl2.tintColor = UIColor.black
            customSegmentedControl2.tag = 1011
            customSegmentedControl2.backgroundColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1)
            customSegmentedControl2.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.white], for: .selected)
            let attributedSegmentFont = NSDictionary(object: UIFont(name: "Futura", size: 10.0)!, forKey: NSFontAttributeName as NSCopying)
            customSegmentedControl2.setTitleTextAttributes(attributedSegmentFont as [NSObject : AnyObject], for: .normal)
            customSegmentedControl2.apportionsSegmentWidthsByContent = true
            customSegmentedControl2.autoresizesSubviews = true
            //customSegmentedControl.addTarget(self, action: Selector(("segmentedValueChanged:")), for: .valueChanged)
            cell.addSubview(customSegmentedControl2)
        } else if newLabel.text == "Available space for NBN Shelter or ODC if CoLo" {
            //print("self.siteTypesArray ><>< " , self.siteTypesArray)
            var customSegmentedControl3 = UISegmentedControl (items: self.shelterTypesArray)
            customSegmentedControl3.frame = CGRect(x: 13, y: 60, width: 300, height: 50)
            customSegmentedControl3.selectedSegmentIndex = UISegmentedControlNoSegment
            customSegmentedControl3.tintColor = UIColor.black
            customSegmentedControl3.tag = 1012
            customSegmentedControl3.backgroundColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1)
            customSegmentedControl3.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.white], for: .selected)
            let attributedSegmentFont = NSDictionary(object: UIFont(name: "Futura", size: 10.0)!, forKey: NSFontAttributeName as NSCopying)
            customSegmentedControl3.setTitleTextAttributes(attributedSegmentFont as [NSObject : AnyObject], for: .normal)
            customSegmentedControl3.apportionsSegmentWidthsByContent = true
            customSegmentedControl3.autoresizesSubviews = true
            //customSegmentedControl.addTarget(self, action: Selector(("segmentedValueChanged:")), for: .valueChanged)
            cell.addSubview(customSegmentedControl3)
        } else if  newLabel.text == "Obstructions" {
            //print("self.siteTypesArray ><>< " , self.siteTypesArray)
            var customSegmentedControl4 = UISegmentedControl (items: self.obstructionTypesArray)
            customSegmentedControl4.frame = CGRect(x: 13, y: 60, width: 360, height: 50)
            customSegmentedControl4.selectedSegmentIndex = UISegmentedControlNoSegment
            customSegmentedControl4.tintColor = UIColor.black
            customSegmentedControl4.tag = 1013
            customSegmentedControl4.backgroundColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1)
            customSegmentedControl4.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.white], for: .selected)
            let attributedSegmentFont = NSDictionary(object: UIFont(name: "Futura", size: 8.0)!, forKey: NSFontAttributeName as NSCopying)
            customSegmentedControl4.setTitleTextAttributes(attributedSegmentFont as [NSObject : AnyObject], for: .normal)
            customSegmentedControl4.apportionsSegmentWidthsByContent = true
            customSegmentedControl4.autoresizesSubviews = true
            //customSegmentedControl.addTarget(self, action: Selector(("segmentedValueChanged:")), for: .valueChanged)
            cell.addSubview(customSegmentedControl4)
        }
            
        else if  newLabel.text == "OH&S Assessment (inc. issues which have occurred from third party or additional installs" {
            //print("self.siteTypesArray ><>< " , self.siteTypesArray)
            var customSegmentedControl6 = UISegmentedControl (items: self.OHSTypesArray)
            customSegmentedControl6.frame = CGRect(x: 13, y: 60, width: 360, height: 50)
            customSegmentedControl6.selectedSegmentIndex = UISegmentedControlNoSegment
            customSegmentedControl6.tintColor = UIColor.black
            customSegmentedControl6.tag = 1040
            customSegmentedControl6.backgroundColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1)
            customSegmentedControl6.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.white], for: .selected)
            let attributedSegmentFont = NSDictionary(object: UIFont(name: "Futura", size: 8.0)!, forKey: NSFontAttributeName as NSCopying)
            customSegmentedControl6.setTitleTextAttributes(attributedSegmentFont as [NSObject : AnyObject], for: .normal)
            customSegmentedControl6.apportionsSegmentWidthsByContent = true
            customSegmentedControl6.autoresizesSubviews = true
            //customSegmentedControl.addTarget(self, action: Selector(("segmentedValueChanged:")), for: .valueChanged)
            cell.addSubview(customSegmentedControl6)
        }
            
        else if  newLabel.text == "Specialised Site specific designs/Engineering solutions required" {
            //print("self.siteTypesArray ><>< " , self.siteTypesArray)
            var customSegmentedControl7 = UISegmentedControl (items: self.SpecialSiteTypesArray)
            customSegmentedControl7.frame = CGRect(x: 13, y: 60, width: 360, height: 50)
            customSegmentedControl7.selectedSegmentIndex = UISegmentedControlNoSegment
            customSegmentedControl7.tintColor = UIColor.black
            customSegmentedControl7.tag = 1041
            customSegmentedControl7.backgroundColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1)
            customSegmentedControl7.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.white], for: .selected)
            let attributedSegmentFont = NSDictionary(object: UIFont(name: "Futura", size: 8.0)!, forKey: NSFontAttributeName as NSCopying)
            customSegmentedControl7.setTitleTextAttributes(attributedSegmentFont as [NSObject : AnyObject], for: .normal)
            customSegmentedControl7.apportionsSegmentWidthsByContent = true
            customSegmentedControl7.autoresizesSubviews = true
            //customSegmentedControl.addTarget(self, action: Selector(("segmentedValueChanged:")), for: .valueChanged)
            cell.addSubview(customSegmentedControl7)
        }
            
            
        else if newLabel.text == "Update Site Handler" || newLabel.text == "Escalate to SAE" || newLabel.text == "Identify Issue on PD/FC" || newLabel.text == "1. Surrounding Clutter/Foliage?" || newLabel.text == "2. Existing underground services" || newLabel.text == "2. a. U/G service need investigation/location for structure install" || newLabel.text == "2. b. U/G service need investigation/location for Power/Fibre install" || newLabel.text == "Existing access is suitable for Construction and NBN O&M?" || newLabel.text == "Existing access is suitable in wet conditions for NBN O&M?" || newLabel.text == "Existing access is suitable in wet conditions for Construction?" || newLabel.text == "Any repair works to be done to existing NBN access ROUTE?. (eg. existing access may be washed out)" || newLabel.text == "Vegetation to be Removed?" || newLabel.text == "Vegetation to be Trimmed?" || newLabel.text == "Trees to be Removed?" || newLabel.text == "Trees to be Trimmed?" || newLabel.text == "Existing combined/central metering?" || newLabel.text == "New / UG Service Mains cable to NBN Site only?" || newLabel.text == "Combined meters to single location?" || newLabel.text == "Common Meter Panel nominated and agreed with Land Owner?" || newLabel.text == "Upgrading of existing Consumer Mains if new Common Metering?" || newLabel.text == "Are there single motors onsite of PA is upgrading from single phase to 3 phase?" || newLabel.text == "SW board upgrade?" || newLabel.text == "Standard Greenfield or CoLo design" || newLabel.text == "NBN Site slopes" || newLabel.text == "Is there enough space on structure for proposed antenna installation? (If insufficient space, please note necessary actions in comments section)" || newLabel.text == "Is there enough space to install feeder brackets? (If insufficient space, please note necessary actions in comments section)" || newLabel.text == "Escalate to SAE" || newLabel.text == "Escalate to Ericsson" || newLabel.text == "Update Site Handler" || newLabel.text  == "Identify issue on PD/FC" || newLabel.text == "Identify costs and update costs in Site Handler" || newLabel.text == "Turn-off/Entry to Site is on double lines, crest, bend, or other potential dangerous road condition" || newLabel.text == "Bridge rating or restrictions" || newLabel.text == "4WD Access only?" || newLabel.text == "Steep Gradients?" || newLabel.text == "New Gates <3m?" || newLabel.text == "Culverts New or Replace?" || newLabel.text == "Crane can access site via roads, access track?" || newLabel.text == "Crane pad setup identified?" {
            var customSegmentedControl5 = UISegmentedControl (items: ["Yes" , "No"])
            customSegmentedControl5.frame = CGRect(x: 30, y: 50, width: 150, height: 40)
            customSegmentedControl5.selectedSegmentIndex = UISegmentedControlNoSegment
            customSegmentedControl5.tintColor = UIColor.black
            customSegmentedControl5.tag = 1020
            customSegmentedControl5.backgroundColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1)
            customSegmentedControl5.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.white], for: .selected)
            let attributedSegmentFont = NSDictionary(object: UIFont(name: "Futura", size: 8.0)!, forKey: NSFontAttributeName as NSCopying)
            customSegmentedControl5.setTitleTextAttributes(attributedSegmentFont as [NSObject : AnyObject], for: .normal)
            customSegmentedControl5.apportionsSegmentWidthsByContent = true
            customSegmentedControl5.autoresizesSubviews = true
            //customSegmentedControl.addTarget(self, action: Selector(("segmentedValueChanged:")), for: .valueChanged)
            cell.addSubview(customSegmentedControl5)
        }
        
        for CalendarimageView in cell.subviews {
            if CalendarimageView.tag == 1003
            {
                CalendarimageView.removeFromSuperview()
            }
        }
        
        if newLabel.text == "Date" {
            ///TEXT
            var candidateTextField = UITextField(frame: CGRect(x: 220, y: 10, width: 140, height: 40))
            candidateTextField.placeholder = " "
            candidateTextField.tag = 1001
            candidateTextField.font = UIFont.systemFont(ofSize: 15)
            candidateTextField.borderStyle = UITextBorderStyle.roundedRect
            candidateTextField.backgroundColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1)
            candidateTextField.autocorrectionType = UITextAutocorrectionType.no
            candidateTextField.keyboardType = UIKeyboardType.default
            candidateTextField.returnKeyType = UIReturnKeyType.done
            candidateTextField.font = UIFont(name: "Futura", size: 9)!
            candidateTextField.clearButtonMode = UITextFieldViewMode.whileEditing;
            candidateTextField.contentVerticalAlignment = UIControlContentVerticalAlignment.center
            cell.addSubview(candidateTextField)
            ///IMAGE
            let Calendarimage1 = "calendar"
            let Calendarimage2 = UIImage(named: Calendarimage1)
            var CalendarimageView = UIImageView(frame: CGRect(x: 183, y: 10.9, width: 35, height: 35))
            //CalendarimageView.layer.borderWidth=1.0
            CalendarimageView.tag = 1003
            CalendarimageView.layer.masksToBounds = true
            //CalendarimageView.layer.cornerRadius = 50;// Corner radius should be half of the height and width.
            CalendarimageView.image = Calendarimage2
            let tap1 = UITapGestureRecognizer(target: self, action: #selector(tapGesture1))
            // add it to the image view;
            CalendarimageView.addGestureRecognizer(tap1)
            CalendarimageView.isUserInteractionEnabled = true
            cell.addSubview(CalendarimageView)
        }
        
        return cell
    }
    
    //var myArray = [String]()
    
    ///textfieldChange
    func textFieldDidChange1(_ textField: UITextField) {
        for textField in arrayOfTextFields{
            print("Changed Text  " , textField.text as Any)
        }
    }
    
    func tapGesture1() {
        let currentDate = Date()
        var dateComponents = DateComponents()
        dateComponents.month = -3
        let threeMonthAgo = Calendar.current.date(byAdding: dateComponents, to: currentDate)
        var dateComponents2 = DateComponents()
        dateComponents2.month = 72
        let oneYearAfter = Calendar.current.date(byAdding: dateComponents2, to: currentDate)
        
        DatePickerDialog().show(" ", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", minimumDate: threeMonthAgo, maximumDate: oneYearAfter, datePickerMode: .date) { (date) in
            if let dt = date {
                print("DATE VALUE  >>>>>> ")
                print("\(dt)")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // go back to sign in screen
        //                let storyboard = UIStoryboard(name: "Main", bundle: nil)
        //                let vc = storyboard.instantiateViewController(withIdentifier: "test")
        //                self.present(vc, animated: true, completion: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


