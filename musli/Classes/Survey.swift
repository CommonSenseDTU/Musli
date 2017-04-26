//
//  Survey.swift
//  musli
//
//  Created by Anders Borch on 1/31/17.
//
//

import Foundation
import RestKit

/// Client side representation of a survey object.
open class Survey: NSObject {
    public var id = ""
    public var title = ""
    public var userId = ""
    public var icon = ""
    public var creationDateTime = Date()
    public var modificationDateTime = Date()
    public var consentDocument = ConsentDocument()
    public var task = Task()
    public var participantIds = [String]()

    public static let attributeMap: Dictionary<String, String> = [
        "id": "id",
        "title": "title",
        "user_id": "userId",
        "icon": "icon",
        "creation_date_time": "creationDateTime",
        "modification_date_time": "modificationDateTime",
        "participant_ids": "participantIds"
    ]

    internal static let mapping: RKObjectMapping = {
        let mapping = RKObjectMapping(for: Survey.self)!
        mapping.addAttributeMappings(from: Survey.attributeMap)

        let documentMapping = ConsentDocument.mapping
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "consent_document", toKeyPath: "consentDocument", with: documentMapping))
        
        let taskMapping = Task.mapping
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "task", toKeyPath: "task", with: taskMapping))

        return mapping
    }()

}
