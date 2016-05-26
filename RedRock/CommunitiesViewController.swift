//
//  CommunitiesViewController.swift
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

class CommunitiesViewController: UIViewController {

    var searchTerms: String = "#spark"
    var wv: VisMasterViewController?
    
    @IBOutlet weak var visHolder: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup Vis
        wv = VisFactory.visualizationControllerForType(.CommunityGraph)!
        wv!.view.frame = CGRect(x: 0, y: 0, width: visHolder.bounds.width, height: visHolder.bounds.height)
        
        self.addChildViewController(wv!)
        self.visHolder.addSubview((wv?.view)!)
        wv?.didMoveToParentViewController(self)
        
        // Make request
        Network.sharedInstance.getCommunities(searchTerms) { (json, error) in
            guard self.wv != nil else {
                log.warning("Network response can not find webview to display data")
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let dest = segue.destinationViewController as! DetailViewController
        dest.communityId = String((sender as! NSDictionary)["community"]!)
        dest.searchTerms = self.searchTerms
    }

}
