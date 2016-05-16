//
//  Config.swift
//  Spark Insights
//
//  Created by Jonathan Alter on 5/29/15.
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
import HEXColor

class Config {
    
    static let skipSearchScreen = false // Default: false
    static let useDummyData = false // Default: false
    static let dummyDataDelay = 1.0 // Seconds
    // The response to get community details has details for all commununities in the graph before
    // this means that the call only needs to be made once, so it is cached until we get new communities
    static let cacheCommunityDetails = true // Default: true
    static let cahceCommunityDetailsDelay = 1.0 // Seconds
    
    // MARK: - Server
    
//    static let serverAddress = "http://localhost:16666" // Localhost
    static let serverAddress = "http://spark11:16666" // spark11
    static let serverSynonyms = "tiara/getsynonyms"
    static let serverTopTerms = "tiara/gettopterms"
    static let serverCommunities = "tiara/getcommunities"
    static let serverCommunityDetails = "tiara/getcommunitiesdetails"
    
    // MARK: - Colors
    static let darkBlueColor = UIColor(rgba: "#1C3648") // Dark Blue
    
    // MARK: Vis settings
    static let noDataMessage = "No data available"
    static let serverErrorMessage = "Server error. Request failed"

    // MARK: global variables
    static var visualizationFolderPath = "" // Holds the path to the visualizations folder, will be initialized at app startup
}
