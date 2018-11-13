//
// Tests.swift
//
// Copyright (c) 2017 KKBOX Taiwan Co., Ltd. All Rights Reserved.
//

import XCTest
import KKBOXOpenAPIiOS
import KKBOXOpenAPIiOS.KKBOXOpenAPIObjects

class Tests: XCTestCase {
	var API: KKBOXOpenAPI!

	override func setUp() {
		super.setUp()
		self.API = KKBOXOpenAPI(clientID: "2074348baadf2d445980625652d9a54f", secret: "ac731b44fb2cf1ea766f43b5a65e82b8")
	}

	override func tearDown() {
		super.tearDown()
	}

	// MARK: -

	func testAccessToken() {
		let d = ["access_token": "1234",
		         "expires_in": 1234567890 as Double,
		         "token_type": "token_type",
		         "scope": "scope"
		] as [String: Any]
		let accessToken = KKAccessToken(dictionary: d)
		XCTAssertEqual(accessToken.accessToken, d["access_token"] as! String)
		XCTAssertEqual(accessToken.expiresIn, d["expires_in"] as! TimeInterval)
		XCTAssertEqual(accessToken.tokenType, d["token_type"] as? String)
		XCTAssertEqual(accessToken.scope, d["scope"] as? String)
	}

	func testScopeParamater() {
		XCTAssertEqual(self.API._scopeParameter([.all]), "all")
		XCTAssertEqual(self.API._scopeParameter([.userProfile]), "user_profile")
		XCTAssertEqual(self.API._scopeParameter([.userTerritory]), "user_territory")
		XCTAssertEqual(self.API._scopeParameter([.userAccountStatus]), "user_account_status")
		XCTAssertEqual(self.API._scopeParameter([.userProfile, .userTerritory]), "user_profile user_territory")
		XCTAssertEqual(Set(self.API._scopeParameter([.userTerritory, .userAccountStatus]).split(separator: " ")), Set("user_territory user_account_status".split(separator: " ")))
		XCTAssertEqual(Set(self.API._scopeParameter([.userProfile, .userAccountStatus]).split(separator: " ")), Set("user_profile user_account_status".split(separator: " ")))
		XCTAssertEqual(self.API._scopeParameter([.userProfile, .userTerritory, .userAccountStatus]), "all")
	}

	// MARK: -

	func validate(track: KKTrackInfo) {
		XCTAssertNotNil(track)
		XCTAssertTrue(track.trackID.count > 0)
		XCTAssertTrue(track.trackName.count > 0)
		XCTAssertTrue(track.duration > 0)
		XCTAssertNotNil(track.trackURL)
		XCTAssertTrue(track.trackOrderInAlbum > 0)
//		XCTAssertTrue(track.territoriesThatAvailableAt.count > 0)
//		XCTAssertTrue(track.territoriesThatAvailableAt.contains(KKTerritoryCode.taiwan.rawValue as NSNumber))
		if let album = track.album {
			self.validate(album: album)
		}
	}

	func validate(album: KKAlbumInfo) {
		XCTAssertNotNil(album)
		XCTAssertTrue(album.albumID.count > 0)
		XCTAssertTrue(album.albumName.count > 0)
		XCTAssertNotNil(album.albumURL)
		XCTAssertTrue(album.images.count == 3)
//		XCTAssertTrue(album.releaseDate.count > 0)
//		XCTAssertTrue(album.territoriesThatAvailableAt.count > 0, "\(album.albumName)")
//		XCTAssertTrue(album.territoriesThatAvailableAt.contains(KKTerritoryCode.taiwan.rawValue as NSNumber))
		self.validate(artist: album.artist)
	}

	func validate(artist: KKArtistInfo) {
		XCTAssertNotNil(artist)
		XCTAssertTrue(artist.artistID.count > 0)
		XCTAssertTrue(artist.artistName.count > 0)
		XCTAssertNotNil(artist.artistURL)
		XCTAssertTrue(artist.images.count == 2)
	}

	func validate(playlist: KKPlaylistInfo) {
		XCTAssertNotNil(playlist);
		XCTAssertTrue(playlist.playlistID.count > 0);
		XCTAssertTrue(playlist.playlistTitle.count > 0);
//		XCTAssertTrue(playlist.playlistDescription.count > 0);
		XCTAssertNotNil(playlist.playlistURL);
		if (playlist.tracks.count > 0) {
			for track in playlist.tracks {
				self.validate(track: track)
			}
		}
	}

