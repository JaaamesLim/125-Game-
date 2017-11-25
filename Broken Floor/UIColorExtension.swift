//
//  UIColorExtension.swift
//  Broken Floor
//
//  Created by JAMES GOT GAME 07 on 14/6/17.
//  Copyright © 2017 Hamaste. All rights reserved.
//

import UIKit

extension UIColor {
    class func rgb(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat) -> UIColor {
        return UIColor(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
}
