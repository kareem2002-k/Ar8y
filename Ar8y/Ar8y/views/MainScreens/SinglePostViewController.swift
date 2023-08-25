//
//  SinglePostViewController.swift
//  Ar8y
//
//  Created by Kareem Ahmed on 25/08/2023.
//

import UIKit

class SinglePostViewController: UIViewController {
    
    var userReplies: [TweetPost]? // Array to hold user posts
    

    var receivedContent: String?
       var receivedAuthorName: String?
       var receivedUsername: String?
       var receivedDate: String?
       var receivedLikesCount: Int?
       var receivedLiked: Bool?

    


    override func viewDidLoad() {
        super.viewDidLoad()

        // Assign received values to outlets
               if let content = receivedContent {
                   contentView.text = content
               }
               if let authorName = receivedAuthorName {
                   fullNameLabel.text = authorName
               }
               if let username = receivedUsername {
                   userNameLabel.text = "@" + username
               }
        
        // Do any additional setup after loading the view.
    }
    
    @IBOutlet weak var fullNameLabel: UILabel!
    
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var contentView: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
    
    
    @IBOutlet weak var heartImage: UIImageView!
    
    
    
    @IBOutlet weak var likesCount: UILabel!
    
    
    
    @IBOutlet weak var replyImage: UIImageView!
    
    
    @IBOutlet weak var replyCount: UILabel!
    
    
    
    @IBOutlet weak var retweetImg: UIImageView!
    
    
    @IBOutlet weak var retweetCount: UILabel!
    
    
    
    @IBOutlet weak var tableView: UITableView!
    
    
    @IBOutlet weak var replyView: UITextField!
    
    
    @IBAction func postReply(_ sender: Any) {
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
