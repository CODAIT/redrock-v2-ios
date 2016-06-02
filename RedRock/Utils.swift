//
//  Utils.swift
//  RedRock
//
//  Created by Jonathan Alter on 6/1/16.
//  Copyright © 2016 IBM. All rights reserved.
//

/**
 * (C) Copyright IBM Corp. 2016, 2016
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

import UIKit
import Foundation

class Utils {
    
    static func cleanSearchText(text: String) -> String {
        let searchText = text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        return searchText.stringByReplacingOccurrencesOfString(" ", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
    
    static func shakeView(view: UIView) {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 2
        animation.autoreverses = true
        animation.fromValue = NSValue(CGPoint: CGPointMake(view.center.x - 5, view.center.y))
        animation.toValue = NSValue(CGPoint: CGPointMake(view.center.x + 5, view.center.y))
        view.layer.addAnimation(animation, forKey: "position")
    }
    
    static func changeMultiplier(constraint: NSLayoutConstraint, multiplier: CGFloat) -> NSLayoutConstraint {
        let newConstraint = NSLayoutConstraint(
            item: constraint.firstItem,
            attribute: constraint.firstAttribute,
            relatedBy: constraint.relation,
            toItem: constraint.secondItem,
            attribute: constraint.secondAttribute,
            multiplier: multiplier,
            constant: constraint.constant)
        
        newConstraint.priority = constraint.priority
        
        return newConstraint
    }
}