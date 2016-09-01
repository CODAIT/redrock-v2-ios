//
//  Network.swift
//  RedRock
//
//  Created by Barbara Gomes on 6/5/15.
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

import Foundation
import QuartzCore
import SwiftyJSON

typealias NetworkRequestResponse = (json: JSON?, error: NSError?) -> ()

class Network
{
    static let sharedInstance = Network()
    
    static var waitingForResponse = false
    private var requestCount = 0
    private var requestTotal = 0
    private var error = false
    private var startTime = CACurrentMediaTime()
    private var cachedCommunityDetailsJSON: JSON?
    
    // MARK: Cache Management
    
    func clearCommunityDetailsCache() {
        cachedCommunityDetailsJSON = nil
        log.verbose("Community Details cache cleared")
    }
    
    // MARK: Call Requests
    
    // Synonyms: http://spark11:16666/tiara/getsynonyms?searchterm=%23love&count=10
    func getSynonyms(searchText: String, callback: NetworkRequestResponse) {
        if Config.useDummyData {
            var path = "response_synonyms"
            if searchText.containsString("#") {
                path = "response_spark2"
            }
            dispatchRequestForResource(path, callback: callback)
            return
        }
        
        var parameters = Dictionary<String,String>()
        parameters["searchterm"] = searchText.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        parameters["count"] = "20"
        let req = self.createRequest(Config.serverSynonyms, paremeters: parameters)
        executeRequest(req, callback: callback)
    }
    
    // Top Terms: http://spark11:16666/tiara/gettopterms?count=20
    func getTopTerms(callback: NetworkRequestResponse) {
        if Config.useDummyData {
            let path = "response_topterms"
            dispatchRequestForResource(path, callback: callback)
            return
        }
        
        var parameters = Dictionary<String,String>()
        parameters["count"] = "7"
        let req = self.createRequest(Config.serverTopTerms, paremeters: parameters)
        executeRequest(req, callback: callback)
    }
    
    // Graph: http://spark11:16666/tiara/getcommunities?searchterms=%23love,%23god&get3d=false
    func getCommunities(searchText: String, callback: NetworkRequestResponse) {
        if Config.useDummyData {
            let path = "response_communities"
            dispatchRequestForResource(path, callback: callback)
            return
        }
        
        var parameters = Dictionary<String,String>()
        parameters["searchterms"] = searchText.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        parameters["get3d"] = "false"
        parameters["top"] = "20"
        let req = self.createRequest(Config.serverCommunities, paremeters: parameters)
        executeRequest(req, callback: callback)
    }
    
    // Community Details: http://spark11:16666/tiara/getcommunitiesdetails?searchterms=%23trump,%23cruz,%23duckingdonald,%23boycottfoxnews,%23iowa,%23caucusfortrump,%23iacaucus,%23trump2,%23makeamericagreatagain,%23familyvalues,%23teamtrump,%23iowa4trump,%23women4trump,%23iowacaucus,%23ia,%23trump2016,%23votetrump,%23gop,%23yuge,%23trumptrain,%23makeameric
    func getCommunityDetails(searchText: String, callback: NetworkRequestResponse) {
        if Config.useDummyData {
            let path = "response_communitydetails"
            dispatchRequestForResource(path, callback: callback)
            return
        }
        
        if Config.cacheCommunityDetails && self.cachedCommunityDetailsJSON != nil {
            log.verbose("Using cached Community Details")
            callCallbackAfterDelay(self.cachedCommunityDetailsJSON, error: nil, delayInSeconds: Config.cahceCommunityDetailsDelay, callback: callback)
            return
        }
        
        func callbackWithCaching(json: JSON?, error: NSError?) {
            if Config.cacheCommunityDetails {
                self.cachedCommunityDetailsJSON = json
                log.verbose("Caching Community Details")
            }
            callback(json: json, error: error)
        }
        
        var parameters = Dictionary<String,String>()
        parameters["searchterms"] = searchText.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        parameters["count"] = "20"
        let req = self.createRequest(Config.serverCommunityDetails, paremeters: parameters)
        executeRequest(req, callback: callbackWithCaching)
    }
    
    
    //MARK: Server
    
