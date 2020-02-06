//
// KKFeaturedPlaylistCategoriesTableViewController.swift
//
// Copyright (c) 2016-2019 KKBOX Taiwan Co., Ltd. All Rights Reserved.
//

import UIKit
import KKBOXOpenAPI

enum KKFeaturedPlaylistCategoriesTableViewControllerState {
	case unknown
	case error(Error)
	case loading
	case loaded(categories: [FeaturedPlaylistCategory], paging: PagingInfo, summary: Summary)
}

class KKFeaturedPlaylistCategoriesTableViewController: UITableViewController {

	private (set) var state: KKFeaturedPlaylistCategoriesTableViewControllerState = .unknown {
		didSet {
			self.tableView.reloadData()
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		self.title = "Categories"
		self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
		self.load()
	}

	private func load() {
		var offset = 0
		switch self.state {
		case let .loaded(categories:categories, paging:_, summary:_): offset = categories.count
		default: break
		}

		sharedAPI.fetchFeaturedPlaylistCategories(territory: .taiwan, offset: offset, limit: 20) { categories, paging, summary, error in
			if let error = error {
				switch self.state {
				case .loaded(categories: _, paging: _, summary: _): return
				default: break
				}
				self.state = .error(error)
				return
			}

			switch self.state {
			case let .loaded(categories:currentPlaylists, paging:_, summary:_):
				self.state = .loaded(categories: currentPlaylists + categories!, paging: paging!, summary: summary!)
			default:
				self.state = .loaded(categories: categories!, paging: paging!, summary: summary!)
			}
		}
	}

	// MARK: - Table view data source

	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch self.state {
		case let .loaded(categories:categories, paging:_, summary:_):
			return categories.count
		default:
			return 0
		}
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
		switch self.state {
		case let .loaded(categories:categories, paging:_, summary:_):
			let category = categories[indexPath.row]
			cell.textLabel?.text = category.title
			cell.accessoryType = .disclosureIndicator
		default:
			break
		}
		return cell
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		switch self.state {
		case let .loaded(categories:categories, paging:_, summary:_):
			let category = categories[indexPath.row]
			let controller = KKFeaturedPlaylistCategoryTableViewController(categoryID: category.id, style: .plain)
			self.navigationController?.pushViewController(controller, animated: true)
		default:
			break
		}
	}

}
