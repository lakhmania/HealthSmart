//
//  Favourites.swift
//  HealthSmart
//
//  Created by Nirali Merchant on 4/13/18.
//  Copyright © 2018 Apoorva Lakhmani. All rights reserved.
//


import UIKit
import Firebase

class Favourites: UIViewController, UITableViewDataSource, UITableViewDelegate,UISearchBarDelegate {

    var favouritesList:[Int] = []
    var searchFavourite:[RecipeDetails]? = []
    var searchActive : Bool = false
    var favRecipesIds : [Recipe]? = []
    let cellSpacingHeight: CGFloat = 15
    var searchedRecipes:[Recipe]? = []
    
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        getFavourites()
        
        let backgroundImage = UIImage(named: "backgroundImg.png")
        let imageView = UIImageView(image: backgroundImage)
        imageView.alpha = 0.8
        self.tableView.backgroundView = imageView
        
        tableView.separatorColor = UIColor.clear
        tableView.tableFooterView = UIView()
        
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "backgroundImg.png")!).withAlphaComponent(0.3)
        
        
        let attributes = [NSAttributedStringKey.font: UIFont(name: "HelveticaNeue-Light", size: 17)!, NSAttributedStringKey.foregroundColor: UIColor.white]
        //let attributes = [NSAttributedStringKey.font: UIFont(name: "HelveticaNeue-Light-Bold", size: 17)!]
       // UINavigationBar.appearance().titleTextAttributes = attributes
        navBar.titleTextAttributes = attributes
        navBar.backgroundColor = UIColor.clear
        navBar.setBackgroundImage(UIImage(), for: .default)
        navBar.shadowImage = UIImage()
        navBar.isTranslucent = true
        
        searchBar.backgroundColor = UIColor.clear
        
        self.searchBar.endEditing(true)
        
    }
    
    func getFavourites(){
        
        var ref: DatabaseReference!
        ref = Database.database().reference()
        let userId = Auth.auth().currentUser?.uid;
        print("User id is ::::: \(userId)")
        ref.child("UserFavourites").child(userId!).observe(.childAdded, with: { (snapshot) in
            ref.child("Recipes").observe(.childAdded, with: { (snap) in
                let recipe = Recipe()
                if snap.key == snapshot.key {
                    
                    let value = snap.value as? NSDictionary
                    recipe.imageUrl = value!["RecipeImageURL"] as? String
                    let image = self.loadImagesForRecipes(imageUrl: recipe.imageUrl)
                    recipe.recipeImage = image
                    recipe.ingridentsList = (value!["RecipeIngridientsList"] as? [String])!
                    recipe.instruction = (value!["RecipeInstruction"] as? [String])!
                    recipe.preparationMin = value!["RecipePrepTime"] as? Int
                    recipe.recipeRating = value!["RecipeRating"] as? Int
                    recipe.servings = value!["RecipeServings"] as? Int
                    recipe.recipeId = Int(snap.key)
                    recipe.recipeName = value!["RecipeName"] as? String
                    
                    self.favRecipesIds?.append(recipe)
                    self.tableView.reloadData()
                }
            })
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func viewAlert (msg: String){
        let alertController  = UIAlertController(title: "Alert Info", message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(action)
        self.present(alertController, animated: true, completion : nil)
    }
    
    func loadImagesForRecipes(imageUrl: String) -> UIImage{
        var image = UIImage()
        var request = URLRequest(url: NSURL(string: imageUrl)! as URL)
        request.httpMethod = "GET"
        request.addValue("3DyY04d0Xwmsh3Z9moMzp0KQHBiwp1tP3wnjsnCUA7VjSyPGto", forHTTPHeaderField: "X-Mashape-Key")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        do {
            // Perform the request
            let response: AutoreleasingUnsafeMutablePointer<URLResponse?>? = nil
            let data = try NSURLConnection.sendSynchronousRequest(request, returning: response)
            image = UIImage(data: data)!
        }catch{
            print("exception while loading recipes")
        }
       
        return image
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
        if !searchText.isEmpty {
            searchedRecipes = favRecipesIds?.filter { recipe in
                return (recipe.recipeName?.lowercased().contains(searchText.lowercased()))!
            }
            
        } else {
            searchedRecipes = favRecipesIds
        }
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return cellSpacingHeight
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        tableView.backgroundColor = UIColor.clear
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let temp = UIView()
        temp.backgroundColor = UIColor.clear
        
        return temp
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favRecipesIds!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let cell : FavouriteRecipe = self.tableView.dequeueReusableCell(withIdentifier: "favRecipeIdentifier", for : indexPath) as! FavouriteRecipe
        if let recipe = favRecipesIds {
            let rep = recipe[indexPath.row]
            cell.cellImage?.image = rep.recipeImage
            cell.cellLabel?.text = rep.recipeName
            cell.cellLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
            cell.cellLabel?.numberOfLines = 0
            cell.cellLabel?.font = UIFont(name: "TimesNewRomanPS-ItalicMT", size: 3.0)
            cell.cellLabel?.font = UIFont.boldSystemFont(ofSize: 20)
            cell.cellLabel?.textColor = UIColor.white
            cell.backgroundColor = UIColor.clear
            cell.cellImage?.contentMode = .scaleAspectFill
            //cell.cellImage?.clipsToBounds = true
        }
        return cell
    }

    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = UIColor.clear
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "favRecipeDetailsSegue" {
            if let controller = segue.destination as? RecipeDetailsController{
                if let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) {
                    controller.recipe = (favRecipesIds?[indexPath.row])!
                }
            }
        }
    }
    
    @IBAction func backBtn(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
}