	func validate(user: KKUserInfo) {
		XCTAssertTrue(user.userID.count > 0)
		XCTAssertTrue(user.userName.count > 0)
		XCTAssertNotNil(user.userURL)
		XCTAssertNotNil(user.userDescription)
		XCTAssertTrue(user.images.count > 0)
	}

	func waitForToken() {
		let e = self.expectation(description: "wait for token")
		self.API.fetchAccessTokenByClientCredential { token, error in
			e.fulfill()
			if let _ = error {
				XCTFail("Failed to fetch token")
				return
			}
		}
		self.wait(for: [e], timeout: 3)
	}

	func useExplicitToken() {
		self.API.accessToken = KKAccessToken(dictionary:
		["access_token": "qHeIPUO2hS8eJ0FKS9tUsQ==",
		 "expires_in": 3153600000,
		 "refresh_token": "hrJp4YOYxbjDVhQG+nnqpg==",
		 "scope": "all",
		 "token_type": "Bearer"]
		)
	}

	// MARK: -

	func testFetchTrack() {
		self.waitForToken()
		let e = self.expectation(description: "testFetchTrack")
		let trackID = "4kxvr3wPWkaL9_y3o_"
		self.API.fetchTrack(withTrackID: trackID, territory: .taiwan) { track, error in
			e.fulfill()
			if let _ = error {
				XCTFail("Failed to fetch track \(String(describing: error))")
				return
			}
			self.validate(track: track!)
		}
		self.wait(for: [e], timeout: 3)
	}

	func testFetchInvalidTrack() {
		self.waitForToken()
		let e = self.expectation(description: "testFetchTrack")
		let trackID = "121231231"
		self.API.fetchTrack(withTrackID: trackID, territory: .taiwan) { track, error in
			e.fulfill()
			XCTAssertNotNil(error)
		}
		self.wait(for: [e], timeout: 3)
	}

	func testFetchAlbum() {
		self.waitForToken()
		let e = self.expectation(description: "testFetchAlbum")
		self.API.fetchAlbum(withAlbumID: "WpTPGzNLeutVFHcFq6", territory: .taiwan) { album, error in
			e.fulfill()
			if let _ = error {
				XCTFail("Failed to fetch album \(String(describing: error))")
				return
			}
			self.validate(album: album!)
		}
		self.wait(for: [e], timeout: 3)
	}

	func testFetchTracksInAlbum() {
		self.waitForToken()
		let e = self.expectation(description: "testFetchTracksInAlbum")
		self.API.fetchTracks(withAlbumID: "WpTPGzNLeutVFHcFq6", territory: .taiwan) { tracks, paging, summary, error in
			e.fulfill()
			if let _ = error {
				XCTFail("Failed to fetch tracks \(String(describing: error))")
				return
			}
			XCTAssertNotNil(tracks)
			XCTAssertTrue(tracks!.count > 0)
			for track in tracks! {
				self.validate(track: track)
			}
			XCTAssertNotNil(paging); XCTAssertTrue(paging!.limit > 0)
			XCTAssertNotNil(summary); XCTAssertTrue(summary!.total > 0)
		}
		self.wait(for: [e], timeout: 3)
	}

	func testFetchArtist() {
		self.waitForToken()
		let e = self.expectation(description: "testFetchArtist")
		self.API.fetchArtistInfo(withArtistID: "8q3_xzjl89Yakn_7GB", territory: .taiwan) { artist, error in
			e.fulfill()
			if let _ = error {
				XCTFail("Failed to fetch artist \(String(describing: error))")
				return
			}
			self.validate(artist: artist!)
		}
		self.wait(for: [e], timeout: 3)
	}

	func testFetchArtistAlbums() {
		self.waitForToken()
		let e = self.expectation(description: "testFetchArtistAlbums")
		self.API.fetchAlbumsBelong(toArtistID: "8q3_xzjl89Yakn_7GB", territory: .taiwan) { albums, paging, summary, error in
			e.fulfill()
			if let _ = error {
				XCTFail("Failed to fetch albums \(String(describing: error))")
				return
			}
			XCTAssertNotNil(albums)
			for album in albums! {
				self.validate(album: album)
			}
			XCTAssertNotNil(paging); XCTAssertTrue(paging!.limit > 0)
			XCTAssertNotNil(summary); XCTAssertTrue(summary!.total > 0)
		}
		self.wait(for: [e], timeout: 3)
	}

