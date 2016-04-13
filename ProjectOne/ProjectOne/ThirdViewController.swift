


import UIKit



var mySmallList = [String: Small]()

class ThirdViewController: UITableViewController, UISearchBarDelegate {
    
    
    
    //-----------
    // VARIABLES
    //-----------
    var smallNamelist = [String]()
    var filteredNames = [String]()
    
    
    var data = NSMutableData()  // Create data storage object
    var selectedSmall = 0 // Initialize selectedDog
    var objects = [[String:String]]()
    
    
    @IBOutlet var searchBar: UISearchBar!
    var searchActive : Bool = false
    
    
    
    //---------------
    // HIDE KEYBOARD
    //---------------
//    func hideKeyboardWhenTappedAround() {
//        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ThirdViewController.dismissKeyboard))
//            view.addGestureRecognizer(tap)
//        }
//        
//        func dismissKeyboard() {
//            view.endEditing(true)
//        }
    
    
    
    //-----------------------
    // PREPARE FOR DOG SEGUE
    //-----------------------
    override func prepareForSegue(segue: UIStoryboardSegue, sender:
        AnyObject?) {
        if segue.identifier == "smallsegue" {
            let detailVC = segue.destinationViewController as! SmallViewController
            let indexPath = tableView.indexPathForCell(sender as! UITableViewCell)!
            
            //sets the data for the destination controller
            if(searchActive){
                detailVC.title = filteredNames[indexPath.row]
                detailVC.filteredNames = filteredNames
                detailVC.smallList = mySmallList
                detailVC.selectedSmall = indexPath.row
            } else {
                detailVC.title = smallNamelist[indexPath.row]
                detailVC.smallNamelist = smallNamelist
                detailVC.smallList = mySmallList
                detailVC.selectedSmall = indexPath.row
            }
            
        }
    }
    
    
    
    //-------------------------
    // DISPLAY TABLEVIEW CELLS
    //-------------------------
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //configure the cell
        let cell = tableView.dequeueReusableCellWithIdentifier("CellIdentifier", forIndexPath: indexPath)
        
        cell.textLabel?.font = UIFont(name: "HelveticaNeue", size: 28)
        cell.textLabel?.textAlignment = .Center
        
        if(searchActive){
            cell.textLabel?.text = filteredNames[indexPath.row]
            
            let plainString = mySmallList[filteredNames[indexPath.row]]!.pic
            let decodedData = NSData(base64EncodedString: plainString, options: NSDataBase64DecodingOptions(rawValue: 0))
            let decodedimage = UIImage(data: decodedData!)
            let image : UIImage = decodedimage! as UIImage
            cell.imageView!.image = image
            return cell
            
            
            
        } else {
            cell.textLabel?.text = smallNamelist[indexPath.row]
            let plainString = mySmallList[smallNamelist[indexPath.row]]!.pic
            let decodedData = NSData(base64EncodedString: plainString, options: NSDataBase64DecodingOptions(rawValue: 0))
            let decodedimage = UIImage(data: decodedData!)
            let image : UIImage = decodedimage! as UIImage
            cell.imageView!.image = image
            return cell
        }
        // Formatting table view cells source
        //http://www.appcoda.com/customize-table-view-cells-for-uitableview/
    }
    
    
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    
    //----------------------
    // # OF ROWS IN SECTION
    //----------------------
    override func tableView(tableView: UITableView, numberOfRowsInSection
        section: Int) -> Int {
        if(searchActive) {
            return filteredNames.count
        } else {
            return smallNamelist.count
        }
    }
    
    
    
    //--------------------
    // Load JSON from URL
    //--------------------
    func loadJSON(){
        let urlPath = "https://www.jessiealbarian.com/smalldata.json"
        guard let url = NSURL(string: urlPath)
            else {
                print("url error")
                return
        }
        let session = NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: {(data, response, error) in
            let httpResponse = response as! NSHTTPURLResponse
            let statusCode = httpResponse.statusCode
            guard statusCode == 200
                else {
                    print("file download error")
                    return
            }
            print("download successful")
            dispatch_async(dispatch_get_main_queue()) { self.parsejson(data!) }
        })
        session.resume()
    }
    
    
    
    //--------------------
    // Search bar function
    //--------------------
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
//        if (searchText.isEmpty == true){
//            filteredNames = smallNamelist
//        } else {
//        
        var i : Int = 0
        while(i < smallNamelist.count){
            for item in smallNamelist{
                filteredNames.append(item)
                i += 1
            }
        }
        
        
        filteredNames = smallNamelist.filter({ (text) -> Bool in
            let tmp: NSString = text // the name from the variable decleration
            let range = tmp.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
            return range.location != NSNotFound
        })
        
        
        if(filteredNames.count == 0){
            searchActive = false;
        } else {
            searchActive = true;
        }
        self.tableView.reloadData()
//        }
    }
    
    
    
    
    //------------
    // Parse JSON
    //------------
    func parsejson(data: NSData){
        do {
            let json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
            let allresults = json["boulder, CO"] as! NSArray
            let results = Array(allresults)
            for item in results {
                let name = item["name"] as! String
                
                let sex = item["sex"]! as! String
                
                let breed = item["breed"]! as! String
                
                let age = item["age"]! as! String
                
                let pic = item["image"]! as! String
                
                mySmallList[name] = Small(newName: name, newSex: sex, newBreed: breed, newAge: age, newPic: pic)
                smallNamelist.append(name)
            }
        } catch {
            print("Error with JSON: \(error)")
        }
        tableView.reloadData()
    }
    
    
    
    //---------------
    // VIEWDIDLOAD
    //---------------
    override func viewDidLoad() {
        if (mySmallList.isEmpty == true){
            loadJSON()
        }
        
        super.viewDidLoad()
        searchBar.delegate = self
//        self.hideKeyboardWhenTappedAround()
    }
    
    
    
    //-------------------------
    // DIDRECEIVEMEMORYWARNING
    //-------------------------
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

