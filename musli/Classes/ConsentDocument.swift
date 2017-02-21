//
//  ConsentDocument.swift
//  musli
//
//  Created by Anders Borch on 1/31/17.
//
//

import Foundation
import RestKit
import ResearchKit

/**
    Client side prepresentation for a consent document.

    The consent document is used for serializing and deserializing consent
    documents from the backend and for getting visual consent step sections.
*/
public class ConsentDocument: NSObject {
    /// UUID of the consent document
    public var id = UUID().uuidString.lowercased()

    /// Date when the document was created
    public var creationDateTime = Date()

    /// Last modification date for the document
    public var modificationDateTime = Date()

    /**
        List of sections in the consent document.

        This list may include sections for description of the review step, the
        sharing options, and the registration options in addition to the sections
        which make up the visual consent step.
    */
    public var sections = [ConsentSection]()

    /**
        Basic properties which are mapped to attributes when serializing and
        deserializing the object for a rest request response.

        This list does not include the ```sections``` property which is mapped
        using a relationship mapping.
    */
    public static let attributeMap: Dictionary<String, String> = [
        "id": "id",
        "creation_date_time": "creationDateTime",
        "modification_date_time": "modificationDateTime"
    ]

    /// Restkit mapping for object serialization and deserialization.
    internal static let mapping: RKObjectMapping = {
        let mapping = RKObjectMapping(for: ConsentDocument.self)!
        mapping.addAttributeMappings(from: ConsentDocument.attributeMap)

        let sectionMapping = ConsentSection.mapping
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "sections", toKeyPath: "sections", with: sectionMapping))

        return mapping
    }()

    /// ORKConsentDocument which includes the sections in the visual consent step.
    public var visual: ORKConsentDocument {
        let document = ORKConsentDocument()
        document.sections = [ORKConsentSection]()
        for section in self.sections {
            guard let visual = section.visual else { continue }
            document.sections!.append(visual)
        }
        return document
    }
}
