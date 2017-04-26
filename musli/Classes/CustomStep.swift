//
//  CustomStep.swift
//  Pods
//
//  Created by Anders Borch on 4/4/17.
//
//

import Foundation
import ResearchKit

open class CustomStep: ORKStep {
    private let step: Step

    public init(step: Step) {
        self.step = step
        super.init(identifier: "custom")
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override var title: String? {
        get {
            return step.title
        }
        set(title) {
            guard title != nil else { return }
            step.title = title!
        }
    }
    
    open override var requestedPermissions: ORKPermissionMask {
        var mask = ORKPermissionMask(rawValue: 0)
        for sensor in step.sensors {
            switch sensor {
            case "motion":
                mask.formUnion(ORKPermissionMask.coreMotionActivity)
            case "accel":
                mask.formUnion(ORKPermissionMask.coreMotionAccelerometer)
            case "audio":
                mask.formUnion(ORKPermissionMask.audioRecording)
            case "gps":
                mask.formUnion(ORKPermissionMask.coreLocation)
            case "video":
                mask.formUnion(ORKPermissionMask.camera)
            default:
                break
            }
        }
        return mask
    }
}
