//
//  SearchViewController.swift
//  RedRock
//
//  Created by Jonathan Alter on 5/2/16.
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

class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    var hashtags = JSON(Array())
    var handles = JSON(Array())
    
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var leftTableView: UITableView!
    @IBOutlet weak var rightTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: Add tapping on trending item searches by that item
//        Network.sharedInstance.findTopTerms { (json, error) in
//            self.hashtags = json!["hashtags"]
//            self.handles = json!["handles"]
//            self.leftTableView.reloadData()
//            self.rightTableView.reloadData()
//        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        let searchTerm = (searchField.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()))!
        (segue.destinationViewController as! RelatedTermsViewController).searchTerm = searchTerm
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        
        var searchText = self.searchField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        searchText = searchText.stringByReplacingOccurrencesOfString(" ", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        if searchText == "" {
            let animation = CABasicAnimation(keyPath: "position")
            animation.duration = 0.07
            animation.repeatCount = 2
            animation.autoreverses = true
            animation.fromValue = NSValue(CGPoint: CGPointMake(self.searchField.center.x - 5, self.searchField.center.y))
            animation.toValue = NSValue(CGPoint: CGPointMake(self.searchField.center.x + 5, self.searchField.center.y))
            self.searchField.layer.addAnimation(animation, forKey: "position")
            
            return false
        }
        
        return true
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")
        
        let label = cell?.viewWithTag(1) as! UILabel
        
        let list = tableView == rightTableView ? hashtags : handles
        label.text = list[indexPath.row]["term"].stringValue
        
        return cell!
    }

    func  tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let list = tableView == rightTableView ? hashtags : handles
        return list.count
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("showRelatedTerms", sender: nil)
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if shouldPerformSegueWithIdentifier("showRelatedTerms", sender: self.searchField) {
            performSegueWithIdentifier("showRelatedTerms", sender: self.searchField)
        }
        return true
    }
}
