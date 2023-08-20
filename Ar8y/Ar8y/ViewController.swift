//
//  ViewController.swift
//  Ar8y
//
//  Created by Kareem Ahmed on 20/08/2023.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if let auth = TokenManager.shared.getToken()  {
            
           
        let storyboard = UIStoryboard(name: "Main", bundle: nil) // Replace with your storyboard name
                    if let tabBarController = storyboard.instantiateViewController(withIdentifier: "TabBar") as? TabBar {
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                        let delegate = windowScene.delegate as? SceneDelegate {
                        delegate.window?.rootViewController = tabBarController
                      }
                    }

            
        } else {
            print("nothing")
        }
        
    }

    @IBOutlet weak var usernameLabel: UITextField!
    
    @IBOutlet weak var passwordLabel: UITextField!
    
    
    
    @IBAction func Login(_ sender: Any) {
        
        UserAuth.shared.Login(username: usernameLabel.text!, password: passwordLabel.text!) { success in

            if success {
                
                
              print("hi")
                
                DispatchQueue.main.async {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    if let tabBarController = storyboard.instantiateViewController(withIdentifier: "TabBar") as? TabBar {
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let delegate = windowScene.delegate as? SceneDelegate {
                            delegate.window?.rootViewController = tabBarController
                        }
                    }
                }
                
                
            } else {
                let missingInformationAlert = UIAlertController(title: "Auth Error", message: "Invalid Email or Password. Try again.", preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                missingInformationAlert.addAction(cancelAction)
                self.present(missingInformationAlert, animated: true, completion: nil)
            }
        }
        
    }
    
    
    
    
}

