//
//  userAuthSystem.swift
//  Ar8y
//
//  Created by Kareem Ahmed on 20/08/2023.
//

import Foundation
import Alamofire

class UserAuth {
    
    static let shared = UserAuth()
    
    var CurrentUser : User!
    
    var isAuth : Bool = false

    
    
    func Login (username : String, password :String ,completion: @escaping (Bool) -> Void)  {
        
        let loginURL = "http://localhost:8000/login"
        let parameters: [String: Any] = ["username": username, "password": password]
        AF.request(loginURL, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                switch response.result {
                case .success:
                    if let token = response.response?.allHeaderFields["Authorization"] as? String {
                        print("done auth ")
                        TokenManager.shared.saveToken(token)
                        completion(true)
                    }
                case .failure(let error):
                    print("Error: \(error)")
                    completion(false)
                    if let responseData = response.data {
                        do {
                            if let json = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any] {
                                print("Error JSON: \(json)")
                            } else {
                                print("Error response is not in JSON format.")
                                // You can print responseData as plain text here if needed
                            }
                        } catch {
                            print("Error parsing error response: \(error)")
                            print("Raw Data: \(responseData)")
                        }
                    }
                    
                }
            }
        
    }
    
    
    

    
    
    
    
    
    func Register (email : String, password :String , firstname : String , lastname : String ,completion: @escaping (Bool) -> Void) {
        
        let loginURL = "http://localhost:8000/register"
        let parameters: [String: Any] = ["email": email, "password": password ,"fullname" : "\(firstname) \(lastname)"]
        
        
        AF.request(loginURL, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                switch response.result {
                case .success:
                    if let token = response.response?.allHeaderFields["Authorization"] as? String {
                        print("done auth ")
                        TokenManager.shared.saveToken(token)
                        completion(true)
                    }
                case .failure(let error):
                    print("Error: \(error)")
                    completion(false)
                    if let responseData = response.data {
                        do {
                            if let json = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any] {
                                print("Error JSON: \(json)")
                            } else {
                                print("Error response is not in JSON format.")
                                // You can print responseData as plain text here if needed
                            }
                        } catch {
                            print("Error parsing error response: \(error)")
                            print("Raw Data: \(responseData)")
                        }
                    }
                    
                }
            }
    }

    func Logout (completion: @escaping (Bool) -> Void){
        let loginURL = "http://localhost:8000/logout"
        
        AF.request(loginURL, method: .post, encoding: JSONEncoding.default)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                switch response.result {
                case .success:
                    TokenManager.shared.removeToken()
                    print("User loged out")
                    completion(true)
                    UserAuth.shared.CurrentUser = nil
                    completion(true)
                    
                case .failure(let error):
                    print("Error: \(error)")
                    completion(false)
                    if let responseData = response.data {
                        do {
                            if let json = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any] {
                                print("Error JSON: \(json)")
                            } else {
                                print("Error response is not in JSON format.")
                                // You can print responseData as plain text here if needed
                            }
                        } catch {
                            print("Error parsing error response: \(error)")
                            print("Raw Data: \(responseData)")
                        }
                    }
                    
                }
            }
    }
    
}
