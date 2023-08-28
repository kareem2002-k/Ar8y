//
//  LikeManager.swift
//  Ar8y
//
//  Created by Kareem Ahmed on 25/08/2023.
//

import Foundation
import Alamofire
class LikeToggle {
    
    static let shared = LikeToggle()
    
    func Like(authtoken : String ,tweetID : String,completion: @escaping ( Bool) -> Void) {
        
        // Define the API endpoint URL
        let apiUrl = "http://192.168.1.13:8000/like/\(tweetID)" // Replace with your actual API URL
        
        // Define the headers with the authentication token
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(authtoken)"
        ]
        
        // Make the GET request
        AF.request(apiUrl, method: .post, headers: headers)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                switch response.result {
                case .success:
                    
                    print("User liked or unliked the post ")
                    completion(true)
                case .failure(let error):
                    print("Error liking or un liking")
                    completion(false)
                }
            }
        
    }
    
    
}