    private func createRequest(serverPath: String, paremeters: Dictionary<String,String>) -> String{
        self.requestTotal += 1
        var urlPath:String = "\(Config.serverAddress)/\(serverPath)"
        if paremeters.count > 0
        {
            urlPath += "?"
            let keys = paremeters.keys
            for key in keys
            {
                urlPath += key + "=" + paremeters[key]! + "&"
            }
            var aux = Array(urlPath.characters)
            aux.removeLast()
            urlPath = String(aux)
        }
        return urlPath
    }
    

    private func executeRequest(req: String, callback: NetworkRequestResponse?) {
        log.debug("Sending Request: " + req)
        Network.waitingForResponse = true
        self.startTime = CACurrentMediaTime()
        let url: NSURL = NSURL(string: req)!
        let session = NSURLSession.sharedSession()
        session.configuration.timeoutIntervalForRequest = 300
        
        let task = session.dataTaskWithURL(url, completionHandler: {data, response, error -> Void in
            self.requestCount += 1
            
            func callbackOnMainThread(json: JSON?, error: NSError?) {
                dispatch_async(dispatch_get_main_queue(), {
                    Network.waitingForResponse = false
                    if callback != nil {
                        callback!(json: json, error: error)
                    }
                })
            }
            
            // Response timer
            let elapsedTime = CACurrentMediaTime() - self.startTime
            log.debug("Request response time: \(elapsedTime)")
                
            if error != nil {
                // There was an error in the network request
                log.error("Network Error: \(error!.localizedDescription)")
                
                callbackOnMainThread(nil, error: error)
                return
            }
            
            var err: NSError?
            
            if let httpResponse = response as? NSHTTPURLResponse
            {
                if httpResponse.statusCode != 200
                {
                    log.error(String(data: data!, encoding: NSUTF8StringEncoding))
                    
                    let errorDesc = "Server Error. Status Code: \(httpResponse.statusCode)"
                    err =  NSError(domain: "Network", code: 0, userInfo: [NSLocalizedDescriptionKey: errorDesc])
                    callbackOnMainThread(nil, error: err)
                    return
                }
            }
            
            var jsonResult: AnyObject?
            do {
                jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
            } catch let error as NSError {
                err = error
                jsonResult = nil
            } catch {
                fatalError()
            }
            if err != nil {
                // There was an error parsing JSON
                log.error("JSON Error: \(err!.localizedDescription)")
                
                callbackOnMainThread(nil, error: err)
                return
            }
            
            let json = JSON(jsonResult as! NSDictionary)
            let status = json["status"].intValue
            
            if(status == 1 || (json["success"] != nil && !json["success"].boolValue)) {
                let msg = json["message"].stringValue
                log.error("Server Error: \(msg)")
                
                err =  NSError(domain: "Network", code: 0, userInfo: [NSLocalizedDescriptionKey: msg])
                callbackOnMainThread(nil, error: err)
                return
            }
            
            // Success
            log.debug("Request completed: Status = OK")
            
            callbackOnMainThread(json, error: nil)
        })
        task.resume()
    }
    
    
    // MARK: - Utils
    
    func dispatchRequestForResource(path: String, callback: NetworkRequestResponse)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            
            let filePath = NSBundle.mainBundle().pathForResource(path, ofType:"json")
            guard filePath != nil else {
                log.error("File not found: \(path).json")
                return
            }
            
            var readError:NSError?
            do {
                let fileData = try NSData(contentsOfFile:filePath!,
                    options: NSDataReadingOptions.DataReadingUncached)
                // Read success
                var parseError: NSError?
                do {
                    let JSONObject: AnyObject? = try NSJSONSerialization.JSONObjectWithData(fileData, options: NSJSONReadingOptions.AllowFragments)
                    log.verbose("JSON file Parse success")
                    let json = JSON(JSONObject!)
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.callCallbackAfterDelay(json, error: nil, callback: callback)
                    })
                } catch let error as NSError {
                    parseError = error
                    // Parse error
                    log.error("Error Parsing JSON data: \(parseError?.localizedDescription)")
                }
            } catch let error as NSError {
                readError = error
                // Read error
                log.error("Error Reading JSON data: \(readError?.localizedDescription)")
            } catch {
                fatalError()
            }
            
        })
        
    }
    
    func callCallbackAfterDelay(json: JSON?, error: NSError?, delayInSeconds: Double = Config.dummyDataDelay, callback: NetworkRequestResponse) {
        let delay = delayInSeconds * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue()) {
            Network.waitingForResponse = false
            callback(json: json, error: error)
        }
    }
    
}