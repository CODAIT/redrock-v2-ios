//
//  SearchViewController.swift
//  RedRock
//
//  Created by Jonathan Alter on 5/2/16.
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
import SwiftyJSON

class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    var hashtags = JSON(Array())
    var handles = JSON(Array())
    var searchTerm: String?
    
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var leftTableView: UITableView!
    @IBOutlet weak var rightTableView: UITableView!
    @IBOutlet weak var trendingLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController!.navigationBar.barTintColor = Config.navBarColor
        self.navigationController!.navigationBar.tintColor = Config.darkBlueColor
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : Config.darkBlueColor];
        self.navigationController!.navigationBar.translucent = false;
        
        Network.sharedInstance.getTopTerms { (json, error) in
            guard json != nil && error == nil else {
                log.debug("getTopTerms error: \(error)")
                return
            }
            self.hashtags = json!["hashtags"]
            self.handles = json!["handles"]
            self.leftTableView.reloadData()
            self.rightTableView.reloadData()
            
            if self.handles.count > 0 || self.handles.count > 0 {
                self.trendingLabel.hidden = false
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
    }
    
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        (segue.destinationViewController as! RelatedTermsViewController).searchTerm = searchTerm!
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        // Does not get called on table click, only on searchButton click and return
        
        searchTerm = Utils.cleanSearchText(self.searchField.text!)
        
        if searchTerm == "" {
            Utils.shakeView(self.searchField)
            
            return false
        }
        
        return true
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")
        
        cell?.backgroundColor = UIColor.clearColor()
        
        let label = cell?.viewWithTag(1) as! UILabel
        
        let list = listForTable(tableView)
        label.text = list[indexPath.row]["term"].stringValue
        
        return cell!
    }

    func  tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let list = listForTable(tableView)
        return list.count
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let list = listForTable(tableView)
        searchTerm = list[indexPath.row]["term"].stringValue
        performSegueWithIdentifier("showRelatedTerms", sender: nil)
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if shouldPerformSegueWithIdentifier("showRelatedTerms", sender: self.searchField) {
            performSegueWithIdentifier("showRelatedTerms", sender: self.searchField)
        }
        return true
    }
    
    // MARK: - Utils
    
    func listForTable(tableView: UITableView) -> JSON {
        return tableView == rightTableView ? hashtags : handles
    }
    
}
