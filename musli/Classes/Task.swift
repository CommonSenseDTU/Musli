//
//  Task.swift
//  Pods
//
//  Created by Anders Borch on 2/28/17.
//
//

import Foundation
import RestKit

open class Task: NSObject {
    public var id = ""
    public var steps = [Step]()

    public static let attributeMap: Dictionary<String, String> = [
        "id": "id"
    ]

    internal static let mapping: RKObjectMapping = {
        let mapping = RKObjectMapping(for: Task.self)!
        mapping.addAttributeMappings(from: Task.attributeMap)
        
        let stepMapping = Step.mapping
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "steps", toKeyPath: "steps", with: stepMapping))
        
        return mapping
    }()

}
