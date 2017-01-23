//
//  SettingsDetailViewController.swift
//  Settings
//
//  Created by connect on 2017. 1. 21..
//  Copyright © 2017년 boostcamp. All rights reserved.
//

import UIKit
import MediaPlayer


class SettingsDetailViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var selectedButton: UIButton!
    @IBOutlet weak var brightnessSlider: UISlider!
    @IBOutlet weak var volumeSlider: UISlider!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var schoolField: UITextField!
    @IBOutlet weak var ageSlider: UISlider!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var marriedSwitch: UISwitch!
    @IBOutlet weak var personalStackView: UIStackView!
    
    enum buttonType: Int {
        case goo1 = 0, goo2, goo3, goo4
    }
    
    var brightness:Float?
    var receivedTagNumber: Int?
    
    let volumeView = MPVolumeView()
    let userDefaults = UserDefaults()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.selectedButton.frame = CGRect(x: selectedButton.frame.origin.x, y:0, width: selectedButton.frame.size.width, height: selectedButton.frame.size.height)
        self.selectedButton.transform = CGAffineTransform.init(rotationAngle: (180.0 * CGFloat(M_PI)) / 180.0)
        
        if let brightness = self.brightness {
            brightnessSlider.value = brightness
        } else {
            brightnessSlider.value = Float(UIScreen.main.brightness)
        }
        
        self.nameField.delegate = self
        self.schoolField.delegate = self
        
        ageSlider.minimumValue = 1
        ageSlider.maximumValue = 100
        
        hideComponents()
    }

    override func viewWillAppear(_ animated: Bool) {
        presentSelectedButton(tagNumber: receivedTagNumber)
        subscribeToKeyboardNotifications()
        setBasicValueForPersonalInfo()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        unsubscribeFromKeyboardNotifications()
    }
    
    func presentSelectedButton(tagNumber:Int?) {
        var image: UIImage?
        var color: UIColor?
        if let number = receivedTagNumber {
            switch(buttonType(rawValue: number)!) {
            case .goo1:
                image = UIImage(named: "Brightness Detail")
                brightnessSlider.isEnabled = true
                brightnessSlider.isHidden = false
                color = UIColor(red: 229/255, green: 49/255, blue: 71/255, alpha: 1.0)
                break
            case .goo2:
                image = UIImage(named: "Volume Detail")
                volumeSlider.isEnabled = true
                volumeSlider.isHidden = false
                color = UIColor(red: 74/255, green: 144/255, blue: 226/255, alpha: 1.0)
                break
            case .goo3:
                image = UIImage(named: "Personal Info Detail")
                personalStackView.isHidden = false
                color = UIColor(red: 248/255, green: 231/255, blue: 28/255, alpha: 1.0)
                break
            case .goo4:
                image = UIImage(named: "Brightness Detail")
                color = UIColor(red: 80/255, green: 227/255, blue: 194/255, alpha: 1.0)
                break
            }
        }
        
        if let image = image {
            selectedButton.setImage(image, for: .normal)
            selectedButton.tintColor = UIColor.white
        }
        
        if let col = color {
            self.view.backgroundColor = col
        }
        
        animateSelectedButton()
    }
    
    func animateSelectedButton() {
        let frame = selectedButton.frame
        let size = selectedButton.frame.size
        UIView.animate(withDuration: 1.2) {
            self.selectedButton.frame = CGRect(x: frame.origin.x, y:self.view.frame.size.height / 3, width: size.width, height: size.height)
            self.selectedButton.transform = CGAffineTransform.init(rotationAngle: (CGFloat(M_PI)) / 180.0)
        }
    }
    
    func hideComponents() {
        brightnessSlider.isHidden = true
        brightnessSlider.isEnabled = false
        volumeSlider.isHidden = true
        volumeSlider.isEnabled = false
        personalStackView.isHidden = true
    }
    
    func setBasicValueForPersonalInfo() {
        let defaults = UserDefaults()
        
        nameField.text = defaults.object(forKey: "name") as? String
        schoolField.text = defaults.object(forKey: "school") as? String
        ageLabel.text = "Age : \(defaults.integer(forKey: "age"))"
        ageSlider.value = Float(defaults.integer(forKey: "age"))
        marriedSwitch.isOn = defaults.bool(forKey: "married")
    }
    
    override func encodeRestorableState(with coder: NSCoder) {
        if let brightness = self.brightness {
            coder.encode(brightness, forKey: "brightness")
        }
        
        if let tagNumber = self.receivedTagNumber {
            coder.encode(tagNumber, forKey: "tagNumber")
        }
        
        coder.encode(nameField.text, forKey: "name")
        coder.encode(schoolField.text, forKey: "school")
        coder.encode(marriedSwitch.isOn, forKey: "married")
        coder.encode(ageSlider.value, forKey: "age")
        super.encodeRestorableState(with: coder)
    }
    
    override func decodeRestorableState(with coder: NSCoder) {
        brightness = coder.decodeFloat(forKey: "brightness")
        receivedTagNumber = coder.decodeInteger(forKey: "tagNumber")
        nameField.text = coder.decodeObject(forKey: "name") as? String
        schoolField.text = coder.decodeObject(forKey: "school") as? String
        marriedSwitch.isOn = coder.decodeBool(forKey: "married")
        ageSlider.value = coder.decodeFloat(forKey: "age")
        ageLabel.text = "Age : \(Int(coder.decodeFloat(forKey: "age")))"
        
        super.decodeRestorableState(with: coder)
    }
    
    override func applicationFinishedRestoringState() {
    }
    
    
    // get keyboard height and shift the view from bottom to higher
    func keyboardWillShow(_ notification: Notification) {
        if nameField.isFirstResponder || schoolField.isFirstResponder {
            view.frame.origin.y = 0 - getKeyboardHeight(notification)
        }
    }
    
    func keyboardWillHide(_ notification: Notification) {
        if nameField.isFirstResponder || schoolField.isFirstResponder {
            view.frame.origin.y = 0
        }
    }
    
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        var newText: NSString = textField.text! as NSString
        newText = newText.replacingCharacters(in: range, with: string) as NSString
        
        if textField == nameField {
            userDefaults.set(newText, forKey: "name")
        }
        
        if textField == schoolField {
            userDefaults.set(newText, forKey: "school")
        }
        
        return true;
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func goBackButtonTapped(_ sender: Any) {
        UIView.animate(withDuration: 0.8) {
            self.selectedButton.transform = CGAffineTransform.init(rotationAngle: (60.0 * CGFloat(M_PI)) / 180.0)
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func brightnessSliderMoved(_ sender: UISlider) {
        if sender == brightnessSlider {
            UIScreen.main.brightness = CGFloat(sender.value)
        }
    }
    
    @IBAction func volumeSliderMoved(_ sender: UISlider) {
        if sender == volumeSlider {
            if let view = volumeView.subviews.first as? UISlider {
                view.value = sender.value
            }
        }
    }
    
    @IBAction func ageValueChanged(_ sender: UISlider) {
        userDefaults.set(Int(sender.value), forKey: "age")
        ageLabel.text = "Age : \(Int(sender.value))"
    }
    
    @IBAction func marriedValueChanged(_ sender: UISwitch) {
        userDefaults.set(sender.isOn, forKey: "married")
    }
}
