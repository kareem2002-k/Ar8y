package routes

import (
	controlers "ar8y/server/controllers"

	"github.com/gofiber/fiber/v2"
)

func Setup(app *fiber.App) {

	// Routes for auth controlers
	app.Post("/register", controlers.Register)
	app.Post("/login", controlers.Login)
	app.Get("/user", controlers.GetUserData)
	app.Post("/logout", controlers.Logout)
	app.Post("/tweet", controlers.PostTweet)
	app.Get("/getMytweets", controlers.GetTweetsOfAuthUser)
	app.Post("/like/:id", controlers.LikeTweet)
	app.Post("/delete/:id", controlers.DeleteTweet)
	app.Post("/reply/:id", controlers.ReplyTweet)
	app.Post("/retweet/:id", controlers.Retweet)

}
