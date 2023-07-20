package models

import "time"

type User struct {
	ID             uint `gorm:"primaryKey"`
	Username       string
	Email          string
	Password       string
	FullName       string
	Bio            string
	ProfilePicture string
	CreatedAt      time.Time
	Tweets         []Tweet    `gorm:"foreignKey:CreatedBy"`
	Followers      []Follower `gorm:"foreignKey:FollowedUserID"`
	Following      []Follower `gorm:"foreignKey:FollowerUserID"`
	Likes          []Like
	Bookmarks      []Bookmark
}

type Tweet struct {
	ID        uint `gorm:"primaryKey"`
	Content   string
	CreatedBy uint
	CreatedAt time.Time
	User      User `gorm:"foreignKey:CreatedBy"`
	Likes     []Like
	Replies   []Reply
	Retweets  []Retweet
	Hashtags  []Hashtag `gorm:"many2many:tweet_hashtags;"`
}

type Like struct {
	ID        uint `gorm:"primaryKey"`
	UserID    uint
	TweetID   uint
	CreatedAt time.Time
	User      User  `gorm:"foreignKey:UserID"`
	Tweet     Tweet `gorm:"foreignKey:TweetID"`
}

type Reply struct {
	ID        uint `gorm:"primaryKey"`
	Content   string
	UserID    uint // the user who is replying
	TweetID   uint // the tweet that is being replied to
	CreatedAt time.Time
	User      User  `gorm:"foreignKey:UserID"`
	Tweet     Tweet `gorm:"foreignKey:TweetID"`
}

type Follower struct {
	ID             uint `gorm:"primaryKey"`
	FollowerUserID uint // the user who is following
	FollowedUserID uint // the user who is being followed
	CreatedAt      time.Time
	FollowerUser   User `gorm:"foreignKey:FollowerUserID"` // the user who is following
	FollowedUser   User `gorm:"foreignKey:FollowedUserID"` // the user who is being followed
}

type Bookmark struct {
	ID        uint `gorm:"primaryKey"`
	UserID    uint
	TweetID   uint
	CreatedAt time.Time
	User      User  `gorm:"foreignKey:UserID"`
	Tweet     Tweet `gorm:"foreignKey:TweetID"`
}

type Hashtag struct {
	ID        uint `gorm:"primaryKey"`
	Name      string
	CreatedAt time.Time
	Tweets    []Tweet `gorm:"many2many:tweet_hashtags;"`
}

type Retweet struct {
	ID        uint `gorm:"primaryKey"`
	UserID    uint
	TweetID   uint
	CreatedAt time.Time
	User      User  `gorm:"foreignKey:UserID"`
	Tweet     Tweet `gorm:"foreignKey:TweetID"`
}
