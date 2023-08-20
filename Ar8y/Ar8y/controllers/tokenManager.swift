//
//  tokenManager.swift
//  Ar8y
//
//  Created by Kareem Ahmed on 20/08/2023.
//

import Foundation
class TokenManager {
   
        static let shared = TokenManager()
        
        private let tokenKey = "AuthToken"
        private let defaults = UserDefaults.standard
        
        // Store the token in UserDefaults
        func saveToken(_ token: String) {
            defaults.set(token, forKey: tokenKey)
        }
        
        // Retrieve the token from UserDefaults
        func getToken() -> String? {
            return defaults.string(forKey: tokenKey)
        }
        
        // Remove the token from UserDefaults
        func removeToken() {
            defaults.removeObject(forKey: tokenKey)
        }
    

}
