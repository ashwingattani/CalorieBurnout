//
//  File.swift
//  CalorieBurnout
//
//  Created by Ashwin Gattani on 26/09/19.
//  Copyright © 2019 Ashwin Gattani. All rights reserved.
//

import Foundation

struct UserInformation: Codable {
    var validInformation: Bool
    var name: String
    var age: String
    var gender: String
    var weight: String
    
    init(_ userInfo: [String: Any]) {
        self.validInformation = userInfo["ValidInformation"] as? Bool ?? false
        self.name = userInfo["Name"] as? String ?? ""
        self.age = userInfo["Age"] as? String ?? ""
        self.gender = userInfo["Gender"] as? String ?? ""
        self.weight = userInfo["Weight"] as? String ?? ""
    }
    
    static func fetchUserInformationPlist() -> UserInformation? {
        
    }
    
    func updateUserInformationPlist() -> Bool {
        
    }
}
