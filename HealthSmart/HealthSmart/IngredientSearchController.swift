//
//  IngredientSearchController.swift
//  HealthSmart
//
//  Created by Nirali Merchant on 4/24/18.
//  Copyright © 2018 Apoorva Lakhmani. All rights reserved.
//

import UIKit

class IngredientSearchController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var hidingView: UIView!
    @IBOutlet weak var searchResult: UITableView!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var showRecipeButton: UIButton!
    
    @IBOutlet weak var stackView: UIStackView!
    var searchActive : Bool = false
    var resultList:[String] = []
    var finalResultList:[String] = []
    var sourceurlList:[String]=[]
    var recipesArray : [Recipe]? = []
    var xPos:Int = 50
    var yPos:Int = 60
    var count:Int = 0
    
    var activityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 100, y: 200, width:50, height:50)) as UIActivityIndicatorView
    
    var window = UIApplication.shared.keyWindow
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        hidingView.isHidden = true
        searchResult.isHidden = true
        
        searchResult.delegate = self
        searchResult.dataSource = self
        searchBar.delegate = self
        
        
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "backgroundImg.png")!).withAlphaComponent(0.7)
        
        let attributes = [NSAttributedStringKey.font: UIFont(name: "HelveticaNeue-Light", size: 17)!, NSAttributedStringKey.foregroundColor: UIColor.white]
     
        navBar.titleTextAttributes = attributes
        navBar.backgroundColor = UIColor.clear
        navBar.setBackgroundImage(UIImage(), for: .default)
        navBar.shadowImage = UIImage()
        navBar.isTranslucent = true
        
        view.addSubview(stackView)
    }
        
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
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        stackView.isHidden = true
        if searchText.count == 0 {
            self.hidingView.isHidden = true
            self.searchResult.isHidden = true
         
        }
        if searchText.count >= 1 {
            loadIngredients(searchText: searchText)
            if resultList.count != 0 {
                
                self.hidingView.isHidden=false
                self.searchResult.isHidden = false
                self.searchResult.reloadData()
            }
            else{
                self.hidingView.isHidden = true
                self.searchResult.isHidden = true
                
                self.searchResult.reloadData()
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        tableView.backgroundColor = UIColor.clear
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchIngIdentifier", for : indexPath)
        let ingredient = resultList[indexPath.row]
        cell.textLabel?.text = ingredient
        cell.backgroundColor = UIColor.clear
        cell.textLabel?.textColor = UIColor.white
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        stackView.isHidden = false
        let cell = searchResult.cellForRow(at: indexPath)
        let ing  = cell?.textLabel?.text
        
        searchBar.text = ""
        
        hidingView.isHidden = true
        searchResult.isHidden = true
       
        
        let textField = UITextField(frame: CGRect(x:xPos,y:yPos,width:170,height:50))
        textField.text = ing
        textField.textColor = UIColor.white
        
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "clear.png"), for: .normal)
        button.frame = CGRect(x: xPos+10, y: yPos, width: 15, height: 15)
        //button.backgroundColor = UIColor.red
        button.addTarget(self, action: #selector(clearTextField(sender:)), for: .touchUpInside)
        //button.isUserInteractionEnabled = true
        textField.rightView = button
        textField.rightViewMode = UITextFieldViewMode.always
        //textField.isUserInteractionEnabled = true
        //textField.isEnabled = true
        
        print(button.superview)
        
        for v in button.subviews{
            print(v)
        }
        
        textField.delegate = self
        
        stackView.addSubview(textField)
    
        yPos = yPos + 20
        
        finalResultList.append(ing!)
    }
    
    @objc func clearTextField(sender: AnyObject){
        let view = sender.superview
        view??.removeFromSuperview()
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = UIColor.clear
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return false
    }
    
    @IBAction func loadRecipesFromIngredients(_ sender: UIButton) {
        
        //activityIndicatorView.center = self.view.center
        //activityIndicatorView.hidesWhenStopped = true
        //activityIndicatorView.activityIndicatorViewStyle = .gray
        
        //self.view.addSubview(activityIndicatorView)
        
        //activityIndicatorView.startAnimating()
        
        var finalString:String = ""
        var count:Int = 0
        for ingredient in finalResultList{
            count  = count + 1
            if count != 1 {
                finalString = finalString + "+" + ingredient
            }
            else{
                finalString = finalString + ingredient
            }
        }
        //if(finalString)
        print(finalString)
        callGetRecipeAPI(ingList: finalString)
        print(recipesArray!.count)
    }
    
    
    
   
    
    func callGetRecipeAPI(ingList:String){
        print(ingList)
        print("https://community-food2fork.p.mashape.com/search?key=da7cc5e289c8851d6ac87c5fb35781a7&q=\(ingList)")
        var request = URLRequest(url: NSURL(string: "https://community-food2fork.p.mashape.com/search?key=da7cc5e289c8851d6ac87c5fb35781a7&q=\(ingList)")! as URL)
        request.httpMethod = "GET"
        request.addValue("lmdZxjW2ujmshMxXbQwt5FmxCFEIp1POt79jsnvoR2sm1lptvR", forHTTPHeaderField: "X-Mashape-Key")
        //request.addValue("3DyY04d0Xwmsh3Z9moMzp0KQHBiwp1tP3wnjsnCUA7VjSyPGto", forHTTPHeaderField: "X-Mashape-Key")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        print(request)
            print("request sent is :::: \(request)")
        do {
            // Perform the request
            let response: AutoreleasingUnsafeMutablePointer<URLResponse?>? = nil
            let data = try NSURLConnection.sendSynchronousRequest(request, returning: response)
            let jsonSerialized = try JSONSerialization.jsonObject(with: data) as? [String : Any]
            if let json = jsonSerialized {
                for recipe in (json["recipes"] as? [[String: Any]])!{
                    let source_url = recipe["source_url"]
                    self.extractRecipeFromUrl(source_url: source_url as! String)
                }
            }
        }catch{
            print("exception while loading recipes")
        }
    }
    
    func loadIngredients(searchText:String){
        resultList = []
        var request = URLRequest(url: NSURL(string: "https://spoonacular-recipe-food-nutrition-v1.p.mashape.com/food/ingredients/autocomplete?intolerances=egg&metaInformation=false&number=100&query=\(searchText)")! as URL)
        request.httpMethod = "GET"
        //request.addValue("3DyY04d0Xwmsh3Z9moMzp0KQHBiwp1tP3wnjsnCUA7VjSyPGto", forHTTPHeaderField: "X-Mashape-Key")
        
        request.addValue("lmdZxjW2ujmshMxXbQwt5FmxCFEIp1POt79jsnvoR2sm1lptvR", forHTTPHeaderField: "X-Mashape-Key")
        
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        do {
            print("request sent is :::: \(request)")
            do {
                // Perform the request
                let response: AutoreleasingUnsafeMutablePointer<URLResponse?>? = nil
                let data = try NSURLConnection.sendSynchronousRequest(request, returning: response)
                let jsonSerialized = try JSONSerialization.jsonObject(with: data) as? [[String : Any]]
                if let json = jsonSerialized {
                    for tempData in json {
                        let name  = tempData["name"]
                        resultList.append(name as! String)
                        print(resultList.count)
                    }
                }
            }catch{
                print("exception while loading recipes")
            }
        }
    }
    
    
    func extractRecipeFromUrl(source_url:String){
        var request = URLRequest(url: NSURL(string: "https://spoonacular-recipe-food-nutrition-v1.p.mashape.com/recipes/extract?forceExtraction=false&url=\(source_url)")! as URL)
        request.httpMethod = "GET"
        request.addValue("lmdZxjW2ujmshMxXbQwt5FmxCFEIp1POt79jsnvoR2sm1lptvR", forHTTPHeaderField: "X-Mashape-Key")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        print(request)
        print("request sent is :::: \(request)")
        do {
            // Perform the request
            let response: AutoreleasingUnsafeMutablePointer<URLResponse?>? = nil
            let data = try NSURLConnection.sendSynchronousRequest(request, returning: response)
            let jsonSerialized = try JSONSerialization.jsonObject(with: data) as? [String : Any]
            if let recipe = jsonSerialized {
            let r = Recipe()
            if recipe["image"] != nil {
                let imageUrl = recipe["image"]! as! String
                print("imageURL = \(imageUrl)")
                
                r.recipeId = recipe["id"] as! Int
                r.imageUrl = imageUrl
                r.recipeName = recipe["title"] as! String
               
                r.preparationMin = recipe["readyInMinutes"] as? Int ?? 0
                
               
                r.servings = recipe["servings"] as? Int ?? 0
                
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
        }catch{
            print("exception while loading recipes")
        }
    }
    
    func viewAlert (msg: String){
        let alertController  = UIAlertController(title: "Alert Info", message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(action)
        self.present(alertController, animated: true, completion : nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        activityIndicatorView.stopAnimating()
        activityIndicatorView.removeFromSuperview()
        
        if segue.identifier == "recipeIngSegue" {
            if  recipesArray!.count > 0{
            if let controller = segue.destination as? RecipeFromIngredientsController{
                controller.recipesArray = recipesArray!
            }
            }
            else{
                viewAlert(msg: "Uh-Oh No recipes found!")
            }
        }
    }
}
