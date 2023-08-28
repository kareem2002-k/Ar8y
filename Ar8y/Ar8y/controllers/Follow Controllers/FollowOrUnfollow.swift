//
//  FollowOrUnfollow.swift
//  Ar8y
//
//  Created by Kareem Ahmed on 28/08/2023.
//

import Foundation
import Alamofire
class FollowController {
    static let shared = FollowController()

    
    func FollowOrUnFollow(authtoken : String ,userID : String,completion: @escaping ( Bool) -> Void) {
        
        // Define the API endpoint URL
        let apiUrl = "http://192.168.1.13:8000/follow/\(userID)" // Replace with your actual API URL
        
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
                    
                    print("Followed or un Followed the user ")
                    completion(true)
                case .failure(let error):
                    print("Error Following or unfollowing")
                    completion(false)
                }
            }
        
    }
}
