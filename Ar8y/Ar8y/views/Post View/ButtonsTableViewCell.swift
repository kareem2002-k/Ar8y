//
//  ButtonsTableViewCell.swift
//  Ar8y
//
//  Created by Kareem Ahmed on 22/08/2023.
//

import UIKit

class ButtonsTableViewCell: UITableViewCell {
    
    var isHeartFilled = false // Keep track of the heart state


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
    }
    
    
    @IBOutlet weak var likesCount: UILabel!
    
    @IBOutlet weak var imageview: UIImageView!
    
    var img : UIImage?
    
    
    func setupImageViewTap() {
           let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))
           imageview.addGestureRecognizer(tapGestureRecognizer)
           imageview.isUserInteractionEnabled = true
       }
       
       @objc private func imageViewTapped() {
           // Handle the tap action here
           // Toggle between grey and red heart colors
                  if isHeartFilled {
                      imageview.tintColor = UIColor.gray
                      imageview.image = img

                  } else {
                      imageview.tintColor = UIColor.red
                      imageview.image = img

                  }
                  
                  // Toggle the heart state
                  isHeartFilled.toggle()
       }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
