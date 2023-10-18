//
//  AppDelegate.swift
//  Ar8y
//
//  Created by Kareem Ahmed on 20/08/2023.
//

import UIKit
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var webSocketTask: URLSessionWebSocketTask!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        establishWebSocketConnection()
        requestNotificationAuthorization()

        // Register for remote notifications
        UNUserNotificationCenter.current().delegate = self
        application.registerForRemoteNotifications()

        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Start WebSocket task in the background
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Close the WebSocket when the app is active
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
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
                    self.sendPushNotification(message: text)
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

    func sendPushNotification(message: String) {
        let content = UNMutableNotificationContent()
        content.title = "New Message"
        content.body = message
        content.sound = UNNotificationSound.default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "websocketMessage", content: content, trigger: trigger)

        let center = UNUserNotificationCenter.current()
        center.add(request) { (error) in
            if let error = error {
                // Handle the error
                print("Error sending push notification: \(error)")
            } else {
                // Notification sent successfully
                print("Push notification sent")
            }
        }
    }

    func requestNotificationAuthorization() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            if granted {
                // User granted permission
            } else {
                // Handle the case where the user denied permission
            }
        }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Always show the notification when it's received
        completionHandler([.alert, .sound])
    }
    
    
      // Handle taps on notifications when the app is in the background or terminated
      func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
          // Handle the notification payload here
          let userInfo = response.notification.request.content.userInfo
          if let message = userInfo["message"] as? String {
              // Handle the message here
              print("Received push notification: \(message)")
          }
          
          completionHandler()
      }
}
