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
    
    fileprivate var contents: [FeedContent] = [
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
        
        navigationController?.isNavigationBarHidden = true
        
        let nib = UINib(nibName: FeedViewCell.cellIdentifier, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: FeedViewCell.cellIdentifier)
        tableView.separatorInset = .zero
        tableView.layoutMargins = .zero
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
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
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FeedViewCell.cellIdentifier)!
        
        if let cell = cell as? FeedViewCell {
            let num = indexPath.row % 5 + 1
            if let image = UIImage(named: "icon_\(num)") {
                cell.setIconImage(image)
            }
            
            let content = contents[indexPath.row]
            cell.setUsername(content.username)
            cell.setMainText(content.text)
        }
        
        cell.layoutMargins = UIEdgeInsets.zero
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contents.count
    }
}

//MARK: - UITableViewDelegate Methods
extension FeedViewController {
    @objc(tableView:heightForRowAtIndexPath:)
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    @objc(tableView:didSelectRowAtIndexPath:)
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        let viewController = DetailViewController()
        if let cell = tableView.cellForRow(at: indexPath) as? FeedViewCell {
            viewController.iconImage = cell.iconImageView?.image
        }
        
        if let cell = tableView.cellForRow(at: indexPath), let image = headerView.screenshotImage() {
            SAInboxAnimatedTransitioningController.shared .configureCotainerView(self, cell: cell, cells: tableView.visibleCells, headerImage: image)
        }
        
        let content = contents[(indexPath as NSIndexPath).row]
        viewController.username = content.username
        viewController.text = content.text
        
        navigationController?.pushViewController(viewController, animated: true)
    }
}
