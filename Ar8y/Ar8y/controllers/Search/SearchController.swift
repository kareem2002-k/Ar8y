//
//  SearchController.swift
//  Ar8y
//
//  Created by Kareem Ahmed on 28/08/2023.
//

import Foundation
import Alamofire

class SearchController {
    
    static let shared = SearchController()

    
    func Search(authtoken : String ,query : String,completion: @escaping ( Bool , [UserProfiLe]?) -> Void) {
        
        // Define the API endpoint URL
        let apiUrl = "http://localhost:8000/search?q=\(query)" // Replace with your actual API URL
        
        // Define the headers with the authentication token
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(authtoken)"
        ]
        
        // Make the GET request
        AF.request(apiUrl, method: .get, headers: headers)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                switch response.result {
                case .success:
                    if let responseData = response.data {
                        do {
                            let Resp = try JSONDecoder().decode(SearchRespones.self, from: responseData)
                            let users = Resp.users
                            
                            completion(true,users)
                        } catch {
                            print("Error decoding user data: \(error)")
                            completion(false, nil)
                        }
                    } else {
                        completion(false, nil)
                    }
                case .failure(let error):
                    print("Error fetching serached data \(error)")
                    completion(false,nil)
                }
            }
        
    }
    
}
