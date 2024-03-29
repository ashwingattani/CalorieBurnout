//
//  SetupViewController.swift
//  CalorieBurnout
//
//  Created by Ashwin Gattani on 25/09/19.
//  Copyright © 2019 Ashwin Gattani. All rights reserved.
//

import UIKit
import Foundation

class SetupViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var genderPicker: UIPickerView!
    @IBOutlet weak var heartbeatImage: UIImageView!
    @IBOutlet weak var restingBPM: UILabel!
    @IBOutlet weak var submitButton: UIButton!
    
    private var selectedGender = ""
    
    static let identifier = "SetupViewController"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.genderPicker.delegate = self
        self.genderPicker.dataSource = self
        
        self.view.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(dismissKeyboard)))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.genderPicker.selectRow(0, inComponent: 0, animated: true)
    }
    
    @IBAction func detectBPM(_ sender: Any) {
        let hrk = HeartRateKitController.init()
        hrk.delegate = self
        self.present(hrk, animated: true, completion: nil)
    }
    
    @IBAction func saveUserInformation(sender: Any) {
        guard let name = self.nameTextField.text, name.count > 0 else {
            self.showErrorPopup()
            return
        }
        
        guard let age = self.ageTextField.text, age.count > 0 else {
            self.showErrorPopup()
            return
        }
        
        guard let weight = self.weightTextField.text, weight.count > 0 else {
            self.showErrorPopup()
            return
        }
        
        if self.selectedGender.count == 0 {
            self.showErrorPopup()
            return
        }
        
        var userInfo: [String: Any] = [:]
        userInfo["ValidInformation"] = true
        userInfo["Name"] = name
        userInfo["Age"] = age
        userInfo["Gender"] = selectedGender
        userInfo["Weight"] = weight
        
        let _ = UserInformation.init(userInfo).updateUserInformation()
        
        let homeController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        self.present(homeController, animated: true, completion: nil)
    }
    
    func showErrorPopup() {
        let alertController = UIAlertController.init(title: "Alert", message: "All fields are mandatory", preferredStyle: .alert)
        let defaultAction = UIAlertAction.init(title: "Ok", style: .destructive, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }

}

extension SetupViewController: UIPickerViewDelegate, UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return row == 0 ? "Male" : "Female"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedGender = row == 0 ? "Male" : "Female"
    }
}

extension SetupViewController: HeartRateKitControllerDelegate {
    func heartRateKitController(_ controller: HeartRateKitController, didFinishWith result: HeartRateKitResult) {
        self.dismiss(animated: true) {
            self.restingBPM.text = String(format: "%.2f", result.bpm)
        }
        
    }
}
