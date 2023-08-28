//
//  MainStruct.swift
//  Ar8y
//
//  Created by Kareem Ahmed on 21/08/2023.
//

import Foundation

struct TweetPost : Codable {
    var Content : String?
    var LikesCount : Int
    var RepliesCount : Int
    var RetweetsCount : Int
    var PublishedAt : String
    var AuthorName : String
    var AuthorUsername : String
    var AuthorID : Int
    var Liked : Bool
    var Retweeted : Bool
    var tweetID : Int
    
    
    enum CodingKeys: String, CodingKey {
        case Content = "content"
        case LikesCount = "likes_count"
        case RepliesCount = "replies_count"
        case RetweetsCount = "retweets_count"
        case PublishedAt = "published_at"
        case AuthorName = "author_name"
        case AuthorUsername = "author_username"
        case AuthorID = "author_id"
        case Liked = "liked"
        case Retweeted = "retweeted"
        case tweetID = "tweet_id"
    }
}



struct TweetPostRespnse: Codable {
    let tweets: [TweetPost]?
}


struct ReplyPost : Codable {
    var Content : String?
    var PublishedAt : String
    var AuthorName : String
    var AuthorUsername : String
    var AuthorID : Int
    
    
    enum CodingKeys: String, CodingKey {
        case Content = "content"
        case PublishedAt = "published_at"
        case AuthorName = "author_name"
        case AuthorUsername = "author_username"
        case AuthorID = "author_id"
    }
}


struct ReplyPostResponse: Codable {
    let replies: [ReplyPost]?
}




struct UserProfiLe : Codable {
    var ID : Int
    var Username : String
    var FullName : String
    var Bio : String
    var NumbOfFollowers : Int
    var NumbOfFollowing : Int
    var IsFollowedByAuthUser : Bool

    
    enum CodingKeys: String, CodingKey {
        case ID = "id"
        case Username = "username"
        case FullName = "full_name"
        case Bio = "bio"
        case NumbOfFollowers = "numb_of_followers"
        case NumbOfFollowing = "numb_of_following"
        case IsFollowedByAuthUser = "is_followed_by_auth_user"
     
    }
}



struct UserProfiLeRespnse: Codable {
    let user: UserProfiLe?
}
