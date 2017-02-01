//
//  ViewController.swift
//  SHRichTextEditor
//
//  Created by Susmita Horrow on 30/01/17.
//  Copyright © 2017 hsusmita. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

	@IBOutlet weak var textView: UITextView!
	@IBOutlet var toolbar: UIToolbar!
	var textEditor: SHRichTextEditor?

	override func viewDidLoad() {
		super.viewDidLoad()
		textEditor = SHRichTextEditor(textView: textView)
	}

	@IBAction func handleIndentButtonTapped(_ sender: Any) {
		let selectedRange = textView.selectedRange
		textView.addIndentation(at: selectedRange.location)
	}

	@IBAction func handleImageButtonTapped(_ sender: Any) {
		let selectedRange = textView.selectedRange
		textView.insertImage(at: selectedRange.location)
	}

	@IBAction func handleLinkButtonTapped(_ sender: Any) {
		let selectedRange = textView.selectedRange
		textView.addLink(for: selectedRange)
	}	
}
