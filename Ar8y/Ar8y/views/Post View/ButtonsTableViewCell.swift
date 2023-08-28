//
//  ButtonsTableViewCell.swift
//  Ar8y
//
//  Created by Kareem Ahmed on 22/08/2023.
//

import UIKit

class ButtonsTableViewCell: UITableViewCell {
    

    let Homepage = HomePageViewController()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
    }
    @IBOutlet weak var replyImg: UIImageView!
    
    
    @IBOutlet weak var retweetImg: UIImageView!
    
    
    @IBOutlet weak var retweetCount: UILabel!
    
    
    
    
    @IBOutlet weak var repliesCount: UILabel!
    
    @IBOutlet weak var likesCount: UILabel!
    
    @IBOutlet weak var imageview: UIImageView!
    
    var img : UIImage?
    
    
    var tweetID : String?
    
    func setupImageViewTap() {
           let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))
           imageview.addGestureRecognizer(tapGestureRecognizer)
           imageview.isUserInteractionEnabled = true
       }
       
    @objc private func imageViewTapped() {
        // Handle the tap action here
        // Toggle between grey and red heart colors
        if let authtok = TokenManager.shared.getToken(){
            LikeToggle.shared.Like(authtoken: authtok, tweetID: self.tweetID!, completion: {
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
                    self.Homepage.present(missingInformationAlert, animated: true, completion: nil)
                }
            }
           
            )
            // Toggle the heart state
        }
                                   
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
