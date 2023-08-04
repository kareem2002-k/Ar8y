package controllers

import (
	"errors"
	"time"

	"github.com/gofiber/fiber/v2"
	"gorm.io/gorm"

	databaseConnection "ar8y/server/databaseConnection"
	"ar8y/server/models"
)

func FollowUser(c *fiber.Ctx) error {
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

	// check if the user is trying to follow themselves
	if string(user.ID) == c.Params("id") {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"message": "You cannot follow yourself",
		})
	}

	// check if the user already follows the other user
	var follower models.Follower

	// get the followed user
	var followedUser models.User

	if err := db.Where("id = ?", c.Params("id")).First(&followedUser).Error; err != nil {
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

	if err := db.Where("follower_user_id = ? AND followed_user_id = ?", user.ID, followedUser.ID).First(&follower).Error; err != nil {
		// Check if the user is not found
		if errors.Is(err, gorm.ErrRecordNotFound) {
			// create the follower
			follower = models.Follower{
				CreatedAt:    time.Now().Format("2006-01-02 15:04:05"),
				FollowerUser: user,
				FollowedUser: followedUser,
			}

			if err := db.Create(&follower).Error; err != nil {
				return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
					"message": "Error following user",
				})
			}

		}

	} else {
		// remove the follower
		if err := db.Delete(&follower).Error; err != nil {
			return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
				"message": "Error unfollowing user",
			})
		} else {
			return c.Status(fiber.StatusOK).JSON(fiber.Map{
				"message": "Follower removed",
			})
		}

	}

	return c.Status(fiber.StatusOK).JSON(fiber.Map{
		"message":  "Success",
		"follower": follower,
	})

}
