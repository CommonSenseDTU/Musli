//
//  ConsentFlowDelegate.swift
//  musli
//
//  Created by Anders Borch on 2/2/17.
//
//

import Foundation
import ResearchKit

/// Delegate which Handles user interaction from the consent flow
open class ConsentFlowDelegate: NSObject, ORKTaskViewControllerDelegate {

    // The survey which the user is consenting to
    var survey: Survey

    /**
        The resource manager used when creating a user account, and uploading
        the consent signature.
    */
    public var resourceManager: ResourceManager
    
    /**
        Set this is a local user account already exists. In that case that user account
        is used instead of creating a new one on completion of the registration flow.
     */
    public var existingUser: User?

    // The latest result of the consent flow
    private var result: ORKTaskResult?

    /**
        Consent flow completion block.

        This is called upon errors and upon completion of the consent flow.
    */
    // TODO: Create an ErrorBlock and call that in stead of the completion block for 409 errors
    public typealias Completion = (_ controller: UIViewController, _ user: User?, _ error: Error?) -> Void
    public var consentCompletion: Completion?

    /**
        Create a consent flow user interaction delegate.

        - parameter survey: The survey which is censented to
        - parameter resourceManager: The resource manager used to create the user account and upload the consent signature
    */
    init(survey: Survey, resourceManager: ResourceManager) {
        self.survey = survey
        self.resourceManager = resourceManager
    }

    /*
        Create a user object from a registration result.

        The email address is used as a user id. That, along with password, first
        name, last name and date of birth is read from the answers given in the
        registration result.

        - parameter registrationResult: The result which contains the user information

        - returns: A new ```User``` object
    */
    private func user(registrationResult: ORKStepResult) -> User {
        let user = User()
        guard let results = registrationResult.results else { return user }
        for result in results {
            guard let textResult = result as? ORKTextQuestionResult else { continue }
            switch result.identifier {
            case ORKRegistrationFormItemIdentifierEmail:
                user.userId = textResult.answer as? String
            case ORKRegistrationFormItemIdentifierPassword:
                user.password = textResult.answer as? String
            case ORKRegistrationFormItemIdentifierGivenName:
                user.firstName = textResult.answer as? String
            case ORKRegistrationFormItemIdentifierFamilyName:
                user.lastName = textResult.answer as? String
            case ORKRegistrationFormItemIdentifierDOB:
                user.dateOfBirth = textResult.answer as? Date
            default:
                break
            }
        }
        return user
    }

    /*
        Get the signature from the registration result.

        - parameter reviewResult: The registration result which contains the signature.

        - returns: Signature instance, if it can be found in the gien result
    */
    private func signature(reviewResult: ORKStepResult) -> Signature? {
        guard let signatureResult = reviewResult.results?.last as? ORKConsentSignatureResult else { return nil }
        return signatureResult.signature as? Signature
    }

    public func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        switch reason {
        case .completed:
            var user: User? = existingUser
            var signature: Signature? = nil
            defer {
                if user != nil {
                    /*
                        A new signature instance is created as a part of the
                        consent flow. Ensure that the consent document is set in
                        the signature instance which is part of the result.
                    */
                    signature?.consentDocument = self.survey.consentDocument

                    user?.signature = signature

                    /*
                        Upload the signature after authorization is completed.
                        Authorization is initiated below.
                    */
                    let authCompletion = { (refreshToken: String?, error: Error?) in
                        user?.refresh = refreshToken
                        guard error == nil else { self.consentCompletion?(taskViewController, user, error) ; return }
                        guard signature != nil else { self.consentCompletion?(taskViewController, user, error) ; return }
                        self.resourceManager.upload(signature: signature!,
                                                    completion: { (success: Bool, error: Error?) in
                                                        self.consentCompletion?(taskViewController, user, error)
                        })
                    }

                    // Authorize after user account is created (below).
                    let createCompletion = { (success: Bool, error: Error?) in
                        guard success else { self.consentCompletion?(taskViewController, nil, error) ; return }
                        self.resourceManager.authorize(username: user!.userId!,
                                                       password: user!.password!,
                                                       completion: authCompletion)
                    }

                    if existingUser != nil {
                        // A user already exists, just authorize
                        createCompletion(true, nil)
                    } else {
                        // Create a user account
                        self.resourceManager.create(user: user!, completion: createCompletion)
                    }
                } else {
                    /*
                        If user or signature is missing, then call completion
                        with an error.
                    */
                    self.consentCompletion?(taskViewController, nil, error)
                }
            }

            // Validate that a result is retrieved as a part of the consent flow.
            guard let results = self.result?.results else { return }

            /*
                Find the registration and review steps, create the user instance,
                and get the updated consent signature.
            */
            for result in results {
                guard let stepResult = result as? ORKStepResult else { continue }
                switch stepResult.identifier {
                case "registration":
                    user = self.user(registrationResult: stepResult)
                case "review":
                    signature = self.signature(reviewResult: stepResult)
                default:
                    break
                }
            }
        default:
            break
        }
    }
    
    private func step(orkStep: ORKStep?) -> Step? {
        guard orkStep != nil else { return nil }
        for step in survey.task.steps {
            if step.id == orkStep?.identifier {
                return step
            }
        }
        return nil
    }

    public func taskViewController(_ taskViewController: ORKTaskViewController, stepViewControllerWillAppear stepViewController: ORKStepViewController) {
        stepViewController.cancelButtonItem = nil
    }

    public func taskViewController(_ taskViewController: ORKTaskViewController, didChange result: ORKTaskResult) {
        self.result = result
    }
}
