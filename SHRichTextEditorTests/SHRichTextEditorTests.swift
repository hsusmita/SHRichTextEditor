//
//  SHRichTextEditorTests.swift
//  SHRichTextEditorTests
//
//  Created by Susmita Horrow on 30/01/17.
//  Copyright © 2017 hsusmita. All rights reserved.
//

import XCTest
@testable import SHRichTextEditor

class SHRichTextEditorTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInitMethod() {
		let textView = UITextView()
		let _ = SHRichTextEditor(textView: textView)
		if let view = textView.inputAccessoryView {
			XCTAssert(view.isKind(of: UIToolbar.classForCoder()))
		} else {
			XCTAssert(false)
		}
    }
	
	func testInsertToolbarItem() {
		let textView = UITextView()
		let editor = SHRichTextEditor(textView: textView)
		
	}
	
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
