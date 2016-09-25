//
//  SAInboxViewController.swift
//  SAInboxViewController
//
//  Created by Taiki Suzuki on 2015/08/15.
//  Copyright (c) 2015年 Taiki Suzuki. All rights reserved.
//

import UIKit
import MisterFusion

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

open class SAInboxViewController: UIViewController {
    
    //MARK: - Inner classes
    open class Appearance: NSObject {
        open var titleTextAttributes: [String : AnyObject]?
        open var tintColor: UIColor?
        open var barTintColor: UIColor?
    }
    
    open class HeaderView: UIView {
        
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
        
        fileprivate func initialization() {
            navigationBar.isTranslucent = false
            addLayoutSubview(navigationBar, andConstraints:
                navigationBar.top |+| SAInboxViewController.statusBarHeight,
                navigationBar.left,
                navigationBar.right,
                navigationBar.bottom
            )
            
            navigationBar.items?.append(navigationItem)
            
            closeButtonItem.target = self
            closeButtonItem.action = #selector(HeaderView.didTapCloseButton(_:))
            closeButtonItem.title = "Close"
        }
        
        func applyAppearance(_ appearance: Appearance) {
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
        
        func setTitle(_ title: String) {
            navigationItem.title = title
        }
        
        func didTapCloseButton(_ sender: AnyObject) {
            closeButtonAction?()
        }
    }
    
    //MARK: - Staitc properties
    open static let appearance = Appearance()
    static let headerViewHeight: CGFloat = 64
    static let statusBarHeight: CGFloat = 20
    
    //MARK: - Instance properties
    open let headerView = HeaderView()
    open let tableView = UITableView()
    open override var title: String? {
        didSet {
            guard  let title = self.title else { return }
            headerView.setTitle(title)
        }
    }
    fileprivate var scrollPosition: CGPoint = CGPoint.zero
    fileprivate var headerViewHeightConstraint: NSLayoutConstraint?
    open var enabledViewControllerBasedAppearance :Bool = false
    open let appearance = Appearance()
    fileprivate var headerViewTopSpaceConstraint: NSLayoutConstraint?
    var shouldHideHeaderView = true

    //MARK: - Life cycle
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        automaticallyAdjustsScrollViewInsets = false
        
        if navigationController?.viewControllers.count > 1 {
            headerView.closeButtonAction = { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
        }
        
        headerView.applyAppearance(SAInboxViewController.appearance)
        let constraints = view.addLayoutSubview(headerView, andConstraints:
            headerView.height |==| SAInboxViewController.headerViewHeight,
            headerView.top,
            headerView.right,
            headerView.left
        )
        headerViewHeightConstraint = constraints.firstAttribute(.height).first
        headerViewTopSpaceConstraint = constraints.firstAttribute(.top).first
        
        tableView.delegate = self
        view.addLayoutSubview(tableView, andConstraints:
            tableView.top |==| headerView.bottom,
            tableView.left,
            tableView.right,
            tableView.bottom
        )
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if enabledViewControllerBasedAppearance {
            headerView.applyAppearance(appearance)
        }
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        view.bringSubview(toFront: headerView)
    }

    //MARK: Public Methods
    public func setHeaderViewHidden(_ hidden: Bool, animated: Bool) {
        headerViewHeightConstraint?.constant = hidden ? 0 : SAInboxViewController.headerViewHeight
        if animated {
            UIView.animate(withDuration: 0.25, animations: {
                self.view.layoutIfNeeded()
            }) 
        } else {
            view.layoutIfNeeded()
        }
    }
}

extension SAInboxViewController: UITableViewDelegate {
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffsetY = scrollView.contentOffset.y
        if shouldHideHeaderView {
            switch contentOffsetY {
                case let y where y > 0 && y <= SAInboxViewController.headerViewHeight - SAInboxViewController.statusBarHeight:
                    headerViewTopSpaceConstraint?.constant = -y
                    headerView.navigationBar.alpha = 1 - y / (SAInboxViewController.headerViewHeight - SAInboxViewController.statusBarHeight)
                case let y where y > SAInboxViewController.headerViewHeight - SAInboxViewController.statusBarHeight:
                    headerViewTopSpaceConstraint?.constant = -SAInboxViewController.headerViewHeight + SAInboxViewController.statusBarHeight
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
