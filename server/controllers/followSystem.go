package controllers

import (
	"errors"
	"time"

	"github.com/gofiber/fiber/v2"
	"gorm.io/gorm"

	databaseConnection "ar8y/server/databaseConnection"
	"ar8y/server/models"

	"strconv"
)

func FollowUser(c *fiber.Ctx) error {
	// get the database connection
	var db = databaseConnection.GetDB()

	// get auth user data from locals
	user, ok := c.Locals("user").(models.User)
	if !ok {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"message": "Internal server error",
		})
	}

	// check if the user is trying to follow himself
	if strconv.Itoa(int(user.ID)) == c.Params("id") {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"message": "You can't follow yourself",
		})
	}

	// get the followed user
	var followedUser models.User
	if err := db.Where("id = ?", c.Params("id")).First(&followedUser).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return c.Status(fiber.StatusNotFound).JSON(fiber.Map{
				"message": "User not found",
			})
		}
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"message": "Error getting user data",
		})
	}

	// Check if the follower relationship exists
	var existingFollower models.Follower
	err := db.Where("follower_user_id = ? AND followed_user_id = ?", user.ID, followedUser.ID).First(&existingFollower).Error
	if err == nil {
		// Follower relationship already exists, delete it to unfollow
		if err := db.Delete(&existingFollower).Error; err != nil {
			return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
				"message": "Error unfollowing user",
			})
		}
		return c.Status(fiber.StatusOK).JSON(fiber.Map{
			"message": "Unfollowed successfully",
		})
	} else if !errors.Is(err, gorm.ErrRecordNotFound) {
		// An error occurred while checking for the existing follower
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"message": "Error checking follower relationship",
		})
	}

	// Create the follower relationship
	follower := models.Follower{
		CreatedAt:      time.Now().Format("2006-01-02 15:04:05"),
		FollowerUser:   user,
		FollowedUser:   followedUser,
		FollowerUserID: user.ID,
		FollowedUserID: followedUser.ID,
	}

	if err := db.Create(&follower).Error; err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"message": "Error following user",
		})
	}

	// Send notification to the followed user
	return c.Status(fiber.StatusOK).JSON(fiber.Map{
		"message": "Followed successfully",
	})
}
