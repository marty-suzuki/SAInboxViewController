//
//  SAInboxAnimatedTransitioningController.swift
//  SAInboxViewController
//
//  Created by 鈴木大貴 on 2015/08/11.
//
//

import UIKit

public class SAInboxAnimatedTransitioningController: NSObject, UIViewControllerAnimatedTransitioning {
    
    enum TrantioningType {
        case Push, SwipePop, BottomPop, TopPop, HeaderPop
    }
    
    //MARK: - Static Properties
    static private let _sharedInstance = SAInboxAnimatedTransitioningController()
    
    //MARK: - Static Methods
    public class func sharedInstance() -> SAInboxAnimatedTransitioningController {
        return _sharedInstance
    }
    
    //MARK: - Instance Properties
    let transitioningContainerView = SAInboxTransitioningContainerView()
    var transitioningType: TrantioningType = .Push
    var selectedCell: UITableViewCell?
    private var _operation: UINavigationControllerOperation?
}

//MARK: - Public Methods
public extension SAInboxAnimatedTransitioningController {
    public func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return 0.3
    }
    
    public func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
        let contentView = transitionContext.containerView()
        
        contentView.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
        
        let duration = transitionDuration(transitionContext)
        if let toViewController = toViewController, fromViewController = fromViewController, operation = _operation {
            switch (operation) {
                case .Push:
                    pushTransition(duration, transitionContext: transitionContext, transitioningType: transitioningType, transitioningContainerView: transitioningContainerView, contentView: contentView, toViewController: toViewController, fromViewController: fromViewController)
                
                case .Pop:
                    popTransition(duration, transitionContext: transitionContext, transitioningType: transitioningType, transitioningContainerView: transitioningContainerView, contentView: contentView, toViewController: toViewController, fromViewController: fromViewController)
                
                case .None:
                    break
            }
            
        }
    }
    
    public func setOperation(operation: UINavigationControllerOperation) -> SAInboxAnimatedTransitioningController {
        _operation = operation
        return self
    }
    
    public func configureCotainerView(superview: UIView, cell: UITableViewCell, cells: [UITableViewCell], headerImage: UIImage) {
        transitioningContainerView.frame = superview.bounds
        transitioningContainerView.setupContainer(cell, cells:cells, superview: superview)
        transitioningContainerView.headerImage = headerImage
    }
}

//MARK: - Private Methods
private extension SAInboxAnimatedTransitioningController {
    private func pushTransition(duration: NSTimeInterval, transitionContext: UIViewControllerContextTransitioning, transitioningType: TrantioningType, transitioningContainerView: SAInboxTransitioningContainerView, contentView: UIView, toViewController: UIViewController, fromViewController: UIViewController) {
        contentView.insertSubview(toViewController.view, aboveSubview: fromViewController.view)
        contentView.addSubview(transitioningContainerView)
        
        if let targetPosition = transitioningContainerView.targetPosition {
            toViewController.view.frame.origin = targetPosition
        }
        
        UIView.animateWithDuration(duration, animations: {
            transitioningContainerView.open()
            toViewController.view.frame.origin.y = 0
            transitioningContainerView.headerImageView.frame.origin.y = -transitioningContainerView.headerImageView.frame.size.height
        }) { finished in
            transitioningContainerView.removeFromSuperview()
            transitionContext.completeTransition(true)
        }
    }
    
    private func popTransition(duration: NSTimeInterval, transitionContext: UIViewControllerContextTransitioning, transitioningType: TrantioningType, transitioningContainerView: SAInboxTransitioningContainerView, contentView: UIView, toViewController: UIViewController, fromViewController: UIViewController) {
        contentView.insertSubview(toViewController.view, belowSubview: fromViewController.view)
        contentView.addSubview(transitioningContainerView)
        
        if let fromViewController = fromViewController as? SAInboxDetailViewController {
            fromViewController.view.frame.origin = fromViewController.endHeaderPosition
            toViewController.view.hidden = true
            
            if transitioningType == .TopPop || transitioningType == .HeaderPop {
                fromViewController.resetContentOffset(isLower: false)
            }
        
            UIView.animateWithDuration(duration, animations: {
                if let targetPosition = transitioningContainerView.targetPosition, targetHeight = transitioningContainerView.targetHeight {
                    if transitioningType == .BottomPop {
                        fromViewController.view.frame.origin.y = -(fromViewController.view.frame.size.height - targetPosition.y) + targetHeight
                    } else if transitioningType == .TopPop || transitioningType == .HeaderPop {
                        fromViewController.view.frame.origin.y = targetPosition.y
                    }
                }
                transitioningContainerView.headerImageView.frame.origin.y = 0
                
                if transitioningType == .BottomPop {
                    fromViewController.resetContentOffset(isLower: true)
                }
                
                transitioningContainerView.close()
                
                fromViewController.view.frame.origin.x = 0
                
            }) { finished in
                toViewController.view.hidden = false
                transitioningContainerView.resetContainer()
                transitioningContainerView.removeFromSuperview()
                transitionContext.completeTransition(true)
            }
        }
    }
}
