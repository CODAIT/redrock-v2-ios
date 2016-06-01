//
//  DetailViewController.swift
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

class DetailViewController: UIViewController {

    var searchTerms: String? // The search terms used to generate the community graph
    var communityId: String? // The id of the community
    var wordCloudWV: VisMasterViewController?
    var sentimentWV: VisMasterViewController?
    
    @IBOutlet weak var leftView: UIView!
    @IBOutlet weak var rightView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup Vis
        wordCloudWV = VisFactory.visualizationControllerForType(VisTypes.WordCount)!
        wordCloudWV!.view.frame = CGRect(x: 0, y: 0, width: leftView.bounds.width, height: leftView.bounds.height)
        
        self.addChildViewController(wordCloudWV!)
        self.leftView.addSubview((wordCloudWV?.view)!)
        wordCloudWV?.didMoveToParentViewController(self)
        
        wordCloudWV?.communityId = communityId!
        
        // Setup Vis
        sentimentWV = VisFactory.visualizationControllerForType(VisTypes.SentimentBar)!
        sentimentWV!.view.frame = CGRect(x: 0, y: 0, width: rightView.bounds.width, height: rightView.bounds.height)
        
        self.addChildViewController(sentimentWV!)
        self.rightView.addSubview((sentimentWV?.view)!)
        sentimentWV?.didMoveToParentViewController(self)
        
        sentimentWV?.communityId = communityId!
        
        // Make request
        
        // TODO: replace the line below with this line when changing the web views
        Network.sharedInstance.getCommunityDetails(searchTerms!) { (json, error) in
        //Network.sharedInstance.getSynonyms(searchTerms!) { (json, error) in
            guard self.wordCloudWV != nil else {
                log.warning("Network response can not find webview to display data")
                return
            }
            
            self.wordCloudWV?.json = json
            
            guard self.sentimentWV != nil else {
                log.warning("Network response can not find webview to display data")
                return
            }
            
            self.sentimentWV?.json = json
            
            
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        wordCloudWV?.onBlur()
        sentimentWV?.onBlur()
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
