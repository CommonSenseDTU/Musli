//
//  OAuthResponse.swift
//  musli
//
//  Created by Anders Borch on 1/31/17.
//
//

import Foundation
import RestKit

/// Client side prepresentation of an OAuth response
internal class OAuthResponse: NSObject {
    internal var accessToken = ""
    internal var tokenType = ""
    internal var refreshToken = ""
    internal var expiresIn = 0
    internal var scope = ""

    public static let attributeMap: Dictionary<String, String> = [
        "access_token": "accessToken",
        "token_type": "tokenType",
        "refresh_token": "refreshToken",
        "expires_in": "expiresIn",
        "scope": "scope"
    ]

    internal static let mapping: RKObjectMapping = {
        let mapping = RKObjectMapping(for: OAuthResponse.self)!
        mapping.addAttributeMappings(from: OAuthResponse.attributeMap)
        return mapping
    }()

}
