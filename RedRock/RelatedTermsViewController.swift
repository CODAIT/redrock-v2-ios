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

class RelatedTermsViewController: UIViewController {

    var searchTerm: String = "@ibm"
    var wv: VisMasterViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup Vis
        wv = VisFactory.visualizationControllerForType(VisTypes.ForceGraph)
        wv?.view.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
        
        self.addChildViewController(wv!)
        self.view.addSubview((wv?.view)!)
        wv?.didMoveToParentViewController(self)
        
        wv?.searchText = searchTerm
        
        // Make request
        Network.sharedInstance.getSynonyms(searchTerm) { (json, error) in
            guard self.wv != nil else {
                log.error("Network response can not find webview to display data")
                return
            }
            
            self.wv?.json = json
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        wv?.onBlur()
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

}
