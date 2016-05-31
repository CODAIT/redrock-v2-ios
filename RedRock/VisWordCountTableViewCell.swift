//
//  VisWordCountTableViewCell.swift
//  RedRock
//
//  Created by Jonathan Alter on 5/31/16.
//  Copyright © 2016 IBM. All rights reserved.
//

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
