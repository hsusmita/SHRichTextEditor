//
//  TextViewController.swift
//  SHRichTextEditor
//
//  Created by Susmita Horrow on 01/02/17.
//  Copyright © 2017 hsusmita. All rights reserved.
//

import UIKit

class TextViewController: UIViewController {

	@IBOutlet weak var webView: UIWebView!
	var string: String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
		webView.loadHTMLString(string, baseURL: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
