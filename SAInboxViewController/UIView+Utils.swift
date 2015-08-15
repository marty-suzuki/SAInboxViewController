//
//  UIView+Utils.swift
//  SAInboxViewController
//
//  Created by 鈴木大貴 on 2015/08/11.
//
//

import UIKit

extension UIView {
    public func screenshotImage() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.mainScreen().scale)
        layer.renderInContext(UIGraphicsGetCurrentContext())
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}