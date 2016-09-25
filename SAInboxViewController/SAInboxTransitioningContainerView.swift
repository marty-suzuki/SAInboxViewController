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
    private struct Const {
        static let imageTag: Int = 10001
    }
    
    fileprivate struct ImageInformation {
        enum Position {
            case below, above, target
        }
        
        let tag: Int
        let initialOrigin: CGPoint
        let height: CGFloat
        let isTarget: Bool
        let position: Position
    }
    
    //MARK: - Instance Properties
    fileprivate var imageInformations: [ImageInformation] = []
    fileprivate(set) var targetPosition: CGPoint?
    fileprivate(set) var targetHeight: CGFloat?
    fileprivate(set) var headerImageView = UIImageView()
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
    var headerViewOrigin: CGPoint = CGPoint.zero
    
    init() {
        super.init(frame: CGRect.zero)
        backgroundColor = .clear
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: - Internal Methods
    func setupContainer(_ targetCell: UITableViewCell, cells: [UITableViewCell], superview: UIView) {
        var detectTarget = false
        imageInformations = cells.enumerated().flatMap { (offset: Int, element: UITableViewCell) -> ImageInformation? in
            guard let point = element.superview?.convert(element.frame.origin, to: superview) else { return nil }
            let isTarget: Bool
            if targetCell == element {
                isTarget = true
                detectTarget = true
                targetPosition = point
                targetHeight = element.frame.height
            } else {
                isTarget = false
            }
            
            let tag = Const.imageTag + offset
            let imageView = UIImageView(frame: element.bounds)
            element.selectionStyle = .none
            imageView.image = element.screenshotImage()
            element.selectionStyle = .default
            imageView.tag = tag
            imageView.frame.origin = point
            addSubview(imageView)
            
            let position: ImageInformation.Position = isTarget ? .target : !detectTarget ? .below : .above
            return ImageInformation(tag: tag, initialOrigin: point, height: element.frame.height, isTarget: isTarget, position: position)
        }
    }
    
    func resetContainer() {
        subviews.forEach { $0.removeFromSuperview() }
        imageInformations.removeAll(keepingCapacity: false)
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
    
    func upperMoveToValue(_ value: CGFloat) {
        imageInformations.forEach {
            guard let targetPosition = targetPosition , targetPosition.y >= $0.initialOrigin.y else { return }
            viewWithTag($0.tag)?.frame.origin.y = $0.initialOrigin.y - targetPosition.y + value
        }
    }
    
    func lowerMoveToValue(_ value: CGFloat) {
        imageInformations.forEach {
            guard let targetPosition = targetPosition , targetPosition.y < $0.initialOrigin.y else { return }
            viewWithTag($0.tag)?.frame.origin.y = frame.size.height + ($0.initialOrigin.y - targetPosition.y) - $0.height - value
        }
    }
}

