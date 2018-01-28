//
// KKBOXOpenAPIObjects.h
//
// Copyright (c) 2016-2018 KKBOX Taiwan Co., Ltd. All Rights Reserved.
//

@import Foundation;

#if TARGET_OS_MACOS
@import AppKit;
#endif
#if TARGET_OS_IOS || TARGET_OS_SIMULATOR || TARGET_OS_TV
@import UIKit;
#endif
#if TARGET_OS_WATCH
@import WatchKit;
#endif

/** The model objects used in KKBOX's Open API. */
@interface KKBOXOpenAPIObject : NSObject
- (nonnull instancetype)initWithDictionary:(nonnull NSDictionary *)dictionary;
@end

@interface KKPagingInfo : KKBOXOpenAPIObject
@property (readonly, assign, nonatomic) NSInteger limit;
@property (readonly, assign, nonatomic) NSInteger offset;
@property (readonly, strong, nonatomic, nullable) NSString *previous;
@property (readonly, strong, nonatomic, nullable) NSString *next;
@end

@interface KKSummary : KKBOXOpenAPIObject
@property (readonly, assign, nonatomic) NSInteger total;
@end

/** The object represents information about an image. */
@interface KKImageInfo : KKBOXOpenAPIObject
/** Width of the image. */
@property (readonly, assign, nonatomic) CGFloat width;
/** Height of the image. */
@property (readonly, assign, nonatomic) CGFloat height;
/** URL of the image. */
@property (readonly, strong, nonatomic, nullable) NSURL *imageURL;
@end

/** The object represents information about an artist on KKBOX. */
@interface KKArtistInfo : KKBOXOpenAPIObject
/** ID of the artist. */
@property (readonly, strong, nonatomic, nonnull) NSString *artistID;
/** Name of the artist. */
@property (readonly, strong, nonatomic, nonnull) NSString *artistName;
/** URL of webpage about the artist. */
@property (readonly, strong, nonatomic, nullable) NSURL *artistURL;
/** Images of the artist. */
@property (readonly, strong, nonatomic, nonnull) NSArray <KKImageInfo *> *images;
@end

/** The object represents information about an album on KKBOX. */
@interface KKAlbumInfo : KKBOXOpenAPIObject
/** ID of the album. */
@property (readonly, strong, nonatomic, nonnull) NSString *albumID;
/** Name of the album. */
@property (readonly, strong, nonatomic, nonnull) NSString *albumName;
/** URL of the webpage about the album. */
@property (readonly, strong, nonatomic, nullable) NSURL *albumURL;
/** The artist of the album. */
@property (readonly, strong, nonatomic, nonnull) KKArtistInfo *artist;
/** Images of the album. */
@property (readonly, strong, nonatomic, nonnull) NSArray <KKImageInfo *> *images;
/** When was the album released. */
@property (readonly, strong, nonatomic, nonnull) NSString *releaseDate;
/** Is the album explicit or not. */
@property (readonly, assign, nonatomic) BOOL explicitness;
/** The territories that the album is availanble at. */
@property (readonly, strong, nonatomic, nonnull) NSSet <NSNumber *> *territoriesThatAvailanbleAt;
@end

/** The object represents a track on KKBOX. */
@interface KKTrackInfo : KKBOXOpenAPIObject
/** ID of the track. */
@property (readonly, strong, nonatomic, nonnull) NSString *trackID;
/** Name of the track.*/
@property (readonly, strong, nonatomic, nonnull) NSString *trackName;
/** URL of the webpage of the track. */
@property (readonly, strong, nonatomic, nullable) NSURL *trackURL;
/** The album that the track belong to. */
@property (readonly, strong, nonatomic, nullable) KKAlbumInfo *album;
/** Length of the track. */
@property (readonly, assign, nonatomic) NSTimeInterval duration;
/** Track order of the track in an album. */
@property (readonly, assign, nonatomic) NSInteger trackOrderInAlbum;
/** Is the track explicit or not. */
@property (readonly, assign, nonatomic) BOOL explicitness;
/** The territories that the track is availanble at. */
@property (readonly, strong, nonatomic, nonnull) NSSet <NSNumber *> *territoriesThatAvailanbleAt;
@end

