import UIKit

class NotificationsViewController: UIViewController {

    var webSocketTask: URLSessionWebSocketTask!

    override func viewDidLoad() {
        super.viewDidLoad()
        establishWebSocketConnection()
        
        sendWebSocketMessage(message: "fuck you")
    }

    func establishWebSocketConnection() {
        // Get the authentication token from your saved data
        if let authToken = TokenManager.shared.getToken() {
            let socketURL = URL(string: "ws://localhost:8000/ws")!

            var request = URLRequest(url: socketURL)
            request.timeoutInterval = 5

            // Add the authentication token to the request headers
            request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")

            let session = URLSession(configuration: .default)
            webSocketTask = session.webSocketTask(with: request)

            // Set up handlers for WebSocket events
            webSocketTask.resume()
            receiveWebSocketEvents()
        } else {
            print("Failed to get token")
        }
    }


    func receiveWebSocketEvents() {
        
        print("func is called")
        webSocketTask.receive { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let message):
                switch message {
                case .data(let data):
                    // Handle received binary data if needed
                    print("Received binary data: \(data)")
                case .string(let text):
                    // Handle received text message
                    print("Received WebSocket message: \(text)")
                    // Here you can handle the received message and update your UI accordingly
                @unknown default:
                    fatalError("Unknown WebSocket message type")
                }
                
                // Continue to listen for more WebSocket events
                self.receiveWebSocketEvents()

            case .failure(let error):
                // Handle WebSocket error
                print("WebSocket error: \(error)")
            }
        }
    }

    func sendWebSocketMessage(message: String) {
        let message = URLSessionWebSocketTask.Message.string(message)
        webSocketTask.send(message) { error in
            if let error = error {
                // Handle send error
                print("WebSocket send error: \(error)")
            }
        }
    }

    // Don't forget to close the WebSocket connection when you're done
    func closeWebSocketConnection() {
        webSocketTask.cancel(with: .goingAway, reason: nil)
    }
}

