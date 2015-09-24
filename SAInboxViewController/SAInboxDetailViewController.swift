//
//  SAInboxDetailViewController.swift
//  SAInboxViewController
//
//  Created by Taiki Suzuki on 2015/08/15.
//  Copyright (c) 2015年 Taiki Suzuki. All rights reserved.
//

import UIKit

@objc public protocol SAInboxDetailViewControllerDelegate: NSObjectProtocol {
    optional func inboxDetailViewControllerShouldChangeStatusBarColor(viewController: SAInboxDetailViewController, isScrollingDirectionUp: Bool)
}

public class SAInboxDetailViewController: SAInboxViewController {
    
    //MARK: Static Properties
    static private let kCellIdentifier = "Cell";
    static private let kStandardValue = CGRectGetHeight(UIScreen.mainScreen().bounds) * 0.2
    
    //MARK: Instatnce Properties
    private var headerPanGesture: UIPanGestureRecognizer?
    private var swipePanGesture: UIPanGestureRecognizer?
    private var stopScrolling = false
    
    private var defaultHeaderPosition: CGPoint = CGPointZero
    private var defaultTableViewPosition: CGPoint = CGPointZero
    
    var thumbImage: UIImage?
    private(set) var endHeaderPosition: CGPoint = CGPointZero
    private(set) var endTableViewPosition: CGPoint = CGPointZero
    
    public weak var delegate: SAInboxDetailViewControllerDelegate?
    
    let alphaView = UIView()
    
    //MARK: Initialize Methods
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
}

//MARK: - Life Cycle
public extension SAInboxDetailViewController {
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.backgroundColor = .clearColor()
        tableView.backgroundView?.backgroundColor = .clearColor()
        
        view.backgroundColor = .whiteColor()
        automaticallyAdjustsScrollViewInsets = false
        
        let headerPanGesture = UIPanGestureRecognizer(target: self, action: "handleHeaderPanGesture:")
        headerView.addGestureRecognizer(headerPanGesture)
        self.headerPanGesture = headerPanGesture
        
        let swipePanGesture = UIPanGestureRecognizer(target: self, action: "handleSwipePanGesture:")
        view.addGestureRecognizer(swipePanGesture)
        self.swipePanGesture = swipePanGesture
        
        shouldHideHeaderView = false
    }
    
    override public func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        view.insertSubview(SAInboxAnimatedTransitioningController.sharedInstance.transitioningContainerView, belowSubview: tableView)
        setupAlphaView()
        view.bringSubviewToFront(headerView)
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        defaultHeaderPosition = headerView.frame.origin
        defaultTableViewPosition = tableView.frame.origin
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

//MARK: - Private Methods
private extension SAInboxDetailViewController {
    private func setupAlphaView() {
        alphaView.frame = view.bounds
        alphaView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
        alphaView.alpha = 0
        view.insertSubview(alphaView, belowSubview: tableView)
    }
    
    private func calculateRudderBanding(distance: CGFloat, constant: CGFloat, dimension: CGFloat) -> CGFloat {
        return (1 - (1 / ((distance * constant / dimension) + 1))) * dimension
    }
}

//MARK: - Internal Methods
extension SAInboxDetailViewController {
    func resetContentOffset(isLower isLower: Bool) {
        if isLower {
            tableView.setContentOffset(CGPoint(x: 0, y: tableView.contentSize.height - tableView.bounds.size.height), animated: false)
        } else {
            tableView.setContentOffset(CGPointZero, animated: false)
        }
    }
    
    func handleSwipePanGesture(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translationInView(view)
        let velocity = gesture.velocityInView(view)
        
        switch gesture.state {
            case .Began:
                SAInboxAnimatedTransitioningController.sharedInstance.transitioningType = .SwipePop
                
            case .Changed:
                
                var position =  translation.x
                if position < 0 {
                    position = 0
                }
                
                let rudderBanding = calculateRudderBanding(position, constant: 0.55, dimension: view.frame.size.width)
                var headerPosition = defaultHeaderPosition.x +  rudderBanding
                if headerPosition < defaultHeaderPosition.x {
                    headerPosition = defaultHeaderPosition.x
                }
                headerView.frame.origin.x = headerPosition
                
                var tableViewPosition = defaultTableViewPosition.x +  rudderBanding
                if tableViewPosition < defaultTableViewPosition.x {
                    tableViewPosition = defaultTableViewPosition.x
                }
                tableView.frame.origin.x = tableViewPosition
                
                alphaView.alpha = 1 - min(rudderBanding / view.frame.size.width, 1)
                
            case .Cancelled, .Ended:
                if velocity.x > 0 {
                    endHeaderPosition = headerView.frame.origin
                    endTableViewPosition = tableView.frame.origin
                    navigationController?.popViewControllerAnimated(true)
                } else {
                    UIView.animateWithDuration(0.25) {
                        self.headerView.frame.origin = self.defaultHeaderPosition
                        self.tableView.frame.origin = self.defaultTableViewPosition
                    }
                }
                
            case .Failed, .Possible:
                break
        }
    }
    
