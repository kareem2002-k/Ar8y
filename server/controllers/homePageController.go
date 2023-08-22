package controllers

import (
	"strconv"

	databaseConnection "ar8y/server/databaseConnection"
	models "ar8y/server/models"

	"github.com/gofiber/fiber/v2"
	"gorm.io/gorm/clause"
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

	// Return the tweets in form ot tweetpost

	var tweetPosts []models.TweetPost

	for _, tweet := range tweets {

		// check if the user has liked the tweet by searching for the user id in the likes
		liked := false
		for _, like := range tweet.Likes {
			if like.User.ID == user.ID {
				liked = true
				break
			}
		}

		// check if the user has retweeted the tweet by searching for the user id in the retweets
		retweeted := false
		for _, retweet := range tweet.Retweets {
			if retweet.User.ID == user.ID {
				retweeted = true
				break
			}
		}

		tweetPosts = append(tweetPosts, models.TweetPost{
			Content:        tweet.Content,
			Liked:          liked,
			Retweeted:      retweeted,
			AuthorName:     tweet.User.FullName,
			AuthorUsername: tweet.User.Username,
			AuthorID:       tweet.User.ID,
			LikesCount:     len(tweet.Likes),
			RepliesCount:   len(tweet.Replies),
			RetweetsCount:  len(tweet.Retweets),
			PublishedAt:    tweet.CreatedAt,
		})

	}

	return c.JSON(fiber.Map{
		"message": "Home page tweets",
		"tweets":  tweetPosts,
	})
}
