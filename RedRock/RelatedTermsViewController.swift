//
//  RelatedTermsViewController.swift
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

class RelatedTermsViewController: UIViewController, UITextFieldDelegate, VisInteractionDelegate {

    var searchTerm: String = "@ibm"
    var wv: VisMasterViewController?
    
    @IBOutlet weak var searchHolder: UIView!
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var visHolder: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.searchField.text = searchTerm
        
        // Setup Vis
        wv = VisFactory.visualizationControllerForType(VisTypes.ForceGraph)
        wv?.view.frame = CGRect(x: 0, y: 0, width: visHolder.bounds.width, height: visHolder.bounds.height)
        
        self.addChildViewController(wv!)
        self.visHolder.addSubview((wv?.view)!)
        wv?.didMoveToParentViewController(self)
        
        wv?.delegate = self
        wv?.searchText = searchTerm
        
        // Make request
        makeSearchRequest()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        
        self.navigationController?.navigationBarHidden = false
        
        // Clearing community details cache because we will have a new community if we navigate back here
        Network.sharedInstance.clearCommunityDetailsCache()
    }
    
    override func viewWillDisappear(animated: Bool) {
        wv?.onBlur()
    }
    
    @IBAction func searchButtonClicked() {
        if shouldSearch() {
            wv?.onLoadingState()
            makeSearchRequest()
        }
    }

    func makeSearchRequest() {
        Network.sharedInstance.getSynonyms(searchTerm) { (json, error) in
            guard self.wv != nil else {
                log.error("Network response can not find webview to display data")
                return
            }
            
            self.wv?.json = json
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        // Pass along the search terms
        var searchTerms = (wv?.chartData)!.map({"\($0[0])"}).joinWithSeparator(",")
        searchTerms = searchTerm + "," + searchTerms
        (segue.destinationViewController as! CommunitiesViewController).searchTerms = searchTerms
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        searchButtonClicked()
        return true
    }

    // MARK: - VisInteractionDelegate
    
    func willReloadChart(searchTerm: String) {
        self.searchField.text = searchTerm
    }
    
    // MARK: - Utils
    
    func shouldSearch() -> Bool {
        // Does not get called on table click, only on searchButton click and return
        
        searchTerm = Utils.cleanSearchText(self.searchField.text!)
        
        if searchTerm == "" {
            Utils.shakeView(self.searchHolder)
            
            return false
        }
        
        return true
    }
}
