package controllers

import (
	"fmt"

	"github.com/gofiber/contrib/websocket"

	"sync"
)

var connections sync.Map // Map to store WebSocket connections

func HandleWebSocket(c *websocket.Conn) {
	// Retrieve user ID from the WebSocket URL query parameter
	userID := "2"

	// Store the WebSocket connection for the user
	connections.Store(userID, c)

	defer func() {
		// Remove the WebSocket connection when the connection is closed
		connections.Delete(userID)
		c.Close()
	}()

	fmt.Printf("WebSocket connected for user %s\n", userID)

	for {
		// Read a message from the WebSocket connection
		_, _, err := c.ReadMessage()
		if err != nil {
			// Handle read error
			// For example, log the error and close the connection
			fmt.Printf("WebSocket read error for user %s: %v\n", userID, err)
			c.Close()
			return
		}

		// Process the received message (if needed)
		// You can implement your message processing logic here

		// Example: Send a welcome message back to the client
		if err := c.WriteMessage(websocket.TextMessage, []byte("Welcome to the WebSocket!")); err != nil {
			// Handle write error
			// For example, log the error and close the connection
			fmt.Printf("WebSocket write error for user %s: %v\n", userID, err)
			c.Close()
			return
		}
	}
}
