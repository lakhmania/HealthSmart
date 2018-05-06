//
//  Login.swift
//  HealthSmart
//
//  Created by Nirali Merchant on 4/23/18.
//  Copyright © 2018 Apoorva Lakhmani. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
class Login: UIViewController, UITextFieldDelegate, FBSDKLoginButtonDelegate {
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var orLabel: UILabel!
    var userEmail:String = ""
    var loginFb:Bool = false
    var fromFav = false
    var favRecipe = Recipe()
    var fbImage = UIImage(named: "profilePhoto.jpg")
    var fbName = String()
    var fbEmail = String()
    var fbImageURL = String()
    var photoURL = URL(string: "")
    var userName = String()
    
    let loginButton: FBSDKLoginButton = {
        let button = FBSDKLoginButton()
        button.readPermissions = ["email"]
        return button
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        mainView.backgroundColor = UIColor(patternImage: UIImage(named: "backgroundImg.png")!)
        
        mainView.addSubview(loginButton)
        loginButton.center = mainView.center
        
        
        loginButton.delegate = self
        
        email.delegate = self
        password.delegate = self
        
        
        if (FBSDKAccessToken.current()) != nil{
            fetchFbUserProfile()
        }
        
        
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        email.resignFirstResponder()
        password.resignFirstResponder()
        
        return true
    }
    
    
    func fetchFbUserProfile(){
        let parameters = ["fileds": "email, first_name, last_name, picture.type(large)"]
        FBSDKGraphRequest(graphPath: "me?fields=id,first_name,picture.type(large),email", parameters: parameters).start { (connection, result, error) -> Void in
            
            if error != nil {
                print(error ?? "")
                return
            }
            
            if let json = result as? [String:Any] {
                self.fbName = (json["first_name"] as AnyObject? as? String)!
                let picture = json["picture"] as! [String:Any]
                let data = picture["data"] as! [String:Any]
                self.fbImageURL = data["url"] as! String
                self.fbEmail = json["email"] as? String ?? ""
                self.loadImageForUrl(url:self.fbImageURL )
                self.loadFBImageToStorage()
            }
        }
    }
    
    func loadImageForUrl(url:String){
        var request = URLRequest(url: NSURL(string: url)! as URL)
        request.httpMethod = "GET"
        do {
            // Perform the request
            let response: AutoreleasingUnsafeMutablePointer<URLResponse?>? = nil
            let data = try NSURLConnection.sendSynchronousRequest(request, returning: response)
            let image = UIImage(data: data)
            self.fbImage = image
        }catch{
            print("exception while loading recipes")
        }
    }
    
