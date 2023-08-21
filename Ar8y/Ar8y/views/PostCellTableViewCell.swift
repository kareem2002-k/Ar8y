//
//  PostCellTableViewCell.swift
//  Ar8y
//
//  Created by Kareem Ahmed on 21/08/2023.
//

import UIKit

class PostCellTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBOutlet weak var Content: UITextView!
    @IBOutlet weak var Name: UILabel!
    
    @IBOutlet weak var UserName: UILabel!
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
