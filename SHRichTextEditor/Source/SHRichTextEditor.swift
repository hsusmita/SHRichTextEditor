//
//  SHRichTextEditor.swift
//  SHRichTextEditor
//
//  Created by Susmita Horrow on 30/01/17.
//  Copyright © 2017 hsusmita. All rights reserved.
//

import Foundation
import UIKit

class SHRichTextEditor: NSObject {
	internal let textView: UITextView
	private var currentCharacterIndex: Int?
	private let toolbar: RichTextToolbar = RichTextToolbar.toolbar()
	fileprivate var imagePickerManager: ImagePickerManager?
	fileprivate var imageBorderView = ImageBorderView.imageBorderView()
	fileprivate var indentationOn: Bool = false
	private var currentCursorPosition: Int? {
		guard let selectedRange = textView.selectedTextRange else {
			return nil
		}
		return textView.offset(from: textView.beginningOfDocument, to: selectedRange.start)
	}
	private var shouldAddIndentation: Bool {
		guard let cursorPosition = currentCursorPosition else {
			return false
		}
		let indentationRange = textView.indentationRange(at: cursorPosition)
		return indentationOn && indentationRange == nil
	}
	
	init(textView: UITextView) {
		self.textView = textView
		super.init()
		configureTextView()
	}
	
	private func configureTextView() {
		textView.indentationStringProvider = self
		textView.imageProvider = self
		textView.linkInputProvider = self
		configureGesture()
		configureToolbar()
		self.textView.delegate = self
		self.textView.inputAccessoryView = toolbar
	}

	private func configureToolbar() {
		toolbar.setAction(for: .bullet, action: {
			self.toggleIndentation()
			self.updateStateOfToolbar()
		})
		toolbar.setAction(for: .bold, action: {
			self.textView.toggleBoldface(self)
			self.updateStateOfToolbar()
		})
		
		toolbar.setAction(for: .italic, action: {
			self.textView.toggleItalics(self)
			self.updateStateOfToolbar()
		})
		
		toolbar.setAction(for: .link, action: { [unowned self] in
			self.textView.addLink(for: self.textView.selectedRange)
			self.updateStateOfToolbar()
		})
		
		toolbar.setAction(for: .camera, action: { [unowned self] in
			if let currentCursorPosition = self.currentCursorPosition {
				self.textView.insertImage(at: currentCursorPosition)
				self.updateStateOfToolbar()
			}
		})
	}
	
	private func toggleIndentation() {
		indentationOn = !indentationOn
		guard let cursorPosition = currentCursorPosition else {
			return
		}
		if shouldAddIndentation {
			textView.addIndentation(at: cursorPosition)
		} else {
			textView.removeIndentation(at: cursorPosition)
		}
		toolbar.bulletButton.tintColor = indentationOn ? UIColor.blue : UIColor.gray
	}
	
	fileprivate func updateStateOfToolbar() {
		guard let cursorPosition = currentCursorPosition else {
			return
		}
		if let font = textView.attributedText.font(at: cursorPosition) {
			toolbar.boldButton.tintColor =  font.isBold ? UIColor.blue : UIColor.gray
			toolbar.italicButton.tintColor = font.isItalic ? UIColor.blue : UIColor.gray
		}
		toolbar.bulletButton.tintColor = indentationOn ? UIColor.blue : UIColor.gray
		toolbar.linkButton.tintColor = textView.attributedText.linkPresent(at: cursorPosition) ? UIColor.blue : UIColor.gray
		if let index = self.currentCharacterIndex {
			toolbar.cameraButton.tintColor = textView.attributedText.imagePresent(at: index) ? UIColor.blue : UIColor.gray
		}
	}

	private func configureGesture() {
		let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
		tap.delegate = self
		textView.addGestureRecognizer(tap)
	}
	
	func handleTap(_ sender: UITapGestureRecognizer) {
		let layoutManager = textView.layoutManager
		var location = sender.location(in: textView)
		location.x -= textView.textContainerInset.left
		location.y -= textView.textContainerInset.top
		
		let characterIndex = layoutManager.characterIndex(for: location, in: textView.textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
		if characterIndex < textView.textStorage.length {
			updateStateOfToolbar()
			removeHighlightIfNeeded()
			currentCharacterIndex = characterIndex
			highlightIfNeeded()
		}
	}
	
	private func removeHighlightIfNeeded() {
		guard let currentCharacterIndex = currentCharacterIndex else {
			return
		}
		if textView.textStorage.imagePresent(at: currentCharacterIndex) {
			imageBorderView.removeFromSuperview()
		}
	}
	
	private func highlightIfNeeded() {
		guard let currentCharacterIndex = currentCharacterIndex else {
			return
		}
		if textView.textStorage.imagePresent(at: currentCharacterIndex) {
			textView.selectImage(at: currentCharacterIndex)
		}
	}
}

extension SHRichTextEditor: UIGestureRecognizerDelegate {
	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
		return true
	}
}

extension SHRichTextEditor: IndentationEnabled {
	
}

extension SHRichTextEditor: LinkInputEnabled {
	var linkAttributes: [String: Any] {
		return [NSFontAttributeName: UIColor.green]
	}
	
	var linkInfoFetcher: (@escaping LinkFetchCompletionBlock) -> () {
		return showLinkInputView
	}
	
	fileprivate func showLinkInputView(completion: @escaping LinkFetchCompletionBlock) {
		let alertController = UIAlertController(title: "Add a link", message: "", preferredStyle: .alert)
		alertController.addTextField(configurationHandler: { textField in
			textField.placeholder = "http://"
		})
		let linkAction = UIAlertAction(title: "Link", style: .default, handler: { action in
			if let linkTextField: UITextField = alertController.textFields!.first, let text = linkTextField.text, !text.isEmpty {
				completion(URL(string: text))
			}
		})
		
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
			alertController.dismiss(animated: true, completion: nil)
		})
		alertController.addAction(cancelAction)
		alertController.addAction(linkAction)
		UIViewController.topMostController?.present(alertController, animated: true, completion: nil)
	}
}

extension SHRichTextEditor: ImageInputEnabled {
	var imageFetcher: (@escaping ImageFetchCompletionBlock) -> () {
		return showImageInputView
	}
	
	func showImageInputView(completionBlock: @escaping ImageFetchCompletionBlock) {
		self.imagePickerManager = ImagePickerManager(with: UIViewController.topMostController!)
		let cameraInputView = CameraInputView.cameraInputView()
		cameraInputView.actionOnCameraTap = { [unowned self] in
			self.imagePickerManager?.showImagePicker(.camera, completion: { image in
				if let image = image {
					completionBlock(image)
				}
			})
		}
		cameraInputView.actionOnLibraryTap = { [unowned self] in
			self.imagePickerManager?.showImagePicker(.photoLibrary, completion: { image in
				if let image = image {
					completionBlock(image)
				}
			})
		}
		textView.inputView = cameraInputView
		textView.reloadInputViews()
	}

	var imageSelectionView: UIView {
		return imageBorderView
	}
}

extension SHRichTextEditor: UITextViewDelegate {
	func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
		guard text == "\n" else {
			return true
		}
		if indentationOn {
			textView.addIndentation(at: range.location)
		}
		return false
	}
}
