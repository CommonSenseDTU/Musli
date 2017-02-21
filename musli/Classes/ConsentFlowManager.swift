//
//  ConsentFlowManager.swift
//  musli
//
//  Created by Anders Borch on 2/1/17.
//
//

import Foundation
import ResearchKit
import RestKit

/**
    Manager class used for generating a consent for view controller which presents
    the visual consent steps in the consent document, the user registration and
    the sharing options.

    The manager includes a delegate which handles user answers in the consent
    flow. A completion block can be set in the delegate class to handle errors
    which occur in the consent flow as well as handling the completion of the flow.
*/
public class ConsentFlowManager {
    private var survey: Survey

    /**
        A delegate which handles user answers in the consent flow. A completion
        block can be set in the delegate class to handle errors which occur in
        the consent flow as well as handling the completion of the flow.
    */
    public var delegate: ConsentFlowDelegate

    internal let signature = Signature()

    /**
        Create a consent flow manager.

        - parameter resourceManager: Resource manager used in the delegate for cfreating an account and uploading the consent signature
        - parameter survey: The survey to create a consent flow for
    */
    public init(resourceManager: ResourceManager, survey: Survey) {
        self.survey = survey
        signature.consentDocument = survey.consentDocument
        self.delegate = ConsentFlowDelegate(survey: survey, resourceManager: resourceManager)
    }

    /// View controller which presents a consent flow.
    public var viewController: UIViewController {
        var steps = [ORKStep]()

        // Create a visual consent step.
        let visualDocument = survey.consentDocument.visual
        if visualDocument.sections != nil && visualDocument.sections!.count > 0 {
            let step = ORKVisualConsentStep(identifier: survey.consentDocument.id, document: visualDocument)
            steps.append(step)
        }

        /*
            Create the review consent step.

            The review step may have a name requirement and a signature
            requirement if the consent document includes the relevant sections.
        */
        let reviews = survey.consentDocument.sections.filter({ $0.type == "review" })
        let nameRequirements = survey.consentDocument.sections.filter({ $0.type == "consent" })
        let signatureRequirements = survey.consentDocument.sections.filter({ $0.type == "signature" })
        if reviews.count > 0 {
            let review = reviews.first!
            if nameRequirements.count > 0 { signature.requiresName = true }
            if signatureRequirements.count > 0 { signature.requiresSignatureImage = true }
            visualDocument.signatures = [signature]

            let step = ORKConsentReviewStep(identifier: "review",
                                            signature: signature,
                                            in: visualDocument)
            step.reasonForConsent = review.popup
            steps.append(step)
        }

        // Create sharing options step.
        let shares = survey.consentDocument.sections.filter({ $0.type == "sharingoptions" })
        if shares.count > 0 {
            let share = shares.first!
            let format = ORKAnswerFormat.choiceAnswerFormat(with: .singleChoice, textChoices: [
                ORKTextChoice(text: share.options[0], detailText: nil, value: "private" as NSCoding & NSCopying & NSObjectProtocol, exclusive: true),
                ORKTextChoice(text: share.options[1], detailText: nil, value: "individual study" as NSCoding & NSCopying & NSObjectProtocol, exclusive: true),
                ORKTextChoice(text: share.options[2], detailText: nil, value: "public" as NSCoding & NSCopying & NSObjectProtocol, exclusive: true)
            ])
            let step = ORKConsentSharingStep(identifier: "sharingoptions",
                                             title: share.title,
                                             text: share.summary,
                                             answer: format)
            steps.append(step)
        }

        /*
            Create account creation step.

            The account creation step may have first name, last name, gender and
            date of birth input fields if configured so in the relevant consent
            section.
        */
        let registrationRequirements = survey.consentDocument.sections.filter({ $0.type == "registration" })
        var registrationOptions: ORKRegistrationStepOption = []
        var registration = ConsentSection()
        if registrationRequirements.count > 0 {
            let registration = registrationRequirements.first!
            for option in registration.options {
                switch option {
                case "includeGivenName":
                    registrationOptions.update(with: .includeGivenName)
                case "includeFamilyName":
                    registrationOptions.update(with: .includeFamilyName)
                case "includeGender":
                    registrationOptions.update(with: .includeGivenName)
                case "includeDOB":
                    registrationOptions.update(with: .includeDOB)
                default:
                    break
                }
            }
        } else {
            registration.title = "Account Registration"
            registration.summary = "Please register at this point"
        }

        let registrationStep = ORKRegistrationStep(identifier: "registration",
                                                   title: registration.title,
                                                   text: registration.summary,
                                                   options: registrationOptions)
        steps.append(registrationStep)

        // Create a view controller which includes the steps above in order
        let task = ORKOrderedTask(identifier: survey.id, steps: steps)

        let controller = ORKTaskViewController(task: task, taskRun: nil)
        controller.delegate = delegate
        return controller
    }


}
