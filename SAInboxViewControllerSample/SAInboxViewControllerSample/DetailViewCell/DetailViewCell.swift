//
//  DetailViewCell.swift
//  SAInboxViewControllerSample
//
//  Created by Taiki Suzuki on 2015/08/15.
//  Copyright (c) 2015年 Taiki Suzuki. All rights reserved.
//

import UIKit

class DetailViewCell: UITableViewCell {

    static let cellIdentifier = "DetailViewCell"
    
    @IBOutlet weak var iconButton: UIButton!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var mainTextView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        iconButton.layer.masksToBounds = true
        selectionStyle = .none
        textView.contentInset = UIEdgeInsets(top: -9, left: -4, bottom: 0, right: 0)
        textView.isScrollEnabled = false
        mainTextView.dataDetectorTypes = .link
        mainTextView.isEditable = false
        mainTextView.isScrollEnabled = false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        iconButton.layer.cornerRadius = iconButton.frame.width / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setIconImage(_ image: UIImage?) {
        if let image = image {
            iconButton.setImage(image, for: UIControlState())
        }
    }
}
