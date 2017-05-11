//
//  ResourceManager.swift
//  musli
//
//  Created by Anders Borch on 1/31/17.
//
//

import Foundation
import RestKit
import Granola

//private let server = "https://commonsensetest.compute.dtu.dk/v1"
private let server = "http://localhost:8000/v1"


/**
    Manager class used for passing resources between client and backend,
    including user authorization and user account creation.
*/
public class ResourceManager {
    /// Semantic communication errors between client and server.
    public enum ResourceError: Error {
        /// The Survey requested was not found on the server.
        case surveyNotFound

        /// User id and password did not match any credentials found on the server.
        case unauthorized
    }

    /// User account creation specific error.
    public enum UserCreationError: Error {

        /// User id already exists on the server.
        case userIdConflict

        /// Error message intented to be used as a message in an error dialog.
        public var localizedDescription: String {
            return NSLocalizedString("UserCreationError_userIdConflict_description",
                                     tableName: "Localizable",
                                     bundle: Bundle(for: ResourceManager.self),
                                     value: "The email address is already in use, please choose a different email address.",
                                     comment: "User ID conflict error description")
        }

        /// Error title intented to be used as a message in an error dialog.
        public var localizedTitle: String {
            return NSLocalizedString("UserCreationError_userIdConflict_title",
                                     tableName: "Localizable",
                                     bundle: Bundle(for: ResourceManager.self),
                                     value: "Email Already In Use",
                                     comment: "User ID conflict error title")
        }

    }

    /*
        Returns a ```RKObjectManager``` instance configured to handle auth
        requests and responses with ```RegistrationData``` and ```OAuthResponse```
        objects mapped to them, respectively.

        Request serialization type changes depending on whether a oauth request
        or a users request is being made.
    */
    private lazy var authManager: RKObjectManager = {
        let authManager = RKObjectManager(baseURL: NSURL(string: server) as URL!)!
        let response = RKResponseDescriptor(mapping: OAuthResponse.mapping,
                                            method: .POST,
                                            pathPattern: "oauth/token",
                                            keyPath: nil,
                                            statusCodes: IndexSet(integer: 200))
        authManager.addResponseDescriptor(response)
        var request = RKRequestDescriptor(mapping: RegistrationData.mapping.inverse(),
                                          objectClass: RegistrationData.self,
                                          rootKeyPath: nil,
                                          method: .POST)
        authManager.addRequestDescriptor(request)
        return authManager
    }()

    /*
        Returns a ```RKObjectManager``` instance configured to handle consent
        flow requests with a ```Survey``` object mapped as a response object.
    */
    private lazy var resourceManager: RKObjectManager = {
        let resourceManager = RKObjectManager(baseURL: NSURL(string: server) as URL!)!
        resourceManager.requestSerializationMIMEType = RKMIMETypeJSON

        let surveyDescriptor = RKResponseDescriptor(mapping: Survey.mapping,
                                                    method: .GET,
                                                    pathPattern: "consentflow/surveys/:id",
                                                    keyPath: nil,
                                                    statusCodes: IndexSet(integer: 200))
        resourceManager.addResponseDescriptor(surveyDescriptor)

        return resourceManager
    }()

    /*
        Returns a ```RKObjectManager``` instance configured to handle signature
        upload requests with a ```Signature``` object mapped for requests.
    */
    private lazy var privateManager: RKObjectManager = {
        let privateManager = RKObjectManager(baseURL: NSURL(string: server) as URL!)!
        privateManager.requestSerializationMIMEType = RKMIMETypeJSON
        let descriptor = RKRequestDescriptor(mapping: Signature.inverseMapping,
                                             objectClass: Signature.self,
                                             rootKeyPath: nil,
                                             method: .POST)
        privateManager.addRequestDescriptor(descriptor)
        return privateManager
    }()

    public var consent: ORKConsent?
    
