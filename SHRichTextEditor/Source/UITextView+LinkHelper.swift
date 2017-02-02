//
//  UITextView+LinkHelper.swift
//  SHRichTextEditor
//
//  Created by Susmita Horrow on 31/01/17.
//  Copyright © 2017 hsusmita. All rights reserved.
//

import Foundation
import UIKit


protocol LinkInputEnabled: class {
	var linkAttributes: [String: Any] { get }
}

protocol LinkInsertProtocol: class {
	func addLink(link: URL, for range: NSRange)
}

extension UITextView: LinkInsertProtocol {
	
	func addLink(link: URL, for range: NSRange) {
		guard range.location + range.length < self.attributedText.length else {
			return
		}
		let mutableAttributedString = NSMutableAttributedString(attributedString: self.attributedText)
		mutableAttributedString.addAttributes(self.linkTextAttributes, range: range)
		mutableAttributedString.addAttribute(NSLinkAttributeName, value: link, range: range)
		self.attributedText = mutableAttributedString
	}
	
	func removeLink(from text: String) {
		
	}
}
