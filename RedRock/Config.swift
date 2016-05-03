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
    
    // MARK: - Server
    // Synonyms: http://spark11:16666/tiara/getsynonyms?searchterm=%23love&count=10
    // Top Terms: http://spark11:16666/tiara/gettopterms?count=20
    // Graph: http://spark11:16666/tiara/getcommunities?searchterms=%23love,%23god&get3d=false
    
//    static let serverAddress = "http://localhost:16666" // Localhost
    static let serverAddress = "http://spark11:16666" // spark11
    static let serverSynonyms = "tiara/getsynonyms"
    
    // MARK: - Colors
    static let darkBlueColor = UIColor(rgba: "#1C3648") // Dark Blue
    
    // MARK: Vis settings
    static let noDataMessage = "No data available"
    static let serverErrorMessage = "Server error. Request failed"

    // MARK: global variables
    static var visualizationFolderPath = "" // Holds the path to the visualizations folder, will be initialized at app startup
}
