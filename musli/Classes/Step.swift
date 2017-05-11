//
//  Step.swift
//  Pods
//
//  Created by Anders Borch on 2/28/17.
//
//

import Foundation
import RestKit
import ResearchKit

open class Step: NSObject {
    public var id = ""
    public var title = ""
    public var type = ""
    public var isPrivate = false
    public var sensors = [String]()
    public var settings = [String: Any]()
    public var items = [StepItem]()

    public static let attributeMap: Dictionary<String, String> = [
        "id": "id",
        "title": "title",
        "type": "type",
        "sensors": "sensors",
        "settings": "settings",
        "private": "isPrivate"
    ]
    
    internal static let mapping: RKObjectMapping = {
        let mapping = RKObjectMapping(for: Step.self)!
        mapping.addAttributeMappings(from: Step.attributeMap)

        let itemMapping = StepItem.mapping
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "items", toKeyPath: "items", with: itemMapping))
        
        return mapping
    }()

    public var visualTask: ORKOrderedTask? {
        switch type {
        case "gait":
            return ORKOrderedTask.fitnessCheck(withIdentifier: "gait",
                                               intendedUseDescription: settings["intendedUseDescription"] as? String,
                                               walkDuration: settings["walkDuration"] as? TimeInterval ?? 0.0,
                                               restDuration: settings["restDuration"] as? TimeInterval ?? 0.0,
                                               options: ORKPredefinedTaskOption(rawValue: 0))
        case "form":
            let step = ORKFormStep(identifier: id)
            step.formItems = self.items.map({ item in item.visual })
            return ORKOrderedTask(identifier: "form", steps: [step])
        case "custom":
            // FIXME: this sucks
            let task = Task()
            task.steps = [self]
            return CustomOrderedTask(task: task)
        default:
            return nil
        }
    }
    
}
