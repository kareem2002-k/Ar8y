//
//  UserPosts.swift
//  Ar8y
//
//  Created by Kareem Ahmed on 21/08/2023.
//
import Foundation
import Alamofire

class UserPosts {
    
    static let shared = UserPosts()
    
    
    func fetchUserData(authtoken : String,completion: @escaping (Bool, [TweetPost]?) -> Void) {
        
        // Define the API endpoint URL
        let apiUrl = "http://localhost:8000/homePage" // Replace with your actual API URL
        
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
