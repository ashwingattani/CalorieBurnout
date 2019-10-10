//
//  ViewController.swift
//  CalorieBurnout
//
//  Created by Ashwin Gattani on 25/09/19.
//  Copyright © 2019 Ashwin Gattani. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var heartBeatLabel: UILabel!
    @IBOutlet weak var calorieCountLabel: UILabel!
    @IBOutlet weak var waitingMessageLabel: UILabel!
    
    static let identifier = "HomeViewController"

    override func viewDidLoad() {
        super.viewDidLoad()
            
    }
    
    @IBAction func detectBPM(_ sender: Any) {
        let hrk = HeartRateKitController.init()
        hrk.delegate = self
        self.present(hrk, animated: true, completion: nil)
    }
}

extension HomeViewController: HeartRateKitControllerDelegate {
    func heartRateKitController(_ controller: HeartRateKitController, didFinishWith result: HeartRateKitResult) {
        self.dismiss(animated: true) {
            self.heartBeatLabel.text = String(format: "%.2f", result.bpm)
        }
        
    }
    
    func heartRateKitControllerDidCancel(_ controller: HeartRateKitController) {
        self.dismiss(animated: true) {
            self.heartBeatLabel.text = "__.__"
            self.calorieCountLabel.text = "__.__"
        }
    }
}

