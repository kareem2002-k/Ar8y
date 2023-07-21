package controllers

import (
	"strconv"

	databaseConnection "ar8y/server/databaseConnection"
	models "ar8y/server/models"
	"errors"

	"github.com/golang-jwt/jwt"

	"github.com/gofiber/fiber/v2"
	"gorm.io/gorm"
	"gorm.io/gorm/clause"
)

func HomePageTweets(c *fiber.Ctx) error {
	// Get the database connection
	db := databaseConnection.GetDB()

	// Get the JWT token from the cookie
	cookie := c.Cookies("jwt")

	// Parse the JWT token
	token, err := jwt.ParseWithClaims(cookie, &jwt.StandardClaims{}, func(token *jwt.Token) (interface{}, error) {
		return []byte(SecretKey), nil
	})

	if err != nil {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
			"message": "Unauthenticated",
		})
	}

	// Get the claims
	claims := token.Claims.(*jwt.StandardClaims)

	// Get the user from the database along with their following list
	var user models.User
	if err := db.Preload("Following").Where("id = ?", claims.Issuer).First(&user).Error; err != nil {
		// Check if the user is not found
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return c.Status(fiber.StatusNotFound).JSON(fiber.Map{
				"message": "User not found",
			})
		}
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"message": "Error getting user data",
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

	return c.JSON(fiber.Map{
		"message": "Home page tweets",
		"tweets":  tweets,
	})
}
