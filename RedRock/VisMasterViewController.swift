//
//  VisMasterViewController.swift
//  RedRock
//
//  Created by Jonathan Alter on 10/12/15.
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

enum VisTypes {
    case TreeMap
    case CirclePacking
    case ForceGraph
    case CommunityGraph
    case StackedBar
    case StackedBarDrilldownCirclePacking
    case TimeMap
    case SidewaysBar
    case PieChart
    case WordCloud
    case WordCount
    case SentimentBar
}

@objc
protocol VisLifeCycleProtocol {
    func onDataSet()
    optional func onFocus()
    optional func onBlur()
}

class VisMasterViewController: UIViewController {
    
    var type: VisTypes!
    var json: JSON! {
        didSet {
            guard json != nil else {
                return
            }
            
            onDataSet()
        }
    }
    var chartData: [[String]] = [[String]]()
    var errorDescription: String! = nil {
        didSet {
            guard errorDescription != nil else {
                return
            }
            onErrorState()
        }
    }
    var searchText: String = ""
    var communityId: String?
    
    var titleText: String {
        switch type! {
        case .ForceGraph:
            return "Similar"
        case .CommunityGraph:
            return "Community Clusters"
        case .WordCount:
            return "Commonly Used Terms"
        case .SentimentBar:
            return "Sentiment Analysis"
        default:
            return ""
        }
    }
    
