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
        let apiUrl = "http://192.168.1.13:8000/homePage" // Replace with your actual API URL
        
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
    
    
    
    
    func fetchReplies(for tweetID: Int, authtoken: String, completion: @escaping (Bool, [ReplyPost]?) -> Void) {
        // Define the API endpoint URL
        let apiUrl = "http://192.168.1.13:8000/getReply/\(tweetID)" // Replace with your actual API URL
        
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
                            let replyResponse = try JSONDecoder().decode(ReplyPostResponse.self, from: responseData)
                            let replies = replyResponse.replies ?? []
                            completion(true, replies)
                        } catch {
                            print("Error decoding reply data: \(error)")
                            completion(false, nil)
                        }
                    } else {
                        completion(false, nil)
                    }
                    
                case .failure(let error):
                    print("Error fetching reply data: \(error)")
                    completion(false, nil)
                }
            }
    }

    
    
    func AddReply (for tweetID: Int, authtok : String ,content : String , completion: @escaping (Bool) -> Void)  {
        
        let loginURL = "http://192.168.1.13:8000/reply/\(tweetID)"
        let parameters: [String: Any] = ["content": content]
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(authtok)"
        ]
        
        
        AF.request(loginURL, method: .post,parameters: parameters, encoding: JSONEncoding.default , headers: headers)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                switch response.result {
                case .success:
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
    
    
    

    
    
    
    
    
    func Register (email : String, password :String , firstname : String , lastname : String ,completion: @escaping (Bool) -> Void) {
        
        let loginURL = "http://192.168.1.13:8000/register"
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

}
