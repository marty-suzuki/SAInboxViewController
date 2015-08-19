//
//  DetailViewCell.swift
//  SAInboxViewControllerSample
//
//  Created by Taiki Suzuki on 2015/08/15.
//  Copyright (c) 2015年 Taiki Suzuki. All rights reserved.
//

import UIKit

class DetailViewCell: UITableViewCell {

    static let kCellIdentifier = "DetailViewCell"
    
    @IBOutlet weak var iconButton: UIButton!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var mainTextView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        iconButton.layer.masksToBounds = true
        selectionStyle = .None
        textView.contentInset = UIEdgeInsets(top: -9, left: -4, bottom: 0, right: 0)
        textView.scrollEnabled = false
        mainTextView.dataDetectorTypes = .Link
        mainTextView.editable = false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        iconButton.layer.cornerRadius = CGRectGetWidth(iconButton.frame) / 2
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setIconImage(image: UIImage?) {
        if let image = image {
            iconButton.setImage(image, forState: .Normal)
        }
    }
}