    /**
        Create a ```ResourceManager``` instance.

        - parameter clientSecret: The secret used to authorize the client with the server.
    */
    public init(clientSecret: String) {
        let mainBundle = Bundle.main
        let clientId: String = mainBundle.infoDictionary?["OMHClientId"] as? String ?? "no-client-id"
        authManager.httpClient.setAuthorizationHeaderWithUsername(clientId, password: clientSecret)
    }

    /*
        Handle a succesful authorization request. A succesful request only means
        that the communication with the server succeeded - not that the
        authorization was succesful. Succesful authentication is determined by
        the existence of a refresh token.

        The access token is set on the resource and private RKObjectManager
        instances if the response includes an ```OAuthResponse``` object.

        - parameter op: The operation object.
        - parameter result: The response mapping result.
        - parameter completion: The completion block to be called once the
    */
    private func authorizeSuccess(op: RKObjectRequestOperation?, result: RKMappingResult?, completion: (_ refrshToken: String?, _ error: Error?) -> Void) {
        var refreshToken: String?
        defer {
            completion(refreshToken, refreshToken != nil ? nil : ResourceError.unauthorized)
        }
        guard let dictionary = result?.dictionary() else { return }
        guard dictionary.count >= 1 else { return }
        guard let response: OAuthResponse = dictionary.values.first as! OAuthResponse? else { return }
        refreshToken = response.refreshToken
        for manager in [self.resourceManager, self.privateManager] {
            manager.httpClient.setDefaultHeader("Authorization", value: "Bearer " + response.accessToken)
        }
    }

    /**
        Request authorization with a given username and password. A completion
        block is called onup completed authorization request. The completion
        block is given a refresh token or an error depending on whether the
        request was succesful or failed. The refresh token can be used in future
        requests in case authorization has expired.

        - parameter username: The username to authenticate.
        - parameter password: The password to use for authentication.
        - parameter completion: The block to be called upon completed request.
    */
    public func authorize(username: String, password: String, completion: @escaping (_ refrshToken: String?, _ error: Error?) -> Void) {
        let createForm: ((AFRKMultipartFormData?) -> Void) = { (data: AFRKMultipartFormData?) in
            data?.appendPart(withForm: "password".data(using: .utf8), name: "grant_type")
            data?.appendPart(withForm: username.data(using: .utf8), name: "username")
            data?.appendPart(withForm: password.data(using: .utf8), name: "password")
        }
        authManager.requestSerializationMIMEType = RKMIMETypeFormURLEncoded
        let request = authManager.multipartFormRequest(with: nil,
                                                       method: .POST,
                                                       path: "oauth/token",
                                                       parameters: nil,
                                                       constructingBodyWith: createForm)

        let success = { (op: RKObjectRequestOperation?, result: RKMappingResult?) in
            self.authorizeSuccess(op: op, result: result, completion: completion)
        }
        let failure = { (op: RKObjectRequestOperation?, error: Error?) in
            completion(nil, error)
        }
        let op = authManager.objectRequestOperation(with: request as URLRequest!,
                                                    success: success,
                                                    failure: failure)
        authManager.enqueue(op)
    }

    /**
        Request authorization with a given refresh token. A completion
        block is called upon completed authorization request. The completion
        block is given a refresh token or an error depending on whether the
        request was succesful or failed. The refresh token can be used in future
        requests in case authorization has expired.

        - parameter refreshToken: The token used to re-autenticate.
        - parameter completion: The block to be called upon completed request.
    */
    public func authorize(token: String, completion: @escaping (_ refrshToken: String?, _ error: Error?) -> Void) {
        let createForm: ((AFRKMultipartFormData?) -> Void) = { (data: AFRKMultipartFormData?) in
            data?.appendPart(withForm: "refresh_token".data(using: .utf8), name: "grant_type")
            data?.appendPart(withForm: token.data(using: .utf8), name: "refresh_token")
        }
        authManager.requestSerializationMIMEType = RKMIMETypeFormURLEncoded
        let request = authManager.multipartFormRequest(with: nil,
                                                       method: .POST,
                                                       path: "oauth/token",
                                                       parameters: nil,
                                                       constructingBodyWith: createForm)

        let success = { (op: RKObjectRequestOperation?, result: RKMappingResult?) in
            self.authorizeSuccess(op: op, result: result, completion: completion)
        }
        let failure = { (op: RKObjectRequestOperation?, error: Error?) in
            completion(nil, error)
        }
        let op = authManager.objectRequestOperation(with: request as URLRequest!,
                                                    success: success,
                                                    failure: failure)
        authManager.enqueue(op)
    }

