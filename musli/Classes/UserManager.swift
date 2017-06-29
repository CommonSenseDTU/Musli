//
//  UserManager.swift
//  Pods
//
//  Created by Anders Borch on 5/22/17.
//
//

import Foundation
import ResearchKit

public class UserManager {
    
    private static let userDefaults = {
        return UserDefaults(suiteName: Bundle(for: UserManager.self).bundleIdentifier)
    }()
    
    public static func save(user: User) throws {
        do {
            try user.createInSecureStore()
        } catch {
            try user.updateInSecureStore()
        }
        userDefaults?.set(user.userId, forKey: "account")
        userDefaults?.synchronize()
    }
    
    public static func load() -> User? {
        let user = User()
        user.userId = userDefaults?.value(forKey: "account") as? String
        guard let result = user.readFromSecureStore() else { return nil }
        guard let data = result.data else { return nil }
        user.set(data: data)
        return user
    }

    public static func remove() throws {
        let user = User()
        user.userId = userDefaults?.value(forKey: "account") as? String
        try user.deleteFromSecureStore()
        userDefaults?.synchronize()
    }
    
    /**
     - return (shouldShowConsent: Bool, consentDocument: ORKConsent?) A tuple with an optional consent document and a bool indicating if
       consent flow should be shown.
     */
    public static func shouldShowConsent(for user: User, in survey: Survey) -> (Bool, ORKConsent?) {
        // Show consent flow if there is no signature date
        guard let date = user.signature?.date else {
            return (true, nil)
        }
        /*
         Show consent flow if consent flow was updated on a later calendar date
         ResearchKit only stores signature date - not time, so we hope the
         researcher won't update the consent document more than once per day...
         */
        guard Calendar.current.compare(date, to: survey.consentDocument.modificationDateTime, toGranularity: Calendar.Component.day) != .orderedAscending else {
            return (true, nil)
        }
        
        guard let object = userDefaults?.object(forKey: "consent") as? [AnyHashable: Any] else {
            return (true, nil)
        }
        let consent = ORKConsent(data: object)
        
        // If the consent document exists, but the user credentials are missing, then re-sign existing consent document.
        guard user.userId != nil && user.password != nil else {
            return (true, consent)
        }

    }
}
