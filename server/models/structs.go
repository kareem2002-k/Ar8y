package models

type User struct {
	ID             uint       `gorm:"primaryKey" json:"id"`
	Username       string     `gorm:"unique" json:"username"`
	Email          string     `json:"email"`
	Password       []byte     `json:"-"`
	FullName       string     `json:"full_name"`
	Bio            string     `json:"bio"`
	ProfilePicture string     `json:"profile_picture"`
	BirthDate      string     `json:"birth_date"`
	CreatedAt      string     `json:"created_at"`
	Tweets         []Tweet    `gorm:"foreignKey:CreatedBy" json:"tweets"`
	Followers      []Follower `gorm:"foreignKey:FollowedUserID" json:"followers"`
	Following      []Follower `gorm:"foreignKey:FollowerUserID" json:"following"`
	Likes          []Like     `json:"likes"`
	Bookmarks      []Bookmark `json:"bookmarks"`
}

type Tweet struct {
	ID        uint      `gorm:"primaryKey" json:"id"`
	Content   string    `json:"content"`
	CreatedBy uint      `json:"created_by"`
	CreatedAt string    `json:"created_at"`
	User      User      `gorm:"foreignKey:CreatedBy" json:"user"`
	Likes     []Like    `json:"likes"` // delete likes when tweet is deleted
	Replies   []Reply   `json:"replies"`
	Retweets  []Retweet `json:"retweets"`
	Hashtags  []Hashtag `gorm:"many2many:tweet_hashtags;" json:"hashtags"`
}

type Like struct {
	ID        uint   `gorm:"primaryKey" json:"id"`
	UserID    uint   `json:"user_id"`
	TweetID   uint   `json:"tweet_id"`
	CreatedAt string `json:"created_at"`
	User      User   `gorm:"foreignKey:UserID" json:"user"`
	Tweet     Tweet  `gorm:"foreignKey:TweetID" json:"-"`
}

type Reply struct {
	ID        uint   `gorm:"primaryKey" json:"id"`
	Content   string `json:"content"`
	UserID    uint   `json:"user_id"`
	TweetID   uint   `json:"tweet_id"`
	CreatedAt string `json:"created_at"`
	User      User   `gorm:"foreignKey:UserID" json:"user"`
	Tweet     Tweet  `gorm:"foreignKey:TweetID" json:"tweet"`
}

type Follower struct {
	ID             uint   `gorm:"primaryKey" json:"id"`
	FollowerUserID uint   `json:"follower_user_id"` // the user who follows
	FollowedUserID uint   `json:"followed_user_id"` // the user who is followed
	CreatedAt      string `json:"created_at"`
	FollowerUser   User   `gorm:"foreignKey:FollowerUserID" json:"follower_user"`
	FollowedUser   User   `gorm:"foreignKey:FollowedUserID" json:"followed_user"`
}

type Bookmark struct {
	ID        uint   `gorm:"primaryKey" json:"id"`
	UserID    uint   `json:"user_id"`
	TweetID   uint   `json:"tweet_id"`
	CreatedAt string `json:"created_at"`
	User      User   `gorm:"foreignKey:UserID" json:"user"`
	Tweet     Tweet  `gorm:"foreignKey:TweetID" json:"tweet"`
}

type Hashtag struct {
	ID        uint    `gorm:"primaryKey" json:"id"`
	Name      string  `json:"name"`
	CreatedAt string  `json:"created_at"`
	Tweets    []Tweet `gorm:"many2many:tweet_hashtags;" json:"tweets"`
}

type Retweet struct {
	ID        uint   `gorm:"primaryKey" json:"id"`
	UserID    uint   `json:"user_id"`
	TweetID   uint   `json:"tweet_id"`
	CreatedAt string `json:"created_at"`
	User      User   `gorm:"foreignKey:UserID" json:"user"`
	Tweet     Tweet  `gorm:"foreignKey:TweetID" json:"tweet"`
}
