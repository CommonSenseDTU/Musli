//
//  TaskFlowManager.swift
//  Pods
//
//  Created by Anders Borch on 2/28/17.
//
//

import UIKit
import ResearchKit
import CoreLocation

/**
 Manager class used for generating a task flow view controller which presents
 the visual tasks in a given survey. Background sensors are also started and
 stopped by this manager class in response to task progress.
 */
public class TaskFlowManager {
    
    private let survey: Survey
    private let resourceManager: ResourceManager
    private let locationManager = CLLocationManager()
    private let locationDelegate = StepLocationDelegate()
    public var delegate: TaskFlowDelegate
    
    /**
     Create a task flow manager.
     
     - parameter resourceManager: Resource manager used in the delegate for cfreating an account and uploading the consent signature
     - parameter survey: The survey to create a consent flow for
     */
    public init(resourceManager: ResourceManager, survey: Survey) {
        self.survey = survey
        self.resourceManager = resourceManager
        self.delegate = TaskFlowDelegate(resourceManager: resourceManager)
    }

    public func start(task: Task) {
        guard let step = task.steps.first else { return }
        for sensor in step.sensors {
            switch sensor {
            case "gps":
                locationManager.requestAlwaysAuthorization()
                locationManager.delegate = locationDelegate
                locationManager.startUpdatingLocation()
            case "motion":
                fallthrough
            case "accel":
                fallthrough
            case "audio":
                fallthrough
            case "video":
                fallthrough
            default:
                break
            }
        }
    }
    
    public func viewController(task: Task) -> UIViewController? {
        guard let step = task.steps.first else { return nil }
        guard let visual = step.visualTask else { return nil }
        var controller: ORKTaskViewController
        if step.type == "custom" {
            controller = CustomTaskViewController(task: task)
        } else {
            controller = ORKTaskViewController(task: visual, taskRun: nil)
        }
        do {
            let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true) as [String]
            guard let caches = paths.first else { throw NSError(domain: "NSSearchPathForDirectoriesInDomains", code: -1, userInfo: ["Error": "Caches not found"]) }
            let outputDirectory = caches + "/" + step.id
            try FileManager().createDirectory(atPath: outputDirectory,
                                              withIntermediateDirectories: true,
                                              attributes: nil)
            controller.outputDirectory = URL(fileURLWithPath: outputDirectory)
        } catch let err {
            print("Error creating output directory: ", err)
        }
        controller.delegate = delegate
        return controller
    }

}
