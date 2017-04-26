//
//  TaskFlowDelegate.swift
//  Pods
//
//  Created by Anders Borch on 2/28/17.
//
//

import UIKit
import ResearchKit
import Granola

open class TaskFlowDelegate: NSObject, ORKTaskViewControllerDelegate {
    
    internal var resourceManager: ResourceManager
    
    public init(resourceManager: ResourceManager) {
        self.resourceManager = resourceManager
    }
    
    /**
        Recursively iterate over results which may be contained in collections.
        Results can be collections which contain results which can be collections.
     
        - parameter results: An array of results to enumerate
        - parameter block: The block to be invoked with each result
     */
    private func enumerateResults(results: [ORKResult]?, block: (_ result: ORKResult) -> Void) {
        guard results != nil else { return }
        for result in results! {
            block(result)
            guard result is ORKCollectionResult else { continue }
            let collection = result as! ORKCollectionResult
            enumerateResults(results: collection.results, block: block)
        }
    }
    
    public func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
 
        let results = taskViewController.result.results
        
        enumerateResults(results: results) { (result: ORKResult) in
            if result is ORKQuestionResult {
                let serializer = OMHSerializerQuestion(result: result as! ORKQuestionResult)
                serializer?.consent = self.resourceManager.consent
                do {
                    guard let json = try serializer?.dictionary(for: result as! ORKQuestionResult) else { return }
                    self.resourceManager.upload(json: json, completion: { (success: Bool, error: Error?) in
                        guard error != nil else { return }
                        print("Error uploading result: \(String(describing: error))")
                    })
                } catch let exception {
                    print("Error serializing result: \(exception)")
                }
            }
        }
        
        //print("output directory", taskViewController.outputDirectory)
        taskViewController.dismiss(animated: true, completion: nil)
    }
}
