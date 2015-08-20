//
//  FeedViewController.swift
//  SAInboxViewControllerSample
//
//  Created by Taiki Suzuki on 2015/08/15.
//  Copyright (c) 2015年 Taiki Suzuki. All rights reserved.
//

import UIKit
import SAInboxViewController

class FeedViewController: SAInboxViewController {
    
    private var contents: [FeedContent] = [
        FeedContent(username: "Alex", text: "This is SAInboxViewController."),
        FeedContent(username: "Brian", text: "It has Inbox like transitioning."),
        FeedContent(username: "Cassy", text: "You can come back to rootViewController"),
        FeedContent(username: "Dave", text: "with four ways."),
        FeedContent(username: "Elithabeth", text: "1. Scrolling up to begining of contents"),
        FeedContent(username: "Alex", text: "2. Scrolling down to end of contents"),
        FeedContent(username: "Brian", text: "3. Header dragging"),
        FeedContent(username: "Cassy", text: "4. Left edge swiping"),
        FeedContent(username: "Dave", text: "Thanks for trying this sample."),
        FeedContent(username: "Elithabeth", text: "by skz-atmosphere")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        title = "Feed"
        
        navigationController?.navigationBarHidden = true
        
        let nib = UINib(nibName: FeedViewCell.kCellIdentifier, bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: FeedViewCell.kCellIdentifier)
        tableView.separatorInset = UIEdgeInsetsZero
        tableView.layoutMargins = UIEdgeInsetsZero
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    struct FeedContent {
        var username: String
        var text: String
    }
}

extension FeedViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(FeedViewCell.kCellIdentifier) as! UITableViewCell
        
        if let cell = cell as? FeedViewCell {
            let num = indexPath.row % 5 + 1
            if let image = UIImage(named: "icon_\(num)") {
                cell.setIconImage(image)
            }
            
            let content = contents[indexPath.row]
            cell.setUsername(content.username)
            cell.setMainText(content.text)
        }
        
        cell.layoutMargins = UIEdgeInsetsZero
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contents.count
    }
}

extension FeedViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
        let viewController = DetailViewController()
        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? FeedViewCell {
            viewController.iconImage = cell.iconImageView?.image
        }
        
        if let cell = tableView.cellForRowAtIndexPath(indexPath), cells = tableView.visibleCells() as? [UITableViewCell] {
            SAInboxAnimatedTransitioningController.sharedInstance.configureCotainerView(view, cell: cell, cells: cells, headerImage: headerView.screenshotImage())
        }
        
        let content = contents[indexPath.row]
        viewController.username = content.username
        viewController.text = content.text
        
        navigationController?.pushViewController(viewController, animated: true)
    }
}