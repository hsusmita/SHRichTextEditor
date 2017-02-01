//
//  ToolbarItem.swift
//  SHRichTextEditor
//
//  Created by Susmita Horrow on 30/01/17.
//  Copyright © 2017 hsusmita. All rights reserved.
//

import Foundation
import UIKit

struct ToolbarItem {
	var name: String?
	var defaultImage: UIImage?
	var selectedImage: UIImage?
	var actionOnTap: (() -> ())
}
