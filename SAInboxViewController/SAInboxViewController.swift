//
//  SAInboxViewController.swift
//  SAInboxViewController
//
//  Created by Taiki Suzuki on 2015/08/15.
//  Copyright (c) 2015年 Taiki Suzuki. All rights reserved.
//

import UIKit

public class SAInboxViewController: UIViewController {
    
    //MARK: - Inner classes
    public class Appearance: NSObject {
        public var titleTextAttributes: [String : AnyObject]?
        public var tintColor: UIColor?
        public var barTintColor: UIColor?
    }
    
    public class HeaderView: UIView {
        
        let navigationBar = UINavigationBar()
        let navigationItem = UINavigationItem()
        let closeButtonItem = UIBarButtonItem()
        var closeButtonAction: (() -> Void)? {
            didSet {
                navigationItem.setLeftBarButtonItems([closeButtonItem], animated: false)
            }
        }
        
        public init() {
            super.init(frame: .zero)
            initialization()
        }
        
        required public init(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func initialization() {
            navigationBar.translucent = false
            navigationBar.translatesAutoresizingMaskIntoConstraints = false
            addSubview(navigationBar)
            self.addConstraints([
                NSLayoutConstraint(item: navigationBar, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: SAInboxViewController.StatusBarHeight),
                NSLayoutConstraint(item: navigationBar, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: navigationBar, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: navigationBar, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: 0)
            ])
            
            navigationBar.items?.append(navigationItem)
            
            closeButtonItem.target = self
            closeButtonItem.action = "didTapCloseButton:"
            closeButtonItem.title = "Close"
        }
        
        func applyAppearance(appearance: Appearance) {
            if let barTintColor = appearance.barTintColor {
                backgroundColor = barTintColor
                navigationBar.barTintColor = barTintColor
            }
            if let titleTextAttributes = appearance.titleTextAttributes {
                navigationBar.titleTextAttributes = titleTextAttributes
            }
            if let tintColor = appearance.tintColor {
                navigationBar.tintColor = tintColor
            }
        }
        
        func setTitle(title: String) {
            navigationItem.title = title
        }
        
        func didTapCloseButton(sender: AnyObject) {
            closeButtonAction?()
        }
    }
    
    //MARK: - Staitc properties
    public static let appearance = Appearance()
    static let HeaderViewHeight: CGFloat = 64
    static let StatusBarHeight: CGFloat = 20
    
    //MARK: - Instance properties
    public let headerView = HeaderView()
    public let tableView = UITableView()
    public override var title: String? {
        didSet {
            if let title = title {
                headerView.setTitle(title)
            }
        }
    }
    private var scrollPosition: CGPoint = CGPointZero
    private var headerViewHeightConstraint: NSLayoutConstraint?
    public var enabledViewControllerBasedAppearance :Bool = false
    public let appearance = Appearance()
    private var headerViewTopSpaceConstraint: NSLayoutConstraint?
    var shouldHideHeaderView = true
}

//MARK: - Life cycle
public extension SAInboxViewController {
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        automaticallyAdjustsScrollViewInsets = false
        
        if navigationController?.viewControllers.count > 1 {
            headerView.closeButtonAction = { [weak self] in
                self?.navigationController?.popViewControllerAnimated(true)
            }
        }
        
        headerView.applyAppearance(SAInboxViewController.appearance)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)
        let headerViewHeightConstraint = NSLayoutConstraint(item: headerView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1, constant: SAInboxViewController.HeaderViewHeight)
        let headerViewTopSpaceConstraint = NSLayoutConstraint(item: headerView, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1, constant: 0)
        view.addConstraints([
            NSLayoutConstraint(item: headerView, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: headerView, attribute: .Right, relatedBy: .Equal, toItem: view, attribute: .Right, multiplier: 1, constant: 0),
            headerViewHeightConstraint,
            headerViewTopSpaceConstraint
        ])
        self.headerViewHeightConstraint = headerViewHeightConstraint
        self.headerViewTopSpaceConstraint = headerViewTopSpaceConstraint
        
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        view.addConstraints([
            NSLayoutConstraint(item: tableView, attribute: .Top, relatedBy: .Equal, toItem: headerView, attribute: .Bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: tableView, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: tableView, attribute: .Right, relatedBy: .Equal, toItem: view, attribute: .Right, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: tableView, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: 0)
        ])
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        if enabledViewControllerBasedAppearance {
            headerView.applyAppearance(appearance)
        }
    }
    
    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        view.bringSubviewToFront(headerView)
    }
}

//MARK: Public Methods
public extension SAInboxViewController {
    public func setHeaderViewHidden(hidden: Bool, animated: Bool) {
        headerViewHeightConstraint?.constant = hidden ? 0 : SAInboxViewController.HeaderViewHeight
        if animated {
            UIView.animateWithDuration(0.25) {
                self.view.layoutIfNeeded()
            }
        } else {
            view.layoutIfNeeded()
        }
    }
}

extension SAInboxViewController: UITableViewDelegate {
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        let contentOffsetY = scrollView.contentOffset.y
        if shouldHideHeaderView {
            if contentOffsetY > 0 && contentOffsetY <= SAInboxViewController.HeaderViewHeight - SAInboxViewController.StatusBarHeight {
                headerViewTopSpaceConstraint?.constant = -contentOffsetY
                headerView.navigationBar.alpha = 1 - contentOffsetY / (SAInboxViewController.HeaderViewHeight - SAInboxViewController.StatusBarHeight)
            } else if contentOffsetY > SAInboxViewController.HeaderViewHeight - SAInboxViewController.StatusBarHeight {
                headerViewTopSpaceConstraint?.constant = -SAInboxViewController.HeaderViewHeight + SAInboxViewController.StatusBarHeight
                headerView.navigationBar.alpha = 0
            } else {
                headerViewTopSpaceConstraint?.constant = 0
                headerView.navigationBar.alpha = 1
            }
            headerView.layoutIfNeeded()
        }
        scrollPosition = scrollView.contentOffset
    }
}