	func testFetchTopTracksWithArtistID() {
		self.waitForToken()
		let e = self.expectation(description: "testFetchTopSongsWithArtistID")
		self.API.fetchTopTracks(withArtistID: "8q3_xzjl89Yakn_7GB", territory: KKTerritoryCode.taiwan) { songs, paging, summary, error in
			e.fulfill()
			if let _ = error {
				XCTFail("Failed to fetch tracks \(String(describing: error))")
				return
			}
			XCTAssertNotNil(songs)
			for track in songs! {
				self.validate(track: track)
			}
			XCTAssertNotNil(paging); XCTAssertTrue(paging!.limit > 0)
			XCTAssertNotNil(summary); XCTAssertTrue(summary!.total > 0)
		}
		self.wait(for: [e], timeout: 3)
	}

	func testFetchRelatedArtistsWithArtistID() {
		self.waitForToken()
		let e = self.expectation(description: "testFetchRelatedArtistsWithArtistID")
		self.API.fetchRelatedArtists(withArtistID: "8q3_xzjl89Yakn_7GB", territory: .taiwan) { artists, paging, summary, error in
			e.fulfill()
			if let _ = error {
				XCTFail("Failed to fetch artist \(String(describing: error))")
				return
			}
			XCTAssertNotNil(artists)
			for artist in artists! {
				self.validate(artist: artist)
			}
			XCTAssertNotNil(paging); XCTAssertTrue(paging!.limit > 0)
			XCTAssertNotNil(summary); XCTAssertTrue(summary!.total > 0)
		}
		self.wait(for: [e], timeout: 3)
	}

	func testFetchPlaylistWithPlaylistID() {
		self.waitForToken()
		let e = self.expectation(description: "testFetchPlaylistWithPlaylistID")
		self.API.fetchPlaylist(withPlaylistID: "OsyceCHOw-NvK5j6Vo", territory: .taiwan) { playlist, paging, summary, error in
			e.fulfill()
			if let _ = error {
				XCTFail("Failed to fetch playlist \(String(describing: error))")
				return
			}
			self.validate(playlist: playlist!)
			XCTAssertTrue(playlist!.tracks.count > 0)
			XCTAssertNotNil(paging); XCTAssertTrue(paging!.limit > 0)
			XCTAssertNotNil(summary); XCTAssertTrue(summary!.total > 0)
		}
		self.wait(for: [e], timeout: 3)
	}

	func testFetchSongsInPlaylistWithPlaylistID() {
		self.waitForToken()
		let e = self.expectation(description: "testFetchSongsInPlaylistWithPlaylistID")
		self.API.fetchTracksInPlaylist(withPlaylistID: "OsyceCHOw-NvK5j6Vo", territory: .taiwan) { tracks, paging, summary, error in
			e.fulfill()
			if let _ = error {
				XCTFail("Failed to fetch playlist \(String(describing: error))")
				return
			}
			XCTAssertTrue(tracks!.count > 0)
			for track in tracks! {
				self.validate(track: track)
			}
			XCTAssertNotNil(paging); XCTAssertTrue(paging!.limit > 0)
			XCTAssertNotNil(summary); XCTAssertTrue(summary!.total > 0)
		}
		self.wait(for: [e], timeout: 3)
	}

	func testFetchFeaturedPlaylists() {
		self.waitForToken()
		let e = self.expectation(description: "testFetchFeaturedPlaylists")
		self.API.fetchFeaturedPlaylists(forTerritory: .taiwan) { playlists, paging, summary, error in
			e.fulfill()
			if let _ = error {
				XCTFail("Failed to fetch playlist \(String(describing: error))")
				return
			}
			XCTAssertTrue(playlists!.count > 0)
			for playlist in playlists! {
				self.validate(playlist: playlist)
			}
			XCTAssertNotNil(paging); XCTAssertTrue(paging!.limit > 0)
			XCTAssertNotNil(summary); XCTAssertTrue(summary!.total > 0)
		}
		self.wait(for: [e], timeout: 3)
	}

