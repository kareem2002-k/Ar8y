//
//  SinglePostView.swift
//  Ar8y
//
//  Created by Kareem Ahmed on 25/08/2023.
//

import UIKit

class SinglePostView: UIViewController {
    
    var replies : [ReplyPost]? // Array to hold user posts
    
    var tweetID : Int?

    
    
    var refreshControl = UIRefreshControl()

    
    
    var receivedContent: String?
       var receivedAuthorName: String?
       var receivedUsername: String?
       var receivedDate: String?
       var receivedLikesCount: Int?
       var receivedLiked: Bool?
    


    @IBOutlet weak var stackOfInput: UIStackView!
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        setupImageViewTap()
        // Register for keyboard notifications
          NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
          NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
            if let content = receivedContent {
 
                textView.text = content
              
            }
            if let authorName = receivedAuthorName {
                
                fullNameLabel.text = authorName
                   }
            if let username = receivedUsername {
                
                userNameLabel.text = "@" + username
                }
        
        
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        
        
        fetchUserPosts()
        
           tableview.refreshControl = refreshControl

        tableview.register(UINib(nibName: "NameTableViewCell", bundle: nil), forCellReuseIdentifier: "namecell")
        tableview.register(UINib(nibName: "ContentTableViewCell", bundle: nil), forCellReuseIdentifier: "contentcell")
       
        
        tableview.separatorStyle = .none // Remove default separators
        tableview.rowHeight = UITableView.automaticDimension
        tableview.estimatedRowHeight = 44 // Set an estimated row height, this can be any value
        
        // Set delegate and dataSource
        tableview.delegate = self
        tableview.dataSource = self
        
        
        imageview.image = img
        imageview.tintColor = color
        
        likesCount.text = "\(receivedLikesCount!)"
        
        
                      
        // Do any additional setup after loading the view.
    }
    
    
    @objc func refreshData(_ sender: Any) {
        fetchUserPosts()
    }
    
    
    var img : UIImage?
    var color : UIColor?

    
    @IBOutlet weak var likesCount: UILabel!
    
    @IBOutlet weak var repliesCount: UILabel!
    
    
    @IBOutlet weak var retweetsCount: UILabel!
    
    
    @IBOutlet weak var imageview: UIImageView!
    
    
    func setupImageViewTap() {
           let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))
           imageview.addGestureRecognizer(tapGestureRecognizer)
           imageview.isUserInteractionEnabled = true
       }
       
    @objc private func imageViewTapped() {
        // Handle the tap action here
        // Toggle between grey and red heart colors
        if let authtok = TokenManager.shared.getToken(){
            LikeToggle.shared.Like(authtoken: authtok, tweetID: "\(self.tweetID!)", completion: {
                suc in
                
                if suc {
                    if  self.imageview.image ==  UIImage(systemName: "heart.fill") {
                        self.likesCount.text = "\(Int( self.likesCount.text ?? "0")! - 1)"
                        self.imageview.tintColor = UIColor.gray
                        self.imageview.image =  UIImage(systemName: "heart")
                        
                        
                    } else {
                        self.imageview.tintColor = UIColor.red
                        self.imageview.image =  UIImage(systemName: "heart.fill")
                        self.likesCount.text = "\(Int( self.likesCount.text ?? "0")! + 1)"
                        
                    }
                } else {
                    let missingInformationAlert = UIAlertController(title: "Auth Error", message: "Invalid Email or Password. Try again.", preferredStyle: .alert)
                    let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    missingInformationAlert.addAction(cancelAction)
                    self.present(missingInformationAlert, animated: true, completion: nil)
                }
            }
           
            )
            // Toggle the heart state
        }
                                   
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
            
            UserPosts.shared.fetchReplies(for: tweetID!, authtoken: authToken)
            { success , repliesGot in

                if success, let fetchedReplies = repliesGot {
                    self.replies = fetchedReplies
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
    
    
    @IBOutlet weak var replyOfUserContent: UITextField!
    
    
    @IBAction func AddReply(_ sender: Any) {
        
        if let authToken = TokenManager.shared.getToken() {
            
            UserPosts.shared.AddReply(for: tweetID!, authtok: authToken, content: replyOfUserContent.text!) {
                succ in
                
                if succ {
                    print("done")
                    self.fetchUserPosts()
                    self.replyOfUserContent.resignFirstResponder()

                    
                }
                
                
            }
        }else {
            print("error getting token")
            refreshControl.endRefreshing()

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


extension SinglePostView: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
       return replies?.count ?? 0  // You might have only one section
   }
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return 2 // Return the number of user posts
   }
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       guard let post = replies?[indexPath.section] else {
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
           if let post = replies?[indexPath.section] {
               let contentText = post.Content
               let contentFont = UIFont.systemFont(ofSize: 17) // Choose your font
               let labelWidth = tableView.frame.width - 16 // Left and right padding
               let estimatedHeight = contentText!.height(withConstrainedWidth: labelWidth, font: contentFont)
               return estimatedHeight + 16 // Add some padding
           }
           return 44 // Default height for content cell
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
          if indexPath.row == 1 {
              return nil // Return nil to prevent selection for row 2
          }
          return indexPath
      }
   
   
   
   
 
    
}
