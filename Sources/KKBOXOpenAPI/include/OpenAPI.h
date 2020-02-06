//
// KKBOXOpenAPI.h
//
// Copyright (c) 2016-2019 KKBOX Taiwan Co., Ltd. All Rights Reserved.
//

@import Foundation;

#import "OpenAPIObjects.h"

/**
 * The access token object. You need a valid access token to access
 * KKBOX's APIs. To obtain an access token, please read about KKBOX's
 * log-in flow.
 */
@interface KKAccessToken : NSObject <NSCoding>

/**
 * Create an access token by giving a dictionary object fetched from
 * KKBOX's log-in APIs.
 *
 * @param inDictionary a given dictionary
 * @return an access token
 */
- (nonnull instancetype)initWithDictionary:(nonnull NSDictionary *)inDictionary NS_DESIGNATED_INITIALIZER;

- (nonnull instancetype)initWithCoder:(nonnull NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

/** The access token string. */
@property (strong, nonatomic, nonnull) NSString *accessToken;
/** How long will the access token expire since now. */
@property (assign, nonatomic) NSTimeInterval expiresIn;
/** Type of the access token. */
@property (strong, nonatomic, nullable) NSString *tokenType;
/** Scope of the access token. */
@property (strong, nonatomic, nullable) NSString *scope;
@end

/** The territory that KKBOX provides service in. */
typedef NS_ENUM(NSUInteger, KKTerritoryCode)
{
	/** Taiwan */
	KKTerritoryCodeTaiwan,
	/** HongKong */
	KKTerritoryCodeHongKong,
	/** Singapore */
	KKTerritoryCodeSingapore,
	/** Malaysia */
	KKTerritoryCodeMalaysia,
	/** Japan */
	KKTerritoryCodeJapan,
} NS_SWIFT_NAME(KKBOXOpenAPI.Territory);

/** The search types used by the search API. */
typedef NS_OPTIONS(NSUInteger, KKSearchType)
{
	/** Default value */
	KKSearchTypeNone = 0,
	/** Search for artists */
	KKSearchTypeArtist = 1 << 0,
	/** Search for albums */
	KKSearchTypeAlbum = 1 << 1,
		/** Search for song tracks */
	KKSearchTypeTrack = 1 << 2,
		/** Search for playlists */
	KKSearchTypePlaylist = 1 << 3
} NS_SWIFT_NAME(KKBOXOpenAPI.SearchType);

/** The permissions that your client requests. */
typedef NS_OPTIONS(NSUInteger, KKScope)
{
	/** No permission */
	KKScopeNone = 0,
	/** Permission to get user profile */
	KKScopeUserProfile = 1 << 0,
	/** Permission to get user territory */
	KKScopeUserTerritory = 1 << 1,
	/** Permission to get user account status */
	KKScopeUserAccountStatus = 1 << 2,
	/** Get all permissions */
	KKScopeAll = KKScopeUserProfile | KKScopeUserTerritory | KKScopeUserAccountStatus
} NS_SWIFT_NAME(KKBOXOpenAPI.Scope);

/** The errors that happen in the SDK. */
extern NSString *_Nonnull const KKBOXOpenAPIErrorDomain;

/**
 * Fired when KKBOXOpenAPI completes logging-in into KKBOX and
 * creating a new access token.
 */
extern NSString *_Nonnull const KKBOXOpenAPIDidLoginNotification;
/**
 * Fired when KKBOXOpenAPI restores a saved access token. You can
 * reset the access token by calling the `-logout` method.
 */
extern NSString *_Nonnull const KKBOXOpenAPIDidRestoreAccessTokenNotification;

/**
 * Callback block for log-in API calls.
 */
typedef void (^KKBOXOpenAPILoginCallback)(KKAccessToken *_Nullable, NSError *_Nullable);

/**
 * Callback block for API calls.
 */
typedef void (^KKBOXOpenAPIDataCallback)(id _Nullable, NSError *_Nullable);

#pragma mark -

/**
 * The class helps to access KKBOX's Open API on Apple platforms such
 * as iOS, macOS, watchOS and tvOS.
 *
 * To start accessing KKBOX's API, you need to register your self to
 * obtain a valid client ID(API Key) and shared secret, then you can
 * use your client ID and secret to initialize an instance of the
 * class. To obtain a client ID, please visit
 * https://developer.kkbox.com/.
 */
@interface KKBOXOpenAPI : NSObject

/**
 * Create a new KKBOXOpenAPI instance. (Default scope is all)
 *
 * @param clientID the API key
 * @param secret the API secret
 * @return A KKBOXOpenAPI instance
 */
- (nonnull instancetype)initWithClientID:(nonnull NSString *)clientID secret:(nonnull NSString *)secret NS_SWIFT_NAME(init(clientID:secret:));

/**
* Create a new KKBOXOpenAPI instance.
*
* @param clientID the API key
* @param secret the API secret
* @param scope the OAuth permission scope
* @return A KKBOXOpenAPI instance
*/
- (nonnull instancetype)initWithClientID:(nonnull NSString *)clientID secret:(nonnull NSString *)secret scope:(KKScope)scope NS_SWIFT_NAME(init(clientID:secret:scope:));

/** Clear existing access token. */
- (void)logout;

/** The current access token. */
@property (readwrite, strong, nullable, nonatomic) KKAccessToken *accessToken;
/** If there is a valid access token. */
@property (readonly, assign) BOOL loggedIn;
@end

#pragma mark - Client Credential Log-in Flow

@interface KKBOXOpenAPI (LoginWithClientCredential)
/**
 * To start using KKBOx's Open API, you need to log-in in to KKBOX at
 * first.  You can generate a client credential to fetch an access
 * token to let KKBOX identify you. It allows you to access public
 * data from KKBOX such as public albums, playlists and so on.
 *
 * @param callback the callback block.
 * @return an NSURLSessionDataTask object that allow you to cancel the
 * task.
 */
- (nonnull NSURLSessionDataTask *)fetchAccessTokenByClientCredentialWithCallback:(nonnull KKBOXOpenAPILoginCallback)callback;
@end

@interface KKBOXOpenAPI (API)

#pragma mark - Song Tracks

/**
 * Fetch the detailed information of a song track.
 *
 * See `https://docs-en.kkbox.codes/reference#tracks_track_id`.
 *
 * @param trackID the ID of the song track
 * @param territory the given territory. The displayed information of
 * a song track may differ in different territories.
 * @param callback the callback block
 * @return an NSURLSessionDataTask object that allow you to cancel the
 * task.
 */
- (nonnull NSURLSessionDataTask *)fetchTrackWithTrackID:(nonnull NSString *)trackID territory:(KKTerritoryCode)territory callback:(nonnull void (^)(KKTrackInfo *_Nullable, NSError *_Nullable))callback NS_SWIFT_NAME(fetchTrack(id:territory:callback:));

#pragma mark - Album

/**
 * Fetch the information of a given album.
 *
 * See `https://docs-en.kkbox.codes/reference#albums_album_id`.
 *
 * @param albumID the given album ID
 * @param territory the given territory
 * @param callback the callback block
 * @return an NSURLSessionDataTask object that allow you to cancel the
 * task.
 */
- (nonnull NSURLSessionDataTask *)fetchAlbumWithAlbumID:(nonnull NSString *)albumID territory:(KKTerritoryCode)territory callback:(nonnull void (^)(KKAlbumInfo *_Nullable, NSError *_Nullable))callback NS_SWIFT_NAME(fetchAlbum(id:territory:callback:));

/**
 * Fetch the song tracks contained in a given album.
 *
 * See `https://docs-en.kkbox.codes/reference#albums_album_id_tracks`.
 *
 * @param albumID the given album ID
 * @param territory the given territory
 * @param callback the callback block
 * @return an NSURLSessionDataTask object that allow you to cancel the
 * task.
 */
- (nonnull NSURLSessionDataTask *)fetchTracksWithAlbumID:(nonnull NSString *)albumID territory:(KKTerritoryCode)territory callback:(nonnull void (^)(NSArray <KKTrackInfo *> *_Nullable, KKPagingInfo *_Nullable, KKSummary *_Nullable, NSError *_Nullable))callback NS_SWIFT_NAME(fetchAlbumTracks(id:territory:callback:));

/**
* Fetch the song tracks contained in a given album.
*
* See `https://docs-en.kkbox.codes/reference#albums_album_id_tracks`.
*
* @param albumID the given album ID
* @param territory the given territory
* @param callback the callback block
* @param offset the offset
* @param limit the limit of response
* @return an NSURLSessionDataTask object that allow you to cancel the
* task.
*/
- (nonnull NSURLSessionDataTask *)fetchTracksWithAlbumID:(nonnull NSString *)albumID territory:(KKTerritoryCode)territory offset:(NSInteger)offset limit:(NSInteger)limit callback:(nonnull void (^)(NSArray <KKTrackInfo *> *_Nullable, KKPagingInfo *_Nullable, KKSummary *_Nullable, NSError *_Nullable))inCallback NS_SWIFT_NAME(fetchAlbumTracks(id:territory:offset:limit:callback:));

#pragma mark - Artists

/**
 * Fetch the detailed profile of an artist.
 *
 * See `https://docs-en.kkbox.codes/reference#artists_artist_id`.
 *
 * @param artistID the ID of the artist
 * @param territory the given territory. The displayed information of
 * an artist may differ in different territories.
 * @param callback the callback block
 * @return an NSURLSessionDataTask object that allow you to cancel the
 * task.
 */
- (nonnull NSURLSessionDataTask *)fetchArtistInfoWithArtistID:(nonnull NSString *)artistID territory:(KKTerritoryCode)territory callback:(nonnull void (^)(KKArtistInfo *_Nullable, NSError *_Nullable))callback NS_SWIFT_NAME(fetchArtist(id:territory:callback:));

/**
 * Fetch the list of the albums belong to an artist.
 *
 * See `https://docs-en.kkbox.codes/reference#artists_artist_id_albums`
 *
 * @param artistID the ID of the artist
 * @param territory the given territory. The albums list may differ in
 * different territories since KKBOX may not be licensed to distribute
 * music content in all territories.
 * @param callback the callback block
 * @return an NSURLSessionDataTask object that allow you to cancel the
 * task.
 */
- (nonnull NSURLSessionDataTask *)fetchAlbumsBelongToArtistID:(nonnull NSString *)artistID territory:(KKTerritoryCode)territory callback:(nonnull void (^)(NSArray <KKAlbumInfo *> *_Nullable, KKPagingInfo *_Nullable, KKSummary *_Nullable, NSError *_Nullable))callback NS_SWIFT_NAME(fetchArtistAlbums(id:territory:callback:));

/**
 * Fetch the list of the albums belong to an artist.
 *
 * See `https://docs-en.kkbox.codes/reference#artists_artist_id_albums`
 *
 * @param artistID the ID of the artist
 * @param territory the given territory. The albums list may differ in
 * different territories since KKBOX may not be licensed to distribute
 * music content in all territories.
 * @param offset the offset
 * @param limit the limit of response
 * @param callback the callback block
 * @return an NSURLSessionDataTask object that allow you to cancel the
 * task.
 */
- (nonnull NSURLSessionDataTask *)fetchAlbumsBelongToArtistID:(nonnull NSString *)artistID territory:(KKTerritoryCode)territory offset:(NSInteger)offset limit:(NSInteger)limit callback:(nonnull void (^)(NSArray <KKAlbumInfo *> *_Nullable, KKPagingInfo *_Nullable, KKSummary *_Nullable, NSError *_Nullable))callback NS_SWIFT_NAME(fetchArtistAlbums(id:territory:offset:limit:callback:));

/**
 * Fetch the top tracks of an artist.
 *
 * See `https://docs-en.kkbox.codes/reference#artists_artist_id_top-tracks`.
 *
 * @param artistID the ID of the artist
 * @param territory the given territory. The displayed information of
 * an artist may differ in different territories.
 * @param callback the callback block
 * @return an NSURLSessionDataTask object that allow you to cancel the
 * task.
 */
- (nonnull NSURLSessionDataTask *)fetchTopTracksWithArtistID:(nonnull NSString *)artistID territory:(KKTerritoryCode)territory callback:(nonnull void (^)(NSArray <KKTrackInfo *> *_Nullable, KKPagingInfo *_Nullable, KKSummary *_Nullable, NSError *_Nullable))callback NS_SWIFT_NAME(fetchArtistTopTracks(id:territory:callback:));

/**
 * Fetch the top tracks of an artist.
 *
 * See `https://docs-en.kkbox.codes/reference#artists_artist_id_top-tracks`.
 *
 * @param artistID the ID of the artist
 * @param territory the given territory. The displayed information of
 * an artist may differ in different territories.
 * @param offset the offset
 * @param limit the limit of response
 * @param callback the callback block
 * @return an NSURLSessionDataTask object that allow you to cancel the
 * task.
 */
- (nonnull NSURLSessionDataTask *)fetchTopTracksWithArtistID:(nonnull NSString *)artistID territory:(KKTerritoryCode)territory offset:(NSInteger)offset limit:(NSInteger)limit callback:(nonnull void (^)(NSArray <KKTrackInfo *> *_Nullable, KKPagingInfo *_Nullable, KKSummary *_Nullable, NSError *_Nullable))callback NS_SWIFT_NAME(fetchArtistTopTracks(id:territory:offset:limit:callback:));

/**
 * Fetch related artists of an artist.
 *
 * See `https://docs-en.kkbox.codes/reference#artists_artist_id_related-artists`.
 *
 * @param artistID the ID of the artist
 * @param territory the given territory. The displayed information of
 * an artist may differ in different territories.
 * @param callback the callback block
 * @return an NSURLSessionDataTask object that allow you to cancel the
 * task.
 */
- (nonnull NSURLSessionDataTask *)fetchRelatedArtistsWithArtistID:(nonnull NSString *)artistID territory:(KKTerritoryCode)territory callback:(nonnull void (^)(NSArray <KKArtistInfo *> *_Nullable, KKPagingInfo *_Nullable, KKSummary *_Nullable, NSError *_Nullable))callback NS_SWIFT_NAME(fetchRelatedArtists(id:territory:callback:));

/**
 * Fetch related artists of an artist.
 *
 * See `https://docs-en.kkbox.codes/reference#artists_artist_id_related-artists`.
 *
 * @param artistID the ID of the artist
 * @param territory the given territory. The displayed information of
 * an artist may differ in different territories.
 * @param offset the offset
 * @param limit the limit of response
 * @param callback the callback block
 * @return an NSURLSessionDataTask object that allow you to cancel the
 * task.
 */
- (nonnull NSURLSessionDataTask *)fetchRelatedArtistsWithArtistID:(nonnull NSString *)artistID territory:(KKTerritoryCode)territory offset:(NSInteger)offset limit:(NSInteger)limit callback:(nonnull void (^)(NSArray <KKArtistInfo *> *_Nullable, KKPagingInfo *_Nullable, KKSummary *_Nullable, NSError *_Nullable))callback NS_SWIFT_NAME(fetchRelatedArtists(id:territory:offset:limit:callback:));

#pragma mark - Shared Playlists

/**
 * Fetches information and song tracks of a given playlist.
 *
 * See `https://docs-en.kkbox.codes/reference#shared-playlists_playlist_id`.
 *
 * @param playlistID the given playlist ID.
 * @param territory the given territory
 * @param callback the callback block
 * @return an NSURLSessionDataTask object that allow you to cancel the
 * task.
 */
- (nonnull NSURLSessionDataTask *)fetchPlaylistWithPlaylistID:(nonnull NSString *)playlistID territory:(KKTerritoryCode)territory callback:(nonnull void (^)(KKPlaylistInfo *_Nullable, KKPagingInfo *_Nullable, KKSummary *_Nullable, NSError *_Nullable))callback NS_SWIFT_NAME(fetchPlaylist(id:territory:callback:));

/**
 * Fetches information and song tracks of a given playlist.
 *
 * See `https://docs-en.kkbox.codes/reference#shared-playlists_playlist_id_tracks`.
 *
 * @param playlistID the given playlist ID.
 * @param territory the given territory
 * @param callback the callback block
 * @return an NSURLSessionDataTask object that allow you to cancel the
 * task.
 */
- (nonnull NSURLSessionDataTask *)fetchTracksInPlaylistWithPlaylistID:(nonnull NSString *)playlistID territory:(KKTerritoryCode)territory callback:(nonnull void (^)(NSArray <KKTrackInfo *> *_Nullable, KKPagingInfo *_Nullable, KKSummary *_Nullable, NSError *_Nullable))callback NS_SWIFT_NAME(fetchPlaylistTracks(id:territory:callback:));

/**
 * Fetches information and song tracks of a given playlist.
 *
 * See `https://docs-en.kkbox.codes/reference#shared-playlists_playlist_id_tracks`.
 *
 * @param playlistID the given playlist ID.
 * @param territory the given territory
 * @param offset the offset
 * @param limit the limit of response
 * @param callback the callback block
 * @return an NSURLSessionDataTask object that allow you to cancel the
 * task.
 */
- (nonnull NSURLSessionDataTask *)fetchTracksInPlaylistWithPlaylistID:(nonnull NSString *)playlistID territory:(KKTerritoryCode)territory offset:(NSInteger)offset limit:(NSInteger)limit callback:(nonnull void (^)(NSArray <KKTrackInfo *> *_Nullable, KKPagingInfo *_Nullable, KKSummary *_Nullable, NSError *_Nullable))callback NS_SWIFT_NAME(fetchPlaylistTracks(id:territory:offset:limit:callback:));

#pragma mark - Featured Playlists

/**
 * Fetch featured playlists.
 *
 * See `https://docs-en.kkbox.codes/reference#featured-playlists`.
 * See also `fetchPlaylistWithPlaylistID:territory:callback:`.
 *
 * @param territory the given territory
 * @param callback the callback block
 * @return an NSURLSessionDataTask object that allow you to cancel the
 * task.
 */
- (nonnull NSURLSessionDataTask *)fetchFeaturedPlaylistsForTerritory:(KKTerritoryCode)territory callback:(nonnull void (^)(NSArray <KKPlaylistInfo *> *_Nullable, KKPagingInfo *_Nullable, KKSummary *_Nullable, NSError *_Nullable))callback NS_SWIFT_NAME(fetchFeaturedPlaylists(territory:callback:));

/**
 * Fetch featured playlists.
 *
 * See `https://docs-en.kkbox.codes/reference#featured-playlists_playlist_id`.
 * See also `fetchPlaylistWithPlaylistID:territory:callback:`.
 *
 * @param territory the given territory
 * @param offset the offset
 * @param limit the limit of response
 * @param callback the callback block
 * @return an NSURLSessionDataTask object that allow you to cancel the
 * task.
 */
- (nonnull NSURLSessionDataTask *)fetchFeaturedPlaylistsForTerritory:(KKTerritoryCode)territory offset:(NSInteger)offset limit:(NSInteger)limit callback:(nonnull void (^)(NSArray <KKPlaylistInfo *> *_Nullable, KKPagingInfo *_Nullable, KKSummary *_Nullable, NSError *_Nullable))callback NS_SWIFT_NAME(fetchFeaturedPlaylists(territory:offset:limit:callback:));

#pragma mark - New-Hits Playlists

/**
 * Fetch new hits playlists.
 *
 * See `https://docs-en.kkbox.codes/reference#new-hits-playlists`.
 * See also `fetchPlaylistWithPlaylistID:territory:callback:`.
 *
 * @param territory the given territory
 * @param callback the callback block
 * @return an NSURLSessionDataTask object that allow you to cancel the
 * task.
 */
- (nonnull NSURLSessionDataTask *)fetchNewHitsPlaylistsForTerritory:(KKTerritoryCode)territory callback:(nonnull void (^)(NSArray <KKPlaylistInfo *> *_Nullable, KKPagingInfo *_Nullable, KKSummary *_Nullable, NSError *_Nullable))callback NS_SWIFT_NAME(fetchNewHitsPlaylists(territory:callback:));

/**
 * Fetch new hits playlists.
 *
 * See `https://docs-en.kkbox.codes/reference#new-hits-playlists_playlist_id`.
 * See also `fetchPlaylistWithPlaylistID:territory:callback:`.
 *
 * @param territory the given territory
 * @param offset the offset
 * @param limit the limit of response
 * @param callback the callback block
 * @return an NSURLSessionDataTask object that allow you to cancel the
 * task.
 */
- (nonnull NSURLSessionDataTask *)fetchNewHitsPlaylistsForTerritory:(KKTerritoryCode)territory offset:(NSInteger)offset limit:(NSInteger)limit callback:(nonnull void (^)(NSArray <KKPlaylistInfo *> *_Nullable, KKPagingInfo *_Nullable, KKSummary *_Nullable, NSError *_Nullable))callback NS_SWIFT_NAME(fetchNewHitsPlaylists(territory:offset:limit:callback:));


#pragma mark - Featured Playlists Categories

/**
 * Fetch feature playlist categories.
 *
 * See `https://docs-en.kkbox.codes/reference#featured-playlist-categories`.
 *
 * @param territory the given territory
 * @param callback the callback block
 * @return an NSURLSessionDataTask object that allow you to cancel the
 * task.
 */
- (nonnull NSURLSessionDataTask *)fetchFeaturedPlaylistCategoriesForTerritory:(KKTerritoryCode)territory callback:(nonnull void (^)(NSArray <KKFeaturedPlaylistCategory *> *_Nullable, KKPagingInfo *_Nullable, KKSummary *_Nullable, NSError *_Nullable))callback NS_SWIFT_NAME(fetchFeaturedPlaylistCategories(territory:callback:));

/**
 * Fetch feature playlist categories.
 *
 * See `https://docs-en.kkbox.codes/reference#featured-playlist-categories`.
 *
 * @param territory the given territory
 * @param offset the offset
 * @param limit the limit of response
 * @param callback the callback block
 * @return an NSURLSessionDataTask object that allow you to cancel the
 * task.
 */
- (nonnull NSURLSessionDataTask *)fetchFeaturedPlaylistCategoriesForTerritory:(KKTerritoryCode)territory offset:(NSInteger)offset limit:(NSInteger)limit callback:(nonnull void (^)(NSArray <KKFeaturedPlaylistCategory *> *_Nullable, KKPagingInfo *_Nullable, KKSummary *_Nullable, NSError *_Nullable))callback NS_SWIFT_NAME(fetchFeaturedPlaylistCategories(territory:offset:limit:callback:));

/**
 * Fetch the feature playlists contained in a given category. You can
 * obtain the categories from the previous method.
 *
 * See `https://docs-en.kkbox.codes/reference#featured-playlist-categories_category_id`.
 * See also `fetchPlaylistWithPlaylistID:territory:callback:`.
 *
 * @param category the given category
 * @param territory the given territory
 * @param callback the callback block
 * @return an NSURLSessionDataTask object that allow you to cancel the
 * task.
 */
- (nonnull NSURLSessionDataTask *)fetchFeaturedPlaylistsInCategory:(nonnull NSString *)category territory:(KKTerritoryCode)territory callback:(nonnull void (^)(KKFeaturedPlaylistCategory *_Nullable, NSArray <KKPlaylistInfo *> *_Nullable, KKPagingInfo *_Nullable, KKSummary *_Nullable, NSError *_Nullable))callback NS_SWIFT_NAME(fetchFeaturedPlaylistCategoryPlaylists(category:territory:callback:));

/**
 * Fetch the feature playlists contained in a given category. You can
 * obtain the categories from the previous method.
 *
 * See `https://docs-en.kkbox.codes/reference#featured-playlist-categories_category_id`.
 * See also `fetchPlaylistWithPlaylistID:territory:callback:`.
 *
 * @param category the given category
 * @param territory the given territory
 * @param offset the offset
 * @param limit the limit of response
 * @param callback the callback block
 * @return an NSURLSessionDataTask object that allow you to cancel the
 * task.
 */
- (nonnull NSURLSessionDataTask *)fetchFeaturedPlaylistsInCategory:(nonnull NSString *)category territory:(KKTerritoryCode)territory offset:(NSInteger)offset limit:(NSInteger)limit callback:(nonnull void (^)(KKFeaturedPlaylistCategory *_Nullable, NSArray <KKPlaylistInfo *> *_Nullable, KKPagingInfo *_Nullable, KKSummary *_Nullable, NSError *_Nullable))callback NS_SWIFT_NAME(fetchFeaturedPlaylistCategoryPlaylists(category:territory:offset:limit:callback:));

#pragma mark - Radio

#pragma mark Mood Station

/**
 * Fetch mood station categories.
 *
 * See `https://docs-en.kkbox.codes/reference#mood-stations`.
 * @param territory the given territory
 * @param callback the callback block
 * @return an NSURLSessionDataTask object that allow you to cancel the
 * task.
 */
- (nonnull NSURLSessionDataTask *)fetchMoodStationsForTerritory:(KKTerritoryCode)territory callback:(nonnull void (^)(NSArray <KKRadioStation *> *_Nullable, KKPagingInfo *_Nullable, KKSummary *_Nullable, NSError *_Nullable))callback NS_SWIFT_NAME(fetchMoodStations(territory:callback:));

/**
 * Fetch mood stations under a specific radio category.
 *
 * See `https://docs-en.kkbox.codes/reference#mood-stations_station_id`.
 *
 * @param stationID the station ID. You can obtain IDs from the
 * previous method.
 * @param territory the given territory
 * @param callback the callback block
 * @return an NSURLSessionDataTask object that allow you to cancel the
 * task.
 */
- (nonnull NSURLSessionDataTask *)fetchMoodStationWithStationID:(nonnull NSString *)stationID territory:(KKTerritoryCode)territory callback:(nonnull void (^)(KKRadioStation *_Nullable, NSArray <KKTrackInfo *> *_Nullable, KKPagingInfo *_Nullable, KKSummary *_Nullable, NSError *_Nullable))callback NS_SWIFT_NAME(fetchMoodStation(id:territory:callback:));

/**
 * Fetch mood stations under a specific radio category.
 *
 * See `https://docs-en.kkbox.codes/reference#mood-stations_station_id`.
 *
 * @param stationID the station ID. You can obtain IDs from the
 * previous method.
 * @param territory the given territory
 * @param offset the offset
 * @param limit the limit of response
 * @param callback the callback block
 * @return an NSURLSessionDataTask object that allow you to cancel the
 * task.
 */
- (nonnull NSURLSessionDataTask *)fetchMoodStationWithStationID:(nonnull NSString *)stationID territory:(KKTerritoryCode)territory offset:(NSInteger)offset limit:(NSInteger)limit callback:(nonnull void (^)(KKRadioStation *_Nullable, NSArray <KKTrackInfo *> *_Nullable, KKPagingInfo *_Nullable, KKSummary *_Nullable, NSError *_Nullable))callback NS_SWIFT_NAME(fetchMoodStation(id:territory:offset:limit:callback:));

#pragma mark Genre Station

/**
 * Fetch the list of genre radio station categories.
 *
 * See `https://docs-en.kkbox.codes/reference#genre-stations`.
 *
 * @param territory the given territory
 * @param callback the callback block
 * @return an NSURLSessionDataTask object that allow you to cancel the
 * task.
 */
- (nonnull NSURLSessionDataTask *)fetchGenreStationsForTerritory:(KKTerritoryCode)territory callback:(nonnull void (^)(NSArray <KKRadioStation *> *_Nullable, KKPagingInfo *_Nullable, KKSummary *_Nullable, NSError *_Nullable))callback NS_SWIFT_NAME(fetchGenreStations(territory:callback:));

/**
 * Fetch genre-based radio stations under a specific genre category.
 *
 * See `https://docs-en.kkbox.codes/reference#genre-stations_station_id`.
 *
 * @param stationID the station ID. You can obtain the list categories
 * from the previous method.
 * @param territory the given territory
 * @param callback the callback block
 * @return an NSURLSessionDataTask object that allow you to cancel the
 * task.
 */
- (nonnull NSURLSessionDataTask *)fetchGenreStationWithStationID:(nonnull NSString *)stationID territory:(KKTerritoryCode)territory callback:(nonnull void (^)(KKRadioStation *_Nullable, NSArray <KKTrackInfo *> *_Nullable, KKPagingInfo *_Nullable, KKSummary *_Nullable, NSError *_Nullable))callback NS_SWIFT_NAME(fetchGenreStation(id:territory:callback:));

/**
 * Fetch genre-based radio stations under a specific genre category.
 *
 * See `https://docs-en.kkbox.codes/reference#genre-stations_station_id`.
 *
 * @param stationID the station ID. You can obtain the list categories
 * from the previous method.
 * @param territory the given territory
 * @param offset the offset
 * @param limit the limit of response
 * @param callback the callback block
 * @return an NSURLSessionDataTask object that allow you to cancel the
 * task.
 */
- (nonnull NSURLSessionDataTask *)fetchGenreStationWithStationID:(nonnull NSString *)stationID territory:(KKTerritoryCode)territory offset:(NSInteger)offset limit:(NSInteger)limit callback:(nonnull void (^)(KKRadioStation *_Nullable, NSArray <KKTrackInfo *> *_Nullable, KKPagingInfo *_Nullable, KKSummary *_Nullable, NSError *_Nullable))callback NS_SWIFT_NAME(fetchGenreStation(id:territory:offset:limit:callback:));

#pragma mark - Search

/**
 * Search within KKBOX's archive.
 *
 * See `https://docs-en.kkbox.codes/reference#search`.
 *
 * @param keyword the keyword
 * @param searchTypes search for song tracks, albums, artists or playlists.
 * @param territory the given territory
 * @param callback the callback block
 * @return an NSURLSessionDataTask object that allow you to cancel the
 * task.
 */
- (nonnull NSURLSessionDataTask *)searchWithKeyword:(nonnull NSString *)keyword searchTypes:(KKSearchType)searchTypes territory:(KKTerritoryCode)territory callback:(nonnull void (^)(KKSearchResults *_Nullable, NSError *_Nullable))callback NS_SWIFT_NAME(search(keyword:types:territory:callback:));

/**
 * Search within KKBOX's archive.
 *
 * See `https://docs-en.kkbox.codes/reference#search`.
 *
 * @param keyword the keyword
 * @param searchTypes search for song tracks, albums, artists or playlists.
 * @param territory the given territory
 * @param offset the offset
 * @param limit the limit of response
 * @param callback the callback block
 * @return an NSURLSessionDataTask object that allow you to cancel the
 * task.
 */
- (nonnull NSURLSessionDataTask *)searchWithKeyword:(nonnull NSString *)keyword searchTypes:(KKSearchType)searchTypes territory:(KKTerritoryCode)territory offset:(NSInteger)offset limit:(NSInteger)limit callback:(nonnull void (^)(KKSearchResults *_Nullable, NSError *_Nullable))callback NS_SWIFT_NAME(search(keyword:types:territory:offset:limit:callback:));


#pragma mark - New Releases

/**
 * Fetch the categories of new released albums in a specific territory.
 *
 * See `https://docs-en.kkbox.codes/reference#new-release-categories`.
 *
 * @param territory the given territory. KKBOX may provide different
 * new released albums in different territories.
 * @param callback the callback block
 * @return an NSURLSessionDataTask object that allow you to cancel the
 * task.
 */
- (nonnull NSURLSessionDataTask *)fetchNewReleaseAlbumCategoriesForTerritory:(KKTerritoryCode)territory callback:(nonnull void (^)(NSArray <KKNewReleaseAlbumsCategory *> *_Nullable, KKPagingInfo *_Nullable, KKSummary *_Nullable, NSError *_Nullable))callback NS_SWIFT_NAME(fetchNewReleaseAlbumCategories(territory:callback:));

/**
 * Fetch the categories of new released albums in a specific territory.
 *
 * See `https://docs-en.kkbox.codes/reference#new-release-categories`.
 *
 * @param territory the given territory. KKBOX may provide different
 * new released albums in different territories.
 * @param offset the offset
 * @param limit the limit of response
 * @param callback the callback block
 * @return an NSURLSessionDataTask object that allow you to cancel the
 * task.
 */
- (nonnull NSURLSessionDataTask *)fetchNewReleaseAlbumCategoriesForTerritory:(KKTerritoryCode)territory offset:(NSInteger)offset limit:(NSInteger)limit callback:(nonnull void (^)(NSArray <KKNewReleaseAlbumsCategory *> *_Nullable, KKPagingInfo *_Nullable, KKSummary *_Nullable, NSError *_Nullable))callback NS_SWIFT_NAME(fetchNewReleaseAlbumCategories(territory:offset:limit:callback:));

/**
 * Fetch new released albums in a specific category and territory.
 *
 * See `https://docs-en.kkbox.codes/reference#new-release-categories_category_id`.
 *
 * @param categoryID the ID of the category.
 * @param territory the given territory. KKBOX may provide different
 * new released albums in different territories.
 * @param callback the callback block
 * @return an NSURLSessionDataTask object that allow you to cancel the
 * task.
 */
- (nonnull NSURLSessionDataTask *)fetchNewReleaseAlbumsUnderCategory:(nonnull NSString *)categoryID territory:(KKTerritoryCode)territory callback:(nonnull void (^)(KKNewReleaseAlbumsCategory *_Nullable, NSArray <KKAlbumInfo *> *_Nullable, KKPagingInfo *_Nullable, KKSummary *_Nullable, NSError *_Nullable))callback NS_SWIFT_NAME(fetchNewReleaseAlbums(id:territory:callback:));

/**
 * Fetch new released albums in a specific category and territory.
 *
 * See `https://docs-en.kkbox.codes/reference#new-release-categories_category_id`.
 *
 * @param categoryID the ID of the category.
 * @param territory the given territory. KKBOX may provide different
 * new released albums in different territories.
 * @param offset the offset
 * @param limit the limit of response
 * @param callback the callback block
 * @return an NSURLSessionDataTask object that allow you to cancel the
 * task.
 */
- (nonnull NSURLSessionDataTask *)fetchNewReleaseAlbumsUnderCategory:(nonnull NSString *)categoryID territory:(KKTerritoryCode)territory offset:(NSInteger)offset limit:(NSInteger)limit callback:(nonnull void (^)(KKNewReleaseAlbumsCategory *_Nullable, NSArray <KKAlbumInfo *> *_Nullable, KKPagingInfo *_Nullable, KKSummary *_Nullable, NSError *_Nullable))callback NS_SWIFT_NAME(fetchNewReleaseAlbums(id:territory:offset:limit:callback:));

#pragma mark - Charts

/**
 * Fetch the categories of charts in a specific territory.
 *
 * See `https://docs-en.kkbox.codes/reference#charts`.
 * See also `fetchPlaylistWithPlaylistID:territory:callback:`.
 *
 * @param territory the given territory. KKBOX may provide different
 * charts in different territories.
 * @param callback the callback block
 * @return an NSURLSessionDataTask object that allow you to cancel the
 * task.
 */
- (nonnull NSURLSessionDataTask *)fetchChartsForTerritory:(KKTerritoryCode)territory callback:(nonnull void (^)(NSArray <KKPlaylistInfo *> *_Nullable, KKPagingInfo *_Nullable, KKSummary *_Nullable, NSError *_Nullable))callback NS_SWIFT_NAME(fetchCharts(territory:callback:));

/**
 * Fetch the categories of charts in a specific territory.
 *
 * See `https://docs-en.kkbox.codes/reference#charts_chart_id`.
 * See also `fetchPlaylistWithPlaylistID:territory:callback:`.
 *
 * @param territory the given territory. KKBOX may provide different
 * charts in different territories.
 * @param offset the offset
 * @param limit the limit of response
 * @param callback the callback block
 * @return an NSURLSessionDataTask object that allow you to cancel the
 * task.
 */
- (nonnull NSURLSessionDataTask *)fetchChartsForTerritory:(KKTerritoryCode)territory offset:(NSInteger)offset limit:(NSInteger)limit callback:(nonnull void (^)(NSArray <KKPlaylistInfo *> *_Nullable, KKPagingInfo *_Nullable, KKSummary *_Nullable, NSError *_Nullable))callback NS_SWIFT_NAME(fetchCharts(territory:offset:limit:callback:));

#pragma mark - Children Contents

/**
 * Fetch the categories for children content in a specific territory.
 *
 * See `https://docs-en.kkbox.codes/reference#children-categories`.
 *
 * @param territory the given territory. KKBOX may provide different
 * contents in different territories.
 * @param callback the callback block
 * @return an NSURLSessionDataTask object that allow you to cancel the
 * task.
 */
- (nonnull NSURLSessionDataTask *)fetchChildrenCategories:(KKTerritoryCode)territory callback:(nonnull void (^)(NSArray <KKChildrenCategory *> *_Nullable, KKPagingInfo *_Nullable, KKSummary *_Nullable, NSError *_Nullable))callback NS_SWIFT_NAME(fetchChildrenCategories(territory:callback:));

/**
 * Fetch subcategories under a children content category.
 *
 * See `https://docs-en.kkbox.codes/reference#children-categories_category_id`.
 *
 * @param categoryID ID of the category.
 * @param territory the given territory. KKBOX may provide different
 * contents in different territories.
 * @param callback the callback block
 * @return an NSURLSessionDataTask object that allow you to cancel the
 * task.
 */
- (nonnull NSURLSessionDataTask *)fetchChildrenCategory:(nonnull NSString *)categoryID territory:(KKTerritoryCode)territory callback:(nonnull void (^)(KKChildrenCategoryGroup *_Nullable, KKPagingInfo *_Nullable, KKSummary *_Nullable, NSError *_Nullable))callback NS_SWIFT_NAME(fetchChildrenCategory(id:territory:callback:));

/**
 * Fetch the playlists under a children content category.
 *
 * See `https://docs-en.kkbox.codes/reference#children-categories_category_id_playlists`.
 *
 * @param categoryID ID of the category.
 * @param territory the given territory. KKBOX may provide different
 * contents in different territories.
 * @param callback the callback block
 * @return an NSURLSessionDataTask object that allow you to cancel the
 * task.
 */
- (nonnull NSURLSessionDataTask *)fetchChildrenCategoryPlaylists:(nonnull NSString *)categoryID territory:(KKTerritoryCode)territory callback:(nonnull void (^)(NSArray <KKPlaylistInfo *> *_Nullable, KKPagingInfo *_Nullable, KKSummary *_Nullable, NSError *_Nullable))callback NS_SWIFT_NAME(fetchChildrenCategoryPlaylists(id:territory:callback:));

/**
 * Fetch the playlists under a children content category.
 *
 * See `https://docs-en.kkbox.codes/reference#children-categories_category_id_playlists`.
 *
 * @param categoryID ID of the category.
 * @param territory the given territory. KKBOX may provide different
 * contents in different territories.
 * @param offset the offset
 * @param limit the limit of response
 * @param callback the callback block
 * @return an NSURLSessionDataTask object that allow you to cancel the
 * task.
 */
- (nonnull NSURLSessionDataTask *)fetchChildrenCategoryPlaylists:(nonnull NSString *)categoryID territory:(KKTerritoryCode)territory offset:(NSInteger)offset limit:(NSInteger)limit callback:(nonnull void (^)(NSArray <KKPlaylistInfo *> *_Nullable, KKPagingInfo *_Nullable, KKSummary *_Nullable, NSError *_Nullable))callback NS_SWIFT_NAME(fetchChildrenCategoryPlaylists(id:territory:offset:limit:callback:));

@end
