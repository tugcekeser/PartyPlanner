//
//  EventTableViewCell.swift
//  iOS-PartyPlanner
//
//  Created by Yan, Tristan on 4/25/17.
//  Copyright © 2017 PartyDevs. All rights reserved.
//

import UIKit

class EventGuestCommentTableViewCell: UITableViewCell {
    var comment: Comment? {
        didSet {
            if let userImageURL = comment?.userImageURL {
                guestImageView.setImageWith(userImageURL)
            } else {
                UserApi.sharedInstance.getUserByEmail(userEmail: (comment?.userEmail)!, success: { (user) in
                    self.comment?.userImageURL = URL(string: (user?.imageUrl)!)
                    self.guestImageView.setImageWith((self.comment?.userImageURL)!)
                }, failure: {})
            }
            guestName.text = comment?.userName
            guestComment.text = comment?.text
        }
    }

    @IBOutlet weak var guestImageView: UIImageView!
    
    @IBOutlet weak var guestName: UILabel!
    
    @IBOutlet weak var guestComment: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
