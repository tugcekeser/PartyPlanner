//
//  HomeEventTableViewCell.swift
//  iOS-PartyPlanner
//
//  Created by Tuze on 5/4/17.
//  Copyright © 2017 PartyDevs. All rights reserved.
//

import UIKit
import AFNetworking

protocol CellSubclassDelegate: class {
  func buttonTapped(cell: HomeEventTableViewCell)
}

class HomeEventTableViewCell: UITableViewCell {
    
    @IBOutlet var invitationImageView: UIImageView!
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var eventNameLabel: UILabel!
    @IBOutlet var eventTimeLabel: UILabel!
    @IBOutlet var eventLocationLabel: UILabel!
    @IBOutlet var rsvpButton: UIButton!
    @IBOutlet var day: UILabel!
    @IBOutlet var month: UILabel!
  
    var delegate: CellSubclassDelegate?

    
    var event: Event? {
        didSet {
            
            Utils.formatCircleImage(image: profileImageView)
            
            if let profileImageURL = event?.hostProfileImageUrl{
                profileImageView.setImageWith(NSURL(string:profileImageURL)! as URL)
            }
            
            if let invitationImageURL = event?.inviteMediaUrl{
                invitationImageView.setImageWith(NSURL(string:invitationImageURL)! as URL)
            }
            
            if let name = event?.name {
                eventNameLabel.text = name
            }
            
            if let address = event?.location{
               eventLocationLabel.text = address
            }
            
            if let time = event?.dateTime{
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .long
                dateFormatter.timeStyle = .long
                eventTimeLabel.text = dateFormatter.string(from: (time))
                
                let dayOfEvent = Calendar.current.component(.day, from: time)
                day.text = String(dayOfEvent)
                let monthOfEvent = Calendar.current.component(.month, from: time)
                month.text = Utils.getMonth(month: monthOfEvent)
            }
            
            if let rsvpStatus = event?.response {
                rsvpButton.setTitle(rsvpStatus, for: .normal)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        rsvpButton.layer.cornerRadius = 3
        self.delegate = nil

        /*rsvpButton.layer.borderWidth = 1
        rsvpButton.layer.borderColor = UIColor.purple.cgColor*/
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
  @IBAction func onRSVPButtonTap(_ sender: Any) {
    self.delegate?.buttonTapped(cell: self)
  }

}
