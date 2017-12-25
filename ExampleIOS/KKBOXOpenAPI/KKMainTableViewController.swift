//
// KKMainTableViewController.swift
//
// Copyright (c) 2016-2017 KKBOX Taiwan Co., Ltd. All Rights Reserved.
//

import UIKit

class KKMainTableViewController: UITableViewController {

	override init(style: UITableViewStyle) {
		super.init(style: style)
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		self.title = "KKBOX Open API"
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}

	// MARK: - Table view routines

	override func numberOfSections(in tableView: UITableView) -> Int {
		return 2
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return [1, 4][section]
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "cell")
		if cell == nil {
			cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
		}
		if indexPath.section == 0 {
			let titlesForLoggingIn =
					["Login with Client Credential"]
			cell.textLabel?.text = titlesForLoggingIn[indexPath.row]
		} else if indexPath.section == 1 {
			let titleForAPIs =
					["Featured Playlists",
					 "Featured Playlist Categories",
					 "New Hits",
					 "Charts"]
			cell.textLabel?.text = titleForAPIs[indexPath.row]
		}
		return cell
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		if indexPath.section == 0 {
			let methodsForLoggingIn =
					[self.loginWithClientCredential]
			methodsForLoggingIn[indexPath.row]()
		}
		if indexPath.section == 1 {
			let methodsForLoggingIn =
					[self.showFeaturedPlaylists,
					 self.showFeaturedPlaylistCategories,
					 self.showNewHits,
					 self.showCharts]
			methodsForLoggingIn[indexPath.row]()
		}
	}

	// MARK: - 

	func loginWithClientCredential() {
		UIApplication.shared.beginIgnoringInteractionEvents()
		sharedAPI.fetchAccessTokenByClientCredential {
			accessToken, error in
			UIApplication.shared.endIgnoringInteractionEvents()
			if error != nil {
				let alert = UIAlertController(title: "Failed to login", message: error?.localizedDescription, preferredStyle: .alert)
				alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
				self.present(alert, animated: true, completion: nil)
				return
			}
		}
		let alert = UIAlertController(title: "Logged In!", message: nil, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
		self.present(alert, animated: true, completion: nil)
	}

	func showFeaturedPlaylists() {
		let controller = KKFeaturedPlaylistsTableViewController(style: .plain)
		self.navigationController?.pushViewController(controller, animated: true)
	}

	func showFeaturedPlaylistCategories() {
		let controller = KKFeaturedPlaylistCategoriesTableViewController(style: .plain)
		self.navigationController?.pushViewController(controller, animated: true)
	}

	func showNewHits() {
		let controller = KKNewHitsTableViewController(style: .plain)
		self.navigationController?.pushViewController(controller, animated: true)
	}

	func showCharts() {
		let controller = KKChartsTableViewController(style: .plain)
		self.navigationController?.pushViewController(controller, animated: true)
	}

}

