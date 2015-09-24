//
//  DetailViewController.swift
//  SAInboxViewControllerSample
//
//  Created by Taiki Suzuki on 2015/08/15.
//  Copyright (c) 2015年 Taiki Suzuki. All rights reserved.
//

import UIKit
import SAInboxViewController
import QuartzCore

class DetailViewController: SAInboxDetailViewController {
    
    var iconImage: UIImage?
    var text: String?
    var username: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        tableView.dataSource = self
        
        let nib = UINib(nibName: DetailViewCell.kCellIdentifier, bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: DetailViewCell.kCellIdentifier)
        
        title = username
        
        tableView.separatorInset = UIEdgeInsetsZero
        tableView.layoutMargins = UIEdgeInsetsZero
        
        let color = UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1)
        appearance.barTintColor = .whiteColor()
        appearance.tintColor = color
        appearance.titleTextAttributes = [NSForegroundColorAttributeName : color]
        enabledViewControllerBasedAppearance = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .Default
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension DetailViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(DetailViewCell.kCellIdentifier)!
        
        if let cell = cell as? DetailViewCell {
            cell.setIconImage(iconImage)
            cell.usernameLabel.text = username
            cell.textView.text = text
        }
        
        cell.layoutMargins = UIEdgeInsetsZero
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return CGRectGetHeight(tableView.frame) * 1.5
    }
}