








import UIKit
import Starscream

class NotificationsViewController: UIViewController {

    var socket: WebSocket!

    override func viewDidLoad() {
        super.viewDidLoad()
        establishWebSocketConnection()
    }


    func establishWebSocketConnection() {
        let socketURL = URL(string: "wss://localhost/ws")!

        var request = URLRequest(url: socketURL)
        request.timeoutInterval = 5
        socket = WebSocket(request: request)
       
        
        socket.delegate = self
        socket.connect()
    }
}

// MARK: - WebSocket Delegate

extension NotificationsViewController: WebSocketDelegate {
    
    
    
    func didReceive(event: Starscream.WebSocketEvent, client: Starscream.WebSocketClient) {
        switch event {
        case .connected:
            print("WebSocket connected")
        case .disconnected(let reason, let code):
            print("WebSocket disconnected with reason: \(reason), code: \(code)")
        case .text(let message):
            print("Received WebSocket message: \(message)")
            // Here you can handle the received message and update your UI accordingly
        case .binary(let data):
            // Handle received binary data if needed
            print("Received binary data")
        case .ping(_):
            // Handle ping event if needed
            print("Received ping")
        case .pong(_):
            // Handle pong event if needed
            print("Received pong")
        case .viabilityChanged(_):
            // Handle viability change if needed
            print("Viability changed")
        case .reconnectSuggested(_):
            // Handle reconnect suggestion if needed
            print("Reconnect suggested")
        case .cancelled:
            // Handle cancelled event if needed
            print("WebSocket connection cancelled")
        case .error(let error):
            print("WebSocket error: \(error?.localizedDescription ?? "Unknown error")")
            // Handle error if needed
        case .peerClosed:
            print("ana mesh fahm 7aga")
        }
        
        
    }
    
    

    
    
}
