//
//  VisWebView.swift
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
import WebKit

class VisWebViewController: VisMasterViewController, VisLifeCycleProtocol, WKNavigationDelegate, WKScriptMessageHandler {
    
    var mainFile: String {
        switch type! {
        case .TreeMap:
            return "treemap.html"
        case .CirclePacking:
            return "circlepacking.html"
        case .StackedBar:
            return "stackedbar.html"
        case .ForceGraph:
            return "forcegraph.html"
        case .CommunityGraph:
            return "communitygraph.html"
        case .StackedBarDrilldownCirclePacking:
            return "StackedBarDrilldownCirclepacking.html"
        case .SidewaysBar:
            return "sidewaysbar.html"
        default:
            return "none"
        }
    }
    
    var dateRange: Array<String> = Array<String>()
    var startDate: NSDate = NSDate()
    var endDate: NSDate = NSDate()
    var highestValue : Double = 0.0
    
    var webView: WKWebView! = nil
    
    var viewSize: CGSize {
        let statusSize = UIApplication.sharedApplication().statusBarFrame.size
        let navSize = self.parentViewController?.navigationController?.navigationBar.frame.size
        let viewSize = self.view.bounds.size
        return CGSize.init(width: viewSize.width, height: viewSize.height - (navSize?.height)! - statusSize.height)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView = createWKWebViewWithConfigurationForCallback()
        visHolderView.addSubview(webView)
    }
    
