//
//  CustomStepViewController.swift
//  musli
//
//  Created by Anders Borch on 3/15/17.
//
//

import UIKit
import ResearchKit

public class CustomTaskViewController: ORKTaskViewController {

    private let customTask: Task
    
    public init(task: Task) {
        self.customTask = task
        super.init(task: CustomOrderedTask(task: task), taskRun: nil)
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func loadView() {
        let view = UIWebView()
        view.loadHTMLString("", baseURL: URL(string: "https://localhost"))
        self.view = view
    }

    override public func viewWillAppear(_ animated: Bool) {
        self.view.frame = UIScreen.main.applicationFrame
    }
}
