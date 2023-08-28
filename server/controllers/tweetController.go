package controllers

import (
	"github.com/gofiber/fiber/v2"

	databaseConnection "ar8y/server/databaseConnection"
	"ar8y/server/models"

	"time"

	"errors"

	"gorm.io/gorm"

	"math"

	"fmt"
)

func PostTweet(c *fiber.Ctx) error {
	var data map[string]string

	// get the database connection
	var db = databaseConnection.GetDB()

	// get auth user data from locals
	user, ok := c.Locals("user").(models.User)
	if !ok {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"message": "Internal server error",
		})
	}

	if err := c.BodyParser(&data); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"message": "Error parsing body",
		})
	}

	// checking if the required fields are empty or not
	if data["content"] == "" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"message": "Content is required",
		})
	}

	// create the tweet
	tweet := models.Tweet{
		Content:   data["content"],
		CreatedAt: time.Now().Format("2006-01-02 15:04:05"),
		User:      user,
	}

	// check if the hashtags are empty or not and create them if they don't exist
	if data["hashtags"] != "" || data["hashtags"] != "[]" {
		for _, hashtagRune := range data["hashtags"] {
			// check if the hashtag exists in the database
			var hashtagM models.Hashtag
			hashtagString := string(hashtagRune)
			db.Where("name = ?", hashtagString).First(&hashtagM)

			if hashtagM.ID == 0 {
				// create the hashtag
				hashtagM = models.Hashtag{
					Name:      hashtagString,
					CreatedAt: time.Now().Format("2006-01-02 15:04:05"),
				}

				db.Create(&hashtagM)
			}

			// append the hashtag to the tweet
			tweet.Hashtags = append(tweet.Hashtags, hashtagM)
		}
	}

	// create the tweet in the database and check for errors
	if err := db.Create(&tweet).Error; err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"message": "Error creating tweet",
		})
	}

	// TODO: Validate the content

	return c.JSON(fiber.Map{
		"message": "Tweet created successfully",
		"userId":  user.ID,
		"tweet":   tweet,
	})

}

func GetTweetsOfAuthUser(c *fiber.Ctx) error {
	// get the database connection
	var db = databaseConnection.GetDB()

	// get auth user data from locals
	user, ok := c.Locals("user").(models.User)

	if !ok {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"message": "Internal server error",
		})
	}

	// Get the tweets of the user
	var tweets []models.Tweet

	// Get the tweets of the user from the database and check for errors
	if err := db.Preload("User").Preload("Likes.User").Preload("Likes.Tweet").Preload("Replies").Preload("Replies.User").Preload("Retweets").Preload("Hashtags").Where("created_by = ?", user.ID).Find(&tweets).Error; err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"message": "Error getting tweets",
		})
	}

	var tweetPosts []models.TweetPost

	// Create a map to track liked and retweeted tweets
	likedTweets := make(map[uint]bool)
	retweetedTweets := make(map[uint]bool)

	// Populate the liked and retweeted tweets maps
	for _, like := range user.Likes {
		likedTweets[like.TweetID] = true
	}

	currentTimestamp := time.Now().Unix()

	for _, tweet := range tweets {

		createdAt, _ := time.Parse("2006-01-02 15:04:05", tweet.CreatedAt)

		// Calculate the time difference in seconds
		timeDiff := currentTimestamp - createdAt.Unix()

		var publishedAtString string

		if timeDiff >= 86400 { // More than a day
			days := int(math.Floor(float64(timeDiff) / 86400))
			publishedAtString = fmt.Sprintf("%dd", days)
		} else if timeDiff >= 3600 { // More than an hour
			hours := int(math.Floor(float64(timeDiff) / 3600))
			publishedAtString = fmt.Sprintf("%dh", hours)
		} else if timeDiff >= 60 { // More than a minute
			minutes := int(math.Floor(float64(timeDiff) / 60))
			publishedAtString = fmt.Sprintf("%dmin", minutes)
		} else { // Less than a minute
			publishedAtString = "Just now"
		}

		tweetPost := models.TweetPost{
			Content:        tweet.Content,
			AuthorName:     tweet.User.FullName,
			AuthorUsername: tweet.User.Username,
			AuthorID:       tweet.User.ID,
			LikesCount:     len(tweet.Likes),
			RepliesCount:   len(tweet.Replies),
			RetweetsCount:  len(tweet.Retweets),
			TweetID:        tweet.ID,
			PublishedAt:    publishedAtString,
		}

		// Check if the tweet is liked and retweeted by the user
		if _, liked := likedTweets[tweet.ID]; liked {
			tweetPost.Liked = true
		}

		if _, retweeted := retweetedTweets[tweet.ID]; retweeted {
			tweetPost.Retweeted = true
		}

		tweetPosts = append(tweetPosts, tweetPost)
	}

	// Now tweetPosts will contain the required tweet information with liked and retweeted flags

	return c.JSON(fiber.Map{
		"message": "Tweets of the user",
		"tweets":  tweetPosts,
	})
}

