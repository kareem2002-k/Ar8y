package controllers

import (
	"fmt"

	"github.com/gofiber/fiber/v2"

	databaseConnection "ar8y/server/databaseConnection"
	"ar8y/server/models"

	"github.com/golang-jwt/jwt"
	"golang.org/x/crypto/bcrypt"

	"strconv"
	"time"
)

const SecretKey = "docksh200920022006"

func Register(c *fiber.Ctx) error {
	var data map[string]string

	// get the database connection
	var db = databaseConnection.GetDB()

	if err := c.BodyParser(&data); err != nil {
		fmt.Printf("Error parsing body in the register controller: %v", err)
		return err
	}

	// checking if the required fields are empty or not
	if data["username"] == "" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"message": "Username is required",
		})
	}

	if data["password"] == "" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"message": "Password is required",
		})
	}

	if data["email"] == "" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"message": "Email is required",
		})
	}

	if data["birth_date"] == "" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"message": "Birth date is required",
		})
	}

	// TODO: Validate the email and birth date

	// check if the username is already taken
	if err := db.Where("username = ?", data["username"]).First(&models.User{}).Error; err == nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"message": "Username is already taken",
		})
	}

	// check if the email is already taken
	if err := db.Where("email = ?", data["email"]).First(&models.User{}).Error; err == nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"message": "Email is already taken",
		})
	}

	// check if the password is less than 6 characters
	if len(data["password"]) < 6 {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"message": "Password must be at least 6 characters",
		})
	}

	// check if the password is more than 50 characters
	if len(data["password"]) > 50 {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"message": "Password must be less than 50 characters",
		})
	}

	// encrypt the password
	encryptedPassword, encryptingErr := bcrypt.GenerateFromPassword([]byte(data["password"]), 14)
	if encryptingErr != nil {
		fmt.Printf("Error encrypting password: %v", encryptingErr)
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"message": "Error encrypting password",
		})
	}

	// create the user
	user := models.User{
		Username:  data["username"],
		Password:  encryptedPassword,
		Email:     data["email"],
		BirthDate: data["birth_date"],
		CreatedAt: time.Now().Format("2006-01-02 15:04:05"),
	}

	// save the user to the database
	if err := db.Create(&user).Error; err != nil {
		fmt.Printf("Error creating user: %v", err)
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"message": "Error creating user",
		})
	}

	claims := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.StandardClaims{
		Issuer:    strconv.Itoa(int(user.ID)),            // convert int to string (int is not allowed)
		ExpiresAt: time.Now().Add(time.Hour * 24).Unix(), // 1 day
	})

	// generate jwt token with secret key
	token, tokenClaimsErr := claims.SignedString([]byte(SecretKey))

	if tokenClaimsErr != nil {
		c.Status(fiber.StatusBadRequest)
		return c.JSON(fiber.Map{
			"message": "User created successfully but error creating jwt token",
		})
	}

	// create cookie with jwt token
	cookie := fiber.Cookie{
		Name:     "jwt",
		Value:    token,
		Expires:  time.Now().Add(time.Hour * 24), // 1 day
		HTTPOnly: true,
	}

	c.Cookie(&cookie)

	return c.Status(fiber.StatusCreated).JSON(fiber.Map{
		"message": "User authinticated successfully",
	})

}

// register form in json format
// {
// 	"username": "ar8y",
//  "email": "ar8y@gmail",
//  "password": "123456",
//  "birth_date": "2000-09-20"
// }

func Login(c *fiber.Ctx) error {
	var data map[string]string

	// get the database connection
	var db = databaseConnection.GetDB()

	if err := c.BodyParser(&data); err != nil {
		fmt.Printf("Error parsing body in the login controller: %v", err)
		return err
	}

	// checking if the required fields are empty or not
	if data["username"] == "" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"message": "Username is required",
		})
	}

	if data["password"] == "" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"message": "Password is required",
		})
	}

	// check if the user exists
	var user models.User
	if err := db.Where("username = ?", data["username"]).First(&user).Error; err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"message": "User does not exist",
		})
	}

	// check if the password is correct
	if err := bcrypt.CompareHashAndPassword(user.Password, []byte(data["password"])); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"message": "Incorrect password",
		})
	}

	claims := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.StandardClaims{
		Issuer:    strconv.Itoa(int(user.ID)),            // convert int to string (int is not allowed)
		ExpiresAt: time.Now().Add(time.Hour * 24).Unix(), // 1 day
	})

	// generate jwt token with secret key
	token, tokenClaimsErr := claims.SignedString([]byte(SecretKey))

	if tokenClaimsErr != nil {
		c.Status(fiber.StatusBadRequest)
		return c.JSON(fiber.Map{
			"message": "User logged in successfully but error creating jwt token",
		})
	}

	// create cookie with jwt token
	cookie := fiber.Cookie{
		Name:     "jwt",
		Value:    token,
		Expires:  time.Now().Add(time.Hour * 24), // 1 day
		HTTPOnly: true,
	}

	c.Cookie(&cookie)

	return c.Status(fiber.StatusCreated).JSON(fiber.Map{
		"message": "User logged in successfully",
	})

} // login form in json format
// {
// 	"username": "ar8y",
//  "password": "123456",
// }

func Logout(c *fiber.Ctx) error {
	// create cookie with jwt token
	cookie := fiber.Cookie{
		Name:     "jwt",
		Value:    "",
		Expires:  time.Now().Add(-time.Hour * 24), // 1 day
		HTTPOnly: true,
	}

	c.Cookie(&cookie)

	return c.Status(fiber.StatusCreated).JSON(fiber.Map{
		"message": "User logged out successfully",
	})

}

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

	// return the user
	return c.JSON(user)

}
