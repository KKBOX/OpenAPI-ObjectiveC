//
// KKChartsTableViewController.swift
//
// Copyright (c) 2008-2017 KKBOX Taiwan Co., Ltd. All Rights Reserved.
//

import UIKit

class KKChartsTableViewController: KKFeaturedPlaylistsTableViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		self.title = "Charts"
	}

	override func load() {
		var offset = 0
		switch self.state {
		case let .loaded(playlists:playlists, paging:_, summary:_): offset = playlists.count
		default: break
		}

		sharedAPI.fetchCharts(territory: .taiwan, offset: offset, limit: 10) { playlists, paging, summary, error in
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
				self.state = .loaded(playlists: playlists!, paging: paging!, summary: summary!)
			}
		}
	}
}
