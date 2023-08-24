//
//  UserPostsTableViewController.swift
//  Ar8y
//
//  Created by Kareem Ahmed on 21/08/2023.
//
import UIKit

class UserPostsTableViewController: UITableViewController {
    
    var userPosts: [TweetPost]? // Array to hold user posts


    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        // Register the custom cell class or nib with the table view
        fetchUserPosts()
        
        tableView.register(UINib(nibName: "NameTableViewCell", bundle: nil), forCellReuseIdentifier: "namecell")
        
        tableView.register(UINib(nibName: "ContentTableViewCell", bundle: nil), forCellReuseIdentifier: "contentcell")
        
        tableView.register(UINib(nibName: "ButtonsTableViewCell", bundle: nil), forCellReuseIdentifier: "buttoncell")
        
        tableView.separatorStyle = .none // Remove default separators
        
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44 // Set an estimated row height, this can be any value

         
    }
    
    
    func fetchUserPosts() {
          
        
        if let authToken = TokenManager.shared.getToken() {
            
            UserPosts.shared.fetchUserData(authtoken: authToken) { success, tweets in
                if success, let fetchedTweets = tweets {
                    self.userPosts = fetchedTweets
                    self.tableView.reloadData()
                } else {
                    // Handle error condition, e.g., show an error message
                }
            }
        }
        else {
            print("error getting token")
        }
       }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return userPosts?.count ?? 0  // You might have only one section
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3 // Return the number of user posts
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let post = userPosts?[indexPath.section] else {
                  return UITableViewCell()
              }
              
              switch indexPath.row {
              case 0:
                  let cell = tableView.dequeueReusableCell(withIdentifier: "namecell", for: indexPath) as! NameTableViewCell
                  cell.Fullname.text = post.AuthorUsername
                  cell.userName.text = post.AuthorUsername
                  cell.time.text = post.PublishedAt
                  return cell
                  
              case 1:
                  let cell = tableView.dequeueReusableCell(withIdentifier: "contentcell", for: indexPath) as! ContentTableViewCell
                  cell.content.text = post.Content
                  return cell
                  
              case 2:
                  let cell = tableView.dequeueReusableCell(withIdentifier: "buttoncell", for: indexPath) as! ButtonsTableViewCell
                  
                  cell.likesCount.text = "\(post.LikesCount)"
                  
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
    
   

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 50 // Height for the name cell
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
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let separatorView = UIView()
        separatorView.backgroundColor = UIColor.lightGray // Customize the separator color
        return separatorView
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.5 // Height of the separator view
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
          return 2 // Height for the gap between sections
      }

      override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
          return UIView() // Empty view for section header
      }
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return ceil(boundingBox.height)
    }
}
