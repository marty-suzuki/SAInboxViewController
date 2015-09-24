//
//  SAInboxTransitioningContainerView.swift
//  SAInboxViewController
//
//  Created by Taiki Suzuki on 2015/08/15.
//  Copyright (c) 2015年 Taiki Suzuki. All rights reserved.
//

import UIKit

class SAInboxTransitioningContainerView: UIView {
    
    //MARK: - Inner Structs
    private struct ImageInformation {
        enum Position {
            case Below, Above, Target
        }
        
        let tag: Int
        let initialOrigin: CGPoint
        let height: CGFloat
        let isTarget: Bool
        let position: Position
    }
    
    //MARK: - Instance Properties
    private var imageInformations: [ImageInformation] = []
    private(set) var targetPosition: CGPoint?
    private(set) var targetHeight: CGFloat?
    private(set) var headerImageView = UIImageView()
    var headerImage: UIImage? {
        set {
            headerImageView.image = newValue
            headerImageView.frame.size = CGSize(width: frame.size.width, height: 64)
            addSubview(headerImageView)
        }
        get {
            return headerImageView.image
        }
    }
    var headerViewOrigin: CGPoint = CGPointZero
    
    init() {
        super.init(frame: CGRectZero)
        backgroundColor = .clearColor()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - Internal Methods
extension SAInboxTransitioningContainerView {
    func setupContainer(targetCell: UITableViewCell, cells: [UITableViewCell], superview: UIView) {
        var imageTag: Int = 10001
        var detectTarget = false
        for cell in cells {
            if let point = cell.superview?.convertPoint(cell.frame.origin, toView: superview) {
                
                let isTarget: Bool
                if targetCell == cell {
                    isTarget = true
                    detectTarget = true
                    targetPosition = point
                    targetHeight = CGRectGetHeight(cell.frame)
                } else {
                    isTarget = false
                }
                
                let position: ImageInformation.Position
                if isTarget {
                    position = .Target
                } else if !detectTarget {
                    position = .Below
                } else {
                    position = .Above
                }
                
                let imageView = UIImageView(frame: cell.bounds)
                cell.selectionStyle = .None
                imageView.image = cell.screenshotImage()
                cell.selectionStyle = .Default
                imageView.tag = imageTag
                imageView.frame.origin = point
                addSubview(imageView)
                
                imageInformations += [ImageInformation(tag: imageTag++, initialOrigin: point, height: CGRectGetHeight(cell.frame), isTarget: isTarget, position: position)]
            }
        }
    }
    
    func resetContainer() {
        for view in subviews { view.removeFromSuperview() }
        imageInformations.removeAll(keepCapacity: false)
        targetPosition = nil
    }
    
    func open() {
        if let targetPosition = targetPosition {
            for imageInformation in imageInformations {
                let view = viewWithTag(imageInformation.tag)
                if imageInformation.isTarget {
                    view?.alpha = 0
                }
                if imageInformation.initialOrigin.y <= targetPosition.y {
                    view?.frame.origin.y = imageInformation.initialOrigin.y - targetPosition.y
                } else {
                    view?.frame.origin.y = frame.size.height + (imageInformation.initialOrigin.y - targetPosition.y) - imageInformation.height
                }
            }
        }
    }
    
    func close() {
        for imageInformation in imageInformations {
            let view = viewWithTag(imageInformation.tag)
            if imageInformation.isTarget {
                view?.alpha = 1
            }
            view?.frame.origin.y = imageInformation.initialOrigin.y
        }
    }
    
    func upperMoveToValue(value: CGFloat) {
        for imageInformation in imageInformations {
            if let targetPosition = targetPosition where targetPosition.y >= imageInformation.initialOrigin.y {
                viewWithTag(imageInformation.tag)?.frame.origin.y = imageInformation.initialOrigin.y - targetPosition.y + value
            }
        }
    }
    
    func lowerMoveToValue(value: CGFloat) {
        for imageInformation in imageInformations {
            if let targetPosition = targetPosition where targetPosition.y < imageInformation.initialOrigin.y {
                viewWithTag(imageInformation.tag)?.frame.origin.y = frame.size.height + (imageInformation.initialOrigin.y - targetPosition.y) - imageInformation.height - value
            }
        }
    }
}