    // MARK: - UI
    var visHolderView: UIView!
    var visHolderBackgroundView: UIView!
    var activityIndicator: UIActivityIndicatorView!
    var messageLabel: UILabel!
    var titleLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(type: VisTypes) {
        super.init(nibName: nil, bundle: nil)
        
        self.type = type
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = Config.lightGreyColor
        
        let formatStringV = "V:|-20-[visHolder]-20-|"
        let formatStringH = "H:|-20-[visHolder]-20-|"
        
        // Vis Background
        visHolderBackgroundView = UIView()
        visHolderBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        visHolderBackgroundView.backgroundColor = UIColor.whiteColor()
        view.addSubview(visHolderBackgroundView)
        
        let backgroundViews = ["visHolder" : visHolderBackgroundView]
        let bkConstraintsV =  NSLayoutConstraint.constraintsWithVisualFormat(formatStringV, options: [] , metrics: nil, views: backgroundViews)
        NSLayoutConstraint.activateConstraints(bkConstraintsV)
        
        let bkConstraintsH =  NSLayoutConstraint.constraintsWithVisualFormat(formatStringH, options: [] , metrics: nil, views: backgroundViews)
        NSLayoutConstraint.activateConstraints(bkConstraintsH)
        
        // Vis Holder
        visHolderView = UIView(frame: CGRect(x: 0, y: 0, width: 150, height: 150 ))
        visHolderView.translatesAutoresizingMaskIntoConstraints = false
        visHolderView.backgroundColor = UIColor.clearColor()
        view.addSubview(visHolderView)
        visHolderView.hidden = true
        
        let views = ["visHolder" : visHolderView]
        let constraintsV =  NSLayoutConstraint.constraintsWithVisualFormat(formatStringV, options: [] , metrics: nil, views: views)
        NSLayoutConstraint.activateConstraints(constraintsV)

        let constraintsH =  NSLayoutConstraint.constraintsWithVisualFormat(formatStringH, options: [] , metrics: nil, views: views)
        NSLayoutConstraint.activateConstraints(constraintsH)
        
        //Loading View
        activityIndicator = createActivityIndicatorView()
        view.addSubview(activityIndicator)
        addConstrainsToCenterInView(activityIndicator)
        
        //Results Label
        messageLabel = createUILabelForError()
        view.addSubview(messageLabel)
        addConstrainsToCenterInView(messageLabel)
        
        //Title Label
        titleLabel = UILabel(frame: CGRect(x: 20,y: 20,width: 50,height: 25))
        titleLabel.text = self.titleText
        titleLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 16)
        titleLabel.sizeToFit()
        titleLabel.adjustsFontSizeToFitWidth = true
        visHolderView.addSubview(titleLabel)
    }
    
    func onDataSet() {
        log.debug("Override onDataSet")
    }
    
    func onFocus() {
        log.debug("Override onFocus")
    }
    
    func onBlur() {
        log.debug("Override onBlur")
    }
    
    func transformData() {
        log.debug("Override transformData")
    }
    
    // MARK: - Display states
    
    func onLoadingState() {
        hideWithAnimation()
        activityIndicator.startAnimating()
        activityIndicator.hidden = false
        messageLabel.hidden = true
    }
    
    func onSuccessState() {
        revealWithAnimation()
        activityIndicator.stopAnimating()
        activityIndicator.hidden = true
        messageLabel.hidden = true
        visHolderView.bringSubviewToFront(titleLabel)
    }
    
    func onNoDataState() {
        self.errorDescription = Config.noDataMessage
    }
    
    func onErrorState() {
        hideWithAnimation()
        activityIndicator.stopAnimating()
        activityIndicator.hidden = true
        messageLabel.text = errorDescription
        messageLabel.hidden = false
    }
    
    func onHiddenState() {
        hideWithAnimation()
        activityIndicator.stopAnimating()
        activityIndicator.hidden = true
        messageLabel.hidden = true
    }
    
    func hideWithAnimation() {
        UIView.animateWithDuration(0.1, animations: {
            self.visHolderView.alpha = 0.0
            }, completion: { finished in
                self.visHolderView.hidden = true
        })
    }
    
    func revealWithAnimation() {
        self.visHolderView.hidden = false
        UIView.animateWithDuration(1.0, animations: {
            self.visHolderView.alpha = 1.0
            }, completion: { finished in
                self.visHolderView.hidden = false
        })
    }
    
    
    func clean() {
        errorDescription = nil
        json = nil
        onLoadingState()
    }
    
    
    // MARK: - UI Utils
    
    func createActivityIndicatorView() -> UIActivityIndicatorView
    {
        let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        activityIndicator.frame = CGRectMake(0, 0, 100, 100);
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
        activityIndicator.color = Config.darkBlueColor
        activityIndicator.startAnimating()
        activityIndicator.hidden = false
        
        return activityIndicator
    }
    
    func createUILabelForError() -> UILabel
    {
        let label = UILabel()
        label.frame = CGRectMake(0, 0, 300, 300);
        label.numberOfLines = 3
        label.textColor = Config.darkBlueColor
        label.text = Config.noDataMessage
        label.font = UIFont(name: "HelveticaNeue-Medium", size: 19)
        label.textAlignment = NSTextAlignment.Center
        label.hidden = true
        
        return label
    }
    
    func addConstrainsToCenterInView(viewToCenter: UIView) {
        let views = [
            "view": viewToCenter
        ]
        viewToCenter.translatesAutoresizingMaskIntoConstraints = false
        let viewConst_W = NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: NSLayoutFormatOptions.DirectionLeadingToTrailing, metrics: nil, views: views)
        let viewConst_H = NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options: NSLayoutFormatOptions.DirectionLeadingToTrailing, metrics: nil, views: views)
        view.addConstraints(viewConst_W)
        view.addConstraints(viewConst_H)
    }
    
    // MARK: - Utils
    
    func returnArrayOfLiveData(numberOfColumns: Int, containerName: String, json: JSON) -> Array<Array<String>>? {
        
        let col_cnt: Int? = numberOfColumns
        let row_cnt: Int? = json.array?.count
        
        if(row_cnt == nil || col_cnt == nil){
            errorDescription = Config.serverErrorMessage
            return nil
        }
        
        var tableData = Array(count: row_cnt!, repeatedValue: Array(count: col_cnt!, repeatedValue: ""))
        
        // populates the 2d array
        for (row, rowJson): (String, JSON) in json {
            for (col, cellJson): (String, JSON) in rowJson {
                let r: Int = Int(row)!
                let c: Int = Int(col)!
                
                tableData[r][c] = cellJson.stringValue.stringByReplacingOccurrencesOfString("\"", withString: "").stringByReplacingOccurrencesOfString("'", withString: "").stringByReplacingOccurrencesOfString("\n", withString: "") //remove quotes
            }
        }
        
        return tableData
        
    }
    
    
    func returnArrayOfData(numberOfColumns: Int, containerName: String, json: JSON) -> Array<Array<String>>? {
        let col_cnt: Int? = numberOfColumns
        let row_cnt: Int? = json[containerName].array?.count
        
        if(row_cnt == nil || col_cnt == nil){
            errorDescription = Config.serverErrorMessage
            return nil
        }
        
        var tableData = Array(count: row_cnt!, repeatedValue: Array(count: col_cnt!, repeatedValue: ""))
        
        // populates the 2d array
        let tableJson = json[containerName]
        for (row, rowJson): (String, JSON) in tableJson {
            for (col, cellJson): (String, JSON) in rowJson {
                let r: Int = Int(row)!
                let c: Int = Int(col)!
                
                tableData[r][c] = cellJson.stringValue.stringByReplacingOccurrencesOfString("\"", withString: "").stringByReplacingOccurrencesOfString("'", withString: "").stringByReplacingOccurrencesOfString("\n", withString: "") //remove quotes
                                
            }
        }

        return tableData
    }
}
