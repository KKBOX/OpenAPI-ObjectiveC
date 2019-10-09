//
// KKFeaturedPlaylistsTableViewController.swift
//
// Copyright (c) 2016-2019 KKBOX Taiwan Co., Ltd. All Rights Reserved.
//

enum KKFeaturedPlaylistsTableViewControllerState {
	case unknown
	case error(Error)
	case loading
	case loaded(playlists: [KKPlaylistInfo], paging: KKPagingInfo, summary: KKSummary)
}

class KKFeaturedPlaylistsTableViewController: UITableViewController {
	var state: KKFeaturedPlaylistsTableViewControllerState = .unknown {
		didSet {
			self.tableView.reloadData()
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		self.title = "Featured Playlists"
		self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
		self.load()
	}

	func load() {
		var offset = 0
		switch self.state {
		case let .loaded(playlists:playlists, paging:_, summary:_): offset = playlists.count
		default: break
		}

		sharedAPI.fetchFeaturedPlaylists(forTerritory: .taiwan, offset: offset, limit: 20) { playlists, paging, summary, error in
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

	// MARK: - Table view data source

	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch self.state {
		case let .loaded(playlists:playlists, paging:_, summary:_):
			return playlists.count
		default:
			return 0
		}
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

		switch self.state {
		case let .loaded(playlists:playlists, paging:_, summary:summary):
			let playlist = playlists[indexPath.row];
			cell.textLabel?.text = playlist.playlistTitle
			cell.accessoryType = .disclosureIndicator
			if indexPath.row == playlists.count - 1 && indexPath.row < summary.total - 1 {
				self.load()
			}
		default:
			break
		}
		return cell
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		switch self.state {
		case let .loaded(playlists:playlists, paging:_, summary:_):
			let playlist = playlists[indexPath.row];
			let controller = KKPlaylistTableViewController(playlistID: playlist.playlistID, style: .plain)
			self.navigationController?.pushViewController(controller, animated: true)
		default:
			break
		}
	}


}
