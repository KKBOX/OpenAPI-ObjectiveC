//
// AppDelegate.swift
//
// Copyright (c) 2016 KKBOX Taiwan Co., Ltd. All Rights Reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		let mainVC = KKMainTableViewController(style: .grouped)
		let navVC = UINavigationController(rootViewController: mainVC)
		self.window = UIWindow()
		self.window?.rootViewController = navVC
		self.window?.makeKeyAndVisible()
		return true
	}

	func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
		return true
	}
}
