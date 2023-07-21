package controllers

import (
	"github.com/gofiber/fiber/v2"

	databaseConnection "ar8y/server/databaseConnection"

	"github.com/golang-jwt/jwt"

	"ar8y/server/models"

	"time"

	"golang.org/x/crypto/bcrypt"

	"errors"

	"gorm.io/gorm"
)

func GetUserData(c *fiber.Ctx) error {
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
		if err := db.Where("id = ?", claims.Issuer).First(&user).Error; err != nil {
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

	// At this point, the user's data, including their likes and tweets, is fetched successfully
	return c.JSON(fiber.Map{
		"message": "User data",
		"user":    user,
	})

}

func ChangeUserDetails(c *fiber.Ctx) error {
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

	// get the user id from the claims
	var user models.User

	if claims.Issuer == "" || claims.ExpiresAt < time.Now().Unix() {
		c.Status(fiber.StatusUnauthorized)
		return c.JSON(fiber.Map{
			"message": "Unauthenticated",
		})

	} else {
		// get the user from the database
		db.Where("id = ?", claims.Issuer).First(&user)
	}

	// get the data from the body
	var data map[string]string

	if err := c.BodyParser(&data); err != nil {
		c.Status(fiber.StatusBadRequest)
		return c.JSON(fiber.Map{
			"message": "Bad request",
		})

	}

	// update the user and check for errors

	if data["full_name"] != "" {
		user.FullName = data["full_name"]
	}

	if data["bio"] != "" {
		user.Bio = data["bio"]
	}

	if data["profile_picture"] != "" {
		user.ProfilePicture = data["profile_picture"]
	}

	if err := db.Save(&user).Error; err != nil {
		c.Status(fiber.StatusUnauthorized)
		return c.JSON(fiber.Map{
			"message": "Something went wrong",
		})

	}

	// return the user
	return c.JSON(fiber.Map{
		"message": "User updated successfully",
	})
}

func ChangeUserPassword(c *fiber.Ctx) error {
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

	// get the user id from the claims
	var user models.User

	if claims.Issuer == "" || claims.ExpiresAt < time.Now().Unix() {
		c.Status(fiber.StatusUnauthorized)
		return c.JSON(fiber.Map{
			"message": "Unauthenticated",
		})

	} else {
		// get the user from the database
		db.Where("id = ?", claims.Issuer).First(&user)
	}

	// get the data from the body
	var data map[string]string

	if err := c.BodyParser(&data); err != nil {
		c.Status(fiber.StatusBadRequest)
		return c.JSON(fiber.Map{
			"message": "Bad request",
		})

	}

	// validate the password
	if data["old_password"] == "" || data["new_password"] == "" {
		c.Status(fiber.StatusUnauthorized)
		return c.JSON(fiber.Map{
			"message": "Please fill in all the fields",
		})

	}

	// check if the new password is at least 6 characters long
	if len(data["new_password"]) < 6 {
		c.Status(fiber.StatusUnauthorized)
		return c.JSON(fiber.Map{
			"message": "Password must be at least 6 characters long",
		})

	}

	// check if the old password is correct by encrypting it and comparing it to the one in the database
	if err := bcrypt.CompareHashAndPassword(user.Password, []byte(data["old_password"])); err != nil {
		c.Status(fiber.StatusUnauthorized)
		return c.JSON(fiber.Map{
			"message": "Incorrect old password",
		})

	}

	// check if the new password is the same as the old password
	if data["new_password"] == data["old_password"] {
		c.Status(fiber.StatusUnauthorized)
		return c.JSON(fiber.Map{
			"message": "New password cannot be the same as the old password",
		})

	}

	// encrypt the new password
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(data["new_password"]), 14)

	if err != nil {
		c.Status(fiber.StatusUnauthorized)
		return c.JSON(fiber.Map{
			"message": "Something went wrong",
		})

	}

	// update the user and check for errors
	user.Password = hashedPassword

	if err := db.Save(&user).Error; err != nil {
		c.Status(fiber.StatusUnauthorized)
		return c.JSON(fiber.Map{
			"message": "Something went wrong",
		})

	}

	return c.JSON(fiber.Map{
		"message": "Password updated successfully",
	})
}
