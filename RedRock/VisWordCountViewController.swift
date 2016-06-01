//
//  VisWordCountViewController.swift
//  RedRock
//
//  Created by Jonathan Alter on 5/26/16.
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
import SwiftyJSON

class VisWordCountViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var tableViewHolderView: UIView!
    
    var words = JSON([]) {
        didSet {
            largestElement = words.first
            
            guard tableView != nil else {
                log.verbose("tableView is nil")
                return
            }
            
            tableView.reloadData()
            layoutTableView()
        }
    }
    var largestElement: (String, JSON)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return words.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! VisWordCountTableViewCell
        
        let word = words[indexPath.row]
        let title = word[0]
        let count = word[1].floatValue
        let largestCount = largestElement?.1[1].floatValue
        cell.titleLabel?.text = "\(title)"
        cell.barPostion = count / largestCount!
        
        return cell
    }
    
    func layoutTableView() {
        let contentSize = tableView.contentSize
        let holderHeight = tableViewHolderView.bounds.height
        
        if contentSize.height < holderHeight {
            tableViewHeight.constant = contentSize.height
        } else {
            tableViewHeight.constant = holderHeight
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