	func testFetchNewHitsPlaylists() {
		self.waitForToken()
		let e = self.expectation(description: "testFetchNewHitsPlaylists")
		self.API.fetchNewHitsPlaylists(forTerritory: .taiwan) { playlists, paging, summary, error in
			e.fulfill()
			if let _ = error {
				XCTFail("Failed to fetch playlist \(String(describing: error))")
				return
			}
			XCTAssertTrue(playlists!.count > 0)
			for playlist in playlists! {
				self.validate(playlist: playlist)
			}
			XCTAssertNotNil(paging); XCTAssertTrue(paging!.limit > 0)
			XCTAssertNotNil(summary); XCTAssertTrue(summary!.total > 0)
		}
		self.wait(for: [e], timeout: 3)
	}

	func testFetchFeaturedPlaylistCategories() {
		self.waitForToken()
		let e = self.expectation(description: "fetchFeaturedPlaylistCategories")
		self.API.fetchFeaturedPlaylistCategories(forTerritory: .taiwan) { categories, paging, summary, error in
			e.fulfill()
			if let _ = error {
				XCTFail("Failed to fetch playlist \(String(describing: error))")
				return
			}
			XCTAssertTrue(categories!.count > 0)
			for category in categories! {
				XCTAssertTrue(category.categoryID.count > 0)
				XCTAssertTrue(category.categoryTitle.count > 0)
				XCTAssertTrue(category.images.count == 2)
			}
			XCTAssertNotNil(paging); XCTAssertTrue(paging!.limit > 0)
			XCTAssertNotNil(summary); XCTAssertTrue(summary!.total > 0)
		}
		self.wait(for: [e], timeout: 3)
	}

	func testFetchFeaturedPlaylistInCategory() {
		self.waitForToken()
		let e = self.expectation(description: "testFetchFeaturedPlaylistInCategory")
		self.API.fetchFeaturedPlaylists(inCategory: "CrBHGk1J1KEsQlPLoz", territory: .taiwan) { category, playlists, paging, summary, error in
			e.fulfill()
			if let _ = error {
				XCTFail("Failed to fetch playlist \(String(describing: error))")
				return
			}

			XCTAssertTrue(category!.categoryID.count > 0)
			XCTAssertTrue(category!.categoryTitle.count > 0)
			XCTAssertTrue(category!.images.count == 2)

			for playlist in playlists! {
				XCTAssertTrue(playlist.playlistID.count > 0)
				XCTAssertTrue(playlist.playlistTitle.count > 0)
			}
			XCTAssertNotNil(paging); XCTAssertTrue(paging!.limit > 0)
			XCTAssertNotNil(summary); XCTAssertTrue(summary!.total > 0)
		}
		self.wait(for: [e], timeout: 3)
	}

	func testFetchMoodStations() {
		self.waitForToken()
		let e = self.expectation(description: "testFetchMoodStations")
		self.API.fetchMoodStations(forTerritory: .taiwan) { stations, paging, summary, error in
			e.fulfill()
			if let _ = error {
				XCTFail("Failed to fetch station \(String(describing: error))")
				return
			}
			for station in stations! {
				XCTAssertTrue(station.stationID.count > 0, "station id")
				XCTAssertTrue(station.stationName.count > 0, "station title")
				XCTAssertTrue(station.images.count > 0, "images")
			}
			XCTAssertNotNil(paging); XCTAssertTrue(paging!.limit > 0)
			XCTAssertNotNil(summary); XCTAssertTrue(summary!.total > 0)
		}
		self.wait(for: [e], timeout: 3)
	}

	func testFetchMoodStation() {
		self.waitForToken()
		let e = self.expectation(description: "testFetchMoodStations")
		self.API.fetchMoodStation(withStationID: "4tmrBI125HMtMlO9OF", territory: .taiwan) { station, tracks, paging, summary, error in
			e.fulfill()
			if let _ = error {
				XCTFail("Failed to fetch station \(String(describing: error))")
				return
			}
			XCTAssertTrue(station!.stationID.count > 0, "station id")
			XCTAssertTrue(station!.stationName.count > 0, "station title")
			XCTAssertTrue(station!.images.count > 0, "images")

			for track in tracks! {
				self.validate(track: track)
			}

			XCTAssertNotNil(paging); XCTAssertTrue(paging!.limit > 0)
			XCTAssertNotNil(summary); XCTAssertTrue(summary!.total > 0)
		}
		self.wait(for: [e], timeout: 3)
	}

