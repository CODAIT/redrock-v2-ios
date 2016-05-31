//
//  AppDelegate.swift
//  RedRock
//
//  Created by Jonathan Alter on 5/27/15.
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
import XCGLogger

let log = XCGLogger.defaultInstance()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // Setup Logger
        #if DEBUGLOG
            log.setup(.Debug, showThreadName: true, showLogLevel: true, showFileNames: true, showLineNumbers: true, writeToFile: nil)
        #else
            log.setup(.Severe, showThreadName: true, showLogLevel: true, showFileNames: true, showLineNumbers: true, writeToFile: nil)
        #endif
        
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default
        
        /*
        NOTE: Copying Visualisations folder to '/tmp/www' to work around an issue with
        loading the files from the bundle. Without this workaround WKNetworkDelegate methods
        will not be called and we will get the following error "Could not create a sandbox extension for /".
        */
        let visFolder = NSURL(fileURLWithPath: NSBundle.mainBundle().resourcePath!).URLByAppendingPathComponent("Visualizations")
        Config.visualizationFolderPath = copyFolderToTempFolder(visFolder.path)!
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}


// MARK: Utils

func copyFolderToTempFolder(filePath: String?) -> String?
{
    log.verbose("Copying \(filePath) to /tmp/www")
    let fileMgr = NSFileManager.defaultManager()
    let tmpPath = NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent("www")
    let error: NSErrorPointer = nil
    do {
        try fileMgr.createDirectoryAtURL(tmpPath, withIntermediateDirectories: true, attributes: nil)
    } catch let error1 as NSError {
        error.memory = error1
        log.error("Couldn't create www subdirectory. \(error)")
        return nil
    }
    let destPath = tmpPath.path!
    // Clean up old files
    if fileMgr.fileExistsAtPath(destPath) {
        do {
            try fileMgr.removeItemAtPath(destPath)
        } catch let error1 as NSError {
            error.memory = error1
            log.error("Couldn't delete folder /tmp/www. \(error)")
        }
    }
    // Copy files to temp dir
    if !fileMgr.fileExistsAtPath(destPath) {
        do {
            try fileMgr.copyItemAtPath(filePath!, toPath: destPath)
        } catch let error1 as NSError {
            error.memory = error1
            log.error("Couldn't copy file to /tmp/www. \(error)")
            return nil
        }
    }
    return destPath
}

extension UIStoryboard {
    class func mainStoryboard() -> UIStoryboard { return UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()) }
    
    class func wordCountViewController() -> VisWordCountViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("VisWordCountViewController") as? VisWordCountViewController
    }
}

