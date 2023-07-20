package databaseconnection

import (
	"log"

	"ar8y/server/models"

	"gorm.io/driver/mysql"
	"gorm.io/gorm"
)

var dB *gorm.DB

func Connect() {

	// connecting to the mysql database using gorm
	con, err := gorm.Open(mysql.Open("root:12345678@/ar8y"), &gorm.Config{})
	if err != nil {
		log.Fatalf("Error connecting to database: %v", err)
		panic(err)
	}

	// assign the connection to the global variable
	dB = con

	// migrate the models
	errors := con.AutoMigrate(&models.User{}, &models.Tweet{}, &models.Like{}, &models.Reply{}, &models.Follower{}, &models.Bookmark{}, &models.Hashtag{}, &models.Retweet{})
	if errors != nil {
		log.Fatalf("failed to auto migrate: %v", err)
	}

	// Create the many-to-many association table between tweets and hashtags
	con.Exec("CREATE TABLE IF NOT EXISTS tweet_hashtags (tweet_id bigint(20) NOT NULL, hashtag_id bigint(20) NOT NULL)")
	con.Exec("ALTER TABLE tweet_hashtags ADD CONSTRAINT fk_tweet FOREIGN KEY (tweet_id) REFERENCES tweets(id) ON DELETE CASCADE ON UPDATE CASCADE")
	con.Exec("ALTER TABLE tweet_hashtags ADD CONSTRAINT fk_hashtag FOREIGN KEY (hashtag_id) REFERENCES hashtags(id) ON DELETE CASCADE ON UPDATE CASCADE")
	con.Exec("ALTER TABLE tweet_hashtags ADD CONSTRAINT uc_tweet_hashtag UNIQUE (tweet_id, hashtag_id)")

}

func GetDB() *gorm.DB {
	return dB
}

func Close() {
	db, err := dB.DB()
	if err != nil {
		log.Fatalf("Error closing database: %v", err)
		panic(err)
	}

	db.Close()
}
