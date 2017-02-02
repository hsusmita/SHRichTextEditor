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
	var textEditor: SHRichTextEditor?

	override func viewDidLoad() {
		super.viewDidLoad()
		textEditor = SHRichTextEditor(textView: textView)
	}
}
