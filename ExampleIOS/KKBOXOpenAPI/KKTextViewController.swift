//
// KKTextViewController.swift
//
// Copyright (c) 2016-2020 KKBOX Taiwan Co., Ltd. All Rights Reserved.
//

import UIKit

class KKTextViewController: UIViewController {
	var text = "" {
		didSet {
			_ = self.view
			self.textView!.text = self.text
		}
	}
	var textView: UITextView?

	override func loadView() {
		self.view = UIView(frame: UIScreen.main.bounds)
		self.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		self.textView = UITextView(frame: self.view.bounds)
		self.textView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		self.view.addSubview(self.textView!)
		self.textView!.text = self.text
	}

}
