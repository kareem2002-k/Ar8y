package main

import (
	databaseconnection "ar8y/server/databaseConnection"

	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/cors"

	Routes "ar8y/server/routes"
)

func main() {
	// connect to the database and migrate the models
	databaseconnection.Connect()

	// create a new fiber app instance
	app := fiber.New()

	// register the routes
	Routes.Setup(app)

	// CORS
	app.Use(cors.New(cors.Config{
		AllowCredentials: true,
		AllowHeaders:     "Origin, Content-Type, Accept",
		AllowMethods:     "GET, POST, PUT, DELETE, OPTIONS",
		AllowOrigins:     "http://localhost:3000", // Replace with your allowed origin(s)

	}))

	app.Listen(":8000")

}
