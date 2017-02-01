//
//  UITextView+LinkHelper.swift
//  SHRichTextEditor
//
//  Created by Susmita Horrow on 31/01/17.
//  Copyright © 2017 hsusmita. All rights reserved.
//

import Foundation
import UIKit

typealias LinkFetchCompletionBlock = (URL?) ->()

protocol LinkInputEnabled: class {
	var linkAttributes: [String: Any] { get }
	var linkInfoFetcher: (@escaping LinkFetchCompletionBlock) -> () { get }
}

protocol LinkInsertProtocol: class {
	var linkInputProvider: LinkInputEnabled? { get }
	func addLink(for range: NSRange)
}

private var linkProviderKey = "linkProviderKey"

extension UITextView: LinkInsertProtocol {
	
	var linkInputProvider: LinkInputEnabled? {
		get {
			return objc_getAssociatedObject(self, &linkProviderKey) as? LinkInputEnabled
		}
		set {
			objc_setAssociatedObject(self, &linkProviderKey, newValue, .OBJC_ASSOCIATION_RETAIN)
		}
	}
	
	func addLink(for range: NSRange) {
		guard let linkInputProvider = linkInputProvider else {
			debugPrint("linkInputProvider is not set")
			return
		}
		guard range.location + range.length < self.attributedText.length else {
			return
		}
		linkInputProvider.linkInfoFetcher { url in
			guard let url = url else {
				return
			}
			let mutableAttributedString = NSMutableAttributedString(attributedString: self.attributedText)
			mutableAttributedString.addAttributes(self.linkTextAttributes, range: range)
			mutableAttributedString.addAttribute(NSLinkAttributeName, value: url, range: range)
			self.attributedText = mutableAttributedString
		}
	}
	
	func removeLink(from text: String) {
		
	}
}
