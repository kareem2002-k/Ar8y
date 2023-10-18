package controllers

import (
	"ar8y/server/models"
	"fmt"
	"sync"

	"github.com/gofiber/contrib/websocket"
)

var WebSocketConnectionPool = struct {
	sync.RWMutex
	Connections map[uint]*websocket.Conn
}{Connections: make(map[uint]*websocket.Conn)}

func Init() {
	WebSocketConnectionPool.Connections = make(map[uint]*websocket.Conn)
	fmt.Println("WebSocket connection pool initialized")
}

func Socket(c *websocket.Conn) {
	// Get the user ID from the Fiber context

	user := c.Locals("user").(models.User)
	userID := user.ID // Replace this with logic to get the actual user ID

	fmt.Println("Socket connection established")

	// Add the WebSocket connection to the pool
	WebSocketConnectionPool.Lock()
	WebSocketConnectionPool.Connections[userID] = c
	WebSocketConnectionPool.Unlock()

	defer func() {
		// Remove the WebSocket connection from the pool when the connection is closed
		WebSocketConnectionPool.Lock()
		delete(WebSocketConnectionPool.Connections, userID)
		WebSocketConnectionPool.Unlock()
		c.Close()
	}()

	for {
		// Read messages from the client
		messageType, p, err := c.ReadMessage()
		if err != nil {
			return
		}

		fmt.Println("Message Type:", messageType)
		fmt.Println("Message:", string(p))
	}
}

func SendFollowNotification(userID uint, message string) {
	WebSocketConnectionPool.RLock()
	defer WebSocketConnectionPool.RUnlock()

	conn, exists := WebSocketConnectionPool.Connections[userID]
	if !exists {
		// User's WebSocket connection not found
		return
	}

	// Send the notification message
	if err := conn.WriteMessage(websocket.TextMessage, []byte(message)); err != nil {
		// Handle sending error, e.g., log or notify
		fmt.Println("Error sending WebSocket notification:", err)
	}
}

// test for web socket

func Test(c *websocket.Conn) {
	welcomeMessage := "Welcome to the WebSocket server!"
	if err := c.WriteMessage(websocket.TextMessage, []byte(welcomeMessage)); err != nil {
		fmt.Println("Error sending welcome message:", err)
	}
	for {
		// Read messages from clients
		messageType, p, err := c.ReadMessage()
		fmt.Println("Message Type: ", messageType)
		fmt.Println("Message: ", string(p))
		if err != nil {
			return
		}

		// Echo the received message back to the client
		if err := c.WriteMessage(messageType, p); err != nil {
			return
		}
	}
}
