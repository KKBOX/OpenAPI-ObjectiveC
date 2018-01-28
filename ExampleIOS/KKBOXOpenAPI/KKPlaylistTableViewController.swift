//
// KKPlaylistTableViewController.swift
//
// Copyright (c) 2016-2018 KKBOX Taiwan Co., Ltd. All Rights Reserved.
//

import UIKit

enum KKPlaylistTableViewControllerState {
	case unknown
	case error(Error)
	case loading
	case loaded(playlist: KKPlaylistInfo, tracks: [KKTrackInfo], paging: KKPagingInfo, summary: KKSummary)
}

class KKPlaylistTableViewController: UITableViewController {
	private (set) var playlistID: String
	private (set) var state: KKPlaylistTableViewControllerState = .unknown {
		didSet {
			switch self.state {
			case let .loaded(playlist:playlist, tracks:_, paging:_, summary:_):
				self.title = playlist.playlistTitle
			default: break
			}
			self.tableView.reloadData()
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		self.state = .loading
		self.load()
	}

	init(playlistID: String, style: UITableViewStyle) {
		self.playlistID = playlistID
		super.init(style: style)
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func load() {
		switch self.state {
		case let .loaded(playlist:playlist, tracks:currentTracks, paging:_, summary:_):
			let offset = currentTracks.count
			sharedAPI.fetchTracksInPlaylist(withPlaylistID: playlistID, territory: .taiwan, offset: offset, limit: 20) { tracks, paging, summary, error in
				if error != nil {
					return
				}
				self.state = .loaded(playlist: playlist, tracks: currentTracks + tracks!, paging: paging!, summary: summary!)
			}
			break
		default:
			sharedAPI.fetchPlaylist(withPlaylistID: self.playlistID, territory: .taiwan) { playlist, paging, summary, error in
				if let error = error {
					self.state = .error(error)
					return
				}
				self.state = .loaded(playlist: playlist!, tracks: playlist!.tracks, paging: paging!, summary: summary!)
			}
		}
	}

	// MARK: - Table view data source

	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch self.state {
		case let .loaded(playlist:_, tracks:tracks, paging:_, summary:_):
			return tracks.count
		default:
			return 0
		}
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		var cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier")
		if cell == nil {
			cell = UITableViewCell(style: .subtitle, reuseIdentifier: "reuseIdentifier")
		}

		switch self.state {
		case let .loaded(playlist:_, tracks:tracks, paging:_, summary:summary):
			let track = tracks[indexPath.row]
			cell?.textLabel?.text = track.trackName
			cell?.detailTextLabel?.text = track.album?.artist.artistName ?? "N/A"

			if indexPath.row == tracks.count - 1 && indexPath.row < summary.total - 1 {
				self.load()
			}

		default:
			break
		}
		return cell!
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		switch self.state {
		case let .loaded(playlist:_, tracks:tracks, paging:_, summary:_):
			let track = tracks[indexPath.row]
			if let url = track.trackURL {
				UIApplication.shared.openURL(url)
			}
		default:
			break
		}
	}

}
