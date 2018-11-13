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
/**
 Create an instance by a given dictionary.

 @param dictionary The dictionary.
 @return A KKBOXOpenAPIObject instance.
 */
- (nonnull instancetype)initWithDictionary:(nonnull NSDictionary *)dictionary;
@end

/** The object that represents the pagination of a API response in list type. */
@interface KKPagingInfo : KKBOXOpenAPIObject
/** The max amount of items in a page. */
@property (readonly, assign, nonatomic) NSInteger limit;
/** Where the list begins. */
@property (readonly, assign, nonatomic) NSInteger offset;
/** The URL for the API call for the previous page. */
@property (readonly, strong, nonatomic, nullable) NSURL *previous;
/** The URL for the API call for the next page. */
@property (readonly, strong, nonatomic, nullable) NSURL *next;
@end

/** The summary of a list. */
@interface KKSummary : KKBOXOpenAPIObject
/** The total amount of items matching the criteria. */
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
/** The ID of the artist. */
@property (readonly, strong, nonatomic, nonnull) NSString *artistID;
/** The name of the artist. */
@property (readonly, strong, nonatomic, nonnull) NSString *artistName;
/** The URL of webpage about the artist. */
@property (readonly, strong, nonatomic, nullable) NSURL *artistURL;
/** The images of the artist. */
@property (readonly, strong, nonatomic, nonnull) NSArray <KKImageInfo *> *images;
@end

/** The object represents information about an album on KKBOX. */
@interface KKAlbumInfo : KKBOXOpenAPIObject
/** The ID of the album. */
@property (readonly, strong, nonatomic, nonnull) NSString *albumID;
/** The name of the album. */
@property (readonly, strong, nonatomic, nonnull) NSString *albumName;
/** The URL of the webpage about the album. */
@property (readonly, strong, nonatomic, nullable) NSURL *albumURL;
/** The artist of the album. */
@property (readonly, strong, nonatomic, nonnull) KKArtistInfo *artist;
/** The images of the album. */
@property (readonly, strong, nonatomic, nonnull) NSArray <KKImageInfo *> *images;
/** When was the album released. */
@property (readonly, strong, nonatomic, nonnull) NSString *releaseDate;
/** Is the album explicit or not. */
@property (readonly, assign, nonatomic) BOOL explicitness;
/** The territories that the album is availanble at. */
@property (readonly, strong, nonatomic, nonnull) NSSet <NSNumber *> *territoriesThatAvailableAt;
@end

/** The object represents a track on KKBOX. */
@interface KKTrackInfo : KKBOXOpenAPIObject
/** The ID of the track. */
@property (readonly, strong, nonatomic, nonnull) NSString *trackID;
/** The name of the track.*/
@property (readonly, strong, nonatomic, nonnull) NSString *trackName;
/** The URL of the webpage of the track. */
@property (readonly, strong, nonatomic, nullable) NSURL *trackURL;
/** The album that the track belong to. */
@property (readonly, strong, nonatomic, nullable) KKAlbumInfo *album;
/** Length of the track. */
@property (readonly, assign, nonatomic) NSTimeInterval duration;
/** The track order of the track in an album. */
@property (readonly, assign, nonatomic) NSInteger trackOrderInAlbum;
/** Is the track explicit or not. */
@property (readonly, assign, nonatomic) BOOL explicitness;
/** The territories that the track is available at. */
@property (readonly, strong, nonatomic, nonnull) NSSet <NSNumber *> *territoriesThatAvailableAt;
@end

/** The object represents a user on KKBOX. */
@interface KKUserInfo : KKBOXOpenAPIObject
/** The ID of the user. */
@property (readonly, strong, nonatomic, nonnull) NSString *userID;
/** The name of the user. */
@property (readonly, strong, nonatomic, nonnull) NSString *userName;
/** The description of the user. */
@property (readonly, strong, nonatomic, nonnull) NSString *userDescription;
/** The URL of the page of the user on KKBOX. */
@property (readonly, strong, nonatomic, nullable) NSURL *userURL;
/** The profile images of the user. */
@property (readonly, strong, nonatomic, nonnull) NSArray <KKImageInfo *> *images;
@end

/** The object represents a playlist on KKBOX. */
@interface KKPlaylistInfo : KKBOXOpenAPIObject
/** The ID of the playlist. */
@property (readonly, strong, nonatomic, nonnull) NSString *playlistID;
/** The title of the playlist. */
@property (readonly, strong, nonatomic, nonnull) NSString *playlistTitle;
/** The description of the playlist. */
@property (readonly, strong, nonatomic, nonnull) NSString *playlistDescription;
/** The URL of the webpage about the playlist on KKBOX. */
@property (readonly, strong, nonatomic, nonnull) NSURL *playlistURL;
/** The curator of the playlist. */
@property (readonly, strong, nonatomic, nonnull) KKUserInfo *playlistOwner;
/** The images of the playlist. */
@property (readonly, strong, nonatomic, nonnull) NSArray <KKImageInfo *> *images;
/** The tracks contained in the playlist. */
@property (readonly, strong, nonatomic, nonnull) NSArray <KKTrackInfo *> *tracks;
/** When was the playlist updated. */
@property (readonly, strong, nonatomic, nonnull) NSString *lastUpdateDate;
@end

/** The object represents a featured playlist category. */
@interface KKFeaturedPlaylistCategory : KKBOXOpenAPIObject
/** The ID of the category. */
@property (readonly, strong, nonatomic, nonnull) NSString *categoryID;
/** The title of the category. */
@property (readonly, strong, nonatomic, nonnull) NSString *categoryTitle;
/** The images of the category. */
@property (readonly, strong, nonatomic, nonnull) NSArray <KKImageInfo *> *images;
@end

/** The object represents a new release album category. */
@interface KKNewReleaseAlbumsCategory : KKBOXOpenAPIObject
/** The ID of the category. */
@property (readonly, strong, nonatomic, nonnull) NSString *categoryID;
/** The title of the category. */
@property (readonly, strong, nonatomic, nonnull) NSString *categoryTitle;
@end

/** The object represents a mood/genre radio station on KKBOX. */
@interface KKRadioStation : KKBOXOpenAPIObject
/** The ID of the station. */
@property (readonly, strong, nonatomic, nonnull) NSString *stationID;
/** The name of the station. */
@property (readonly, strong, nonatomic, nonnull) NSString *stationName;
/** The category of the station. Note: not every station is catogorized. */
@property (readonly, strong, nonatomic, nullable) NSString *stationCategory;
/** The images of the station. Noe: not every station has images. */
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

/** The overall pagination info. */
@property (readonly, strong, nonatomic, nonnull) KKPagingInfo *paging;
/** The overall summary. */
@property (readonly, strong, nonatomic, nonnull) KKSummary *summary;
@end
