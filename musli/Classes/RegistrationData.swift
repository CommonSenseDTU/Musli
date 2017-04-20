//
//  RegistrationData.swift
//  musli
//
//  Created by Anders Borch on 2/9/17.
//
//

import Foundation
import RestKit

/// Client side representation of data used to register a new user.
open class RegistrationData: NSObject {
    public var userId = ""
    public var password = ""

    public static let attributeMap: Dictionary<String, String> = [
        "username": "userId",
        "password": "password"
    ]

    internal static let mapping: RKObjectMapping = {
        let mapping = RKObjectMapping(for: RegistrationData.self)!
        mapping.addAttributeMappings(from: RegistrationData.attributeMap)
        return mapping
    }()
}