/** The obejct represents a user on KKBOX. */
@interface KKUserInfo : KKBOXOpenAPIObject
/** ID of the user. */
@property (readonly, strong, nonatomic, nonnull) NSString *userID;
/** Name of the user. */
@property (readonly, strong, nonatomic, nonnull) NSString *userName;
/** Description of the user. */
@property (readonly, strong, nonatomic, nonnull) NSString *userDescription;
/** URL of the page of the user on KKBOX. */
@property (readonly, strong, nonatomic, nullable) NSURL *userURL;
/** Profile images of the user. */
@property (readonly, strong, nonatomic, nonnull) NSArray <KKImageInfo *> *images;
@end

/** The object represents a playlist on KKBOX. */
@interface KKPlaylistInfo : KKBOXOpenAPIObject
/** ID of the playlist. */
@property (readonly, strong, nonatomic, nonnull) NSString *playlistID;
/** Title of the playlist. */
@property (readonly, strong, nonatomic, nonnull) NSString *playlistTitle;
/** Description of the playlist. */
@property (readonly, strong, nonatomic, nonnull) NSString *playlistDescription;
/** URL of the webpage about the playlist on KKBOX. */
@property (readonly, strong, nonatomic, nonnull) NSURL *playlistURL;
/** The curator of the playlist. */
@property (readonly, strong, nonatomic, nonnull) KKUserInfo *playlistOwner;
/** Images of the playlist. */
@property (readonly, strong, nonatomic, nonnull) NSArray <KKImageInfo *> *images;
/** Tracks contained in the playlist. */
@property (readonly, strong, nonatomic, nonnull) NSArray <KKTrackInfo *> *tracks;
/** When was the playlist updated. */
@property (readonly, strong, nonatomic, nonnull) NSString *lastUpdateDate;
@end

@interface KKFeaturedPlaylistCategory : KKBOXOpenAPIObject
@property (readonly, strong, nonatomic, nonnull) NSString *categoryID;
@property (readonly, strong, nonatomic, nonnull) NSString *categoryTitle;
@property (readonly, strong, nonatomic, nonnull) NSArray <KKImageInfo *> *images;
@end

@interface KKNewReleaseAlbumsCategory : KKBOXOpenAPIObject
@property (readonly, strong, nonatomic, nonnull) NSString *categoryID;
@property (readonly, strong, nonatomic, nonnull) NSString *categoryTitle;
@end

/** The obejct represents a mood/genre radio station on KKBOX. */
@interface KKRadioStation : KKBOXOpenAPIObject
/** ID of the station. */
@property (readonly, strong, nonatomic, nonnull) NSString *stationID;
/** Name if the station. */
@property (readonly, strong, nonatomic, nonnull) NSString *stationName;
/** Category of the station. Note: not every station is catogorized. */
@property (readonly, strong, nonatomic, nullable) NSString *stationCategory;
/** Images of the station. Noe: not every station has images. */
@property (readonly, strong, nonatomic, nonnull) NSArray <KKImageInfo *> *images;
@end

/** The object represents search results. */
@interface KKSearchResults : KKBOXOpenAPIObject
/** Track search results. Available when searching for tracks is specified. */
@property (readonly, strong, nonatomic, nullable) NSArray <KKTrackInfo *> *tracks;
@property (readonly, strong, nonatomic, nullable) KKPagingInfo *tracksPaging;
@property (readonly, strong, nonatomic, nullable) KKSummary *tracksSummary;
/** Album search results. Available when searching for albums is specified. */
@property (readonly, strong, nonatomic, nullable) NSArray <KKAlbumInfo *> *albums;
@property (readonly, strong, nonatomic, nullable) KKPagingInfo *albumsPaging;
@property (readonly, strong, nonatomic, nullable) KKSummary *albumsSummary;
/** Artists search results. Available when searching for artists is specified. */
@property (readonly, strong, nonatomic, nullable) NSArray <KKArtistInfo *> *artists;
@property (readonly, strong, nonatomic, nullable) KKPagingInfo *artistsPaging;
@property (readonly, strong, nonatomic, nullable) KKSummary *artistsSummary;
/** Playlists search results. Available when searching for playlists is specified. */
@property (readonly, strong, nonatomic, nullable) NSArray <KKPlaylistInfo *> *playlists;
@property (readonly, strong, nonatomic, nullable) KKPagingInfo *playlistsPaging;
@property (readonly, strong, nonatomic, nullable) KKSummary *playlistsSummary;
@property (readonly, strong, nonatomic, nonnull) KKPagingInfo *paging;
@property (readonly, strong, nonatomic, nonnull) KKSummary *summary;
@end


