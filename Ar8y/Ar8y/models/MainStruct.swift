//
//  MainStruct.swift
//  Ar8y
//
//  Created by Kareem Ahmed on 21/08/2023.
//

import Foundation

struct TweetPost : Codable {
    var Content : String
    var LikesCount : Int
    var RepliesCount : Int
    var RetweetsCount : Int
    var PublishedAt : String
    var AuthorName : String
    var AuthorUsername : String
    var AuthorID : Int
    var Liked : Bool
    var Retweeted : Bool
    
    
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
    }
}



struct TweetPostRespnse: Codable {
    let tweets: [TweetPost]?
}





