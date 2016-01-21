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
        cells.forEach {
            guard let point = $0.superview?.convertPoint($0.frame.origin, toView: superview) else { return }
            let isTarget: Bool
            if targetCell == $0 {
                isTarget = true
                detectTarget = true
                targetPosition = point
                targetHeight = CGRectGetHeight($0.frame)
            } else {
                isTarget = false
            }
            
            let imageView = UIImageView(frame: $0.bounds)
            $0.selectionStyle = .None
            imageView.image = $0.screenshotImage()
            $0.selectionStyle = .Default
            imageView.tag = imageTag
            imageView.frame.origin = point
            addSubview(imageView)
            
            let position: ImageInformation.Position = isTarget ? .Target : !detectTarget ? .Below : .Above
            imageInformations += [ImageInformation(tag: imageTag++, initialOrigin: point, height: CGRectGetHeight($0.frame), isTarget: isTarget, position: position)]
        }
    }
    
    func resetContainer() {
        subviews.forEach { $0.removeFromSuperview() }
        imageInformations.removeAll(keepCapacity: false)
        targetPosition = nil
    }
    
    func open() {
        guard let targetPosition = targetPosition else { return }
        imageInformations.forEach {
            let view = viewWithTag($0.tag)
            if $0.isTarget {
                view?.alpha = 0
            }
            if $0.initialOrigin.y <= targetPosition.y {
                view?.frame.origin.y = $0.initialOrigin.y - targetPosition.y
            } else {
                view?.frame.origin.y = frame.size.height + ($0.initialOrigin.y - targetPosition.y) - $0.height
            }
        }
    }
    
    func close() {
        imageInformations.forEach {
            let view = viewWithTag($0.tag)
            if $0.isTarget {
                view?.alpha = 1
            }
            view?.frame.origin.y = $0.initialOrigin.y
        }
    }
    
    func upperMoveToValue(value: CGFloat) {
        imageInformations.forEach {
            guard let targetPosition = targetPosition where targetPosition.y >= $0.initialOrigin.y else { return }
            viewWithTag($0.tag)?.frame.origin.y = $0.initialOrigin.y - targetPosition.y + value
        }
    }
    
    func lowerMoveToValue(value: CGFloat) {
        imageInformations.forEach {
            guard let targetPosition = targetPosition where targetPosition.y < $0.initialOrigin.y else { return }
            viewWithTag($0.tag)?.frame.origin.y = frame.size.height + ($0.initialOrigin.y - targetPosition.y) - $0.height - value
        }
    }
}

