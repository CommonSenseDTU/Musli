//
//  User.swift
//  musli
//
//  Created by Anders Borch on 2/8/17.
//
//

import Foundation
import Locksmith

/// User account object, normally created by the consent flow manager.
open class User: NSObject, GenericPasswordSecureStorable, CreateableSecureStorable, ReadableSecureStorable, DeleteableSecureStorable {
    public var id = UUID().uuidString.lowercased()
    public var userId: String?
    public var password: String?
    public var refresh: String?
    public var firstName: String?
    public var lastName: String?
    public var gender: String?
    public var dateOfBirth: Date?
    public var signature: Signature?

    /// Registration data used for authorization and account creation.
    public var registrationData: RegistrationData {
        let registration = RegistrationData()
        registration.userId = userId ?? ""
        registration.password = password ?? ""
        return registration
    }

    public var service: String { return "Musli" }
    public var account: String { return userId ?? "" }
    public var signatureDate: String? {
        get {
            return self.signature?.signatureDate
        }
        set(date) {
            /*
             Signature may not be initialized if instance was created by Locksmith
             so we create a signature instance on demand for storing the signature date.
             */
            if self.signature == nil {
                self.signature = Signature()
            }
            self.signature!.signatureDate = date
        }
    }
    
    public static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }
    
    public var data: [String: Any] {
        let dateOfBirth = self.dateOfBirth != nil ? User.dateFormatter.string(from: self.dateOfBirth!) : nil
        return [
            "id": id,
            "userId": userId ?? "",
            "password": password ?? "",
            "refresh": refresh ?? "",
            "firstName": firstName ?? "",
            "lastName": lastName ?? "",
            "gender": gender ?? "",
            "dateOfBirth": dateOfBirth ?? "",
            "signatureDate": signatureDate ?? ""
        ]
    }
    
    public func set(data: [String: Any]) {
        if data["id"] is String {
            self.id = data["id"] as! String
        }
        self.password = data["password"] as? String
        self.refresh = data["refresh"] as? String
        self.firstName = data["firstName"] as? String
        self.lastName = data["lastName"] as? String
        self.gender = data["gender"] as? String
        if let date = data["dateOfBirth"] as? String {
            self.dateOfBirth = User.dateFormatter.date(from: date)
        }
        self.signatureDate = data["signatureDate"] as? String
    }
}
