//
//  VisNativeViewController.swift
//  RedRock
//
//  Created by Jonathan Alter on 5/26/2016.
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

class VisNativeViewController: VisMasterViewController, VisLifeCycleProtocol {
    
    var wordCountVC: VisWordCountViewController? = nil
    var sentimentBarVC: VisSentimentBarViewController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.clipsToBounds = true
        
        switch type! {
        case .WordCount:
            wordCountVC = UIStoryboard.wordCountViewController()
            wordCountVC!.view.frame = CGRect(origin: CGPointZero, size: visHolderView.bounds.size)
            self.visHolderView.addSubview(wordCountVC!.view)
            addChildViewController(wordCountVC!)
            wordCountVC?.didMoveToParentViewController(self)
        case .SentimentBar:
            sentimentBarVC = UIStoryboard.sentimentBarViewController()
            sentimentBarVC!.view.frame = CGRect(origin: CGPointZero, size: visHolderView.bounds.size)
            self.visHolderView.addSubview(sentimentBarVC!.view)
            addChildViewController(sentimentBarVC!)
            sentimentBarVC?.didMoveToParentViewController(self)
        default:
            log.error("Unknown type: \(type)")
        }
    }
    
    override func onDataSet() {
        onLoadingState()
        
        transformData()
        
        onSuccessState()
    }
    
    override func onFocus() {
        
    }
    
    override func onBlur() {
        
    }
    
    override func clean() {
        
        super.clean()
    }
    
    override func transformData() {
        switch self.type! {
        case .WordCount :
            transformDataForWordCount()
        case .SentimentBar:
            transformDataForSentimentBar()
        default:
            return
        }
    }
    
    func transformDataForWordCount() {
        let communitydetails = json!["communitydetails"]
        let wordcloud = communitydetails["wordcloud"]
        let words = wordcloud[self.communityId!]
        
        guard words.count != 0 else {
            errorDescription = Config.noDataMessage
            return
        }
        
        guard wordCountVC != nil else {
            log.verbose("wordCountVC is nil")
            return
        }
        
        wordCountVC?.words = words
    }
    
    func transformDataForSentimentBar() {
        let communitydetails = json!["communitydetails"]
        let sentiment = communitydetails["sentiment"]
        let communitySentiment = sentiment[self.communityId!]
        
        guard communitySentiment != nil else {
            errorDescription = Config.noDataMessage
            return
        }
        
        guard sentimentBarVC != nil else {
            log.verbose("sentimentBarVC is nil")
            return
        }
        
        sentimentBarVC?.sentiment = (positive: communitySentiment[0].intValue, negative: communitySentiment[1].intValue, neutral:communitySentiment[2].intValue)
    }
}