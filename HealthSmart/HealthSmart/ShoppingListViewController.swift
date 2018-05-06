//
//  ShoppingListViewController.swift
//  HealthSmart
//
//  Created by Apoorva Lakhmani on 4/23/18.
//  Copyright © 2018 Apoorva Lakhmani. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation

class ShoppingListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var recipeIngTable: UITableView!
    
    @IBOutlet weak var navBar: UINavigationBar!
    
    var shopListArray : [shoppingList]? = []
    var recipeNameArray: [String] = []
    
    let cellSpacingHeight: CGFloat = 15
    
    var locManager = CLLocationManager()
    
    var storesNearMe = [StoreLocDetail]()
    var currentLocation: CLLocation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locManager.requestWhenInUseAuthorization()
        
        LoadShopListForUserFromDB()
        //print(shopListArray?.count)
        recipeIngTable.dataSource = self
        recipeIngTable.delegate = self
        
        recipeIngTable.separatorColor = UIColor.clear
        recipeIngTable.tableFooterView = UIView()
        
        recipeIngTable.backgroundColor = UIColor.clear
        
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "backgroundImg.png")!)
        let attributes = [NSAttributedStringKey.font: UIFont(name: "HelveticaNeue-Light", size: 17)!,NSAttributedStringKey.foregroundColor: UIColor.white]
        //let attributes = [NSAttributedStringKey.font: UIFont(name: "HelveticaNeue-Light-Bold", size: 17)!]
       navBar.titleTextAttributes = attributes
        navBar.backgroundColor = UIColor.clear
        navBar.setBackgroundImage(UIImage(), for: .default)
        navBar.shadowImage = UIImage()
        navBar.isTranslucent = true
    }
    
    func LoadShopListForUserFromDB(){
        
        var ref: DatabaseReference!
        ref = Database.database().reference()

        if Auth.auth().currentUser != nil{
            let userId = Auth.auth().currentUser?.uid
            ref.child("UserShopList").child(String(describing: userId!)).observe(.childAdded, with: { (snapshot) in
                
                let shopList = shoppingList()
                
                let value = snapshot.value as? NSDictionary
                let recipeName = snapshot.key
                //self.recipeNameArray.append(snapshot.key)
                let ingList = value?["shopList"] as? [String] ?? [""]
                shopList.recipeName = recipeName
                shopList.IngList = ingList
                
                self.shopListArray?.append(shopList)
                self.recipeIngTable.reloadData()
                
            }) { (error) in
                print(error.localizedDescription)
            }
        }
        
        
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        tableView.backgroundColor = UIColor.clear
        return shopListArray!.count
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let temp = UIView()
        temp.backgroundColor = UIColor.clear
        
        return temp
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if shopListArray![section].opened == true{
            return shopListArray![section].IngList.count + 1
        } else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "recipeIngIdentifier")
            cell?.textLabel?.text = shopListArray![indexPath.section].recipeName
            cell?.textLabel?.textColor = UIColor.brown
            cell?.textLabel?.font = UIFont.boldSystemFont(ofSize: 20)
            //cell?.textLabel!.font = UIFont(name: "Zapfino", size: 14.0)
            cell?.textLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
            cell?.textLabel?.numberOfLines = 0
            cell?.backgroundColor = UIColor.clear
            return cell!
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "recipeIngIdentifier")
            var ingName = shopListArray![indexPath.section].IngList[indexPath.row - 1].components(separatedBy: "-")
            cell?.textLabel?.text = ingName[0]
            //cell?.textLabel?.textAlignment = .center
            cell?.textLabel?.textColor = UIColor.white
            cell?.textLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
            cell?.textLabel?.numberOfLines = 0
            cell?.backgroundColor = UIColor.clear
            return cell!
        }
    }
    
    // Set the spacing between sections
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return cellSpacingHeight
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = UIColor.clear
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if shopListArray![indexPath.section].opened == true {
            shopListArray![indexPath.section].opened = false
            let sections = IndexSet.init(integer: indexPath.section)
            tableView.reloadSections(sections, with: .none)
        }else{
            shopListArray![indexPath.section].opened = true
            let sections = IndexSet.init(integer: indexPath.section)
            tableView.reloadSections(sections, with: .none)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backBtn(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    func getCurrentLocationCoordinates(){
        
        
        if( CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse){
            
            currentLocation = locManager.location
            
        }
    }
    @IBAction func findNearbyStores(_ sender: UIButton) {
        
        getCurrentLocationCoordinates()
        
        let lat = currentLocation.coordinate.latitude
        let long = currentLocation.coordinate.longitude
        
        print(lat)
        print(long)
        
        var request = URLRequest(url: NSURL(string: "https://maps.googleapis.com/maps/api/place/search/json?location=\(lat),\(long)&radius=1000&types=grocery_or_supermarket&sensor=true&key=AIzaSyBujf95a0exvveY7ptQ89P89x_W1f16iy4")! as URL)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        do{
            // Perform the request
            var response: AutoreleasingUnsafeMutablePointer<URLResponse?>? = nil
            let data = try NSURLConnection.sendSynchronousRequest(request, returning: response)
            // Convert the data to JSON
            let jsonSerialized = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
            
            print(jsonSerialized)
            if let json = jsonSerialized {
                let result = json["results"] as? [[String:Any]]
                for res in result! {
                    var storeLocDetail = StoreLocDetail()
                    
                    let geo = res["geometry"] as? [String:Any]
                    let loc = geo!["location"] as? [String:Any]
                    
                    storeLocDetail.storeName = (res["name"] as? String)!
                    storeLocDetail.latitude = loc!["lat"] as? Double
                    storeLocDetail.longitude = loc!["lng"] as? Double
                    
                    storesNearMe.append(storeLocDetail)
                }
            }
            
            
        }catch{
             print("exception while loading recipes")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "storeMapSegue" {
            if let controller = segue.destination as? StoreMapViewController{
                controller.stores = storesNearMe
            }
        }
    }
}
