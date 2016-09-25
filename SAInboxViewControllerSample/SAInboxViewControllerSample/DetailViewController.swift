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
        
        let nib = UINib(nibName: DetailViewCell.cellIdentifier, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: DetailViewCell.cellIdentifier)
        
        title = username
        
        tableView.separatorInset = .zero
        tableView.layoutMargins = .zero
        
        let color = UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1)
        appearance.barTintColor = .white
        appearance.tintColor = color
        appearance.titleTextAttributes = [NSForegroundColorAttributeName : color]
        enabledViewControllerBasedAppearance = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension DetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DetailViewCell.cellIdentifier)!
        
        if let cell = cell as? DetailViewCell {
            cell.setIconImage(iconImage)
            cell.usernameLabel.text = username
            cell.textView.text = text
        }
        
        cell.layoutMargins = .zero
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    @objc(tableView:heightForRowAtIndexPath:)
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.height * 1.5
    }
}
