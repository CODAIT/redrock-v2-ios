//
//  VisWordCountViewController.swift
//  RedRock
//
//  Created by Jonathan Alter on 5/26/16.
//  Copyright © 2016 IBM. All rights reserved.
//

import UIKit
import SwiftyJSON

class VisWordCountViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var words = JSON([]) {
        didSet {
            largestElement = words.first
            
            guard tableView != nil else {
                log.verbose("tableView is nil")
                return
            }
            
            tableView.reloadData()
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
