//
//  SAInboxViewController.swift
//  SAInboxViewController
//
//  Created by Taiki Suzuki on 2015/08/15.
//  Copyright (c) 2015年 Taiki Suzuki. All rights reserved.
//

import UIKit
import MisterFusion

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
            addLayoutSubview(navigationBar, andConstraints:
                navigationBar.Top |+| SAInboxViewController.StatusBarHeight,
                navigationBar.Left,
                navigationBar.Right,
                navigationBar.Bottom
            )
            
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
        let constraints = view.addLayoutSubview(headerView, andConstraints:
            headerView.Height |=| self.dynamicType.HeaderViewHeight,
            headerView.Top,
            headerView.Right,
            headerView.Left
        )
        headerViewHeightConstraint = constraints.firstAttribute(.Height).first
        headerViewTopSpaceConstraint = constraints.firstAttribute(.Top).first
        
        tableView.delegate = self
        view.addLayoutSubview(tableView, andConstraints:
            tableView.Top |==| headerView.Bottom,
            tableView.Left,
            tableView.Right,
            tableView.Bottom
        )
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
        headerViewHeightConstraint?.constant = hidden ? 0 : self.dynamicType.HeaderViewHeight
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
            switch contentOffsetY {
                case let y where y > 0 && y <= (self.dynamicType.HeaderViewHeight - self.dynamicType.StatusBarHeight):
                    headerViewTopSpaceConstraint?.constant = -y
                    headerView.navigationBar.alpha = 1 - y / (self.dynamicType.HeaderViewHeight - self.dynamicType.StatusBarHeight)
                case let y where y > self.dynamicType.HeaderViewHeight - self.dynamicType.StatusBarHeight:
                    headerViewTopSpaceConstraint?.constant = -self.dynamicType.HeaderViewHeight + self.dynamicType.StatusBarHeight
                    headerView.navigationBar.alpha = 0
                default:
                    headerViewTopSpaceConstraint?.constant = 0
                    headerView.navigationBar.alpha = 1
            }
            headerView.layoutIfNeeded()
        }
        scrollPosition = scrollView.contentOffset
    }
}