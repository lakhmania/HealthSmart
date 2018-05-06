//
//  TimerController.swift
//  HealthSmart
//
//  Created by Nirali Merchant on 4/28/18.
//  Copyright © 2018 Apoorva Lakhmani. All rights reserved.
//

import UIKit


class TimerController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate{
   
    
    
    @IBOutlet weak var pickerView: UIPickerView!
    
    @IBOutlet weak var selectionButton: UIButton!
   
    
    var pickOption:[String] = []
    var time:Int = 60
    var recipe:Recipe?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for index in 1...60 {
            pickOption.append(String(index))
        }
        
        print(recipe?.recipeName)
        

        pickerView.delegate = self
        pickerView.dataSource = self
        
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickOption.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String{
        return pickOption[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            self.time  = Int(pickOption[row])! * 60
        
    }
    
    @IBAction func donePressed(_ sender: UIButton) {
        performSegue(withIdentifier: "timeSelectedSegue", sender: self)
    }
    
    @IBAction func cancelPressed(_ sender: UIButton) {
        
        dismiss(animated: true, completion: nil)
    }
       override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "timeSelectedSegue" {
            if let controller = segue.destination as? RecipeDetailsController{
                print("****Time::::::::::\(time)")
                controller.seconds = time
                controller.timerSet = true
                controller.recipe = recipe!
            }
        }
     }
    
    
}
