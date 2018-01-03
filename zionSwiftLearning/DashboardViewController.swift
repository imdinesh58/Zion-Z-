
import UIKit
import MapKit

class DashboardViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var openMenu: UIButton!
    @IBOutlet weak var newleadingConsraint: NSLayoutConstraint!
    @IBOutlet weak var menuView2: UIView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var logout: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var control: UISegmentedControl!
    @IBOutlet weak var selectedWorkSite: UILabel!
    @IBOutlet weak var selectedProject: UILabel!
    @IBOutlet weak var siteInfo: UIButton!
    @IBOutlet weak var dashboard: UIButton!
    
    ///bottom images

    ///////
    @IBOutlet var syncItem: UILabel!
    
    var menuShowing = false
    @IBAction func slideMenuClick() {
        if(menuShowing){
            newleadingConsraint.constant = -194
            UIView.animate(withDuration: 0.3, animations: {
                self.view.layoutIfNeeded()
            })
            notCountImg.isHidden = false
        }else{
            newleadingConsraint.constant = 0
            UIView.animate(withDuration: 0.3, animations: {
                self.view.layoutIfNeeded()
            })
            notCountImg.isHidden = true
        }
        menuShowing = !menuShowing
    }
    
    @IBAction func logoutClick() {
        print("Clearing property")
        selectedProject.text = "Project"
        selectedWorkSite.text = "Worksite"
        selectedProject.textColor = UIColor.black
        selectedWorkSite.textColor = UIColor.black
        newleadingConsraint.constant = -194
        searchBar.text = ""
        
        let defaults = UserDefaults.standard
        defaults.set("", forKey: "AccessToken")
        // go back to sign in screen
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ViewController")
        self.present(vc, animated: true, completion: nil)
    }
    
    var searchActive : Bool = false
    var testData:[String] = []
    var Projectitems = [[String:String]]()
    var Siteitems = [[String:String]]()
    var Formitems = [[String:String]]()
    var testDatasample:[String] = []
    var multiArray:String = "project"
    var testDataID:[String] = []
    var testData2:[String] = []
    var testData2ID:[String] = []
    var filtered:[String] = []
    var filtered2:[String] = []
    ///
    var setProjectId:String = ""
    var setWorkSiteId:String = ""
    /// Templates
    var testData3:[String] = []
    ////
    var MainJSON:[String] = []
    
    @IBAction func controlChanged() {
        if(control.selectedSegmentIndex == 0){
            //reset
            testData3.removeAll()
            Formitems.removeAll()
            
            multiArray = "project"
            searchBar.text = ""
            selectedProject.text = "Project"
            selectedWorkSite.text = "Worksite"
            tableView.isHidden = true
            //testData.removeAll()
            //testData3.removeAll()
            //getProjectsListJSON()
            //print("<<< testData.count empty >>>>>>>  ", testData.count)
            if testData.isEmpty == false {
                self.testData = self.testDatasample
                print("not none ")
            }
        } else if(control.selectedSegmentIndex == 1){
            //reset
            
            testData3.removeAll()
            Formitems.removeAll()
            
            multiArray = "site"
            searchBar.text = ""
            selectedWorkSite.text = "Worksite"
            tableView.isHidden = true
            //testData2.removeAll()
            //getSitesListJSON();
            if testData2.isEmpty == false {
                self.testData = self.testData2
            }
        } else if(control.selectedSegmentIndex == 2){
            multiArray = "form"
            searchBar.text = ""
            tableView.isHidden = true
            //testData3.removeAll()
            //ListSiteInfoForms();
            if testData3.isEmpty == false {
                self.testData = self.testData3
            }
        } else {
            multiArray = "project"
            searchBar.text = ""
            tableView.isHidden = true
            //testData.removeAll()
            //getProjectsListJSON()
            if testData.isEmpty == false {
                self.testData = testDatasample
            }
        }
        //self.tableView.reloadData()
    }
    
    @IBOutlet var netWorkIcon: UIImageView!
    @IBOutlet weak var notCountImg: UIButton!
    
    @IBOutlet weak var notificationsImg: UIImageView!
    @IBOutlet weak var compilanceImg: UIImageView!
    @IBOutlet weak var raiseActionImg: UIImageView!
    @IBOutlet weak var myActions: UIImageView!
    @IBOutlet weak var downloadsImg: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //defer { print("first") }
        //print("second")
        
        SYNCView.isHidden = true
        
        OperationQueue.main.addOperation{
            self.syncItem.text = "0"
            NotificationCenter.default.addObserver(self, selector: #selector(self.refreshLbl), name: NSNotification.Name(rawValue: "refresh"), object: nil)
        }
        
        //SYNC Icon Click
        let tap = UITapGestureRecognizer(target: self, action: #selector(DashboardViewController.DoSYNCOperation))
        syncItem?.isUserInteractionEnabled = true
        syncItem?.addGestureRecognizer(tap)
        
        //NETWORK Icon Click
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(DashboardViewController.GoTestPage))
        notificationsImg?.isUserInteractionEnabled = true
        notificationsImg?.addGestureRecognizer(tap2)
        
        let tap3 = UITapGestureRecognizer(target: self, action: #selector(DashboardViewController.GoTestPage))
        raiseActionImg?.isUserInteractionEnabled = true
        raiseActionImg?.addGestureRecognizer(tap3)
        
        let tap4 = UITapGestureRecognizer(target: self, action: #selector(DashboardViewController.GoTestPage))
        myActions?.isUserInteractionEnabled = true
        myActions?.addGestureRecognizer(tap4)
        
        let tap5 = UITapGestureRecognizer(target: self, action: #selector(DashboardViewController.GoTestPage))
        compilanceImg?.isUserInteractionEnabled = true
        compilanceImg?.addGestureRecognizer(tap5)
        
        let tap6 = UITapGestureRecognizer(target: self, action: #selector(DashboardViewController.GoTestPage))
        downloadsImg?.isUserInteractionEnabled = true
        downloadsImg?.addGestureRecognizer(tap6)
        
        
        
        OperationQueue.main.addOperation{
            //tableview 1
            self.tableView.delegate = self
            self.tableView.dataSource = self
            self.searchBar.delegate = self
            /// hide table view
            self.tableView.isHidden = true
            
            // Do any additional setup after loading the view, typically from a nib.
            self.menuView2.layer.shadowOpacity = 1
            self.menuView2.layer.shadowRadius = 6
            
            //MapView - setup
            // Drop a pin
            let newYorkLocation = CLLocationCoordinate2DMake(12.9803, 80.2276)
            let dropPin = MKPointAnnotation()
            dropPin.coordinate = newYorkLocation
            dropPin.title = "Current Location"
            self.mapView.addAnnotation(dropPin)
            //Zoom to user location
            self.mapView.showsUserLocation = true
            let regionRadius: CLLocationDistance = 1000
            let noLocation = CLLocationCoordinate2D(latitude: 12.9803, longitude: 80.2276)
            let viewRegion = MKCoordinateRegionMakeWithDistance(noLocation, regionRadius * 1, regionRadius * 1)
            self.mapView.setRegion(viewRegion, animated: false)
            
            //API CALL
            //self.getProjectsListJSON()
        }
    } //viewDidLoad close
    
    func GoTestPage() {
        // go next
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "test")
        self.present(vc, animated: true, completion: nil)
    }
    
    
    @IBOutlet var SYNCView: UIView!
    @IBOutlet var SYNCClose: UIButton!
    @IBOutlet var UploadSync: UIButton!
    
    @IBAction func UploadSYNCClick() {
        self.TemplateCommitPOST()
    }
    
    @IBAction func SYNCCloseClick() {
         SYNCView.isHidden = true
    }
    
    func DoSYNCOperation(){
        //show Sync items
       SYNCView.isHidden = false
    }
    
    func TemplateCommitPOST() {
        //STAGING POST CALL
        // create the request & respons
        OperationQueue.main.addOperation{
            var request = URLRequest(url: URL(string: "https://ss-t.vspl.net/zion.api.fsit2/Form/Commit")!)
            request.httpMethod = "POST"
            //read Auth Token
            let defaults = UserDefaults.standard
            let Token = defaults.string(forKey: "AccessToken")
            if (Token != nil)
            {
                print("RETRIEVED TOKEN --- DASHBOARD SCREEN ||||||  ")
                //print(Token)
            }
            ///READ STAGING ID
            let stagingId = defaults.string(forKey: "stagingID")
            if (stagingId != nil)
            {
                //print("RETRIEVED STAGING ID --- ")
                //print(stagingId as Any)
            }
            let setAuthToken = "bearer " + Token!
            //print("AUTHORIZATION  " + setAuthToken)
            request.setValue(setAuthToken, forHTTPHeaderField: "authorization")
            let postString = "stagingDataId="+stagingId!;
            request.httpBody = postString.data(using: .utf8)
            request.httpBody = postString.data(using: String.Encoding.utf8);
            
            let task = URLSession.shared.dataTask(with: request) {
                data, response, error in
                
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                    //check for http error code
                    print("StatusCode should be 200, but is \(httpStatus.statusCode)")
                    let responseString = String(data: data!, encoding: String.Encoding.utf8)
                    print("ResponseString Failure = " +     responseString!)
                    OperationQueue.main.addOperation{
                        let alert = UIAlertController(title: "Alert", message: "Form Upload to server Failed...", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                    
                }
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode == 200 {
                    //no errors //status ok
                    print("StatusCode should be 200 === \(httpStatus.statusCode)")
                    let responseString = String(data: data!, encoding: String.Encoding.utf8)
                    print("ResponseString Success = " +     responseString!)
                    self.syncItem.text = "0"
                }
                
            } // end of task response
            task.resume()
        }
    }
    
    func refreshLbl() {
        print("ONE SYNC ITEMS ADDED")
        syncItem.text = "1"
    }
    
    func getProjectsListJSON(){
        DispatchQueue.main.async(){
            let req = NSMutableURLRequest(url: NSURL(string:"https://ss-t.vspl.net/zion.api.fsit2/Projects")! as URL)
            req.httpMethod = "GET"
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
            req.setValue(setAuthToken, forHTTPHeaderField: "authorization")
            
            let task = URLSession.shared.dataTask(with: req as URLRequest) {
                data, response, error in
                // Check for error
                if error != nil {
                    print("error=\(error)")
                    return
                }
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                    print("StatusCode is === \(httpStatus.statusCode)")
                    OperationQueue.main.addOperation{
                        let alert = UIAlertController(title: "Alert", message: "Server Error... failed to load projects", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
                
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode == 200 {
                    let responseString = String(data: data!, encoding: String.Encoding.utf8)
                    // print("ResponseString = \(responseString)")
                    //print("ResponseString = success status " +     responseString!)
                    self.convertStringToDictionary(text: responseString!)
                }
                
            }  //close task
            task.resume()
        }
    }
    
    
    func convertStringToDictionary(text: String) -> [String:AnyObject]? {
        DispatchQueue.main.async(){
            if let data = text.data(using: String.Encoding.utf8) {
                do {
                    let jsonObj = try JSONSerialization.jsonObject(with: data, options: [])
                    
                    for anItem in jsonObj as! [Dictionary<String, AnyObject>] {
                        let projectID = anItem["projectID"] as! String
                        let projectName = anItem["projectName"] as! String
                        
                        //print("PN " , projectName)
                        //print("PI " , projectID)
                        //set these values in tableview cell
                        self.testData.append(projectName)
                        self.testDatasample.append(projectName)
                        self.testDataID.append(projectID)
                        
                        let dict  = ["projectID":projectID,"projectName":projectName]
                        
                        self.Projectitems.append(dict as [String : String])
                        
                        self.tableView.reloadData()
                    }
                    
                    //print("self.Projectitems  "  , self.Projectitems)
                    
                    // print("Pushed " , testData)
                } catch {
                    // Catch any other errors
                }
            }
        }
        return nil
    }
    
    //search 1
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //print("change 1")
        DispatchQueue.main.async(){
            if(searchText.characters.count > 0){
                if(self.multiArray == "project"){
                    self.filtered = self.testData.filter({ (text) -> Bool in
                        let tmp: NSString = (text as? NSString)!
                        let range = tmp.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
                        return range.location != NSNotFound
                    })
                }
                if(self.multiArray == "site"){
                    self.filtered = self.testData2.filter({ (text) -> Bool in
                        let tmp: NSString = (text as? NSString)!
                        let range = tmp.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
                        return range.location != NSNotFound
                    })
                }
                if(self.multiArray == "form"){
                    self.filtered = self.testData3.filter({ (text) -> Bool in
                        let tmp: NSString = (text as? NSString)!
                        let range = tmp.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
                        return range.location != NSNotFound
                    })
                }
                
                if(self.filtered.count == 0){
                    self.searchActive = false;
                } else {
                    
                    
                    self.searchActive = true;
                }
                self.tableView.isHidden = false
                self.tableView.reloadData()
            } else{
                self.tableView.isHidden = true
            }
        }
    }
    
    
    //table 1
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(searchActive) {
            
            return filtered.count
        }
        return Projectitems.count
    }
    
    private func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layer.transform = CATransform3DMakeScale(0.1,0.1,1)
        UIView.animate(withDuration: 0.25, animations: {
            cell.layer.transform = CATransform3DMakeScale(1,1,1)
        })
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        //NOT WORKING
        //let dictn : NSDictionary = Projectitems[indexPath.section] as NSDictionary
        //print("DICTN >>> " , dictn.object(forKey: "projectName") as Any)
        //WORKING
        //print("Projectitems >> " , Projectitems[indexPath.row]["projectName"] as Any)
        
        
        if(self.searchActive){
            cell.textLabel?.text = self.filtered[indexPath.row]
        } else {
            if(self.multiArray == "project"){
                if self.Projectitems.isEmpty == false {
                    let item = self.Projectitems[indexPath.row]
                    let title = item["projectName"]!
                    //print("Projectitems SEARCH " , title)
                    cell.textLabel?.text = title
                }else{
                    OperationQueue.main.addOperation{
                        let alert = UIAlertController(title: "Alert", message: "Projects Not Loaded.. try again", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                    tableView.isHidden = true
                }
            }
            if(self.multiArray == "site"){
                if self.Siteitems.isEmpty == false {
                    let item = self.Siteitems[indexPath.row]
                    let title = item["siteName"]!
                    //print("Siteitems  SEARCH " , title)
                    cell.textLabel?.text = title
                }else{
                    OperationQueue.main.addOperation{
                        let alert = UIAlertController(title: "Alert", message: "Sites Not Loaded.. try again", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                    tableView.isHidden = true
                }
            }
            /* if(self.multiArray == "form"){
             if self.Formitems.isEmpty == false {
             let item = self.Formitems[indexPath.row]
             let title = item["Templates"]!
             print("Formitems SEARCH " , title)
             cell.textLabel?.text = title
             }else{
             OperationQueue.main.addOperation{
             let alert = UIAlertController(title: "Alert", message: "Templates Not available", preferredStyle: UIAlertControllerStyle.alert)
             alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
             self.present(alert, animated: true, completion: nil)
             }
             }
             } */
        }
        
        //Programmatically create label
        //         let newLabel = UILabel(frame: CGRect(x: 100, y: 5.0, width: 300.0, height: 30.0))
        //        if(searchActive){
        //            newLabel.text = filtered[indexPath.row]
        //        }else{
        //            newLabel.text = title
        //        }
        //         newLabel.textColor = UIColor.black
        //         newLabel.font = UIFont.systemFont(ofSize: 11.0)
        //         cell.addSubview(newLabel)
        
        
        let image : UIImage = UIImage(named: "vis")!
        image.draw(in: CGRect(x: 5, y: 10, width: 5, height: 5))
        cell.textLabel?.textAlignment = NSTextAlignment.left
        cell.imageView?.image = image
        
        return cell;
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //print("testDataID Array " , testDataID)
        
        let indexPaths = tableView.indexPathForSelectedRow
        let currentCell = tableView.cellForRow(at: indexPaths!)! as UITableViewCell
        //print("Current Cell ", currentCell.textLabel!.text as Any)
        searchBar.text = currentCell.textLabel!.text
        
        //projects
        
        if(currentCell.textLabel!.text == "Ericsson - Expansion"){
            print("projectID tableView Click 2 " , Projectitems[indexPath.row]["projectID"] as Any)
            
            setProjectId = Projectitems[indexPath.row]["projectID"]!
            
            Siteitems.removeAll()
            testData2.removeAll()
            Formitems.removeAll()
            testData3.removeAll()
            
            getSitesListJSON(setProjectId: setProjectId);
            
            selectedProject.text = currentCell.textLabel!.text
            selectedWorkSite.text = "Worksite"
            selectedWorkSite.textColor = UIColor.black
            ///reset to normal
            siteInfo.backgroundColor = UIColor.white
            siteInfo.titleLabel?.textColor = UIColor(red: 39/255, green: 21/255, blue: 11/255, alpha: 1)
            dashboard.backgroundColor = UIColor(red: 39/255, green: 21/255, blue: 11/255, alpha: 1)
            dashboard.titleLabel?.textColor = UIColor.white
        } else if(currentCell.textLabel!.text == "Telstra Wireless"){
            print("projectID tableView Click 2 " , Projectitems[indexPath.row]["projectID"] as Any)
            
            setProjectId = Projectitems[indexPath.row]["projectID"]!
            
            Siteitems.removeAll()
            testData2.removeAll()
            Formitems.removeAll()
            testData3.removeAll()
            
            getSitesListJSON(setProjectId: setProjectId);
            
            selectedProject.text = currentCell.textLabel!.text
            selectedWorkSite.text = "Worksite"
            selectedWorkSite.textColor = UIColor.black
            ///reset to normal
            siteInfo.backgroundColor = UIColor.white
            siteInfo.titleLabel?.textColor = UIColor(red: 39/255, green: 21/255, blue: 11/255, alpha: 1)
            dashboard.backgroundColor = UIColor(red: 39/255, green: 21/255, blue: 11/255, alpha: 1)
            dashboard.titleLabel?.textColor = UIColor.white
        } else if(currentCell.textLabel!.text == "Optus"){
            print("projectID tableView Click 2 " , Projectitems[indexPath.row]["projectID"] as Any)
            setProjectId = Projectitems[indexPath.row]["projectID"]!
            
            Siteitems.removeAll()
            testData2.removeAll()
            Formitems.removeAll()
            testData3.removeAll()
            
            getSitesListJSON(setProjectId: setProjectId);
            
            selectedProject.text = currentCell.textLabel!.text
            selectedWorkSite.text = "Worksite"
            selectedWorkSite.textColor = UIColor.black
            ///reset to normal
            siteInfo.backgroundColor = UIColor.white
            siteInfo.titleLabel?.textColor = UIColor(red: 39/255, green: 21/255, blue: 11/255, alpha: 1)
            dashboard.backgroundColor = UIColor(red: 39/255, green: 21/255, blue: 11/255, alpha: 1)
            dashboard.titleLabel?.textColor = UIColor.white
        } else if(currentCell.textLabel!.text == "Ericsson"){
            print("projectID tableView Click 2 " , Projectitems[indexPath.row]["projectID"] as Any)
            setProjectId = Projectitems[indexPath.row]["projectID"]!
            
            Siteitems.removeAll()
            testData2.removeAll()
            Formitems.removeAll()
            testData3.removeAll()
            
            getSitesListJSON(setProjectId: setProjectId);
            
            selectedProject.text = currentCell.textLabel!.text
            selectedWorkSite.text = "Worksite"
            selectedWorkSite.textColor = UIColor.black
            ///reset to normal
            siteInfo.backgroundColor = UIColor.white
            siteInfo.titleLabel?.textColor = UIColor(red: 39/255, green: 21/255, blue: 11/255, alpha: 1)
            dashboard.backgroundColor = UIColor(red: 39/255, green: 21/255, blue: 11/255, alpha: 1)
            dashboard.titleLabel?.textColor = UIColor.white
        }
            ///templates
        else if(currentCell.textLabel!.text == "Stage 2 Site DC Checklist"){
            dashboard.backgroundColor = UIColor.white
            dashboard.titleLabel?.textColor = UIColor(red: 39/255, green: 21/255, blue: 11/255, alpha: 1)
            siteInfo.backgroundColor = UIColor(red: 39/255, green: 21/255, blue: 11/255, alpha: 1)
            siteInfo.titleLabel?.textColor = UIColor.white
            //go to next View
            OperationQueue.main.addOperation {  // run in main thread
                let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                let vc = mainStoryboard.instantiateViewController(withIdentifier: "Form1") as! Form1
                vc.formName = "Stage 2 Site DC Checklist - DESIGN"
                self.present(vc, animated: true, completion: nil)
            }
        }else if(currentCell.textLabel!.text == "Stage 1 Site DC Checklist"){
            dashboard.backgroundColor = UIColor.white
            dashboard.titleLabel?.textColor = UIColor(red: 39/255, green: 21/255, blue: 11/255, alpha: 1)
            siteInfo.backgroundColor = UIColor(red: 39/255, green: 21/255, blue: 11/255, alpha: 1)
            siteInfo.titleLabel?.textColor = UIColor.white
            //go to next View
            OperationQueue.main.addOperation {  // run in main thread
                let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                let vc = mainStoryboard.instantiateViewController(withIdentifier: "Form1") as! Form1
                vc.formName = "Stage 1 Site DC Checklist - DESIGN"
                self.present(vc, animated: true, completion: nil)
            }
        }else if(currentCell.textLabel!.text == "Site Diary"){
            dashboard.backgroundColor = UIColor.white
            dashboard.titleLabel?.textColor = UIColor(red: 39/255, green: 21/255, blue: 11/255, alpha: 1)
            siteInfo.backgroundColor = UIColor(red: 39/255, green: 21/255, blue: 11/255, alpha: 1)
            siteInfo.titleLabel?.textColor = UIColor.white
            //go to next View
            OperationQueue.main.addOperation {  // run in main thread
                let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                let vc = mainStoryboard.instantiateViewController(withIdentifier: "Form1") as! Form1
                vc.formName = "Site Diary - SITE DIARY"
                self.present(vc, animated: true, completion: nil)
            }
        }else if(currentCell.textLabel!.text == "Toolbox Meeting"){
            dashboard.backgroundColor = UIColor.white
            dashboard.titleLabel?.textColor = UIColor(red: 39/255, green: 21/255, blue: 11/255, alpha: 1)
            siteInfo.backgroundColor = UIColor(red: 39/255, green: 21/255, blue: 11/255, alpha: 1)
            siteInfo.titleLabel?.textColor = UIColor.white
            //go to next View
            OperationQueue.main.addOperation {  // run in main thread
                let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                let vc = mainStoryboard.instantiateViewController(withIdentifier: "Form1") as! Form1
                vc.formName = "Toolbox Meeting - SHE"
                self.present(vc, animated: true, completion: nil)
            }
        }else if(currentCell.textLabel!.text == "Daily Pre-start and JSA Meeting"){
            dashboard.backgroundColor = UIColor.white
            dashboard.titleLabel?.textColor = UIColor(red: 39/255, green: 21/255, blue: 11/255, alpha: 1)
            siteInfo.backgroundColor = UIColor(red: 39/255, green: 21/255, blue: 11/255, alpha: 1)
            siteInfo.titleLabel?.textColor = UIColor.white
            //go to next View
            OperationQueue.main.addOperation {  // run in main thread
                let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                let vc = mainStoryboard.instantiateViewController(withIdentifier: "Form1") as! Form1
                vc.formName = "Daily Pre-start and JSA Meeting - SITE PACK"
                self.present(vc, animated: true, completion: nil)
            }
        }
            ///sites
        else{
            print("siteID >> " , Siteitems[indexPath.row]["siteID"] as Any)
            selectedWorkSite.text = currentCell.textLabel!.text
            selectedWorkSite.textColor = UIColor.red
            //selecting worksites
            setWorkSiteId = Siteitems[indexPath.row]["siteID"]!
            
            testData3.removeAll()
            Formitems.removeAll()
            
            let defaults = UserDefaults.standard
            defaults.set("", forKey: "MainJSON")
            
            ListSiteInfoForms(setWorkSiteId : setWorkSiteId)
            
            ///reset to normal
            siteInfo.backgroundColor = UIColor.white
            siteInfo.titleLabel?.textColor = UIColor(red: 39/255, green: 21/255, blue: 11/255, alpha: 1)
            dashboard.backgroundColor = UIColor(red: 39/255, green: 21/255, blue: 11/255, alpha: 1)
            dashboard.titleLabel?.textColor = UIColor.white
        }
        
        selectedProject.textColor = UIColor.red
        self.tableView.isHidden = true
    }
    
    /// sites \\\
    func getSitesListJSON(setProjectId : String){
        
        print("setProjectId  inside function " , setProjectId)
        
        let req = NSMutableURLRequest(url: NSURL(string:"https://ss-t.vspl.net/zion.api.fsit2/WorkSitesForProject/" + setProjectId)! as URL)
        req.httpMethod = "GET"
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
        req.setValue(setAuthToken, forHTTPHeaderField: "authorization")
        
        let task = URLSession.shared.dataTask(with: req as URLRequest) {
            data, response, error in
            // Check for error
            if error != nil {
                print("error=\(error)")
                return
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("StatusCode is === \(httpStatus.statusCode)")
                OperationQueue.main.addOperation{
                    let alert = UIAlertController(title: "Alert", message: "Select Project", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode == 200 {
                let responseString = String(data: data!, encoding: String.Encoding.utf8)
                // print("ResponseString = \(responseString)")
                //print("ResponseString = success status " +     responseString!)
                self.convertStringToDictionary2(text: responseString!)
            }
            
        }  //close task
        task.resume()
    }
    
    func convertStringToDictionary2(text: String) -> [String:AnyObject]? {
        if let data = text.data(using: String.Encoding.utf8) {
            do {
                let jsonObj = try JSONSerialization.jsonObject(with: data, options: [])
                
                for anItem in jsonObj as! [Dictionary<String, AnyObject>] {
                    let siteID = anItem["siteID"] as! String
                    let siteName = anItem["siteName"] as! String
                    
                    //set these values in tableview cell
                    testData2.append(siteName)
                    testData2ID.append(siteID)
                    // searchBar.text = ""
                    let dict  = ["siteID":siteID,"siteName":siteName]
                    
                    self.Siteitems.append(dict as [String : String])
                    
                    self.tableView.reloadData()
                    
                }
                print("Site testData2 " ,  testData2)
                print("Site ITEMS " ,  self.Siteitems)
            } catch {
                // Catch any other errors
            }
        }
        return nil
    }
    
    func ListSiteInfoForms(setWorkSiteId : String){
        
        DispatchQueue.main.async(){
            print("setWorkSiteId inside Function >>> " , setWorkSiteId)
            
            let req = NSMutableURLRequest(url: NSURL(string:"https://ss-t.vspl.net/zion.api.fsit2/Form/Templates/d444f503-3354-40df-8021-f4c9e99074b6/3643")! as URL)
            req.httpMethod = "GET"
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
            req.setValue(setAuthToken, forHTTPHeaderField: "authorization")
            
            let task = URLSession.shared.dataTask(with: req as URLRequest) {
                data, response, error in
                // Check for error
                if error != nil {
                    print("error=\(error)")
                    return
                }
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                    print("StatusCode is === \(httpStatus.statusCode)")
                    OperationQueue.main.addOperation{
                        let alert = UIAlertController(title: "Alert", message: "Select Work Site", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
                
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode == 200 {
                    let responseString = String(data: data!, encoding: String.Encoding.utf8)
                    // print("ResponseString = \(responseString)")
                    //print("ResponseString = success status " +     responseString!)
                    self.convertStringToDictionary3(text: responseString!)
                    let defaults = UserDefaults.standard
                    defaults.set(responseString, forKey: "MainJSON")
                }
            }  //close task
            task.resume()
        }
    }
    
    func convertStringToDictionary3(text: String) -> [String:AnyObject]? {
        DispatchQueue.main.async(){
            if let data_ = text.data(using: String.Encoding.utf8) {
                do {
                    let jsonObj = try JSONSerialization.jsonObject(with: data_, options: [])
                    
                    for anItem in jsonObj as! [Dictionary<String, AnyObject>] {
                        let Templates = anItem["name"] as! String
                        //print("Templates  " , Templates)
                        self.testData3.append(Templates)
                        
                        let dict  = ["Templates":Templates]
                        
                        self.Formitems.append(dict as [String : String])
                        self.tableView.reloadData()
                    }
                    print("Formitems >>> &&&&&&&&& << " , self.Formitems)
                } catch {
                    // Catch any other errors
                }
            }
        }
        return nil
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

