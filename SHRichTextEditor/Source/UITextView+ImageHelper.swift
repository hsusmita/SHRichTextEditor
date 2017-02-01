//
//  UITextView+ImageHelper.swift
//  SHRichTextEditor
//
//  Created by Susmita Horrow on 31/01/17.
//  Copyright © 2017 hsusmita. All rights reserved.
//

import Foundation
import UIKit

typealias ImageFetchCompletionBlock = (UIImage?) ->()

protocol ImageInputEnabled: class {
	var imageFetcher: (@escaping ImageFetchCompletionBlock) -> () { get }
	var imageSelectionView: UIView { get }
}

protocol ImageInsertProtocol {
	var imageProvider: ImageInputEnabled? { get }
	func insertImage(at index: Int)
	func selectImage(at index: Int)
	func deselectImage(at index: Int)
}

private var imageProviderKey = "imageProviderKey"

extension UITextView: ImageInsertProtocol {

	var imageProvider: ImageInputEnabled? {
		get {
			return objc_getAssociatedObject(self, &imageProviderKey) as? ImageInputEnabled
		}
		set {
			objc_setAssociatedObject(self, &imageProviderKey, newValue, .OBJC_ASSOCIATION_RETAIN)
		}
	}

	func selectImage(at index: Int) {
		guard let imageProvider = imageProvider else {
			debugPrint("imageProvider is not set")
			return
		}

		let glyphRange: NSRange = layoutManager.range(ofNominallySpacedGlyphsContaining: index)
		var textRect: CGRect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
		textRect.origin.x += textContainerInset.left
		textRect.origin.y += textContainerInset.top
		imageProvider.imageSelectionView.frame = textRect
		addSubview(imageProvider.imageSelectionView)
	}
	
	func deselectImage(at index: Int) {
		guard let imageProvider = imageProvider else {
			debugPrint("imageProvider is not set")
			return
		}
		imageProvider.imageSelectionView.removeFromSuperview()
	}
	
	func insertImage(at index: Int) {
		guard let imageProvider = imageProvider else {
			debugPrint("imageProvider is not set")
			return
		}
		imageProvider.imageFetcher { [unowned self] (image) in
			guard let image = image else {
				return
			}
			let oldWidth = image.size.width
			let scaleFactor = oldWidth / (self.frame.size.width - 20)
			self.attributedText = self.attributedText.insert(image, at: index, scaleFactor: scaleFactor)
			self.selectImage(at: index)
		}
	}
}
