//
//  ContentTableViewCell.swift
//  Ar8y
//
//  Created by Kareem Ahmed on 22/08/2023.
//

import UIKit

class ContentTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBOutlet weak var content: UITextView!
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
