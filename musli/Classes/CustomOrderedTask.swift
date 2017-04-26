//
//  CustomOrderedTask.swift
//  Pods
//
//  Created by Anders Borch on 4/4/17.
//
//

import Foundation
import ResearchKit

open class CustomOrderedTask: ORKOrderedTask {
    
    internal let customTask: Task
    
    public init(task: Task) {
        self.customTask = task
        super.init(identifier: "custom", steps: [])
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
