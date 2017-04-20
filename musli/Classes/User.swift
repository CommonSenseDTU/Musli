//
//  User.swift
//  musli
//
//  Created by Anders Borch on 2/8/17.
//
//

import Foundation

/// User account object, normally created by the consent flow manager.
open class User: NSObject {
    public var id = UUID().uuidString.lowercased()
    public var userId: String?
    public var password: String?
    public var firstName: String?
    public var lastName: String?
    public var gender: String?
    public var dateOfBirth: Date?
    public var signature: Signature?

    /// Registration data used for authorization and account creation.
    public var registrationData: RegistrationData {
        var registration = RegistrationData()
        registration.userId = userId ?? ""
        registration.password = password ?? ""
        return registration
    }
}
