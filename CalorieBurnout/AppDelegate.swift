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
        
        var propertyListFormat =  PropertyListSerialization.PropertyListFormat.xml
        var userInfoPlist: [String: AnyObject] = [:]
        let plistPath: String? = Bundle.main.path(forResource: "UserInformation", ofType: "plist")!
        let plistXML = FileManager.default.contents(atPath: plistPath!)!
        do {
            userInfoPlist = try PropertyListSerialization.propertyList(from: plistXML, options: .mutableContainersAndLeaves, format: &propertyListFormat) as! [String:AnyObject]

        } catch {
            print("Error reading plist: \(error), format: \(propertyListFormat)")
        }
        
        if false { //if let isUserInfoAvailable = userInfoPlist["ValidInformation"] as? Bool, isUserInfoAvailable {
//            let homeController = HomeViewController.init()
            let homeController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
            application.keyWindow?.rootViewController = homeController
        } else {
//            let setupController = SetupViewController.init()
            let setupController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SetupViewController") as! SetupViewController
            self.window?.rootViewController = setupController
        }
        
        return true
    }

}