    func handleHeaderPanGesture(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translationInView(view)
        let velocity = gesture.velocityInView(view)
        
        switch gesture.state {
            case .Began:
                SAInboxAnimatedTransitioningController.sharedInstance.transitioningType = .HeaderPop
                
            case .Changed:
                var position = translation.y
                if position < 0 {
                    position = 0
                }
                
                let rudderBanding = calculateRudderBanding(position, constant: 0.55, dimension: view.frame.size.height)
                var headerPosition = defaultHeaderPosition.y + rudderBanding
                if headerPosition < defaultHeaderPosition.y {
                    headerPosition = defaultHeaderPosition.y
                }
                headerView.frame.origin.y = headerPosition
                
                var tableViewPosition = defaultTableViewPosition.y + rudderBanding
                if tableViewPosition < defaultTableViewPosition.y {
                    tableViewPosition = defaultTableViewPosition.y
                }
                tableView.frame.origin.y = tableViewPosition
                
                SAInboxAnimatedTransitioningController.sharedInstance.transitioningContainerView.upperMoveToValue(rudderBanding)
                
                alphaView.alpha = 1 - min(1, (rudderBanding / 180))
                
            case .Cancelled, .Ended:
                if velocity.y  > 0 {
                    endHeaderPosition = headerView.frame.origin
                    endTableViewPosition = tableView.frame.origin
                    navigationController?.popViewControllerAnimated(true)
                } else {
                    UIView.animateWithDuration(0.25) {
                        self.headerView.frame.origin = self.defaultHeaderPosition
                        self.tableView.frame.origin = self.defaultTableViewPosition
                        SAInboxAnimatedTransitioningController.sharedInstance.transitioningContainerView.upperMoveToValue(0)
                        self.alphaView.alpha = 1
                    }
                }
                
            case .Failed, .Possible:
                break
        }
    }
}

//MARK: - UITableViewDelegate Methods
extension SAInboxDetailViewController {
    public func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let yOffset = scrollView.contentOffset.y
        let value = yOffset - (scrollView.contentSize.height - scrollView.bounds.size.height)
        
        let standardValue = SAInboxDetailViewController.kStandardValue
        if value > standardValue || yOffset < -standardValue {
            endHeaderPosition = headerView.frame.origin
            endTableViewPosition = tableView.frame.origin
            navigationController?.popViewControllerAnimated(true)
            stopScrolling = true
        } else {
            stopScrolling = false
        }
    }
    
    public override func scrollViewDidScroll(scrollView: UIScrollView) {
        super.scrollViewDidScroll(scrollView)
        
        let yOffset = scrollView.contentOffset.y
        if yOffset < 0 {
            scrollView.scrollIndicatorInsets.top = -yOffset
        } else if yOffset > scrollView.contentSize.height - scrollView.bounds.size.height {
            scrollView.scrollIndicatorInsets.bottom = yOffset - (scrollView.contentSize.height - scrollView.bounds.size.height)
        } else {
            scrollView.scrollIndicatorInsets = UIEdgeInsetsZero
        }
        
        if stopScrolling {
            scrollView.setContentOffset(scrollView.contentOffset, animated: false)
            return
        }
        
        let standardValue = SAInboxDetailViewController.kStandardValue
        let transitioningController = SAInboxAnimatedTransitioningController.sharedInstance
        let value = yOffset - (scrollView.contentSize.height - scrollView.bounds.size.height)
        let transitioningContainerView = transitioningController.transitioningContainerView
        if  value >= 0  {
            transitioningContainerView.lowerMoveToValue(value)
            transitioningController.transitioningType = .BottomPop
            alphaView.alpha = 1 - min(max(0 ,value / (standardValue * 2)), 1)
            return
        } else {
            transitioningContainerView.lowerMoveToValue(0)
            alphaView.alpha = 0
        }
        
        if yOffset <= 0 {
            transitioningContainerView.upperMoveToValue(-yOffset)
            headerView.frame.origin.y = -yOffset
            transitioningController.transitioningType = .TopPop
            alphaView.alpha = 1 - min(max(0 ,-yOffset / (standardValue * 2)), 1)
        } else {
            transitioningContainerView.upperMoveToValue(0)
            alphaView.alpha = 0
            headerView.frame.origin.y = 0
        }
    }
}

