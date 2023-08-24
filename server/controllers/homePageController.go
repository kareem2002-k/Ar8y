package controllers

import (
	"strconv"

	databaseConnection "ar8y/server/databaseConnection"
	models "ar8y/server/models"

	"github.com/gofiber/fiber/v2"
	"gorm.io/gorm/clause"

	"fmt"

	"math"

	"time"
)

func HomePageTweets(c *fiber.Ctx) error {
	// Get the database connection
	db := databaseConnection.GetDB()

	// get auth user data from locals
	user, ok := c.Locals("user").(models.User)
	if !ok {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"message": "Internal server error",
		})
	}

	// Get the offset and maximum number of tweets to load from the request parameters (query parameters)
	offset, err := strconv.Atoi(c.Query("offset", "0"))
	if err != nil || offset < 0 {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"message": "Invalid offset",
		})
	}
	maxTweetsToLoad := 20 // Change this to the desired maximum number of tweets to load

	var tweets []models.Tweet

	// Query the database to fetch tweets made by the users in the list of followingUserIDs with the specified offset and limit
	followingUserIDs := make([]uint, 0, len(user.Following)+1)
	followingUserIDs = append(followingUserIDs, user.ID) // Add current user's ID to the list of IDs to fetch tweets from
	for _, following := range user.Following {
		followingUserIDs = append(followingUserIDs, following.FollowedUserID)
	}

	// Find the tweets made by the users in the followingUserIDs list
	if err := db.Preload(clause.Associations).Where("created_by IN (?)", followingUserIDs).
		Order("created_at DESC").Offset(offset).Limit(maxTweetsToLoad).Find(&tweets).Error; err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"message": "Error getting home page tweets",
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

	return c.JSON(fiber.Map{
		"message": "Home page tweets",
		"tweets":  tweetPosts,
	})
}
