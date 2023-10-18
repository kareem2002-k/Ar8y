//
//  ProfileData.swift
//  Ar8y
//
//  Created by Kareem Ahmed on 28/08/2023.
//

import Foundation
import Alamofire

class ProfileData {
    
    static let shared = ProfileData()

    
    
    func fetchUserData(for userID: Int, authtoken: String, completion: @escaping (Bool, UserProfiLe?) -> Void) {
        // Define the API endpoint URL
        let apiUrl = "http://localhost:8000/getUser/\(userID)" // Replace with your actual API URL
        
        // Define the headers with the authentication token
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(authtoken)"
        ]
        
        // Make the GET request
        AF.request(apiUrl, headers: headers)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                switch response.result {
                case .success:
                    if let responseData = response.data {
                        do {
                            let userResp = try JSONDecoder().decode(UserProfiLeRespnse.self, from: responseData)
                            let userProfile = userResp.user
                            completion(true, userProfile)
                        } catch {
                            print("Error decoding user data: \(error)")
                            completion(false, nil)
                        }
                    } else {
                        completion(false, nil)
                    }
                    
                case .failure(let error):
                    print("Error fetching user data: \(error)")
                    completion(false, nil)
                }
            }
    }
    
    
    
    
    
    
    
    func fetchUserTweets(userId : String ,authtoken : String,completion: @escaping (Bool, [TweetPost]?) -> Void) {
        
        // Define the API endpoint URL
        let apiUrl = "http://localhost:8000/getTweets/\(userId)" // Replace with your actual API URL
        
        // Define the headers with the authentication token
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(authtoken)"
        ]
        
        // Make the GET request
        AF.request(apiUrl, headers: headers)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                switch response.result {
                case .success:
                    if let responseData = response.data {
                        do {
                            let Resp = try JSONDecoder().decode(TweetPostRespnse.self, from: responseData)
                            let tweets = Resp.tweets
                            completion(true,tweets)
                        } catch {
                            print("Error decoding user data: \(error)")
                            completion(false, nil)
                        }
                    } else {
                        completion(false, nil)
                    }
                    
                case .failure(let error):
                    print("Error fetching user data: \(error)")
                    completion(false, nil)
                }
            }
        
    }
    
    
    
    func fetchAuthUserProfile(authtoken : String,completion: @escaping (Bool, UserProfiLe?) -> Void) {
        
            // Define the API endpoint URL
            let apiUrl = "http://localhost:8000/getAuthUserdata" // Replace with your actual API URL
            
            // Define the headers with the authentication token
            let headers: HTTPHeaders = [
                "Authorization": "Bearer \(authtoken)"
            ]
            
            // Make the GET request
            AF.request(apiUrl, headers: headers)
                .validate(statusCode: 200..<300)
                .responseJSON { response in
                    switch response.result {
                    case .success:
                        if let responseData = response.data {
                            do {
                                let userResp = try JSONDecoder().decode(UserProfiLeRespnse.self, from: responseData)
                                let userProfile = userResp.user
                                completion(true, userProfile)
                            } catch {
                                print("Error decoding user data: \(error)")
                                completion(false, nil)
                            }
                        } else {
                            completion(false, nil)
                        }
                        
                    case .failure(let error):
                        print("Error fetching user data: \(error)")
                        completion(false, nil)
                    }
                }
        
    }
    
    func fetchMyTweets(authtoken : String,completion: @escaping (Bool, [TweetPost]?) -> Void) {
        
        // Define the API endpoint URL
        let apiUrl = "http://localhost:8000/getMyTweets" // Replace with your actual API URL
        
        // Define the headers with the authentication token
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(authtoken)"
        ]
        
        // Make the GET request
        AF.request(apiUrl, headers: headers)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                switch response.result {
                case .success:
                    if let responseData = response.data {
                        do {
                            let Resp = try JSONDecoder().decode(TweetPostRespnse.self, from: responseData)
                            let tweets = Resp.tweets
                            
                            completion(true,tweets)
                        } catch {
                            print("Error decoding user data: \(error)")
                            completion(false, nil)
                        }
                    } else {
                        completion(false, nil)
                    }
                    
                case .failure(let error):
                    print("Error fetching user data: \(error)")
                    completion(false, nil)
                }
            }
        
    }
    

    
    
    
}
