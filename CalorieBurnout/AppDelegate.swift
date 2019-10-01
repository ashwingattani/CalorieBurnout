//
//  AppDelegate.swift
//  CalorieBurnout
//
//  Created by Ashwin Gattani on 25/09/19.
//  Copyright © 2019 Ashwin Gattani. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow? = nil

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        if let userInfo = UserInformation.fetchUserInformationPlist(), userInfo.validInformation {
            let homeController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: HomeViewController.identifier) as! HomeViewController
            self.window?.rootViewController = homeController
        } else {
            let setupController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: SetupViewController.identifier) as! SetupViewController
            self.window?.rootViewController = setupController
        }
        
        return true
    }

}

