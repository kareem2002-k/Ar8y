package controllers

import (
	"github.com/gofiber/fiber/v2"

	databaseConnection "ar8y/server/databaseConnection"

	"github.com/golang-jwt/jwt"

	"ar8y/server/models"

	"fmt"

	"strconv"

	"strings"
)

func AuthMiddleware(c *fiber.Ctx) error {
	// Get the database connection
	var db = databaseConnection.GetDB()

	// Get the JWT token from the Authorization header
	tokenString := c.Get("Authorization")

	// Remove the "Bearer " prefix if present
	if strings.HasPrefix(tokenString, "Bearer ") {
		tokenString = strings.TrimPrefix(tokenString, "Bearer ")
	}

	// Check if the token is missing or empty
	if tokenString == "" {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
			"message": "Unauthorized, missing token",
		})
	}

	// Parse the JWT token with StandardClaims
	token, err := jwt.ParseWithClaims(tokenString, &jwt.StandardClaims{}, func(token *jwt.Token) (interface{}, error) {
		return []byte(SecretKey), nil
	})

	// Check if there was an error parsing the token
	if err != nil {
		if err == jwt.ErrSignatureInvalid {
			return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
				"message": "Unauthorized, invalid token signature",
			})
		}
		fmt.Printf("Error parsing token: %v\n", err)
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
			"message": "Unauthorized, error parsing token",
		})
	}

	// Get the claims from the token
	claims, ok := token.Claims.(*jwt.StandardClaims)
	if !ok || !token.Valid {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
			"message": "Unauthorized, invalid token claims",
		})
	}

	fmt.Printf("Claims: %+v\n", claims)

	// Get the user ID from the claims
	userID, err := strconv.Atoi(claims.Issuer)
	if err != nil {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
			"message": "Unauthorized, invalid user ID",
		})
	}

	// Get the user from the database based on the user ID and preload the likes and tweets and followers and following and retweets and check for errors
	var user models.User
	if err := db.Preload("Likes").Preload("Tweets").Preload("Followers").Preload("Following").First(&user, userID).Error; err != nil {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
			"message": "Unauthorized, user not found",
		})
	}

	// Add the user object to the context to be used in the subsequent routes
	c.Locals("user", user)

	fmt.Printf("Authenticated User: %+v\n", user)

	// Continue to the next middleware or route handler
	return c.Next()
}
