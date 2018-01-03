
import UIKit

class test: UIViewController, UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate {
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func backButtonClick(_ sender: Any) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc : UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "DashboardViewController") as UIViewController
        self.present(vc, animated: true, completion: nil)
    }
    
    var tasks : [Task] = []
    
    @IBOutlet var AddItem: UIBarButtonItem!
    private let refreshControl = UIRefreshControl()
    
    @IBAction func AddItemOnclick(_ sender: Any) {
        var alert = UIAlertView()
        alert.title = "Add Item"
        alert.message = "Enter the item content"
        alert.addButton(withTitle: "Cancel")
        alert.addButton(withTitle: "Ok")
        alert.alertViewStyle = .plainTextInput
        alert.delegate = self
        alert.show()
    }
    
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int){
        if buttonIndex != 1{
            return
        }
        let task = Task(context: context)
        task.name = alertView.textField(at: 0)?.text!
        //Save the data to Core Data
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        //Re-Fetch
        getData()
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        ///Refresh Control
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(test.refreshData(sender:)), for: .valueChanged)
    }
    
   func refreshData(sender: UIRefreshControl) {
        // Code to refresh table view
        getData()
        tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //get data from core data
        getData()
        tableView.reloadData()
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //  var cell:UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "Cell")as UITableViewCell!
        //        if !(cell != nil){
        //            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "Cell")
        //        }
        
        let cell = UITableViewCell()
        let task = tasks[indexPath.row]
        
        //check & add text to cell if name is not a nil value - method 1
        if let myName = task.name {
            cell.textLabel?.text = myName
        }
        //check & add text to cell if name is not a nil value - method 2
        //cell.textLabel?.text = task.name!
        return cell
    }
    
    func getData(){
        do {
            tasks = try context.fetch(Task.fetchRequest())
        } catch{
            print("Failed in Fetch from Core Data")
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let task = tasks[indexPath.row]
            context.delete(task)
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            
            do {
                tasks = try context.fetch(Task.fetchRequest())
            }
            catch {
                print("Fetching Failed")
            }
        }
        tableView.reloadData()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}