func LikeTweet(c *fiber.Ctx) error {

	// get the database connection
	var db = databaseConnection.GetDB()

	// get auth user data from locals
	user, ok := c.Locals("user").(models.User)

	if !ok {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"message": "Internal server error",
		})
	}

	// get the tweet id from the params
	tweetId := c.Params("id")

	// get the tweet from the database
	var tweet models.Tweet
	if err := db.Where("id = ?", tweetId).First(&tweet).Error; err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"message": "Error getting tweet from database",
			"id":      tweetId,
		})
	}

	// check if the tweet exists
	if tweet.ID == 0 {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"message": "Tweet doesn't exist",
		})
	}

	// Like the tweet if the user hasn't liked it already
	var like models.Like
	if err := db.Where("user_id = ? AND tweet_id = ?", user.ID, tweet.ID).First(&like).Error; err != nil {
		// create the like
		like = models.Like{
			CreatedAt: time.Now().Format("2006-01-02 15:04:05"),
			User:      user,
			Tweet:     tweet,
		}

		// create the like in the database and check for errors
		if err := db.Create(&like).Error; err != nil {
			return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
				"message": "Error creating like",
			})
		}

	} else {
		// remove the like from the database
		db.Delete(&like)

		return c.JSON(fiber.Map{
			"message": "Unliked The Tweet",
		})

	}

	return c.JSON(fiber.Map{
		"message": "Liked the tweet",
	})
}

func ReplyTweet(c *fiber.Ctx) error {
	// get the database connection
	var db = databaseConnection.GetDB()

	// get auth user data from locals
	user, ok := c.Locals("user").(models.User)

	if !ok {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"message": "Internal server error",
		})
	}

	// get the tweet id from the params
	tweetId := c.Params("id")

	// get the tweet from the database
	var tweet models.Tweet
	if err := db.Where("id = ?", tweetId).First(&tweet).Error; err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"message": "Error getting tweet from database",
			"id":      tweetId,
		})
	}

	// check if the tweet exists
	if tweet.ID == 0 {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"message": "Tweet doesn't exist",
		})
	}

	// get the content from the body
	var data map[string]string

	// get the data from the body
	if err := c.BodyParser(&data); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"message": "Error parsing body",
		})
	}

	// check if the content is empty or not
	if data["content"] == "" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"message": "Content is required",
		})
	}

	// create the reply
	var reply = models.Reply{
		Content:   data["content"],
		CreatedAt: time.Now().Format("2006-01-02 15:04:05"),
		User:      user,
		Tweet:     tweet,
	}

	// create the reply in the database and check for errors
	if err := db.Create(&reply).Error; err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"message": "Error creating reply",
		})
	}

	return c.JSON(fiber.Map{
		"message": "Reply created successfully",
		"reply":   reply,
	})
}

func Retweet(c *fiber.Ctx) error {
	// get the database connection
	var db = databaseConnection.GetDB()

	// Get the Auth middleware
	if err := AuthMiddleware(c); err != nil {
		return err
	}

	// get auth user data from locals
	user, ok := c.Locals("user").(models.User)

	if !ok {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"message": "Internal server error",
		})
	}

	// get the tweet id from the params
	tweetId := c.Params("id")

	// get the tweet from the database
	var tweet models.Tweet
	if err := db.Where("id = ?", tweetId).First(&tweet).Error; err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"message": "Error getting tweet from database",
			"id":      tweetId,
		})
	}

	// check if the tweet exists
	if tweet.ID == 0 {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"message": "Tweet doesn't exist",
		})
	}

	// check if the tweet is already retweeted
	var retweet models.Retweet
	if err := db.Where("user_id = ? AND tweet_id = ?", user.ID, tweet.ID).First(&retweet).Error; err != nil {
		// create the retweet
		retweet = models.Retweet{
			CreatedAt: time.Now().Format("2006-01-02 15:04:05"),
			User:      user,
			Tweet:     tweet,
		}

		// create the retweet in the database and check for errors
		if err := db.Create(&retweet).Error; err != nil {
			return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
				"message": "Error creating retweet",
			})
		}

	} else {
		// remove the retweet from the database
		db.Delete(&retweet)

		return c.JSON(fiber.Map{
			"message": "Unretweeted The Tweet",
		})

	}

	return c.JSON(fiber.Map{
		"message": "Retweeted the tweet",
	})
}

func Bookmark(c *fiber.Ctx) error {
	// get the database connection
	var db = databaseConnection.GetDB()

	// Get the Auth middleware
	if err := AuthMiddleware(c); err != nil {
		return err
	}

	// get auth user data from locals
	user, ok := c.Locals("user").(models.User)

	if !ok {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"message": "Internal server error",
		})
	}

	// get the tweet id from the params
	tweetId := c.Params("id")

	// get the tweet from the database
	var tweet models.Tweet
	if err := db.Where("id = ?", tweetId).First(&tweet).Error; err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"message": "Error getting tweet from database",
			"id":      tweetId,
		})
	}

	// check if the tweet exists
	if tweet.ID == 0 {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"message": "Tweet doesn't exist",
		})
	}

	// check if the tweet is already bookmarked
	var bookmark models.Bookmark
	if err := db.Where("user_id = ? AND tweet_id = ?", user.ID, tweet.ID).First(&bookmark).Error; err != nil {
		// create the bookmark
		bookmark = models.Bookmark{
			CreatedAt: time.Now().Format("2006-01-02 15:04:05"),
			User:      user,
			Tweet:     tweet,
		}

		// create the bookmark in the database and check for errors
		if err := db.Create(&bookmark).Error; err != nil {
			return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
				"message": "Error creating bookmark",
			})
		}

	} else {
		// remove the bookmark from the database
		db.Delete(&bookmark)

		return c.JSON(fiber.Map{
			"message": "Unbookmarked The Tweet",
		})

	}

	return c.JSON(fiber.Map{
		"message": "Bookmarked the tweet",
	})

}

