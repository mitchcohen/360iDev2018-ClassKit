//
//  ClassKitManager.swift
//  ClassKitPresidents
//
//  Created by Mitch Cohen on 8/26/18.
//  Copyright © 2018 Proactive Interactive, LLC. All rights reserved.
//

import UIKit
import ClassKit

class ClassKitManager: NSObject, CLSDataStoreDelegate {
    
    @objc public var currentActivity:CLSActivity?
    @objc public var currentContext:CLSContext?
    @objc public var year:String = ""
    
    static let sharedInstance: ClassKitManager = {
        let instance = ClassKitManager()
        return instance
    }()

    @objc public func setupClassKit() {
        CLSDataStore.shared.delegate = self
    }
    
    @objc public func createContexts() {
        let elections = MSCElections()
        for year in elections.years() {
            if let yearString = year as? String {
                CLSDataStore.shared.mainAppContext.descendant(
                        matchingIdentifierPath: ["Elections", yearString]) {
                    (context, error) in
                    if error != nil {
                        print("Error finding context in createContexts! \(error?.localizedDescription ?? "")")
                    }
                }
            }
        }
    }
    
    @objc public func configureCurrentContext(year:String) {
        self.year = year;
        CLSDataStore.shared.mainAppContext.descendant(
            matchingIdentifierPath: ["Elections", year])
        { (context, error) in
            self.currentContext = context
            self.currentContext?.becomeActive()
        }
    }
    
    @objc public func startActivityForContext(context:CLSContext) {
        guard context.isActive else {
            print("No Active Context!")
            return
        }
        self.currentActivity = context.createNewActivity()
        if let currentActivity = self.currentActivity {
            currentActivity.start()
            print("Started activity: ",self.currentActivity ?? "NONE!!!")
        } else {
            assertionFailure()
        }
    }
    
    @objc public func setScore(score:Double) {
        let scoreItem = CLSScoreItem(identifier: self.year,
                                     title: "score",
                                     score: score,
                                     maxScore: 1)
        self.currentActivity?.primaryActivityItem = scoreItem
        print("Activity score set to ",score, scoreItem)
    }
    
    @objc public func save() {
        self.currentActivity?.stop()
        self.currentContext?.resignActive()
        self.currentActivity = nil
        self.currentContext = nil
        CLSDataStore.shared.save { (error) in
            if error != nil {
                print("Error saving activity! \(error?.localizedDescription ?? "")")
            } else {
                print("Activity saved successfully")
            }
        }
    }
    
    func createContext(forIdentifier identifier: String,
                       parentContext: CLSContext,
                       parentIdentifierPath: [String]) -> CLSContext? {
        let context = CLSContext.init(type: .quiz,
                                      identifier: identifier,
                                      title: identifier);

        context.topic = CLSContextTopic.socialScience
        
        if identifier != "Elections" {
            context.universalLinkURL = URL(string: "electionquiz://\(identifier)")
        }
        
        return context;
    }
}
