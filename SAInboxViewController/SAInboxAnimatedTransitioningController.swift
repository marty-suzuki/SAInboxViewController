//
//  SAInboxAnimatedTransitioningController.swift
//  SAInboxViewController
//
//  Created by Taiki Suzuki on 2015/08/15.
//  Copyright (c) 2015年 Taiki Suzuki. All rights reserved.
//

import UIKit

open class SAInboxAnimatedTransitioningController: NSObject, UIViewControllerAnimatedTransitioning {
    
    enum TrantioningType {
        case push, swipePop, bottomPop, topPop, headerPop
    }
    
    //MARK: - Static Properties
    open static let sharedInstance = SAInboxAnimatedTransitioningController()
    
    //MARK: - Instance Properties
    let transitioningContainerView = SAInboxTransitioningContainerView()
    var transitioningType: TrantioningType = .push
    var selectedCell: UITableViewCell?
    fileprivate var operation: UINavigationControllerOperation?

    //MARK: - Public Methods
    open func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    open func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to),
            let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
        else { return }
        
        let contentView = transitionContext.containerView
        guard let operation = operation else { return }
        contentView.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
        
        let duration = transitionDuration(using: transitionContext)
        switch (operation) {
        case .push:
            pushTransition(duration, transitionContext: transitionContext, transitioningType: transitioningType, transitioningContainerView: transitioningContainerView, contentView: contentView, toViewController: toViewController, fromViewController: fromViewController)
            return
            
        case .pop:
            popTransition(duration, transitionContext: transitionContext, transitioningType: transitioningType, transitioningContainerView: transitioningContainerView, contentView: contentView, toViewController: toViewController, fromViewController: fromViewController)
            return
            
        default:
            break
        }
        transitionContext.completeTransition(true)
    }
    
    open func setOperation(_ operation: UINavigationControllerOperation) -> SAInboxAnimatedTransitioningController {
        self.operation = operation
        return self
    }
    
    open func configureCotainerView(_ viewController: SAInboxViewController, cell: UITableViewCell, cells: [UITableViewCell], headerImage: UIImage) {
        transitioningContainerView.frame = viewController.view.bounds
        transitioningContainerView.setupContainer(cell, cells:cells, superview: viewController.view)
        transitioningContainerView.headerImage = headerImage
        transitioningContainerView.headerViewOrigin = viewController.headerView.frame.origin
        transitioningContainerView.headerImageView.frame.origin.y = transitioningContainerView.headerViewOrigin.y
    }

    //MARK: - Private Methods
    fileprivate func pushTransition(_ duration: TimeInterval, transitionContext: UIViewControllerContextTransitioning, transitioningType: TrantioningType, transitioningContainerView: SAInboxTransitioningContainerView, contentView: UIView, toViewController: UIViewController, fromViewController: UIViewController) {
        contentView.insertSubview(toViewController.view, aboveSubview: fromViewController.view)
        contentView.addSubview(transitioningContainerView)
        
        if let targetPosition = transitioningContainerView.targetPosition {
            toViewController.view.frame.origin = targetPosition
        }
        
        UIView.animate(withDuration: duration, animations: {
            transitioningContainerView.open()
            toViewController.view.frame.origin.y = 0
            transitioningContainerView.headerImageView.frame.origin.y = -transitioningContainerView.headerImageView.frame.size.height
        }, completion: { finished in
            transitioningContainerView.removeFromSuperview()
            transitionContext.completeTransition(true)
        }) 
    }
    
    fileprivate func popTransition(_ duration: TimeInterval, transitionContext: UIViewControllerContextTransitioning, transitioningType: TrantioningType, transitioningContainerView: SAInboxTransitioningContainerView, contentView: UIView, toViewController: UIViewController, fromViewController: UIViewController) {
        contentView.insertSubview(toViewController.view, belowSubview: fromViewController.view)
        contentView.addSubview(transitioningContainerView)
        
        guard let fromViewController = fromViewController as? SAInboxDetailViewController else { return }
        
        fromViewController.view.frame.origin = fromViewController.endHeaderPosition
        toViewController.view.isHidden = true
        
        if transitioningType == .topPop || transitioningType == .headerPop {
            fromViewController.resetContentOffset(isLower: false)
        }
    
        UIView.animate(withDuration: duration, animations: {
            if let targetPosition = transitioningContainerView.targetPosition, let targetHeight = transitioningContainerView.targetHeight {
                if transitioningType == .bottomPop {
                    fromViewController.view.frame.origin.y = -(fromViewController.view.frame.size.height - targetPosition.y) + targetHeight
                } else if transitioningType == .topPop || transitioningType == .headerPop {
                    fromViewController.view.frame.origin.y = targetPosition.y
                }
            }
            transitioningContainerView.headerImageView.frame.origin.y = transitioningContainerView.headerViewOrigin.y
            
            if transitioningType == .bottomPop {
                fromViewController.resetContentOffset(isLower: true)
            }
            
            transitioningContainerView.close()
            
            fromViewController.view.frame.origin.x = 0
            
        }, completion: { finished in
            toViewController.view.isHidden = false
            transitioningContainerView.resetContainer()
            transitioningContainerView.removeFromSuperview()
            transitionContext.completeTransition(true)
        }) 
    }
}
