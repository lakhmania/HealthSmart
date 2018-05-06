//
//  RecipeDetailsController.swift
//  HealthSmart
//
//  Created by Apoorva Lakhmani on 4/13/18.
//  Copyright © 2018 Apoorva Lakhmani. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation

class RecipeDetailsController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var recipe = Recipe()
    
    @IBOutlet weak var recipeImg: UIImageView!
    
    @IBOutlet weak var servingLabel: UILabel!
    
    @IBOutlet weak var ingredientsTable: UITableView!
    
    @IBOutlet weak var instructionTable: UITableView!
    @IBOutlet weak var scroll: UIScrollView!
    
    @IBOutlet weak var navBarItem: UINavigationItem!
    @IBOutlet weak var exportIngList: UIButton!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var prepTime: UILabel!
    
    @IBOutlet weak var prep: UILabel!
    @IBOutlet weak var exportBtn: UIButton!
    @IBOutlet weak var rating: UILabel!
    
    @IBOutlet weak var timerImage: UIImageView!
    @IBOutlet weak var timerButton: UIBarButtonItem!
    @IBOutlet weak var timerLabel: UILabel!
    
    var seconds:Int?
    var timerSet:Bool = false
    
    var timer = Timer()
    var isTimerRunning:Bool = false
    var player: AVAudioPlayer?
    
    let cellSpacingHeight: CGFloat = 15
    
    var instArray : [String] = []

    override func viewDidLoad() {
        
        super.viewDidLoad()
        timerLabel.isHidden = true
        timerImage.isHidden = true
        ingredientsTable.delegate = self
        ingredientsTable.dataSource = self
        
        instructionTable.delegate = self
        instructionTable.dataSource = self
        
        exportIngList.layer.borderWidth = 1.0
        exportIngList.layer.borderColor = UIColor.blue.cgColor
        
        let label = UILabel()
        //label.text = recipe.recipeName
        var strList = recipe.recipeName.components(separatedBy: " ")
        var temp = String()
        var count:Int = 1
        for item in strList{
            if count <= 3 {
            temp = temp   +  item + " "
            count  = count + 1
            }
        }
        label.text = temp
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        navBarItem.titleView = label
        
        ingredientsTable.separatorColor = UIColor.clear
        instructionTable.separatorColor = UIColor.clear
        
        ingredientsTable.tableFooterView = UIView()
        instructionTable.tableFooterView = UIView()
        
//        toolbar.backgroundColor = UIColor.clear
//        toolbar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
//        toolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
//        toolbar.isTranslucent = true
        
        setRecipeDetails()
        
        let scrollView = self.view.viewWithTag(1)
        scrollView?.backgroundColor = UIColor(patternImage: UIImage(named:"backgroundImg.png")!).withAlphaComponent(0.3)

        ingredientsTable.backgroundColor = UIColor.clear
        instructionTable.backgroundColor = UIColor.clear
        prep.backgroundColor = UIColor.clear
        
        
        exportIngList.backgroundColor = UIColor.lightGray
        exportIngList.layer.cornerRadius = 8
        exportIngList.layer.borderWidth = 1
        exportIngList.layer.borderColor = UIColor.darkGray.cgColor
        
        let attributes = [NSAttributedStringKey.font: UIFont(name: "HelveticaNeue-Light", size: 17)!, NSAttributedStringKey.foregroundColor: UIColor.black]
        //let attributes = [NSAttributedStringKey.font: UIFont(name: "HelveticaNeue-Light-Bold", size: 17)!]
        navBar.titleTextAttributes = attributes
        
        if timerSet == true{
            timerLabel.isHidden = false
            timerImage.isHidden = false
            self.runTimer()
        }
    }
    
    func setRecipeDetails(){
        recipeImg.image = recipe.recipeImage
        servingLabel.text = String(recipe.servings)
        prepTime.text = "\(recipe.preparationMin!) mins"
        prepTime.lineBreakMode = NSLineBreakMode.byWordWrapping
        prepTime.numberOfLines = 0
        rating.text = "\(recipe.recipeRating!)"
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        tableView.backgroundColor = UIColor.clear
        //return recipe.instruction.count
        //return 1
        if tableView == self.ingredientsTable {
            return recipe.ingridentsList.count
        }
        
        if tableView == self.instructionTable{
            return recipe.instruction.count
        }
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let temp = UIView()
        temp.backgroundColor = UIColor.clear

        return temp
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
//        if tableView == self.ingredientsTable {
//            return recipe.ingridentsList.count
//        }
//
//        if tableView == self.instructionTable{
//            return recipe.instruction.count
//        }
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        
        if tableView == self.ingredientsTable{
            let cell : IngredientsDetails = tableView.dequeueReusableCell(withIdentifier: "ingredientIdentifier", for : indexPath) as! IngredientsDetails
            var strArr = recipe.ingridentsList[indexPath.section].components(separatedBy: "-")
            cell.ingName.text = strArr[0]
            cell.ingQuantity.text = strArr[1]
            
            cell.backgroundColor = UIColor.clear
            
            return cell
        }
        
        if tableView == self.instructionTable{
            cell = tableView.dequeueReusableCell(withIdentifier: "instructionIdentifier")!
            cell!.textLabel!.text = recipe.instruction[indexPath.section]
            cell!.textLabel!.lineBreakMode = NSLineBreakMode.byWordWrapping
            cell!.textLabel!.numberOfLines = 0
            cell!.backgroundColor = UIColor.white
            cell?.backgroundColor = UIColor.clear
        }
        return cell!
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = UIColor.clear
    }
    
    // Set the spacing between sections
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == self.instructionTable {
            return cellSpacingHeight
        }
        return 0
    }
    
    @IBAction func shareClicked(_ sender: UIButton) {
        let activityVC = UIActivityViewController(activityItems:["www.google.com"], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = self.view
        
        self.present(activityVC, animated: true, completion: nil)
    }
    
    
    
    @IBAction func backBtn(_ sender: UIBarButtonItem) {
        
        dismiss(animated: true, completion: nil)
    }
    
    func viewAlert (msg: String){
        let alertController  = UIAlertController(title: "Alert Info", message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(action)
        self.present(alertController, animated: true, completion : nil)
    }
    
    @IBAction func exportIngList(_ sender: UIButton) {
        var ref: DatabaseReference!
        ref = Database.database().reference()
        
        if Auth.auth().currentUser != nil{
           let userId = Auth.auth().currentUser?.uid
            ref.child("UserShopList").child(String(describing: userId!)).child(recipe.recipeName).setValue(["shopList": recipe.ingridentsList])
            viewAlert(msg: "successfully exported ingredients")
        }
        
        
        
        
        
    }
    
    @IBAction func addFav(_ sender: UIBarButtonItem) {
        if sender.image == UIImage(named:"like.png"){
            if Auth.auth().currentUser != nil {
                // User is signed in.
                sender.image = UIImage(named:"fillLike.png")
                let userId = Auth.auth().currentUser?.uid
                addToFavourite(userId : userId!)
                print("Recipe added to favourites")
                return
            } else {
                // No user is signed in.
                self.performSegue(withIdentifier: "favToLoginSegue", sender: self)
                //self.viewAlert(msg: "Please login before adding to favourites")
            }
            
        }
        
        if sender.image == UIImage(named:"fillLike.png"){
            if Auth.auth().currentUser != nil {
                sender.image = UIImage(named:"like.png")
                let userId = Auth.auth().currentUser?.uid
                removeFromFavourites(userId: userId!)
                return
            }else {
                // No user is signed in.
                
                //self.viewAlert(msg: "Please login before adding to favourites")
                
            }
        }
    }
    
    func addToFavourite(userId : String){
        var ref: DatabaseReference!
        ref = Database.database().reference()
        var ings : String = ""
        
        ref.child("Recipes").child(String(recipe.recipeId)).setValue(["RecipeName":recipe.recipeName,"RecipeIngridientsList":recipe.ingridentsList,"RecipeInstruction":recipe.instruction,"RecipeImageURL":recipe.imageUrl,"RecipeRating": recipe.recipeRating,"RecipeServings":recipe.servings,"RecipePrepTime":recipe.preparationMin])
        ref.child("UserFavourites").child(userId).child(String(recipe.recipeId)).setValue(["RecipeName":recipe.recipeName])
    }
    
    func removeFromFavourites(userId : String){
        var ref: DatabaseReference!
        ref = Database.database().reference()
        
        ref.child("UserFavourites").child(userId).child(String(recipe.recipeId)).removeValue()
    }
    
    
    @IBAction func startTimerBtnTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "timerSegue", sender: self)
        
    }
    
    @objc func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(RecipeDetailsController.updateTimer)), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer() {
        if seconds! < 1 {
            timer.invalidate()
            self.playSound()
            //Send alert to indicate "time's up!"
        } else {
            seconds = seconds! -  1
            timerLabel.text = timeString(time: TimeInterval(seconds!))
        }
    }
    
    func timeString(time:TimeInterval) -> String {
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i", minutes, seconds)
    }
    
    func playSound() {
        guard let url = Bundle.main.url(forResource: "ChillingMusic", withExtension: "wav") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            
            
            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            //player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            
            // iOS 10 and earlier require the following line:
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.wav.rawValue)
            
            guard let player = player else { return }
            
            player.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
   
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "favToLoginSegue" {
            if let controller = segue.destination as? Login{
                controller.fromFav = true
                controller.favRecipe = recipe
            }
        }
        if segue.identifier == "youtubeSegue" {
            if let controller = segue.destination as? YouTubeViewController{
                controller.recipeName = recipe.recipeName
            }
        }
        if segue.identifier == "timerSegue" {
            if let controller = segue.destination as? TimerController{
                print("***\(recipe.recipeName)")
                controller.recipe = recipe
            }
        }
        
    }
    
}
