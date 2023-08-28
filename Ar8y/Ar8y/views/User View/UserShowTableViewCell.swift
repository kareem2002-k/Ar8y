//
//  UserShowTableViewCell.swift
//  Ar8y
//
//  Created by Kareem Ahmed on 28/08/2023.
//

import UIKit

class UserShowTableViewCell: UITableViewCell {
    
    var id : Int?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBOutlet weak var fullnameLabel: UILabel!
    
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var followButton: UIButton!
    
    
    @IBAction func followbutton(_ sender: Any) {
        if let authtok = TokenManager.shared.getToken() {
                FollowController.shared.FollowOrUnFollow(authtoken: authtok, userID: "\(id!)") { [weak self] success in
                    guard let self = self else { return }
                    
                    if success {
                  
                      
                        
                    // Update the button title and appearance based on the new state
                        updateFollowButtonState()
                    }
                }
            }
        
    }
    
    
    func updateFollowButtonState() {
        if followButton.titleLabel?.text == "Follow" {
            followButton.setTitle("Unfollow", for: .normal)

            
            // You can update other UI properties here for the "following" state
        } else {
            followButton.setTitle("Follow", for: .normal)

            // You can update other UI properties here for the "not following" state
        }
    }

    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
