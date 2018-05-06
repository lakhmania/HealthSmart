 //
 //  SignUp.swift
 //  HealthSmart
 //
 //  Created by Nirali Merchant on 4/22/18.
 //  Copyright © 2018 Apoorva Lakhmani. All rights reserved.
 //
 
 import UIKit
 import Firebase
 import FirebaseAuth
 import FirebaseStorage
 
 class SignUp: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate{
    
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var email: UITextField!
    
    let imagePicker = UIImagePickerController()
    var imagePath:String = ""
    var photoURL:URL?
    var name:String?
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "backgroundImg.png")!)
        
        photo.layer.cornerRadius = photo.frame.width/2
        photo.clipsToBounds = true
        uploadButton.layer.cornerRadius = uploadButton.frame.width/2
        uploadButton.clipsToBounds = true
        uploadButton.layer.borderColor = UIColor.black.cgColor
        uploadButton.layer.borderWidth = 0.5
        
        email.delegate = self
        password.delegate = self
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
    
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        let imageURL = info[UIImagePickerControllerReferenceURL] as! NSURL
        self.imagePath = imageURL.absoluteString!
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            photo?.contentMode = .scaleAspectFill
            photo?.image = pickedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func viewAlert (msg: String){
        let alertController  = UIAlertController(title: "Alert Info", message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(action)
        self.present(alertController, animated: true, completion : nil)
    }
    
    @IBAction func uploadPhoto(_ sender: UIButton) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    @IBAction func signupUser(_ sender: Any) {
        let email = self.email.text!
        let password = self.password.text!
        let userName = self.userName.text!
        self.name = userName
        
        if self.email.text?.count == 0{
            shakeOnEmpty(field: self.email)
        }else if self.password.text?.count == 0{
            shakeOnEmpty(field: self.password)
        }else if self.userName.text?.count == 0{
            shakeOnEmpty(field: self.userName)
        }else {
            if(email != "" || password != "" || userName != ""){
                Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
                    if let error = error {
                        print(error.localizedDescription)
                        self.viewAlert(msg: error as! String)
                        return
                    }
                }
            }
            self.performSegue(withIdentifier: "signupHomeSegue", sender:self)
        }
    
        
    }
    
    func uploadPhotoToStorage(email:String){
        var imgData: NSData?
        if photo != nil {
            imgData = UIImagePNGRepresentation((photo.image!)) as NSData?
            
            let storage = Storage.storage()
            let storageRef = storage.reference()
            let photoRef = storageRef.child("images/" + email + ".png")
            
            guard let uploadData = UIImagePNGRepresentation(photo.image!)
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
        
    }
    
    func uploadProfilePicture(controller : Login){
        var imgData: NSData?
        imgData = UIImagePNGRepresentation((photo.image!)) as! NSData
        let storage = Storage.storage()
        let storageRef = storage.reference()
       // print("Image Path:::::::\(imagePath)")
       // let localFile = URL(string: imagePath)!
        let photoRef = storageRef.child("images/" + email.text! + ".png")
        
        guard let uploadData = UIImagePNGRepresentation(photo.image!)
            else{
                return
        }
        let uploadTask = photoRef.putData(uploadData, metadata: nil) { metadata, error in
            if let error = error {
                print(error.localizedDescription)
                self.viewAlert(msg: error.localizedDescription)
                return
            } else {
                self.photoURL = metadata!.downloadURL()
                controller.photoURL = self.photoURL
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
        if segue.identifier == "signupHomeSegue" {
            if let controller = segue.destination as? Login{
                uploadProfilePicture(controller: controller)
                controller.userName = self.name!
            }
        }
    }
 }
 
 
