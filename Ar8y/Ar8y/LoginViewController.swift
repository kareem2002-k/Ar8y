//
//  LoginViewController.swift
//  Ar8y
//
//  Created by Kareem Ahmed on 22/08/2023.
//

import UIKit

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if let auth = TokenManager.shared.getToken()  {
            
           
        let storyboard = UIStoryboard(name: "Main", bundle: nil) // Replace with your storyboard name
                    if let tabBarController = storyboard.instantiateViewController(withIdentifier: "TabBar2") as? TabBar2 {
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                        let delegate = windowScene.delegate as? SceneDelegate {
                        delegate.window?.rootViewController = tabBarController
                      }
                    }

            
        } else {
            print("nothing")
        }
    }
    
    @IBAction func signin(_ sender: Any) {
        
      
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
