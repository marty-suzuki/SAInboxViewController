//
//  SAInboxDetailViewController.swift
//  SAInboxViewController
//
//  Created by Taiki Suzuki on 2015/08/15.
//  Copyright (c) 2015年 Taiki Suzuki. All rights reserved.
//

import UIKit

@objc public protocol SAInboxDetailViewControllerDelegate: NSObjectProtocol {
    @objc optional func inboxDetailViewControllerShouldChangeStatusBarColor(_ viewController: SAInboxDetailViewController, isScrollingDirectionUp: Bool)
}

open class SAInboxDetailViewController: SAInboxViewController {
    
    //MARK: Static Properties
    private struct Const {
        static let cellIdentifier = "Cell";
        static let standardValue = UIScreen.main.bounds.height * 0.2
    }
    
    //MARK: Instatnce Properties
    private lazy var headerPanGesture: UIPanGestureRecognizer = {
        return UIPanGestureRecognizer(target: self, action: #selector(SAInboxDetailViewController.handleHeaderPanGesture(_:)))
    }()
    private lazy var swipePanGesture: UIPanGestureRecognizer = {
        return UIPanGestureRecognizer(target: self, action: #selector(SAInboxDetailViewController.handleSwipePanGesture(_:)))
    }()
    private var stopScrolling = false
    
    private var defaultHeaderPosition: CGPoint = .zero
    private var defaultTableViewPosition: CGPoint = .zero
    
    var thumbImage: UIImage?
    private(set) var endHeaderPosition: CGPoint = .zero
    private(set) var endTableViewPosition: CGPoint = .zero
    
    open weak var delegate: SAInboxDetailViewControllerDelegate?
    
    let alphaView = UIView()
    
    //MARK: Initialize Methods
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }

    //MARK: - Life Cycle
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.backgroundColor = .clear
        tableView.backgroundView?.backgroundColor = .clear
        
        view.backgroundColor = .white
        automaticallyAdjustsScrollViewInsets = false
        
        headerView.addGestureRecognizer(headerPanGesture)
        view.addGestureRecognizer(swipePanGesture)
        
        shouldHideHeaderView = false
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        view.insertSubview(SAInboxAnimatedTransitioningController.shared.transitioningContainerView, belowSubview: tableView)
        setupAlphaView()
        view.bringSubview(toFront: headerView)
    }
    
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        defaultHeaderPosition = headerView.frame.origin
        defaultTableViewPosition = tableView.frame.origin
    }
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: - Private Methods
    func setupAlphaView() {
        alphaView.frame = view.bounds
        alphaView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
        alphaView.alpha = 0
        view.insertSubview(alphaView, belowSubview: tableView)
    }
    
    func calculateRudderBanding(_ distance: CGFloat, constant: CGFloat, dimension: CGFloat) -> CGFloat {
        return (1 - (1 / ((distance * constant / dimension) + 1))) * dimension
    }

    //MARK: - Internal Methods
    func resetContentOffset(isLower: Bool) {
        if isLower {
            tableView.setContentOffset(CGPoint(x: 0, y: tableView.contentSize.height - tableView.bounds.size.height), animated: false)
            return
        }
        tableView.setContentOffset(CGPoint.zero, animated: false)
    }
    
    func handleSwipePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        let velocity = gesture.velocity(in: view)
        
        switch gesture.state {
            case .began:
                SAInboxAnimatedTransitioningController.shared.transitioningType = .swipePop
                
            case .changed:
                let position = max(0, translation.x)
                let rudderBanding = calculateRudderBanding(position, constant: 0.55, dimension: view.frame.size.width)
                let headerPosition = max(defaultHeaderPosition.x, defaultHeaderPosition.x + rudderBanding)
                headerView.frame.origin.x = headerPosition
                
                let tableViewPosition = max(defaultTableViewPosition.x, defaultTableViewPosition.x + rudderBanding)
                tableView.frame.origin.x = tableViewPosition
                
                alphaView.alpha = 1 - min(rudderBanding / view.frame.size.width, 1)
                
            case .cancelled, .ended:
                if velocity.x > 0 {
                    endHeaderPosition = headerView.frame.origin
                    endTableViewPosition = tableView.frame.origin
                    navigationController?.popViewController(animated: true)
                } else {
                    UIView.animate(withDuration: 0.25, animations: {
                        self.headerView.frame.origin = self.defaultHeaderPosition
                        self.tableView.frame.origin = self.defaultTableViewPosition
                    }) 
                }
                
            case .failed, .possible:
                break
        }
    }
    
    func handleHeaderPanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        let velocity = gesture.velocity(in: view)
        
        switch gesture.state {
            case .began:
                SAInboxAnimatedTransitioningController.shared.transitioningType = .headerPop
                
            case .changed:
                let position = max(0, translation.y)
                let rudderBanding = calculateRudderBanding(position, constant: 0.55, dimension: view.frame.size.height)
                let headerPosition = max(defaultHeaderPosition.y, defaultHeaderPosition.y + rudderBanding)
                headerView.frame.origin.y = headerPosition
                
                let tableViewPosition = max(defaultTableViewPosition.y, defaultTableViewPosition.y + rudderBanding)
                tableView.frame.origin.y = tableViewPosition
                
                SAInboxAnimatedTransitioningController.shared.transitioningContainerView.upperMoveToValue(rudderBanding)
                
                alphaView.alpha = 1 - min(1, (rudderBanding / 180))
                
            case .cancelled, .ended:
                if velocity.y  > 0 {
                    endHeaderPosition = headerView.frame.origin
                    endTableViewPosition = tableView.frame.origin
                    navigationController?.popViewController(animated: true)
                } else {
                    UIView.animate(withDuration: 0.25, animations: {
                        self.headerView.frame.origin = self.defaultHeaderPosition
                        self.tableView.frame.origin = self.defaultTableViewPosition
                        SAInboxAnimatedTransitioningController.shared.transitioningContainerView.upperMoveToValue(0)
                        self.alphaView.alpha = 1
                    }) 
                }
                
            case .failed, .possible:
                break
        }
    }

    //MARK: - UITableViewDelegate Methods
    open func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let yOffset = scrollView.contentOffset.y
        let value = yOffset - (scrollView.contentSize.height - scrollView.bounds.size.height)
        
        let standardValue = Const.standardValue
        if value > standardValue || yOffset < -standardValue {
            endHeaderPosition = headerView.frame.origin
            endTableViewPosition = tableView.frame.origin
            navigationController?.popViewController(animated: true)
            stopScrolling = true
        } else {
            stopScrolling = false
        }
    }
    
    open override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        super.scrollViewDidScroll(scrollView)
        
        let yOffset = scrollView.contentOffset.y
        if yOffset < 0 {
            scrollView.scrollIndicatorInsets.top = -yOffset
        } else if yOffset > scrollView.contentSize.height - scrollView.bounds.size.height {
            scrollView.scrollIndicatorInsets.bottom = yOffset - (scrollView.contentSize.height - scrollView.bounds.size.height)
        } else {
            scrollView.scrollIndicatorInsets = UIEdgeInsets.zero
        }
        
        if stopScrolling {
            scrollView.setContentOffset(scrollView.contentOffset, animated: false)
            return
        }
        
        let standardValue = Const.standardValue
        let transitioningController = SAInboxAnimatedTransitioningController.shared
        let value = yOffset - (scrollView.contentSize.height - scrollView.bounds.size.height)
        let transitioningContainerView = transitioningController.transitioningContainerView
        if  value >= 0  {
            transitioningContainerView.lowerMoveToValue(value)
            transitioningController.transitioningType = .bottomPop
            alphaView.alpha = 1 - min(max(0 ,value / (standardValue * 2)), 1)
            return
        } else {
            transitioningContainerView.lowerMoveToValue(0)
            alphaView.alpha = 0
        }
        
        if yOffset <= 0 {
            transitioningContainerView.upperMoveToValue(-yOffset)
            headerView.frame.origin.y = -yOffset
            transitioningController.transitioningType = .topPop
            alphaView.alpha = 1 - min(max(0 ,-yOffset / (standardValue * 2)), 1)
        } else {
            transitioningContainerView.upperMoveToValue(0)
            alphaView.alpha = 0
            headerView.frame.origin.y = 0
        }
    }
}

