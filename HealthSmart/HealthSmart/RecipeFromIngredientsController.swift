//
//  RecipeFromIngredientsController.swift
//  HealthSmart
//
//  Created by Nirali Merchant on 4/25/18.
//  Copyright © 2018 Apoorva Lakhmani. All rights reserved.
//

import UIKit

class RecipeFromIngredientsController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UITextFieldDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var navBar: UINavigationBar!
    
    var recipesArray  = [Recipe]()
    var searchActive : Bool = false
    var searchedRecipes:[Recipe]? = []
    var activityIndicatorView = UIActivityIndicatorView()
    let cellSpacingHeight: CGFloat = 15
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        

        
        tableView!.delegate = self
        tableView!.dataSource = self
        searchBar.delegate = self
        
        
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "backgroundImg.png")!).withAlphaComponent(0.3)
        let attributes = [NSAttributedStringKey.font: UIFont(name: "HelveticaNeue-Light", size: 17)!, NSAttributedStringKey.foregroundColor: UIColor.white]
       
        navBar.titleTextAttributes = attributes
        navBar.backgroundColor = UIColor.clear
        navBar.setBackgroundImage(UIImage(), for: .default)
        navBar.shadowImage = UIImage()
        navBar.isTranslucent = true
        
        self.searchBar.endEditing(true)
        
        loadImagesForRecipes()
        searchedRecipes = recipesArray
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        return true
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
        guard let recipe_temp = searchedRecipes else {
            return 0
        }
        return recipe_temp.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : RecipeFromIngredientsTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "recipeIdentifier", for : indexPath) as! RecipeFromIngredientsTableViewCell
        let recipe = recipesArray[indexPath.row]
        cell.recipeImageView?.image = recipe.recipeImage
        cell.recipeLabel.text = recipe.recipeName
        cell.recipeLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        cell.recipeLabel.numberOfLines = 0
        cell.recipeLabel.font = UIFont(name: "TimesNewRomanPS-ItalicMT", size: 3.0)
        cell.recipeLabel.font = UIFont.boldSystemFont(ofSize: 20)
        cell.recipeLabel.textColor = UIColor.white
        cell.backgroundColor = UIColor.clear
        cell.recipeImageView?.contentMode = .scaleAspectFill
        
        return cell
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = UIColor.clear
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
            searchedRecipes = recipesArray.filter { recipe in
                return (recipe.recipeName?.lowercased().contains(searchText.lowercased()))!
            }
            
        } else {
            searchedRecipes = recipesArray
        }
        tableView.reloadData()
    }
    
    
    func loadImagesForRecipes(){
        for recipe in recipesArray{
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ingRecipeDetailSegue" {
            if let controller = segue.destination as? RecipeDetailsController{
                if let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) {
                    controller.recipe = (searchedRecipes?[indexPath.row])!
                }
            }
        }
    }
    
    
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
