//
//  ViewController.swift
//  Ar8y
//
//  Created by Kareem Ahmed on 22/08/2023.
//

import UIKit

import NVActivityIndicatorView

class ViewController: UIViewController {
    
    let activityIndicatorView = NVActivityIndicatorView(
          frame: CGRect(x: 0, y: 0, width: 40, height: 40),
          type: .ballPulse,
          color: .black,
          padding: nil
      )
    
    @IBOutlet weak var blur: UIVisualEffectView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        blur.isHidden = true
        
        
        if let authtok = TokenManager.shared.getToken() {
            
            DispatchQueue.main.async {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let tabBarController = storyboard.instantiateViewController(withIdentifier: "TabBar2") as? TabBar2 {
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let delegate = windowScene.delegate as? SceneDelegate {
                        delegate.window?.rootViewController = tabBarController
                    }
                }
            }
            
            
        }else{
            
           
            let blurEffect = UIBlurEffect(style: .extraLight)
            blur.effect = blurEffect
        }
            

        // Do any additional setup after loading the view.
    }
    
    @IBOutlet weak var usernameLabel: UITextField!
    
    
    @IBOutlet weak var passwordLabel: UITextField!
    
    
    @IBAction func login(_ sender: Any) {
        
        self.activityIndicatorView.center = self.view.center
        self.view.addSubview(activityIndicatorView)

        self.blur.isHidden = false

        // Show loading indicator
        self.activityIndicatorView.startAnimating()
        
        UserAuth.shared.Login(username: usernameLabel.text!, password: passwordLabel.text!) { success in

            if success {
                
                self.activityIndicatorView.stopAnimating()
                self.blur.isHidden = true

                
                DispatchQueue.main.async {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    if let tabBarController = storyboard.instantiateViewController(withIdentifier: "TabBar2") as? TabBar2 {
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let delegate = windowScene.delegate as? SceneDelegate {
                            delegate.window?.rootViewController = tabBarController
                        }
                    }
                }
                
                
            } else {
                self.activityIndicatorView.stopAnimating()
                self.blur.isHidden = true

                let missingInformationAlert = UIAlertController(title: "Auth Error", message: "Invalid Email or Password. Try again.", preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                missingInformationAlert.addAction(cancelAction)
                self.present(missingInformationAlert, animated: true, completion: nil)
            }
        }
        
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
