//
//  VisWordCountTableViewCell.swift
//  RedRock
//
//  Created by Jonathan Alter on 5/31/16.
//  Copyright © 2016 IBM. All rights reserved.
//

/**
 * (C) Copyright IBM Corp. 2015, 2015
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

class VisWordCountTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var barHolder: UIView!
    @IBOutlet weak var bar: UIView!
    @IBOutlet weak var barWidth: NSLayoutConstraint!
    
    var barPostion: NSNumber = 0.0 {
        didSet {
            updateBar()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        updateBar()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func updateBar() {
        let width = barHolder.bounds.width * CGFloat(barPostion)
        barWidth.constant = width
    }
    
}
