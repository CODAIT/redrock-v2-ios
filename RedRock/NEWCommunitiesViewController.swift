//
//  NEWCommunitiesViewController.swift
//  RedRock
//
//  Created by Jonathan Alter on 5/2/16.
//  Copyright © 2016 IBM. All rights reserved.
//

import UIKit

class NEWCommunitiesViewController: UIViewController {

    var searchTerm: String = "test"
    var wv: VisMasterViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup Vis
        wv = VisFactory.visualizationControllerForType(VisTypes.ForceGraph)!
        wv!.view.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
        
        self.addChildViewController(wv!)
        self.view.addSubview((wv?.view)!)
        wv?.didMoveToParentViewController(self)
        
        // Make request
        Network.sharedInstance.findSynonyms(searchTerm) { (json, error) in
            guard self.wv != nil else {
                Log("Network response can not find webview to display data")
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
