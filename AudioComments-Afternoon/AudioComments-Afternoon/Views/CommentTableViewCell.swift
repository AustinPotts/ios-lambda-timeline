//
//  CommentTableViewCell.swift
//  AudioComments-Afternoon
//
//  Created by Austin Potts on 3/11/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class CommentTableViewCell: UITableViewCell {

    
    
    
    @IBOutlet weak var authorLabel: UILabel!
    
    
    @IBAction func playButtonTapped(_ sender: Any) {
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