    func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        if(message.name == "callbackHandler") {
            log.debug("JavaScript is sending a message \(message.body)")
    
            let body = message.body as! NSDictionary
            if let action = body.valueForKey("action") {
                switch action as! String {
                case "reload":
                    self.clean()
                    reloadChart(body)
                case "showdetails":
                    self.parentViewController!.performSegueWithIdentifier("communityDetails", sender: body)
                default:
                    log.error("Unknown action [\(action)] sent from web view")
                }
            }
            
        } else if (message.name == "console") {
            // DEBUG: Use the following method to print console logs from the WKWebView
            // window.webkit.messageHandlers.console.postMessage("SOME STRING");
            log.debug("WKWebView Log: \(message.body)")
        }
    }
    
    func reloadChart(dict: NSDictionary) {
        if let name = dict.valueForKey("chartname") {
            switch name as! String {
            case "forcenode":
                let term = dict.valueForKey("name") as! String
                Network.sharedInstance.getSynonyms(term) { (json, error) in
                    self.json = json
                }
            default:
                log.error("Can't Reload unknown chart [\(name)]")
            }
        }
    }
    
    func createWKWebViewWithConfigurationForCallback() -> WKWebView{
        let contentController = WKUserContentController();
        
        contentController.addScriptMessageHandler(self, name: "callbackHandler")
        contentController.addScriptMessageHandler(self, name: "console")
        
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        
        let myWebView = WKWebView(frame: self.view.bounds, configuration: config)
        
        myWebView.frame = self.view.bounds
        myWebView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        myWebView.navigationDelegate = self
        
        // don't let webviews scroll
        myWebView.scrollView.scrollEnabled = false;
        myWebView.scrollView.bounces = false;
        
        return myWebView
    }
    
    override func onDataSet() {
        if  self.json["searchTerm"] {
            self.searchText = self.json["searchTerm"].string!
        }
        
        log.debug("Loading mainFile: \(mainFile)")
        let tempVisPath = NSURL(fileURLWithPath: Config.visualizationFolderPath).URLByAppendingPathComponent(NSURL(fileURLWithPath: self.mainFile).path!)
        let request = NSURLRequest(URL: tempVisPath)
        webView.loadRequest(request)
    }
    
    override func onFocus() {
        switch type! {
        case .ForceGraph :
            webView.evaluateJavaScript("startAnimation();", completionHandler: nil)
        default:
            break
        }
    }
    
    override func onBlur() {
        let webViewScrollView = webView.scrollView
        webViewScrollView.zoomScale = webViewScrollView.minimumZoomScale
        
        switch type! {
        case .ForceGraph :
            webView.evaluateJavaScript("stopAnimation();", completionHandler: nil)
        default:
            break
        }
    }
    
    override func onSuccessState() {
        let webViewScrollView = webView.scrollView
        webViewScrollView.zoomScale = webViewScrollView.minimumZoomScale
        
        super.onSuccessState()
    }
    
    // MARK: - WKNavigationDelegate
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        transformData()
    }
    
    override func transformData() {
        let delay = 0.2 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue()) {
            
            guard self.json != nil else {
                self.errorDescription = (self.errorDescription != nil) ? self.errorDescription : Config.serverErrorMessage
                return
            }
            
            switch self.type! {
            case .TreeMap:
                self.transformDataForTreemapping()
            case .CirclePacking:
                self.transformDataForCirclepacking()
            case .ForceGraph:
                self.transformDataForForcegraph()
            case .CommunityGraph:
                self.transformDataForCommunitygraph()
            case .StackedBar:
                self.transformDataForStackedbar()
            case .SidewaysBar:
                self.transformDataForSidewaysbar()
            case .StackedBarDrilldownCirclePacking:
                self.transformDataForStackedBarDrilldownCirclepacking()
            default:
                return
            }
        }
    }
    
    func transformDataForTreemapping(){
        onLoadingState()
        
        let viewSize = self.viewSize
        
        let treemapData = json!["profession"].description
        var treemapDataTrimmed : String
        
        if let rangeOfStart = treemapData.rangeOfString("\"profession\" : ["){
            treemapDataTrimmed = "{\"name\": \"Profession\",\"children\": ["+treemapData.substringFromIndex(rangeOfStart.endIndex)
            
            treemapDataTrimmed = treemapDataTrimmed.stringByReplacingOccurrencesOfString("\n", withString: "")
            
            let script9 = "var data7 = '\(treemapDataTrimmed)'; var w = \(viewSize.width); var h = \(viewSize.height); renderChart(data7, w, h);";
            
            webView.evaluateJavaScript(script9, completionHandler: nil)
            
            onSuccessState()
        } else {
            errorDescription = Config.noDataMessage
        }
    }
    
    func transformDataForCirclepacking(){
        onLoadingState()
        
        func loadData() {
            if self.chartData.count > 0
            {
                // Reorder Circle Packing Data
                self.chartData.sortInPlace({$0[2] < $1[2]})
                
                let viewSize = self.viewSize
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                    var script9 = "var data7 = '{\"name\": \" \",\"children\": ["
                    
                    var groupName : String = "uninitialized"
                    
                    for r in 0..<self.chartData.count{
                        if(groupName != self.chartData[r][2]){
                            // stop the group (unless it's the first one)
                            if(groupName != "uninitialized"){
                                script9+="]},"
                            }
                            // new group
                            groupName = self.chartData[r][2]
                            script9+="{\"name\": \""
                            script9+=groupName
                            script9+="\", \"children\": ["
                        }
                        else{
                            //continue the group
                            script9+=","
                        }
                        
                        script9+="{\"name\": \""
                        script9+=self.chartData[r][0]
                        script9+="\", \"size\":"
                        script9+=self.chartData[r][3]
                        script9+="}"
                    }
                    script9+="]}]}';var w = \(viewSize.width); var h = \(viewSize.height);  renderChart(data7, w, h);"
                    
                    log.verbose(script9)
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.webView.evaluateJavaScript(script9, completionHandler: nil)
                        
                        self.onSuccessState()
                    })
                })
                
            }
            else {
                onNoDataState()
            }
        }
        
        let numberOfColumns = 4        // number of columns
        let containerName = "cluster" // name of container for data
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            let data = self.returnArrayOfData(numberOfColumns, containerName: containerName, json: self.json!)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if(data != nil){
                    self.chartData = data!
                    loadData()
                }
                else{
                    self.errorDescription = Config.serverErrorMessage
                }
            })
        })
        
    }
    
    func makeScriptForSidewaysBar(firstIndex: Int, upperIndex: Int?=nil) -> String {
        var script9 = "var myData = [{\"key\": \"Tweet Count\", \"values\": ["
        
        for r in firstIndex..<self.chartData.count{
            
            script9+="{\"x\": \""
            script9+=self.chartData[r][0]
            script9+="\", \"y\":"
            script9+=self.chartData[r][1]
            script9+="}"
            
            // there's another data point so we need the comma
            if(r != (self.chartData.count-1)){
                script9+=","
            }
        }
        script9+="]}]; renderChart(myData);"
        
        return script9
    }
    
    func transformDataForSidewaysbar(){
        
        func loadData() {
            if self.chartData.count > 0
            {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                    
                    let script9 = self.makeScriptForSidewaysBar(0)
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.webView.evaluateJavaScript(script9, completionHandler: nil)
                        self.onSuccessState()
                        
                    })
                })
            }
            else
            {
                onNoDataState()
            }
        }
        
        let numberOfColumns = 2        // number of columns
        let containerName = "wordCount" // name of container for data
        
        var contentJson = json
        if contentJson != nil
        {
            contentJson = json![containerName]
            
            if contentJson != nil
            {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                    let data = self.returnArrayOfLiveData(numberOfColumns, containerName: containerName, json: contentJson!)
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        if(data != nil){
                            self.chartData = data!
                            loadData()
                        }
                        else{
                            self.errorDescription = Config.serverErrorMessage
                        }
                    })
                })
            }
            else
            {
                errorDescription = Config.serverErrorMessage
            }
        }
        else
        {
            errorDescription = Config.serverErrorMessage
        }
    }
    
    
    
    func transformDataForStackedBarDrilldownCirclepacking(){
        
        onLoadingState()
        
        func loadData() {
            if self.chartData.count > 0
            {
                // Reorder Circle Packing Data
                self.chartData.sortInPlace({$0[1] < $1[1]})
                
                let viewSize = self.viewSize
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                    var script9 = "var data7 = '{\"name\": \" \",\"children\": ["
                    
                    var groupName : String = "uninitialized"
                    
                    for r in 0..<self.chartData.count{
                        if(groupName != self.chartData[r][1]){
                            // stop the group (unless it's the first one)
                            if(groupName != "uninitialized"){
                                script9+="]},"
                            }
                            // new group
                            groupName = self.chartData[r][1]
                            script9+="{\"name\": \""
                            script9+=groupName
                            script9+="\", \"children\": ["
                        }
                        else{
                            //continue the group
                            script9+=","
                        }
                        
                        script9+="{\"name\": \""
                        script9+=self.chartData[r][0]
                        script9+="\", \"size\":"
                        let aString : String = "\(Int(Float(self.chartData[r][2])!*(10000)))"
                        script9+=aString
                        script9+="}"
                    }
                    script9+="]}]}';var w = \(viewSize.width); var h = \(viewSize.height);  renderChart(data7, w, h);"
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.webView.evaluateJavaScript(script9, completionHandler: nil)
                        
                        self.onSuccessState()
                    })
                })
                
            }
            else {
                onNoDataState()
            }
        }
        
        let numberOfColumns = 3        // number of columns
        let containerName = "topics" // name of container for data
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            let data = self.returnArrayOfData(numberOfColumns, containerName: containerName, json: self.json!)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if(data != nil){
                    self.chartData = data!
                    loadData()
                }
                else{
                    self.errorDescription = Config.serverErrorMessage
                }
            })
        })
        //}
        
    }
    
    func transformDataForStackedbar(){
        
        func loadData() {
            onLoadingState()
            
            if self.chartData.count > 0
            {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                    
                    let script9 = self.makeScriptForStackedBar(0)
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.webView.evaluateJavaScript(script9, completionHandler: nil)
                        self.onSuccessState()
                        
                    })
                })
            }
            else
            {
                onNoDataState()
            }
        }
        
        let numberOfColumns = 4        // number of columns
        let containerName = "sentiment" // name of container for data
        
        var contentJson = json
        if contentJson != nil
        {
            
            contentJson = json![containerName]
            
            if contentJson != nil
            {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                    let data = self.returnArrayOfData(numberOfColumns, containerName: containerName, json: contentJson!)
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        if(data != nil){
                            self.chartData = data!
                            loadData()
                        }
                        else{
                            self.errorDescription = Config.serverErrorMessage
                        }
                    })
                })
            }
            else
            {
                errorDescription = Config.serverErrorMessage
            }
        }
        else
        {
            errorDescription = Config.serverErrorMessage
        }
    }
    
    func makeScriptForStackedBar(firstIndex: Int, upperIndex: Int?=nil) -> String {
        var script9 = "var myData = [{\"key\": \"Tweet Count\", \"values\": ["
        let viewSize = self.viewSize
        
        for r in firstIndex..<self.chartData.count{
            if (self.dateRange.indexOf(self.chartData[r][0]) == nil)
            {
                self.dateRange.append(self.chartData[r][0])
            }
            
            
            script9+="{\"x\": \""
            script9+=self.chartData[r][0]
            script9+="\", \"y\":"
            script9+=self.chartData[r][1]
            script9+=", \"z\":"
            script9+=self.chartData[r][2]
            script9+="}"
            
            
            if let unwrappedUpperIndex = upperIndex {
                if(self.chartData[r][0] == dateRange[unwrappedUpperIndex]){
                    //it's the end of the range, get out of here
                    break
                }
            }
            
            // there's another data point so we need the comma
            if(r != (self.chartData.count-1)){
                script9+=","
            }
        }
        
        script9+="]}]; renderChart(myData, \(viewSize.width), \(viewSize.height));"
        
        return script9
    }
    
    func getPositiveAndNegativeSentimentValuesForGivenDate(givenDate: NSDate) -> (Double, Double) {
        var foundBiggerDate = false
        
        let dateFormat = NSDateFormatter()
        dateFormat.dateFormat = "YYYY MM/dd HH"
        dateFormat.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        
        var posValue = 0.0
        var negValue = 0.0
        
        for r in 0..<self.chartData.count{
            var currentDate = NSDate()
            if(!foundBiggerDate){
                currentDate = dateFormat.dateFromString("2015 \(self.chartData[r][0])")!
            }
            if( !foundBiggerDate && currentDate.compare(givenDate) == .OrderedDescending){ //currentDate is later than givenDate
                // found a greater date, break out
                foundBiggerDate = true
                posValue = (chartData[r][1] as NSString).doubleValue
                negValue = (chartData[r][2] as NSString).doubleValue
            }
            else if(!foundBiggerDate && currentDate.compare(givenDate) == .OrderedAscending){ //currentDate is earlier than givenDate
                
            }
            else if(!foundBiggerDate){ //dates are the same
                foundBiggerDate = true
                posValue = (chartData[r][1] as NSString).doubleValue
                negValue = (chartData[r][2] as NSString).doubleValue
            }
        }
        
        return (posValue, negValue)
        
    }
    
    func redrawStackedBarWithNewRange(lowerIndex: Int, upperIndex: Int){
        var firstIndex = 0
        while firstIndex < self.chartData.count && dateRange[lowerIndex] != self.chartData[firstIndex][0] {
            firstIndex += 1
        }
        
        let script9 = self.makeScriptForStackedBar(firstIndex, upperIndex: upperIndex)
        
        if type == VisTypes.StackedBar {
            webView.evaluateJavaScript(script9, completionHandler: nil)
        }
        
    }
    
    func transformDataForForcegraph(){
        func loadData() {
            onLoadingState()
            if self.chartData.count > 0
            {
                let viewSize = self.viewSize
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                    
                    let searchTermCount = self.json["searchTermCount"].floatValue
                    let searchTerm = self.json["searchTerm"].stringValue
                    var script9 = "var myData = '{\"nodes\": [ {\"name\":\"\(searchTerm)\",\"value\":\(searchTermCount),\"group\":1}, "
                    for r in 0..<self.self.chartData.count{
                        script9+="{\"name\": \""
                        script9+=self.chartData[r][0]
                        script9+="\", \"value\": "
                        script9+=self.chartData[r][2]
                        script9+=", \"group\": 2"
                        script9+="}"
                        if(r != (self.chartData.count-1)){
                            script9+=","
                        }
                    }
                    script9+="], \"links\": ["
                    for r in 0..<self.chartData.count{
                        script9+="{\"source\": 0"
                        script9+=", \"target\": "
                        script9+="\(r+1)"
                        script9+=", \"distance\": "
                        let myInteger = Int((self.chartData[r][1] as NSString).floatValue*10000)
                        script9+="\(myInteger)"
                        script9+="}"
                        if(r != (self.chartData.count-1)){
                            script9+=","
                        }
                    }
                    script9+="]}'; var w = \(viewSize.width); var h = \(viewSize.height); renderChart(myData,w,h);"
                    
                    // For testing
//                    script9 = "var myData='{\"nodes\":[    {\"name\":\"Myriel\",\"value\":52,\"group\":1},    {\"name\":\"Labarre\",\"value\":5,\"group\":2},    {\"name\":\"Valjean\",\"value\":17,\"group\":2},    {\"name\":\"Mme.deR\",\"value\":55,\"group\":2},    {\"name\":\"Mme.deR\",\"value\":17,\"group\":2},    {\"name\":\"Isabeau\",\"value\":44,\"group\":2},    {\"name\":\"Mme.deR\",\"value\":17,\"group\":2},    {\"name\":\"Isabeau\",\"value\":22,\"group\":2},    {\"name\":\"Isabeau\",\"value\":17,\"group\":2},    {\"name\":\"Gervais\",\"value\":33,\"group\":2}  ],  \"links\":[    {\"source\":0,\"target\":1,\"distance\":33},    {\"source\":0,\"target\":2,\"distance\":22},    {\"source\":0,\"target\":3,\"distance\":22},    {\"source\":0,\"target\":4,\"distance\":11},    {\"source\":0,\"target\":5,\"distance\":22},    {\"source\":0,\"target\":6,\"distance\":22},    {\"source\":0,\"target\":7,\"distance\":43},    {\"source\":0,\"target\":8,\"distance\":22},    {\"source\":0,\"target\":9,\"distance\":22}  ]}'; var w = \(viewSize.width); var h = \(viewSize.height); renderChart(myData,w,h);";

                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.webView.evaluateJavaScript(script9, completionHandler: nil)
                        self.onSuccessState()
                    })
                })
                
            }
            else {
                onNoDataState()
            }
            
        }
        
        let numberOfColumns = 3        // number of columns
        let containerName = "distance" // name of container for data
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            let data = self.returnArrayOfData(numberOfColumns, containerName: containerName, json: self.json!)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if(data != nil){
                    self.chartData = data!
                    loadData()
                }
                else{
                    self.errorDescription = Config.serverErrorMessage
                }
            })
        })
    }
    
    func transformDataForCommunitygraph(){
        func loadData() {
            onLoadingState()
            if self.chartData.count > 0
            {
                
                //Log("transformDataForCommunitygraph... ");
                //Log(self.chartData);
                
                //var data = '{"nodes": [{"label":"Myriel","id":1,"degree":7,"community":1,"x":5,"y":5}, {"label":"Hebert","id":2,"degree":2,"community":1,"x":20,"y":5}, {"label":"Scads","id":3,"degree":5,"community":2,"x":23,"y":22.1}], "links":[ {"source":1,"target":0,"weight":2.0}, {"source":2,"target":4,"weight":5.0}, {"source":4,"target":1,"weight":1.0} ]}'
                
                let viewSize = self.viewSize
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {

                    var minX = 0.0
                    var minY = 0.0
                    
                    var maxX = 0.0
                    var maxY = 0.0
                    
                    var script9 = "var myData = '{\"nodes\": ["
                        
                    for r in 0..<self.chartData.count{
                        script9+="{\"label\": \""
                        script9+=self.chartData[r][0]
                        script9+="\", \"id\": "
                        script9+=self.chartData[r][1]
                        script9+=", \"degree\": "
                        script9+="1" //TODO: fix when when data isn't broken
                        script9+=", \"community\": "
                        script9+=self.chartData[r][3]
                        script9+=", \"x\": "
                        script9+=self.chartData[r][4]
                        
                        let thisX = (self.chartData[r][4] as NSString).doubleValue
                        if( thisX > maxX )
                        {
                            maxX = thisX
                        }
                        if( thisX < minX )
                        {
                            minX = thisX
                        }
                        
                        script9+=", \"y\": "
                        script9+=self.chartData[r][5]

                        let thisY = (self.chartData[r][5] as NSString).doubleValue
                        if( maxY < thisY )
                        {
                            maxY = thisY
                        }
                        
                        if( thisY < minY )
                        {
                            minY = thisY
                        }

                        
                        script9+="}"
                        if(r != (self.chartData.count-1)){
                            script9+=","
                        }
                    }
                    script9+="], \"links\": ["
                    script9+="]}'; var w = \(viewSize.width); var h = \(viewSize.height); var minX = \(minX); var minY = \(minY); var maxX = \(maxX); var maxY = \(maxY); renderChart(myData,w,h,minX, minY, maxX,maxY);"
 
                    //let script9 = "var data = '{\"nodes\": [{\"label\":\"Hebert\",\"id\":2,\"degree\":2,\"community\":1,\"x\":20,\"y\":5}, {\"label\":\"Scads\",\"id\":3,\"degree\":5,\"community\":2,\"x\":23,\"y\":22.1}], \"links\":[]}'; renderChart(data, 960, 760);"
                    
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.webView.evaluateJavaScript(script9, completionHandler: nil)
                        self.onSuccessState()
                    })
                })
                
            }
            else {
                onNoDataState()
            }
            
        }
        
        
        let containerName = "communities" // name of container for data
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            
            let communityData = self.json[containerName]
            
            let nodes = self.returnArrayOfData(7, containerName: "nodes", json: communityData)
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if(nodes != nil){
                    self.chartData = nodes!
                    loadData()
                }
                else{
                    self.errorDescription = Config.serverErrorMessage
                }
            })
        })
    }
    
}
