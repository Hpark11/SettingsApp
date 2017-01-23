//
//  ViewController.swift
//  Settings
//
//  Created by connect on 2017. 1. 21..
//  Copyright © 2017년 boostcamp. All rights reserved.
//

import UIKit
import MediaPlayer

class SettingsMainViewController: UIViewController, UIViewControllerTransitioningDelegate {

    @IBOutlet weak var firstButton: UIButton!
    @IBOutlet weak var secondButton: UIButton!
    @IBOutlet weak var thirdButton: UIButton!
    @IBOutlet weak var fourthButton: UIButton!
    
    let transition = PopAnimator()
    var selectedButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        
        let defaults = UserDefaults.standard
        let name = defaults.string(forKey: "user_name")
        print(name as Any)
    }
    
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let detailController = segue.destination as? SettingsDetailViewController {
            detailController.transitioningDelegate = self
            detailController.modalPresentationStyle = .custom
            detailController.receivedTagNumber = sender as? Int
        }
    }
    
    @IBAction func handleButton(_ sender: UIButton) {
        self.selectedButton = sender
        if sender != thirdButton {
            self.performSegue(withIdentifier: "settingsDetail", sender: sender.tag)
        } else {
            UIApplication.shared.open(URL(string:UIApplicationOpenSettingsURLString)!, options: [:]) { (success) in
                if success {
                    print("settings opened")
                }
            }
        }
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .Present
        transition.origin = selectedButton.center
        transition.circleColor = selectedButton.tintColor!
        return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .Dismiss
        transition.origin = selectedButton.center
        transition.circleColor = selectedButton.tintColor!
        return transition
    }
}

