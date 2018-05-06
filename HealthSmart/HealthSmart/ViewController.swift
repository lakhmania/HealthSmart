//
//  ViewController.swift
//  HealthSmart
//
//  Created by Apoorva Lakhmani on 4/13/18.
//  Copyright © 2018 Apoorva Lakhmani. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var navBar: UINavigationBar!
    
    @IBOutlet weak var photo: UIImageView?
    @IBOutlet weak var trailingC: NSLayoutConstraint!
    
    @IBOutlet weak var loginButton: UIButton!
    let cellSpacingHeight: CGFloat = 15
    
    @IBOutlet weak var leadingC: NSLayoutConstraint!
    var menuIsVisible = false
    var displayImagesList = [String]()
    var recipesArray : [Recipe]? = []
    var loginButtonTitle = String()
    var loginFb = Bool()
    var image:UIImage? = UIImage(named: "profilePhoto.jpg")!{
        didSet {
            photo?.contentMode = .scaleAspectFill
            photo?.image = image
        }
    }
    @IBOutlet weak var tableView: UITableView!
  
    override func viewDidLoad() {
        
       
        
        photo?.layer.borderWidth = 1
       
        photo?.layer.borderColor = UIColor.black.cgColor
       
        photo?.clipsToBounds = true
        photo?.contentMode = .scaleAspectFill
        super.viewDidLoad()
        loadRecipes()
        loadImagesForRecipes()
        tableView!.delegate = self
        tableView!.dataSource = self
        loadUserDetails()
        let backgroundImage = UIImage(named: "backgroundImg.png")
        let imageView = UIImageView(image: backgroundImage)
        imageView.alpha = 0.5
        self.tableView.backgroundView = imageView
        
        
        let attributes = [NSAttributedStringKey.font: UIFont(name: "HelveticaNeue-Light", size: 17)!]
        UINavigationBar.appearance().titleTextAttributes = attributes
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadUserDetails(){
        let user = Auth.auth().currentUser;
        if(user != nil){
            let name = user?.displayName
            let email = user?.email
            if loginButtonTitle != ""{
                loginButton.setTitle(loginButtonTitle, for: .normal)
            }
            else if name != "" {
                loginButton.setTitle(name, for: .normal)
            }
            loginButton.isUserInteractionEnabled = false
            loadUserProfilePicStorage(email:email!)
        }
        else{
            loginButton.setTitle("login", for: .normal)
            loginButton.isUserInteractionEnabled = true
            image = UIImage(named: "profilePhoto.jpg")
            photo?.contentMode = .scaleAspectFill
            photo?.image = image
        }
    }
    
    func loadUserProfilePicStorage(email: String){
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let photoRef = storageRef.child("images/" + email + ".png")
        print(photoRef)
        photoRef.getData(maxSize: 30 * 1024 * 1024) { data, error in
            
            if let error = error {
                self.viewAlert(msg: error.localizedDescription)
                return
            } else {
                let image = UIImage(data: data!)!
                self.photo?.image = image
                self.photo?.contentMode = .scaleAspectFill
                print(image.size)
            }
        }
    }
    
    func loadRecipes(){
        var request = URLRequest(url: NSURL(string: "https://spoonacular-recipe-food-nutrition-v1.p.mashape.com/recipes/random?limitLicense=false&number=7")! as URL)
        request.httpMethod = "GET"
        //request.addValue("3DyY04d0Xwmsh3Z9moMzp0KQHBiwp1tP3wnjsnCUA7VjSyPGto", forHTTPHeaderField: "X-Mashape-Key")
        
        request.addValue("lmdZxjW2ujmshMxXbQwt5FmxCFEIp1POt79jsnvoR2sm1lptvR", forHTTPHeaderField: "X-Mashape-Key")
        
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        do {
            // Perform the request
            var response: AutoreleasingUnsafeMutablePointer<URLResponse?>? = nil
            let data = try NSURLConnection.sendSynchronousRequest(request, returning: response)
            // Convert the data to JSON
            let jsonSerialized = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
            
            if let json = jsonSerialized {
                for recipe in (json["recipes"] as? [[String: Any]])!{
                    let r = Recipe()
                    if recipe["image"] != nil {
                        let imageUrl = recipe["image"]! as! String
                        print("imageURL = \(imageUrl)")
                        
                        r.recipeId = recipe["id"] as! Int
                        r.imageUrl = imageUrl
                        r.recipeName = recipe["title"] as! String
                        r.preparationMin = recipe["readyInMinutes"] as! Int
                        r.servings = recipe["servings"] as! Int
                        r.recipeRating = recipe["aggregateLikes"] as! Int
                        
                        for ing in (recipe["extendedIngredients"] as? [[String : Any]])! {
                            
                            r.ingridentsList.append("\(ing["name"] as! String) - \(String((ing["amount"] as? Int) ?? 0)) \((ing["unit"] as? String) ?? "")")
                            
                        }
                        for inst in (recipe["analyzedInstructions"] as? [[String : Any]])! {
                            
                            for steps in (inst["steps"] as? [[String : Any]])! {
                                
                                r.instruction.append("\(String(steps["number"] as! Int)). \(steps["step"] as! String)")
                            }
                            
                        }
                        
                        self.recipesArray?.append(r)
                    }
                }
            }
        }catch{
            print("exception while loading recipes")
        }
    }
    
    func loadImagesForRecipes(){
        for recipe in recipesArray!{
            var request = URLRequest(url: NSURL(string: recipe.imageUrl)! as URL)
            request.httpMethod = "GET"
            request.addValue("3DyY04d0Xwmsh3Z9moMzp0KQHBiwp1tP3wnjsnCUA7VjSyPGto", forHTTPHeaderField: "X-Mashape-Key")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            do {
                // Perform the request
                let response: AutoreleasingUnsafeMutablePointer<URLResponse?>? = nil
                let data = try NSURLConnection.sendSynchronousRequest(request, returning: response)
                let image = UIImage(data: data)
                recipe.recipeImage = image
            }catch{
                print("exception while loading recipes")
            }
        }
        
    }
    
    func viewAlert (msg: String){
        let alertController  = UIAlertController(title: "Alert Info", message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(action)
        self.present(alertController, animated: true, completion : nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "recipeDetailsSegue" {
            if let controller = segue.destination as? RecipeDetailsController{
                if let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) {
                    controller.recipe = (recipesArray?[indexPath.row])!
                }
            }
        }
        if segue.identifier == "ingSegue"{
            var user = Auth.auth().currentUser;
            print(user?.displayName)
            if(user == nil){
                viewAlert(msg: "Please login to access this page")
            }
        }
        
        if segue.identifier == "favSegue"{
            var user = Auth.auth().currentUser;
            print(user?.displayName)
            if(user == nil){
                viewAlert(msg: "Please login to access this page")
            }
        }
        if segue.identifier == "loginSegue"{
            if let controller = segue.destination as? Login{
                //controller.popoverPresentationController?.sourceRect = CGRect(x: view.center.x, y: view.center.y, width: 0, height: 0)
                //controller.popoverPresentationController?.sourceRect = CGRect(x: UIScreen.main.bounds.width * 0.5 - 200, y: UIScreen.main.bounds.height * 0.5 - 100, width: 400, height: 200)
                //controller.popoverPresentationController?.sourceView = view
                //controller.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
            }
            

        }
    }
    
    // Set the spacing between sections
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return cellSpacingHeight
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        tableView.backgroundColor = UIColor.clear
        //return recipesArray!.count
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let temp = UIView()
        temp.backgroundColor = UIColor.clear
        
        return temp
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipesArray!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : RecipeDetailsTableCell = self.tableView.dequeueReusableCell(withIdentifier: "recipeDetailIdentifier", for : indexPath) as! RecipeDetailsTableCell
        if let recipe = recipesArray {
            let rep = recipe[indexPath.row]
            cell.recipeImage?.image = rep.recipeImage
            cell.recipeName?.text = rep.recipeName
            cell.recipeName?.lineBreakMode = NSLineBreakMode.byWordWrapping
            cell.recipeName?.numberOfLines = 0
            cell.recipeName?.font = UIFont(name: "TimesNewRomanPS-ItalicMT", size: 3.0)
            cell.recipeName?.font = UIFont.boldSystemFont(ofSize: 20)
            cell.recipeName?.textColor = UIColor.white
            cell.backgroundColor = UIColor.clear
            cell.recipeImage?.contentMode = .scaleAspectFill
        }
        return cell
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = UIColor.clear
    }
    
    @IBAction func menuBtnTapped(_ sender: Any) {
        if !menuIsVisible{
            leadingC.constant = 150
            trailingC.constant = -150
            
            menuIsVisible = true
            
        } else{
            leadingC.constant = 0
            trailingC.constant = 0;
            
            menuIsVisible = false
        }
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn, animations: {
            self.view.layoutIfNeeded()
        }) { (animationComplete) in
            print("the animation is complete")
        }
    }
    
    @IBAction func logOut(_ sender: UIBarButtonItem) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            loginButton.setTitle("Login", for: .normal)
            loginButton.isUserInteractionEnabled = true
            let image:UIImage? = UIImage(named: "profilePhoto.jpg")!
            photo?.image = image
            print("Logged out user")
            self.viewAlert(msg: "Successfully logged out")
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
}

