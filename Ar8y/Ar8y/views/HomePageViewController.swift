//
//  HomePageViewController.swift
//  Ar8y
//
//  Created by Kareem Ahmed on 21/08/2023.
//

import UIKit

class HomePageViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        if let auth = TokenManager.shared.getToken()  {
            
            UserAuth.shared.fetchUserData(authtoken: auth){
                user , error in
                if let user = user {
                       // User data fetched successfully
                    UserAuth.shared.CurrentUser = user
                    
                    print("email",user.Email)
                    print("fullname" , user.FullName)
                    print("tweet" , user.Tweets)
                   
                   }
            }
          

            
        }
        
        
        
        // Do any additional setup after loading the view.
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
