//
//  FeedViewCell.swift
//  SAInboxViewControllerSample
//
//  Created by Taiki Suzuki on 2015/08/15.
//  Copyright (c) 2015年 Taiki Suzuki. All rights reserved.
//

import UIKit
import QuartzCore

class FeedViewCell: UITableViewCell {

    static let kCellIdentifier = "FeedViewCell"
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var mainTextLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        iconImageView.layer.masksToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        iconImageView.layer.cornerRadius = CGRectGetWidth(iconImageView.frame) / 2
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setIconImage(image: UIImage) {
        iconImageView.image = image
    }
    
    func setMainText(text: String) {
        mainTextLabel.text = text
    }
    
    func setUsername(name: String) {
        usernameLabel.text = name
    }
}
