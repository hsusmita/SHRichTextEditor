//
//  RichTextToolbar.swift
//  DentalPlex
//
//  Created by Susmita Horrow on 05/01/17.
//  Copyright © 2017 Susmita Horrow. All rights reserved.
//

import UIKit

enum ToolbarButtonType: Int {
	case bullet
	case bold
	case italic
	case link
	case camera
}

typealias BarButtonAction = (() -> ())

class RichTextToolbar: UIToolbar {
	@IBOutlet weak var bulletButton: UIBarButtonItem!
	@IBOutlet weak var boldButton: UIBarButtonItem!
	@IBOutlet weak var italicButton: UIBarButtonItem!
	@IBOutlet weak var linkButton: UIBarButtonItem!
	@IBOutlet weak var cameraButton: UIBarButtonItem!

	private var actions: [ToolbarButtonType: BarButtonAction] = [:]

	class func toolbar() -> RichTextToolbar {
		let toolBar = UINib(nibName: "RichTextToolbar", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! RichTextToolbar
		toolBar.configureActions()
		return toolBar
	}
	
	func setAction(for barButton: ToolbarButtonType, action: @escaping BarButtonAction) {
		actions[barButton] = action
	}
	
	private func configureActions() {
		bulletButton.action = #selector(performAction(sender:))
		boldButton.action = #selector(performAction(sender:))
		italicButton.action = #selector(performAction(sender:))
		linkButton.action = #selector(performAction(sender:))
		cameraButton.action = #selector(performAction(sender:))
	}
	
	@objc func performAction(sender: UIBarButtonItem) {
		var buttonType: ToolbarButtonType?
		switch sender {
		case bulletButton:
			buttonType = .bullet
		case boldButton:
			buttonType = .bold
		case italicButton:
			buttonType = .italic
		case linkButton:
			buttonType = .link
		case cameraButton:
			buttonType = .camera
		default:
			break
		}
		if let buttonType = buttonType,
		let action = actions[buttonType] {
			action()
		}
	}
}
