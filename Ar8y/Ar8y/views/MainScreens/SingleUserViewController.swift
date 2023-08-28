//
//  SingleUserViewController.swift
//  Ar8y
//
//  Created by Kareem Ahmed on 28/08/2023.
//

import UIKit
import NVActivityIndicatorView


class SingleUserViewController: UIViewController {
    
    var id : Int = 0
    
    var user : UserProfiLe?
    
    var loadingIndicator: NVActivityIndicatorView!
    
    
    var userPosts: [TweetPost]? // Array to hold user posts
    
    var refreshControl = UIRefreshControl()


    override func viewDidLoad() {
        super.viewDidLoad()

       
        loadingIndicator = NVActivityIndicatorView(
              frame: CGRect(x: 0, y: 0, width: 40, height: 40),
              type: .circleStrokeSpin,
              color: .gray,
              padding: nil
          )
        
          loadingIndicator.center = view.center
        
        
          view.addSubview(loadingIndicator)
        
        fetchUserData()
        fetchUserPosts()

        tableView.refreshControl = refreshControl

           
           tableView.register(UINib(nibName: "NameTableViewCell", bundle: nil), forCellReuseIdentifier: "namecell")
           tableView.register(UINib(nibName: "ContentTableViewCell", bundle: nil), forCellReuseIdentifier: "contentcell")
           tableView.register(UINib(nibName: "ButtonsTableViewCell", bundle: nil), forCellReuseIdentifier: "buttoncell")
           
           tableView.separatorStyle = .none // Remove default separators
           tableView.rowHeight = UITableView.automaticDimension
           tableView.estimatedRowHeight = 44 // Set an estimated row height, this can be any value
           
           // Set delegate and dataSource
           tableView.delegate = self
           tableView.dataSource = self
        
        
        
        
        // Do any additional setup after loading the view.
    }
    
    
    
    
    
    @IBOutlet weak var fullnameLabel: UILabel!
    
    
    @IBOutlet weak var userNameLable: UILabel!
    
    
    @IBOutlet weak var bioLabel: UILabel!
    
    
    @IBOutlet weak var numberOfFollowing: UILabel!
    
    
    
    @IBOutlet weak var numberOfFollowers: UIStackView!
    
    
    
    @IBOutlet weak var tableView: UITableView!
    
    
    @IBOutlet weak var followButton: UIButton!
    
    
    @IBAction func followOrUnfollow(_ sender: Any) {
    }
    
    
    
    // Hide the bottom Nav bar
    
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
    
    
    func fetchUserData() {
          
        
        loadingIndicator.startAnimating()

        
        if let authToken = TokenManager.shared.getToken() {
            self.loadingIndicator.stopAnimating()

            ProfileData.shared.fetchUserData(for: id, authtoken: authToken) {

                suc , data in
                
                
                if suc , let fetchedata = data {
                    self.user = fetchedata
                    
                    self.fullnameLabel.text = self.user?.FullName
                    self.userNameLable.text = self.user?.Username
                    self.bioLabel.text = self.user?.Bio
                    self.numberOfFollowing.text = "\(self.user!.NumbOfFollowing)"
                    
                    
                    
                    
                } else {
                    print("error getting data")
                }
                
            }
            
        }
        
        


        
           
        
      
       }

    
    
    func fetchUserPosts() {
          
        
        if let authToken = TokenManager.shared.getToken() {
            
            loadingIndicator.startAnimating()
            

            ProfileData.shared.fetchUserTweets(userId: "\(id)", authtoken: authToken ){
            
         success, tweets in
                

                self.loadingIndicator.stopAnimating()

                if success, let fetchedTweets = tweets {
                    self.userPosts = fetchedTweets
                    self.tableView.reloadData()
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
    
    
    
    
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SingleUserViewController: UITableViewDelegate, UITableViewDataSource {
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
            cell.Fullname.text = post.AuthorName
            cell.userName.text = "@\(post.AuthorUsername)"
            cell.time.text = post.PublishedAt
            cell.selectionStyle = .none // Disable selection effect

            return cell
            
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "contentcell", for: indexPath) as! ContentTableViewCell
            cell.content.text = post.Content
            cell.selectionStyle = .none // Disable selection effect

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
                singlePost.tweetID =  userPosts?[indexPath.section].tweetID
                            

                
                // Configure the detailViewController if needed
                navigationController?.pushViewController(singlePost, animated: false)
            }
        }else if indexPath.row == 0{
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let singleuser = storyboard.instantiateViewController(withIdentifier: "userProfile") as? SingleUserViewController {
                // Assign data to the receiving variables
                          
                singleuser.id = (userPosts?[indexPath.section].AuthorID)!

                
                // Configure the detailViewController if needed
                navigationController?.pushViewController(singleuser, animated: false)
            }
            
        }
    }

}