    func loadFBImageToStorage(){
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let photoRef = storageRef.child("images/" + fbEmail + ".png")
        guard let uploadData = UIImagePNGRepresentation(fbImage ?? UIImage(named: "profilePhoto.jpg")!)
            else{
                return
        }
        _ = photoRef.putData(uploadData, metadata: nil) { metadata, error in
            if let error = error {
                print(error.localizedDescription)
                self.viewAlert(msg: error as! String)
                return
            } else {
                self.photoURL = metadata!.downloadURL()
            }
        }
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!){
        print("completed fb login")
        
        let fbloginresult : FBSDKLoginManagerLoginResult = result
        if result.isCancelled {
            return
        }
        self.loginFb = true
        fetchFbUserProfile()
        signInFBUser()
        redirectFbUsertoMainPage()
        
        
    }
    
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!){
        FBSDKAccessToken.setCurrent(nil)
        FBSDKLoginManager().logOut()
        FBSDKProfile.setCurrent(nil)
        
        let fbLoginManager: FBSDKLoginManager = FBSDKLoginManager()
        fbLoginManager.loginBehavior = FBSDKLoginBehavior.web
    }
    
    func loginButtonWillLOgin(loginButton: FBSDKLoginButton!)-> Bool{
        return true
    }
    
    func redirectFbUsertoMainPage(){
        if self.loginFb == true {
            if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController1") as? ViewController
            {
                vc.image = self.fbImage!
                vc.loginButtonTitle =   self.fbName
                present(vc, animated: true, completion: nil)
            }
        }
    }
    
    func signInFBUser(){
        let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
        Auth.auth().signIn(with: credential) { (user, error) in
            if let error = error {
                self.viewAlert(msg: error.localizedDescription)
                return
            }
            self.photoURL = user?.photoURL
            if user != nil {
                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                changeRequest?.photoURL = self.photoURL
                changeRequest?.displayName = self.fbName
                changeRequest?.commitChanges { (error) in
                    if let error = error {
                        self.viewAlert(msg: error.localizedDescription)
                        return
                    }
                }
            }
        }
    }
    
    func viewAlert (msg: String){
        let alertController  = UIAlertController(title: "Alert Info", message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(action)
        self.present(alertController, animated: true, completion : nil)
    }
    
    @IBAction func login(_ sender: UIButton) {
        let email = self.email.text!
        let password = self.password.text!
        self.userEmail = email
        
        if self.email.text?.count == 0 {
            shakeOnEmpty(field: self.email)
        } else if self.password.text?.count == 0{
            shakeOnEmpty(field: self.password)
        } else {
            Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                if user != nil {
                    if self.fromFav == true {
                        self.performSegue(withIdentifier: "favAfterLoginIn", sender: self)
                    }else{
                        self.performSegue(withIdentifier: "loginHomeSegue", sender: self)
                    }
                }
                if let error = error {
                    print(error.localizedDescription)
                    self.viewAlert(msg: error.localizedDescription)
                    return
                }
            }
            changeUserProfile()
        }
    }
    
    func changeUserProfile(){
        let user  = Auth.auth().currentUser
        if let user = user{
            let changeRequest = user.createProfileChangeRequest()
            changeRequest.photoURL = self.photoURL
            changeRequest.displayName = self.userName
            changeRequest.commitChanges{(error) in
                if let error = error {
                    print(error.localizedDescription)
                    self.viewAlert(msg: error as! String)
                    return
                }
            }
        }
    }
    
    @IBAction func backButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    func  downlodProfilePhoto(controller : ViewController){
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let photoRef = storageRef.child("images/" + userEmail + ".png")
        print(photoRef)
        photoRef.getData(maxSize: 30 * 1024 * 1024) { data, error in
            if let error = error {
                self.viewAlert(msg: error.localizedDescription)
                return
            } else {
                let image = UIImage(data: data!)!
                controller.image = image
                print("retrieved")
                print(image.size)
            }
        }
    }
    
    @IBAction func forgotPassword(_ sender: UIButton) {
        if email.text?.count == 0 {
            shakeOnEmpty(field: email)
        }else{
            Auth.auth().sendPasswordReset(withEmail: email.text!) { error in
                if let error = error {
                    print(error.localizedDescription)
                    self.viewAlert(msg: error as! String)
                    return
                }
                self.viewAlert(msg: "Please check your mail for new password")
            }
        }
    }

    func shakeOnEmpty(field : UITextField){
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: field.center.x - 10, y: field.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: field.center.x + 10, y: field.center.y))
        
        field.layer.add(animation, forKey: "position")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "loginHomeSegue" {
            if let controller = segue.destination as? ViewController{
                downlodProfilePhoto(controller: controller)
                let storage = Storage.storage()
                let storageRef = storage.reference()
                let photoRef = storageRef.child("images/" + userEmail + ".png")
                print(photoRef)
                photoRef.getData(maxSize: 30 * 1024 * 1024) { data, error in
                    if let error = error {
                        self.viewAlert(msg: error.localizedDescription)
                        return
                    } else {
                        let image = UIImage(data: data!)!
                        controller.image = image
                        print("retrieved")
                        print(image.size)
                    }
                }
                controller.loginButtonTitle = "\(userName)"
            }
        }
        if segue.identifier == "favAfterLoginIn" {
            if let controller = segue.destination as? RecipeDetailsController{
                controller.recipe = favRecipe
            }
        }
    }
}
