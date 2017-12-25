//
// KKFeaturedPlaylistCategoryTableViewController.swift
//
// Copyright (c) 2016-2017 KKBOX Taiwan Co., Ltd. All Rights Reserved.
//

import UIKit

class KKFeaturedPlaylistCategoryTableViewController: KKFeaturedPlaylistsTableViewController {

	private (set) var categoryID: String

	init(categoryID: String, style: UITableViewStyle) {
		self.categoryID = categoryID
		super.init(style: style)
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func load() {
		var offset = 0
		switch self.state {
		case let .loaded(playlists:playlists, paging:_, summary:_): offset = playlists.count
		default: break
		}

		sharedAPI.fetchFeaturedPlaylists(inCategory: categoryID, territory: .taiwan, offset: offset, limit: 20) { (category, playlists, paging, summary, error) in
			if let error = error {
				switch self.state {
				case .loaded(playlists: _, paging: _, summary: _): return
				default: break
				}
				self.state = .error(error)
				return
			}

			switch self.state {
			case let .loaded(playlists:currentPlaylists, paging:_, summary:_):
				self.state = .loaded(playlists: currentPlaylists + playlists!, paging: paging!, summary: summary!)
			default:
				self.title = category!.categoryTitle
				self.state = .loaded(playlists: playlists!, paging: paging!, summary: summary!)
			}
		}
	}

}
