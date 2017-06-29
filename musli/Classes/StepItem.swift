//
//  StepItem.swift
//  Pods
//
//  Created by Anders Borch on 4/20/17.
//
//

import Foundation
import ResearchKit
import RestKit

open class StepItem: NSObject {
    public var id = ""
    public var format = ""
    public var question = ""
    public var imageUrls = [URL]()
    public var selectedImageUrls = [URL]()
    public var values = [String]()
    
    public static let attributeMap: Dictionary<String, String> = [
        "id": "id",
        "format": "format",
        "question": "question",
        "urls": "imageUrls",
        "selected_urls": "selecteImageUrls",
        "values": "values"
    ]
    
    internal static let mapping: RKObjectMapping = {
        let mapping = RKObjectMapping(for: StepItem.self)!
        mapping.addAttributeMappings(from: StepItem.attributeMap)
        return mapping
    }()

    /*
     "horizontalscale"
     "boolean"
     "picker"
     "singletextchoice"
     "multitextchoice"
     "numeric"
     "timeofday"
     "date"
     "textarea"
     "textinput"
     "validated"
     "verticalscale"
     "email"
     "location"
     */
    
    
    internal var visualFormat: ORKAnswerFormat? {
        switch format {
        case "horizontalscale":
            return ORKAnswerFormat.scale(withMaximumValue: 10,
                                         minimumValue: 1,
                                         defaultValue: 5,
                                         step: 1,
                                         vertical: false,
                                         maximumValueDescription: "",
                                         minimumValueDescription: "")
        case "boolean":
            return ORKAnswerFormat.booleanAnswerFormat()
        case "picker":
            return ORKAnswerFormat.valuePickerAnswerFormat(with: [ORKTextChoice(text: "", value: "" as NSCoding & NSCopying & NSObjectProtocol)])
        case "singletextchoice":
            return ORKAnswerFormat.choiceAnswerFormat(with: .singleChoice, textChoices: [ORKTextChoice(text: question, value: "" as NSCoding & NSCopying & NSObjectProtocol)])
        case "multitextchoice":
            return ORKAnswerFormat.choiceAnswerFormat(with: .singleChoice, textChoices: [ORKTextChoice(text: question, value: "" as NSCoding & NSCopying & NSObjectProtocol)])
        case "numeric":
            return ORKAnswerFormat.integerAnswerFormat(withUnit: nil)
        case "timeofday":
            return ORKAnswerFormat.timeOfDayAnswerFormat()
        case "date":
            return ORKAnswerFormat.dateAnswerFormat()
        case "textarea":
            return ORKAnswerFormat.textAnswerFormat(withMaximumLength: 0)
        case "textinput":
            let format =  ORKAnswerFormat.textAnswerFormat(withMaximumLength: 0)
            format.multipleLines = false
            return format
        //case "validated":
        case "verticalscale":
            return ORKAnswerFormat.scale(withMaximumValue: 10,
                                         minimumValue: 1,
                                         defaultValue: 5,
                                         step: 1,
                                         vertical: true,
                                         maximumValueDescription: "",
                                         minimumValueDescription: "")
        case "email":
            return ORKAnswerFormat.emailAnswerFormat()
        case "location":
            return ORKAnswerFormat.locationAnswerFormat()
        case "imagechoice":
            var choices = [ORKImageChoice]()
            for index in 0..<imageUrls.count {
                choices.append(ORKImageChoice(normalImageURL: imageUrls[index],
                                              selectedImageURL: selectedImageUrls[index],
                                              placeHolderImage: nil,
                                              selectedPlaceHolderImage: nil,
                                              text: nil,
                                              value: values[index] as NSCoding & NSCopying & NSObjectProtocol))
            }
            return ORKAnswerFormat.choiceAnswerFormat(with: choices)
        default:
            return nil
        }
    }
    
    public var visual: ORKFormItem {
        return ORKFormItem(identifier: id,
                           text: question,
                           answerFormat: visualFormat)
    }
}