func DeleteTweet(c *fiber.Ctx) error {
	// get the database connection
	var db = databaseConnection.GetDB()

	// Get the Auth middleware
	if err := AuthMiddleware(c); err != nil {
		return err
	}

	// get auth user data from locals
	user, ok := c.Locals("user").(models.User)

	if !ok {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"message": "Internal server error",
		})
	}

	// get the tweet id from the params
	tweetId := c.Params("id")

	// get the tweet from the database
	var tweet models.Tweet
	if err := db.Where("id = ?", tweetId).First(&tweet).Error; err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"message": "Error getting tweet from database",
			"id":      tweetId,
		})
	}

	// check if the tweet exists
	if tweet.ID == 0 {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"message": "Tweet doesn't exist",
		})
	}

	// check if the tweet is created by the user
	if tweet.CreatedBy != user.ID {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
			"message": "Unauthorized",
		})
	}

	// First, delete the likes associated with the tweet
	if err := db.Where("tweet_id = ?", tweet.ID).Delete(&models.Like{}).Error; err != nil {
		// Check if the error is "record not found"
		if errors.Is(err, gorm.ErrRecordNotFound) {
			// Likes not found, proceed with deleting retweets
		} else {
			return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
				"message": "Error deleting likes",
			})
		}
	}

	// Next, delete the retweets associated with the tweet
	if err := db.Where("tweet_id = ?", tweet.ID).Delete(&models.Retweet{}).Error; err != nil {
		// Check if the error is "record not found"
		if errors.Is(err, gorm.ErrRecordNotFound) {
			// Retweets not found, proceed with deleting replies
		} else {
			return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
				"message": "Error deleting retweets",
			})
		}
	}

	// Finally, delete the replies associated with the tweet
	if err := db.Where("tweet_id = ?", tweet.ID).Delete(&models.Reply{}).Error; err != nil {
		// Check if the error is "record not found"
		if errors.Is(err, gorm.ErrRecordNotFound) {
			// Replies not found, proceed with deleting the tweet
		} else {
			return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
				"message": "Error deleting replies",
			})
		}
	}

	// Now, delete the tweet itself
	if err := db.Delete(&tweet).Error; err != nil {
		// Check if the error is "record not found"
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return c.Status(fiber.StatusNotFound).JSON(fiber.Map{
				"message": "Tweet not found",
			})
		}

		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"message": "Error deleting tweet",
		})
	}

	return c.JSON(fiber.Map{
		"message": "Tweet deleted successfully",
	})
}

func GetReplies(c *fiber.Ctx) error {
	// get the database connection
	var db = databaseConnection.GetDB()

	// get the tweet id from the params
	tweetId := c.Params("id")

	// get the replies from the database
	var replies []models.Reply

	if err := db.Preload("User").Where("tweet_id = ?", tweetId).Find(&replies).Error; err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"message": "Error getting replies",
			"id":      tweetId,
		})
	}

	// check if there is replies or not
	if len(replies) == 0 {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{
			"message": "No replies found",
		})
	}

	var replyPosts []models.ReplyPost

	for _, reply := range replies {
		createdAt, _ := time.Parse("2006-01-02 15:04:05", reply.CreatedAt)

		// Calculate the time difference in seconds
		timeDiff := time.Now().Unix() - createdAt.Unix()

		var publishedAtString string

		if timeDiff >= 86400 { // More than a day
			days := int(math.Floor(float64(timeDiff) / 86400))
			publishedAtString = fmt.Sprintf("%dd", days)
		} else if timeDiff >= 3600 { // More than an hour
			hours := int(math.Floor(float64(timeDiff) / 3600))
			publishedAtString = fmt.Sprintf("%dh", hours)
		} else if timeDiff >= 60 { // More than a minute
			minutes := int(math.Floor(float64(timeDiff) / 60))
			publishedAtString = fmt.Sprintf("%dmin", minutes)
		} else { // Less than a minute
			publishedAtString = "Just now"
		}

		replyPost := models.ReplyPost{
			Content:        reply.Content,
			AuthorName:     reply.User.FullName,
			AuthorUsername: reply.User.Username,
			AuthorID:       reply.User.ID,
			ReplyID:        reply.ID,
			PublishedAt:    publishedAtString,
		}

		replyPosts = append(replyPosts, replyPost)
	}

	return c.JSON(fiber.Map{
		"message": "Replies of the tweet",
		"replies": replyPosts,
	})

}
