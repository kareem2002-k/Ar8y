//
//  AddNewPostViewController.swift
//  Ar8y
//
//  Created by Kareem Ahmed on 25/08/2023.
//

import UIKit

class AddNewPostViewController: UIViewController {

    @IBOutlet weak var contentField: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()

        let createOrderButton = UIBarButtonItem(
               title: "Post Tweet",
               image: nil,
               target: self,
               action: #selector(createNewTweet)
           )
           navigationItem.rightBarButtonItem = createOrderButton
        // Do any additional setup after loading the view.
    }
    
    @objc func createNewTweet () {
        print("work")
        if let auth = TokenManager.shared.getToken(){
            PostAdd.shared.AddPost(authtok: auth, content: contentField.text! ){ suc in
                if suc {
                    print("tweeted")
                }else{
                    print("something went wrong")
                }
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
