//
//  UITextView+ImageHelper.swift
//  SHRichTextEditor
//
//  Created by Susmita Horrow on 31/01/17.
//  Copyright © 2017 hsusmita. All rights reserved.
//

import Foundation
import UIKit

protocol ImageInsertProtocol {
	func insertImage(image: UIImage, at index: Int)
	func selectImage(at index: Int, selectionView: UIView)
	func deselectImage(at index: Int, selectionView: UIView)
}

extension UITextView: ImageInsertProtocol {

	func insertImage(image: UIImage, at index: Int) {
		let oldWidth = image.size.width
		let scaleFactor = oldWidth / (self.frame.size.width - 20)
		self.attributedText = self.attributedText.insert(image, at: index, scaleFactor: scaleFactor)
	}

	func selectImage(at index: Int, selectionView: UIView) {
		let glyphRange: NSRange = layoutManager.range(ofNominallySpacedGlyphsContaining: index)
		var textRect: CGRect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
		textRect.origin.x += textContainerInset.left
		textRect.origin.y += textContainerInset.top
		selectionView.frame = textRect
		addSubview(selectionView )
	}
	
	func deselectImage(at index: Int, selectionView: UIView) {
		selectionView.removeFromSuperview()
	}
}