	func testFetchGenreStations() {
		self.waitForToken()
		let e = self.expectation(description: "testFetchGenreStations")
		self.API.fetchGenreStations(forTerritory: .taiwan) { stations, paging, summary, error in
			e.fulfill()
			if let _ = error {
				XCTFail("Failed to fetch station \(String(describing: error))")
				return
			}
			for station in stations! {
				XCTAssertTrue(station.stationID.count > 0, "station id")
				XCTAssertTrue(station.stationName.count > 0, "station title")
			}
			XCTAssertNotNil(paging); XCTAssertTrue(paging!.limit > 0)
			XCTAssertNotNil(summary); XCTAssertTrue(summary!.total > 0)
		}
		self.wait(for: [e], timeout: 3)
	}


	func testFetchGenreStation() {
		self.waitForToken()
		let e = self.expectation(description: "testFetchGenreStation")
		self.API.fetchGenreStation(withStationID: "9ZAb9rkyd3JFDBC0wF", territory: .taiwan) { station, tracks, paging, summary, error in
			e.fulfill()
			if let _ = error {
				XCTFail("Failed to fetch station \(String(describing: error))")
				return
			}
			XCTAssertTrue(station!.stationID.count > 0, "station id")
			XCTAssertTrue(station!.stationName.count > 0, "station title")

			for track in tracks! {
				self.validate(track: track)
			}

			XCTAssertNotNil(paging); XCTAssertTrue(paging!.limit > 0)
			XCTAssertNotNil(summary); XCTAssertTrue(summary!.total > 0)
		}
		self.wait(for: [e], timeout: 3)
	}

	func testSearch() {
		self.waitForToken()
		let e = self.expectation(description: "testSearch")
		self.API.search(withKeyword: "Love", searchTypes: [.track, .album, .artist, .playlist], territory: .taiwan) { result, error in
			e.fulfill()
			if let _ = error {
				XCTFail("Failed to search \(String(describing: error))")
				return
			}
			XCTAssertTrue(result!.tracks!.count > 0)
			XCTAssertTrue(result!.albums!.count > 0)
			XCTAssertTrue(result!.artists!.count > 0)
			XCTAssertTrue(result!.playlists!.count > 0)
		}

		self.wait(for: [e], timeout: 10)
	}

	func testFetchNewReleaseAlbumCategories() {
		self.waitForToken()
		let e = self.expectation(description: "testFetchNewReleaseAlbumCategories")
		self.API.fetchNewReleaseAlbumCategories(forTerritory: .taiwan) { categories, paging, summary, error in
			e.fulfill()
			if let _ = error {
				XCTFail("Failed to fetch categories. \(String(describing: error))")
				return
			}
			for category in categories! {
				XCTAssertTrue(category.categoryID.count > 0)
				XCTAssertTrue(category.categoryTitle.count > 0)
			}
			XCTAssertNotNil(paging); XCTAssertTrue(paging!.limit > 0)
			XCTAssertNotNil(summary); XCTAssertTrue(summary!.total > 0)
		}
		self.wait(for: [e], timeout: 3)
	}

	func testFetchNewReleaseAlbumsUnderCategory() {
		self.waitForToken()
		let e = self.expectation(description: "testFetchNewReleaseAlbumsUnderCategory")
		self.API.fetchNewReleaseAlbumsUnderCategory("0pGAIGDf5SqYh_SyHr", territory: .taiwan) { category, albums, paging, summary, error in
			e.fulfill()
			if let _ = error {
				XCTFail("Failed to fetch albums. \(String(describing: error))")
				return
			}

			XCTAssertTrue(category!.categoryID.count > 0)
			XCTAssertTrue(category!.categoryTitle.count > 0)

			for album in albums! {
				self.validate(album: album)
			}

			XCTAssertNotNil(paging); XCTAssertTrue(paging!.limit > 0)
			XCTAssertNotNil(summary); XCTAssertTrue(summary!.total > 0)
		}
		self.wait(for: [e], timeout: 3)
	}

	func testFetchCharts() {
		self.waitForToken()
		let e = self.expectation(description: "testFetchCharts")
		self.API.fetchCharts(forTerritory: .taiwan) { charts, paging, summary, error in
			e.fulfill()
			if let _ = error {
				XCTFail("Failed to fetch charts. \(String(describing: error))")
				return
			}

			for playlist in charts! {
				self.validate(playlist: playlist)
			}
			XCTAssertNotNil(paging); XCTAssertTrue(paging!.limit > 0)
			XCTAssertNotNil(summary); XCTAssertTrue(summary!.total > 0)
		}
		self.wait(for: [e], timeout: 3)
	}
	
}

