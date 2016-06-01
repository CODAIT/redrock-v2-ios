//
//  VisSentimentBarViewController.swift
//  RedRock
//
//  Created by Jonathan Alter on 6/1/16.
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

typealias SentimentType = (positive:Int , negative:Int, neutral:Int)

class VisSentimentBarViewController: UIViewController {

    @IBOutlet weak var sentimentBarHolderView: UIView!
    @IBOutlet weak var negativeBarHeight: NSLayoutConstraint!
    @IBOutlet weak var positiveBarHeight: NSLayoutConstraint!
    
    @IBOutlet weak var neutralPercentLabel: UILabel!
    @IBOutlet weak var negativePercentLabel: UILabel!
    @IBOutlet weak var positivePercentLabel: UILabel!
    
    var sentiment: SentimentType? {
        didSet {
            updateBar()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateBar() {
        guard sentiment != nil else {
            log.verbose("sentiment is nil")
            return
        }
        
        let pos = Float((sentiment?.positive)!)
        let neg = Float((sentiment?.negative)!)
        let neut = Float((sentiment?.neutral)!)
        let total = pos + neg + neut
        let positiveRatio = pos / total
        let negativeRatio = neg / total
        let neutralRatio = neut / total
        
        // Set label text
        neutralPercentLabel.text = String(format: "%.0f %%", round(neutralRatio * 100))
        negativePercentLabel.text = String(format: "%.0f %%", round(negativeRatio * 100))
        positivePercentLabel.text = String(format: "%.0f %%", round(positiveRatio * 100))
        
        // Set bar heights
        let holderHeight = sentimentBarHolderView.bounds.height
        positiveBarHeight.constant = CGFloat(positiveRatio) * holderHeight
        negativeBarHeight.constant = CGFloat(negativeRatio) * holderHeight
    }

}
