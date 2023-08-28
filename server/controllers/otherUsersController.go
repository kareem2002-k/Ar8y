package controllers

import (
	"github.com/gofiber/fiber/v2"

	databaseConnection "ar8y/server/databaseConnection"

	"ar8y/server/models"

	"fmt"

	"math"

	"time"
)

func GetSpecficUser(c *fiber.Ctx) error {
	// get the database connection
	var db = databaseConnection.GetDB()

	// get the id from the params
	id := c.Params("id")

	// get the user from the database
	var user models.User

	// get user followers and check if the auth user follows the user

	// get auth user data from locals
	authUser, ok := c.Locals("user").(models.User)
	if !ok {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"message": "Internal server error",
		})
	}

	// get the user from the database
	if err := db.Preload("Followers").Preload("Following").First(&user, id).Error; err != nil {
		c.Status(fiber.StatusNotFound)
		return c.JSON(fiber.Map{
			"message": "User not found",
		})

	}

	var userProfile models.UserProfile

	// check if the auth user follows the user
	for _, follower := range user.Followers {
		if follower.FollowerUserID == authUser.ID {
			userProfile.IsFollowedByAuthUser = true
			break
		} else {
			userProfile.IsFollowedByAuthUser = false
		}
	}

	//

	userProfile.ID = user.ID

	userProfile.Username = user.Username

	userProfile.FullName = user.FullName

	userProfile.Bio = user.Bio

	userProfile.NumbOfFollowers = len(user.Followers)

	userProfile.NumbOfFollowing = len(user.Following)

	// return the user
	return c.JSON(fiber.Map{
		"message": "User fetched successfully",
		"user":    userProfile,
	})

}

func GetSpecficUserTweets(c *fiber.Ctx) error {

	// get the database connection
	var db = databaseConnection.GetDB()

	// get auth user data from locals
	user, ok := c.Locals("user").(models.User)

	// get the id from the params
	id := c.Params("id")

	if !ok {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"message": "Internal server error",
		})
	}

	// Get the tweets of the user
	var tweets []models.Tweet

	// Get the tweets of the user from the database and check for errors
	if err := db.Preload("User").Preload("Likes.User").Preload("Likes.Tweet").Preload("Replies").Preload("Replies.User").Preload("Retweets").Preload("Hashtags").Where("created_by = ?", id).Order("created_at DESC").Find(&tweets).Error; err != nil {
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
