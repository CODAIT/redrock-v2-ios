//
//  NEWDetailViewController.swift
//  RedRock
//
//  Created by Jonathan Alter on 5/2/16.
//  Copyright © 2016 IBM. All rights reserved.
//

import UIKit

class NEWDetailViewController: UIViewController {

    var searchTerm: String = "test"
    var wordCloudWV: VisMasterViewController?
    var sentimentWV: VisMasterViewController?
    
    @IBOutlet weak var leftView: UIView!
    @IBOutlet weak var rightView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup Vis
        wordCloudWV = VisFactory.visualizationControllerForType(VisTypes.ForceGraph)!
        wordCloudWV!.view.frame = CGRect(x: 0, y: 0, width: leftView.bounds.width, height: leftView.bounds.height)
        
        self.addChildViewController(wordCloudWV!)
        self.leftView.addSubview((wordCloudWV?.view)!)
        wordCloudWV?.didMoveToParentViewController(self)
        
        // Setup Vis
        sentimentWV = VisFactory.visualizationControllerForType(VisTypes.ForceGraph)!
        sentimentWV!.view.frame = CGRect(x: 0, y: 0, width: rightView.bounds.width, height: rightView.bounds.height)
        
        self.addChildViewController(sentimentWV!)
        self.rightView.addSubview((sentimentWV?.view)!)
        sentimentWV?.didMoveToParentViewController(self)
        
        // Make request
        Network.sharedInstance.findSynonyms(searchTerm) { (json, error) in
            guard self.wordCloudWV != nil else {
                Log("Network response can not find webview to display data")
                return
            }
            
            self.wordCloudWV?.json = json
            
            guard self.wordCloudWV != nil else {
                Log("Network response can not find webview to display data")
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
