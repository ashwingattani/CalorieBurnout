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
        if let userInfoData = UserDefaults.standard.object(forKey: "UserInformation") as? Data {
            let decoder = JSONDecoder()
            if let userInformation = try? decoder.decode(UserInformation.self, from: userInfoData) {
                return userInformation
            }
            return nil
        }
        return nil
    }
    
    func updateUserInformationPlist() -> Bool {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(self) {
            UserDefaults.standard.set(encoded, forKey: "UserInformation")
            return true
        }
        return false
    }
}
