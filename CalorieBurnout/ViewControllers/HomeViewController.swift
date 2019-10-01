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
        
        // Do any additional setup after loading the view.
    }
}

