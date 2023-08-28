package routes

import (
	"github.com/gofiber/fiber/v2"

	controlers "ar8y/server/controllers"
)

func Setup(app *fiber.App) {

	// Routes for auth controlers
	app.Post("/register", controlers.Register) // tested
	app.Post("/login", controlers.Login)       // TODO: test this

	app.Post("/logout", controlers.Logout) // tested

	app.Use(controlers.AuthMiddleware) // Register the AuthMiddleware first

	app.Post("/tweet", controlers.PostTweet) // tested (with auth) but not tested (without auth) yet
	// and not tested with hashtags yet

	app.Post("/like/:id", controlers.LikeTweet)                // tested
	app.Post("/delete/:id", controlers.DeleteTweet)            // tested with auth user and his tweet not tested with not auth user and not his tweet
	app.Post("/reply/:id", controlers.ReplyTweet)              // tested with auth user and his tweet not tested with not auth user and not his tweet
	app.Post("/retweet/:id", controlers.Retweet)               // tested with auth user and his tweet not tested with not auth user and not his tweet
	app.Get("/getAuthUserdata", controlers.GetUserData)        // tested
	app.Post("/follow/:id", controlers.FollowUser)             // tested
	app.Get("/homePage", controlers.HomePageTweets)            // tested
	app.Get("/getMyTweets", controlers.GetTweetsOfAuthUser)    // testet
	app.Get("/getReply/:id", controlers.GetReplies)            // tested
	app.Get("/getUser/:id", controlers.GetSpecficUser)         // tested
	app.Get("/getTweets/:id", controlers.GetSpecficUserTweets) // tested

	app.Get("/search", controlers.SearchforUsers)

}
