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
    var restingBPM: CGFloat
    
    init(_ userInfo: [String: Any]) {
        self.validInformation = userInfo["ValidInformation"] as? Bool ?? false
        self.name = userInfo["Name"] as? String ?? ""
        self.age = userInfo["Age"] as? String ?? ""
        self.gender = userInfo["Gender"] as? String ?? ""
        self.weight = userInfo["Weight"] as? String ?? ""
        self.restingBPM = userInfo["BPM"] as? CGFloat ?? 0
    }
    
    static func fetchUserInformation() -> UserInformation? {
        if let userInfoData = UserDefaults.standard.object(forKey: "UserInformation") as? Data {
            let decoder = JSONDecoder()
            if let userInformation = try? decoder.decode(UserInformation.self, from: userInfoData) {
                return userInformation
            }
            return nil
        }
        return nil
    }
    
    func updateUserInformation() -> Bool {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(self) {
            UserDefaults.standard.set(encoded, forKey: "UserInformation")
            return true
        }
        return false
    }
    
    func getConstantsForCalorieCalculation() -> (age: CGFloat, weight: CGFloat, heartRate: CGFloat, constant: CGFloat) {
        switch self.gender {
        case "Male":
            return (0.2017, 0.1988, 0.6309, 55.0969)
        case "Female":
            return (0.074, 0.1988, 0.4472, 20.4022)
        default: return (0, 0, 0, 0)
        }
    }
}
