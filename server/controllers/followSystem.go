package controllers

import (
	"errors"
	"time"

	"github.com/gofiber/fiber/v2"
	"github.com/golang-jwt/jwt"
	"gorm.io/gorm"

	databaseConnection "ar8y/server/databaseConnection"
	"ar8y/server/models"
)

func FollowUser(c *fiber.Ctx) error {
	// get the database connection
	var db = databaseConnection.GetDB()

	// get the jwt token from the cookie
	cookie := c.Cookies("jwt")

	// parse the jwt token
	token, err := jwt.ParseWithClaims(cookie, &jwt.StandardClaims{}, func(token *jwt.Token) (interface{}, error) {
		return []byte(SecretKey), nil
	})

	if err != nil {
		c.Status(fiber.StatusUnauthorized)
		return c.JSON(fiber.Map{
			"message": "Unauthenticated",
		})
	}

	// get the claims
	claims := token.Claims.(*jwt.StandardClaims)

	// Get the user id from the claims
	var user models.User

	if claims.Issuer == "" || claims.ExpiresAt < time.Now().Unix() {
		c.Status(fiber.StatusUnauthorized)
		return c.JSON(fiber.Map{
			"message": "Unauthenticated",
		})
	} else {
		// Get the user from the database along with their likes and tweets
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
