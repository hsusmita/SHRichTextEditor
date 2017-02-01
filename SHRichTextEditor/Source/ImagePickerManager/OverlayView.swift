//
//  OverlayView.swift
//  SHRichTextEditor
//
//  Created by Susmita Horrow on 11/01/17.
//  Copyright © 2017 hsusmita. All rights reserved.
//

import UIKit

class OverlayView: UIView {
	var actionOnClickButtonTap: (() -> ())?
	var actionOnFlashButtonTap: ((_ isFlashOn: Bool) -> ())?
	var actionOnCancelButtonTap: (() -> ())?

	class func overlayView() -> OverlayView {
		let view = UINib(nibName: "OverlayView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! OverlayView
		return view
	}
	
	@IBAction func didTapClickButton(_ sender: Any) {
		if let action = actionOnClickButtonTap {
			action()
		}
	}
	
	@IBAction func didTapCancelButton(_ sender: Any) {
		if let action = actionOnCancelButtonTap {
			action()
		}
	}
}