    /**
        Retrieve a survey from the server. The completion block is given the
        survey or an error as parameters if the request succeeds or fails,
        respectively.

        - parameter id: The id of the survey to request.
        - parameter completion: The block which is called upon completion.
    */
    public func survey(id: String, completion: @escaping (_ survey: Survey?, _ error: Error?) -> Void) {
        var survey: Survey?
        let success = { (op: RKObjectRequestOperation?, result: RKMappingResult?) in
            var error: Error = ResourceError.surveyNotFound
            defer {
                completion(survey, survey != nil ? nil : error)
            }
            guard let dictionary = result?.dictionary() else { return }
            guard dictionary.count >= 1 else { return }
            survey = dictionary.values.first as! Survey?
            guard survey != nil else { return }
        }
        let failure = { (op: RKObjectRequestOperation?, error: Error?) in
            completion(nil, error)
        }
        let request = resourceManager.request(with: nil,
                                              method: .GET,
                                              path: "consentflow/surveys/" + id,
                                              parameters: nil)

        let op = resourceManager.objectRequestOperation(with: request as URLRequest!,
                                                        success: success,
                                                        failure: failure)
        resourceManager.enqueue(op)
    }

    /**
        Upload a signature to the server. The client must be authorized before
        uploading. The completion block is given a success boolean parameter and
        an optional error parameter which is set if the upload fails.

        - parameter signature: The signature to upload.
        - parameter completion: The block called after completed or failed upload.
    */
    public func upload(signature: Signature, completion: @escaping ((_ success: Bool, _ error: Error?) -> Void)) {
        let success = { (op: RKObjectRequestOperation?, result: RKMappingResult?) in
            completion(true, nil)
        }
        let failure = { (op: RKObjectRequestOperation?, error: Error?) in
            completion(false, error)
        }
        privateManager.post(signature,
                            path: "private/signatures/my",
                            parameters: [:],
                            success: success,
                            failure: failure)
    }
    
    
    public func upload(json: [AnyHashable: Any], forStep step: Step, completion: @escaping ((_ success: Bool, _ error: Error?) -> Void)) {
        let success = { (op: RKObjectRequestOperation?, result: RKMappingResult?) in
            completion(true, nil)
        }
        let failure = { (op: RKObjectRequestOperation?, error: Error?) in
            completion(false, error)
        }

        var path = "dataPoints"
        if step.isPrivate {
            path = "private/dataPoints"
        }
        
        resourceManager.post(nil,
                             path: path,
                             parameters: json,
                             success: success,
                             failure: failure)
    }

    /**
        Create a new user account on the server. The completion block is given a
        success boolean parameter and an optional error parameter which is set
        if the upload fails.

        - parameter user: The user account information, usually created by the consent flow manager.
        - parameter completion: The block called after completed or failed account creation.
    */
    public func create(user: User, completion: @escaping ((_ success: Bool, _ error: Error?) -> Void)) {
        let failure = { (op: RKObjectRequestOperation?, error: Error?) in
            guard error != nil else { completion(false, error) ; return }
            if ((error! as NSError).userInfo[AFRKNetworkingOperationFailingURLResponseErrorKey] as? HTTPURLResponse)?.statusCode == 409 {
                completion(false, UserCreationError.userIdConflict)
            } else {
                completion(false, error)
            }
        }
        let createSuccess = { (op: RKObjectRequestOperation?, result: RKMappingResult?) in
            completion(true, nil)
        }
        authManager.requestSerializationMIMEType = RKMIMETypeJSON
        authManager.post(user.registrationData,
                         path: "users",
                         parameters: [:],
                         success: createSuccess,
                         failure: failure)
    }

}
