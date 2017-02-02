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
	fileprivate var currentCharacterIndex: Int?
	private let toolbar: RichTextToolbar = RichTextToolbar.toolbar()
	fileprivate var imagePickerManager: ImagePickerManager?
	fileprivate var indentationOn: Bool = false
	fileprivate var imageSelectionView = ImageBorderView.imageBorderView()
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
	
	private var isImageInputMode: Bool = false {
		didSet {
			updateInputView()
		}
	}
	
	private var cameraInputView: CameraInputView {
		self.imagePickerManager = ImagePickerManager(with: UIViewController.topMostController!)
		let view = CameraInputView.cameraInputView()
		view.actionOnCameraTap = { [unowned self] in
			self.imagePickerManager?.showImagePicker(.camera, completion: { image in
				if let image = image, let index = self.currentCursorPosition {
					self.textView.insertImage(image: image, at: index)
				}
			})
		}
		view.actionOnLibraryTap = { [unowned self] in
			self.imagePickerManager?.showImagePicker(.photoLibrary, completion: { image in
				if let image = image, let index = self.currentCursorPosition {
					self.textView.insertImage(image: image, at: index)
				}
			})
		}
		return view
	}
	
	init(textView: UITextView) {
		self.textView = textView
		super.init()
		configureTextView()
	}
	
	private func configureTextView() {
		configureGesture()
		configureToolbar()
		self.textView.delegate = self
		self.textView.inputAccessoryView = toolbar
	}
	
	private func configureToolbar() {
		toolbar.setAction(for: .bullet, action: {
			self.toggleIndentation()
			self.updateStateOfToolbar()
			self.isImageInputMode = false
		})
		toolbar.setAction(for: .bold, action: {
			self.textView.toggleBoldface(self)
			self.updateStateOfToolbar()
			self.isImageInputMode = false
		})
		
		toolbar.setAction(for: .italic, action: {
			self.textView.toggleItalics(self)
			self.updateStateOfToolbar()
			self.isImageInputMode = false
		})
		
		toolbar.setAction(for: .link, action: { [unowned self] in
			self.showLinkInputView(completion: { (url) in
				if let url = url {
					self.textView.addLink(link: url, for: self.textView.selectedRange)
				}
			})
			self.updateStateOfToolbar()
			self.isImageInputMode = false
		})
		
		toolbar.setAction(for: .camera, action: { [unowned self] in
			self.updateStateOfToolbar()
			self.isImageInputMode = true
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
			toolbar.cameraButton.tintColor = textView.attributedText.imagePresent(at: index) || isImageInputMode ? UIColor.blue : UIColor.gray
		}
	}
	
	private func updateInputView() {
		self.textView.inputView = isImageInputMode ? cameraInputView : nil
		self.textView.reloadInputViews()
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
			removeHighlightIfNeeded()
			currentCharacterIndex = characterIndex
			highlightIfNeeded()
			updateStateOfToolbar()
			isImageInputMode = textView.attributedText.imagePresent(at: characterIndex)
		}
	}
	
	private func removeHighlightIfNeeded() {
		guard let currentCharacterIndex = currentCharacterIndex else {
			return
		}
		if textView.textStorage.imagePresent(at: currentCharacterIndex) {
			textView.deselectImage(at: currentCharacterIndex, selectionView: imageSelectionView)
		}
	}
	
	private func highlightIfNeeded() {
		guard let currentCharacterIndex = currentCharacterIndex else {
			return
		}
		if textView.textStorage.imagePresent(at: currentCharacterIndex) {
			textView.selectImage(at: currentCharacterIndex, selectionView: imageSelectionView)
		}
	}
}

extension SHRichTextEditor: UIGestureRecognizerDelegate {
	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
		return true
	}
}

extension SHRichTextEditor: LinkInputEnabled {
	var linkAttributes: [String: Any] {
		return [NSFontAttributeName: UIColor.green]
	}
	
	fileprivate func showLinkInputView(completion: @escaping (URL?) -> ()) {
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

extension SHRichTextEditor: UITextViewDelegate {
	func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
		guard text == "\n" && indentationOn else {
			return true
		}
		textView.addIndentation(at: range.location)
		return false
	}
}
