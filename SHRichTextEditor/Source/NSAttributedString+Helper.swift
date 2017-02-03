//
//  NSAttributedString+Helper.swift
//  SHRichTextEditor
//
//  Created by Susmita Horrow on 30/01/17.
//  Copyright © 2017 hsusmita. All rights reserved.
//

import Foundation
import UIKit

extension NSAttributedString {
	
	func font(at index: Int) -> UIFont? {
		var range: NSRange = NSRange()
		guard index < length else {
			return nil
		}
		let currentAttributes = attributes(at: index, effectiveRange: &range)
		let font: UIFont = currentAttributes[NSFontAttributeName] as! UIFont
		return font
	}
	
	func linkPresent(at index: Int) -> Bool {
		var range: NSRange = NSRange()
		guard index < length else {
			return false
		}
		let currentAttributes = attributes(at: index, effectiveRange: &range)
		return currentAttributes[NSLinkAttributeName] != nil
	}
	
	func imagePresent(at index: Int) -> Bool {
		guard index < length else {
			return false
		}
		let attributeValue = attribute(NSAttachmentAttributeName, at: index, effectiveRange: nil)
		return attributeValue != nil
	}
	
	func insert(_ image: UIImage, at index: Int, scaleFactor: CGFloat) -> NSAttributedString? {
		guard index < length else {
			return nil
		}
		let textAttachment = NSTextAttachment()
		textAttachment.image = image
		textAttachment.image = UIImage(cgImage: textAttachment.image!.cgImage!, scale: scaleFactor, orientation: .up)
		let attrStringWithImage = NSAttributedString(attachment: textAttachment)
		let mutableAttributedString = NSMutableAttributedString(attributedString: self)
		mutableAttributedString.insert(attrStringWithImage, at: index)
		mutableAttributedString.addAttribute(NSAttachmentAttributeName, value: textAttachment, range: NSRange(location: index, length: 1))
//		mutableAttributedString.addAttribute(UserHandleAttributeDictonary, value: [NSForegroundColorAttributeName: UIColor.black,
//		                                                                           NSFontAttributeName: UIFont.systemFont(ofSize: 20.0),
//		                                                                           NSBackgroundColorAttributeName: UIColor.green
//			], range: NSRange(location: index, length: 1))
		mutableAttributedString.append(NSAttributedString(string: "     "))
		return mutableAttributedString
	}
}
