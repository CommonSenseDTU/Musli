//
//  ConsentSection.swift
//  musli
//
//  Created by Anders Borch on 1/31/17.
//
//

import Foundation
import RestKit
import ResearchKit

/**
    Client side prepresentation for a section in a consent document.

    The consent document is used for serializing and deserializing consent
    documents from the backend and for getting visual consent step sections.
*/
public class ConsentSection: NSObject {
    public var id = UUID().uuidString.lowercased()
    public var creationDateTime = Date()
    public var modificationDateTime = Date()
    public var type = ""
    public var title = ""
    public var summary = ""
    public var content = ""
    public var popup = ""
    public var options = [String]()

    /**
        Basic properties which are mapped to attributes when serializing and
        deserializing the object for a rest request response.
    */
    public static let attributeMap: Dictionary<String, String> = [
        "id": "id",
        "creation_date_time": "creationDateTime",
        "modification_date_time": "modificationDateTime",
        "type": "type",
        "title": "title",
        "summary": "summary",
        "content": "content",
        "popup": "popup",
        "options": "options"
    ]

    /// Restkit mapping for object serialization and deserialization.
    internal static let mapping: RKObjectMapping = {
        let mapping = RKObjectMapping(for: ConsentSection.self)!
        mapping.addAttributeMappings(from: ConsentSection.attributeMap)
        return mapping
    }()

    // Mapping between section type and its string representation
    private var sectionType: ORKConsentSectionType? {
        switch type {
        case "overview":
            return .overview
        case "datagathering":
            return .dataGathering
        case "privacy":
            return .privacy
        case "datause":
            return .dataUse
        case "timecommitment":
            return .timeCommitment
        case "studysurvey":
            return .studySurvey
        case "studytasks":
            return .studyTasks
        case "withdrawing":
            return .withdrawing
        default:
            return nil
        }
    }

    /**
        - returns: An ORKConsentSection instance if this section is a part of a visual consent step
    */
    public var visual: ORKConsentSection? {
        guard let type = sectionType else { return nil }
        let section = ORKConsentSection(type: type)
        section.title = title
        section.summary = summary
        section.content = content
        return section
    }
}
