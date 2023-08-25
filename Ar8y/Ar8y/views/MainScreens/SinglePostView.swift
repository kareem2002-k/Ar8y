//
//  SinglePostView.swift
//  Ar8y
//
//  Created by Kareem Ahmed on 25/08/2023.
//

import UIKit

class SinglePostView: UIViewController {
    
    var userPosts: [TweetPost]? // Array to hold user posts

    
    
    var refreshControl = UIRefreshControl()

    
    
    var receivedContent: String?
       var receivedAuthorName: String?
       var receivedUsername: String?
       var receivedDate: String?
       var receivedLikesCount: Int?
       var receivedLiked: Bool?


    @IBOutlet weak var stackOfInput: UIStackView!
    
    @IBOutlet weak var contentView: UITextView!
    
    @IBOutlet weak var contentViewHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Register for keyboard notifications
          NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
          NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
            if let content = receivedContent {
                
                contentView.text = content
                print(content)
                textView.text = content
                
              
                let contentSize = contentView.sizeThatFits(CGSize(width: contentView.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
                
                if contentSize.height > 60 {
                    contentViewHeightConstraint.constant = 150
                }else {
                    contentViewHeightConstraint.constant = 50

                }
                    
                
              
            }
            if let authorName = receivedAuthorName {
                
                fullNameLabel.text = authorName
                   }
            if let username = receivedUsername {
                
                userNameLabel.text = "@" + username
                }
        
        fetchUserPosts()
        
           tableview.refreshControl = refreshControl

        tableview.register(UINib(nibName: "NameTableViewCell", bundle: nil), forCellReuseIdentifier: "namecell")
        tableview.register(UINib(nibName: "ContentTableViewCell", bundle: nil), forCellReuseIdentifier: "contentcell")
        tableview.register(UINib(nibName: "ButtonsTableViewCell", bundle: nil), forCellReuseIdentifier: "buttoncell")
        
        tableview.separatorStyle = .none // Remove default separators
        tableview.rowHeight = UITableView.automaticDimension
        tableview.estimatedRowHeight = 44 // Set an estimated row height, this can be any value
        
        // Set delegate and dataSource
        tableview.delegate = self
        tableview.dataSource = self
        

              
        // Do any additional setup after loading the view.
        
        

    }
    
    
  
    @IBOutlet weak var textView: UITextView!
    
  
    @IBOutlet weak var stackView: UIStackView!
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide the tab bar
        tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Show the tab bar when leaving this view controller
        tabBarController?.tabBar.isHidden = false
    }
    
    @IBOutlet weak var stackOfInputBottomConstraint: NSLayoutConstraint!
    
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            // Adjust the bottom constraint of your stackOfInput
            stackOfInputBottomConstraint.constant = keyboardFrame.height
            
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        // Reset the bottom constraint of your stackOfInput
        stackOfInputBottomConstraint.constant = 0
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    
    func fetchUserPosts() {
          
        
        if let authToken = TokenManager.shared.getToken() {
            
            UserPosts.shared.fetchUserData(authtoken: authToken) { success, tweets in
                

                if success, let fetchedTweets = tweets {
                    self.userPosts = fetchedTweets
                    self.tableview.reloadData()
                } else {
                    // Handle error condition, e.g., show an error message
                }
                self.refreshControl.endRefreshing()

            }
        }
        else {
            print("error getting token")
            refreshControl.endRefreshing()

        }
       }

    
    
    
    
    
  
    @IBOutlet weak var tableview: UITableView!
    
    @IBOutlet weak var fullNameLabel: UILabel!
    
    @IBOutlet weak var userNameLabel: UILabel!
    

    @IBOutlet weak var likeImage: UIImageView!
    
    @IBOutlet weak var likeCount: UILabel!
    
    @IBOutlet weak var replyCount: UILabel!
    
    @IBOutlet weak var retweetCount: UILabel!
    
    @IBOutlet weak var replyOfUserContent: UITextField!
    
    
    @IBAction func AddReply(_ sender: Any) {
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


extension SinglePostView: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
       return userPosts?.count ?? 0  // You might have only one section
   }
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return 3 // Return the number of user posts
   }
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       guard let post = userPosts?[indexPath.section] else {
           return UITableViewCell()
       }
       
       switch indexPath.row {
       case 0:
           let cell = tableView.dequeueReusableCell(withIdentifier: "namecell", for: indexPath) as! NameTableViewCell
           cell.Fullname.text = post.AuthorUsername
           cell.userName.text = "@\(post.AuthorUsername)"
           cell.time.text = post.PublishedAt
           return cell
           
       case 1:
           let cell = tableView.dequeueReusableCell(withIdentifier: "contentcell", for: indexPath) as! ContentTableViewCell
           cell.content.text = post.Content
           return cell
           
       case 2:
           let cell = tableView.dequeueReusableCell(withIdentifier: "buttoncell", for: indexPath) as! ButtonsTableViewCell
           
           cell.likesCount.text = "\(post.LikesCount)"
           cell.tweetID = "\(post.tweetID)"
           
           if post.Liked {
               cell.imageview.image =  UIImage(systemName: "heart.fill")
               cell.imageview.tintColor = .red
           }else{
               cell.imageview.image =  UIImage(systemName: "heart")
               cell.imageview.tintColor = .gray
           }
           
           cell.setupImageViewTap() // Enable tap gesture on the image view
           // Configure action buttons cell here
           return cell
           
       default:
           return UITableViewCell()
       }
   }
   
   
   
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       switch indexPath.row {
       case 0:
           return 38 // Height for the name cell
       case 1:
           // Calculate dynamic height for content cell
           if let post = userPosts?[indexPath.section] {
               let contentText = post.Content
               let contentFont = UIFont.systemFont(ofSize: 17) // Choose your font
               let labelWidth = tableView.frame.width - 16 // Left and right padding
               let estimatedHeight = contentText!.height(withConstrainedWidth: labelWidth, font: contentFont)
               return estimatedHeight + 16 // Add some padding
           }
           return 44 // Default height for content cell
       case 2:
           return 44 // Height for the action cell
       default:
           return 44 // Default height for other cells
       }
   }
   
   
   // Helper method to calculate height for content cell
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
       let separatorView = UIView()
       separatorView.backgroundColor = UIColor.lightGray // Customize the separator color
       return separatorView
   }
   
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
       return 0.5 // Height of the separator view
   }
   
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
       return 0 // Height for the gap between sections
   }
   
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
       return UIView() // Empty view for section header
   }
   
   func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
          // Check if you want to allow selection for this particular row
          if indexPath.row == 2 {
              return nil // Return nil to prevent selection for row 2
          }
          return indexPath
      }
   
   
   
   
   func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       if indexPath.row == 1 {
           // Perform the push to the desired view controller here
           // For example:
           let storyboard = UIStoryboard(name: "Main", bundle: nil)
           if let singlePost = storyboard.instantiateViewController(withIdentifier: "singlePost") as? SinglePostView {
               // Assign data to the receiving variables
                           singlePost.receivedContent = userPosts?[indexPath.section].Content
                           singlePost.receivedAuthorName = userPosts?[indexPath.section].AuthorName
                           singlePost.receivedUsername = userPosts?[indexPath.section].AuthorUsername
                           singlePost.receivedDate = userPosts?[indexPath.section].PublishedAt
                           singlePost.receivedLikesCount = userPosts?[indexPath.section].LikesCount
                           singlePost.receivedLiked = userPosts?[indexPath.section].Liked
                           

               
               // Configure the detailViewController if needed
               navigationController?.pushViewController(singlePost, animated: false)
           }
       }
   }
    
}
