//
//  SystemStructs.swift
//  Ar8y
//
//  Created by Kareem Ahmed on 20/08/2023.
//

import Foundation

struct User : Codable {
    var ID: Int
    var Username: String
    var Email: String
    var Bio : String?
    var FullName: String?
    var CreatedAt: String
    var BirthDate: String?
    var Tweets : [Tweet]?
    var Followers : [Follower]?
    var Following : [Follower]?
    var Likes : [Like]?
    var Bookmarks : [Bookmark]?
   
    enum CodingKeys: String, CodingKey {
        case ID = "id"
        case Email = "email"
        case Username = "username"
        case FullName = "full_name"
        case Bio = "bio"
        case CreatedAt = "created_at"
        case BirthDate = "birth_date"
        case Tweets = "tweets"
        case Followers = "followers"
        case Following = "following"
        case Likes = "likes"
        case Bookmarks = "bookmarks"
        
    }
}


struct UserResponse: Codable {
    let user: User
}




struct SearchRespones: Codable {
    let users: [UserProfiLe]
}

struct  Follower : Codable {
    var ID: Int
    var FollowerUserID: Int
    var FollowedUserID: Int
    var CreatedAt : String
    var FollowerUser : User?
    var FollowedUser : User?

     enum CodingKeys: String, CodingKey {
         case ID = "id"
         case FollowerUserID = "follower_user_id"
         case FollowedUserID = "followed_user_id"
         case CreatedAt = "created_at"
         case FollowerUser = "follower_user"
         case FollowedUser = "followed_user"
        
     }
}


struct Tweet : Codable {
    var  ID : Int
    var  Content : String
    var  CreatedBy : Int
    var CreatedAt : String
    var User : User?
    var Likes : [Like]?
    var Replies : [Reply]?
    var Retweets : [Retweet]?
    var Hashtags : [Hashtag]?
    
   

    enum CodingKeys: String, CodingKey {
        case ID = "id"
        case Content = "content"
        case CreatedBy = "created_by"
        case CreatedAt = "created_at"
        case User = "user"
        case Likes = "likes"
        case Replies = "replies"
        case Hashtags = "hashtags"
        case Retweets = "retweets"
        
    }
       
}
 

struct Like : Codable {
    var  ID : Int
    var  UserID : Int
    var  TweetID : Int
    var CreatedAt : String
    var User : User?
    var Tweet : Tweet?
    
    enum CodingKeys: String, CodingKey {
        case ID = "id"
        case UserID = "user_id"
        case TweetID = "tweet_id"
        case CreatedAt = "created_at"
        case User = "user"
        case Tweet = "tweet"
    }
}


struct Reply : Codable {
    var  ID : Int
    var Content : String
    var  UserID : Int
    var  TweetID : Int
    var CreatedAt : String
    var User : User?
    var Tweet : Tweet?
    
    enum CodingKeys: String, CodingKey {
        case ID = "id"
        case UserID = "user_id"
        case TweetID = "tweet_id"
        case CreatedAt = "created_at"
        case User = "user"
        case Tweet = "tweet"
        case Content = "content"
    }
}

struct Retweet : Codable {
    var  ID : Int
    var  UserID : Int
    var  TweetID : Int
    var CreatedAt : String
    var User : User?
    var Tweet : Tweet?
    
    enum CodingKeys: String, CodingKey {
        case ID = "id"
        case UserID = "user_id"
        case TweetID = "tweet_id"
        case CreatedAt = "created_at"
        case User = "user"
        case Tweet = "tweet"
    }
    
}

struct Hashtag : Codable {
    var  ID : Int
    var  Name : String
    var  Tweets : [Tweet]?
    var CreatedAt : String
    
    enum CodingKeys: String, CodingKey {
        case ID = "id"
        case Name = "name"
        case CreatedAt = "created_at"
        case Tweets = "tweets"
    }
}



struct Bookmark : Codable {
    var  ID : Int
    var  UserID : Int
    var  TweetID : Int
    var CreatedAt : String
    var User : User?
    var Tweet : Tweet?
    
    enum CodingKeys: String, CodingKey {
        case ID = "id"
        case UserID = "user_id"
        case TweetID = "tweet_id"
        case CreatedAt = "created_at"
        case User = "user"
        case Tweet = "tweet"
    }
}
