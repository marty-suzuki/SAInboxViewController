//
//  UIView+Utils.swift
//  SAInboxViewController
//
//  Created by Taiki Suzuki on 2015/08/15.
//  Copyright (c) 2015年 Taiki Suzuki. All rights reserved.
//

import UIKit

extension UIView {
    public func screenshotImage() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.mainScreen().scale)
        layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}