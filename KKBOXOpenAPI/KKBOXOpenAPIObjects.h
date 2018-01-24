//
// KKBOXOpenAPIObjects.h
//
// Copyright (c) 2008-2017 KKBOX Taiwan Co., Ltd. All Rights Reserved.
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

/** The model objects used in KKBOX's Open API. **/
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

/** The object represents information about an image. **/
@interface KKImageInfo : KKBOXOpenAPIObject
/** The width of the image. **/
@property (readonly, assign, nonatomic) CGFloat width;
/** The height of the image. **/
@property (readonly, assign, nonatomic) CGFloat height;
/** The URL of the image. **/
@property (readonly, strong, nonatomic, nullable) NSURL *imageURL;
@end

/** The object represents information about an artist on KKBOX. **/
@interface KKArtistInfo : KKBOXOpenAPIObject
/** ID of the artist. **/
@property (readonly, strong, nonatomic, nonnull) NSString *artistID;
/** Name of the artist. **/
@property (readonly, strong, nonatomic, nonnull) NSString *artistName;
/** URL of webpage about the artist. **/
@property (readonly, strong, nonatomic, nullable) NSURL *artistURL;
/** Images of the artist. **/
@property (readonly, strong, nonatomic, nonnull) NSArray <KKImageInfo *> *images;
@end

/** The object represents information about an album on KKBOX. **/
@interface KKAlbumInfo : KKBOXOpenAPIObject
/** ID of the album. **/
@property (readonly, strong, nonatomic, nonnull) NSString *albumID;
/** Name of the album. **/
@property (readonly, strong, nonatomic, nonnull) NSString *albumName;
/** URL of the webpage about the album. **/
@property (readonly, strong, nonatomic, nullable) NSURL *albumURL;
/** The artist of the album. **/
@property (readonly, strong, nonatomic, nonnull) KKArtistInfo *artist;
/** Images of the album. **/
@property (readonly, strong, nonatomic, nonnull) NSArray <KKImageInfo *> *images;
/** When was the album released. **/
@property (readonly, strong, nonatomic, nonnull) NSString *releaseDate;
@property (readonly, assign, nonatomic) BOOL explicitness;
@property (readonly, strong, nonatomic, nonnull) NSSet <NSNumber *> *territoriesThatAvailanbleAt;
@end

@interface KKTrackInfo : KKBOXOpenAPIObject
@property (readonly, strong, nonatomic, nonnull) NSString *trackID;
@property (readonly, strong, nonatomic, nonnull) NSString *trackName;
@property (readonly, strong, nonatomic, nullable) NSURL *trackURL;
@property (readonly, strong, nonatomic, nullable) KKAlbumInfo *album;
@property (readonly, assign, nonatomic) NSTimeInterval duration;
@property (readonly, assign, nonatomic) NSInteger trackOrderInAlbum;
@property (readonly, assign, nonatomic) BOOL explicitness;
@property (readonly, strong, nonatomic, nonnull) NSSet <NSNumber *> *territoriesThatAvailanbleAt;
@end

@interface KKUserInfo : KKBOXOpenAPIObject
@property (readonly, strong, nonatomic, nonnull) NSString *userID;
@property (readonly, strong, nonatomic, nonnull) NSString *userName;
@property (readonly, strong, nonatomic, nonnull) NSString *userDescription;
@property (readonly, strong, nonatomic, nullable) NSURL *userURL;
@property (readonly, strong, nonatomic, nonnull) NSArray <KKImageInfo *> *images;
@end

@interface KKPlaylistInfo : KKBOXOpenAPIObject
@property (readonly, strong, nonatomic, nonnull) NSString *playlistID;
@property (readonly, strong, nonatomic, nonnull) NSString *playlistTitle;
@property (readonly, strong, nonatomic, nonnull) NSString *playlistDescription;
@property (readonly, strong, nonatomic, nonnull) NSURL *playlistURL;
@property (readonly, strong, nonatomic, nonnull) KKUserInfo *playlistOwner;
@property (readonly, strong, nonatomic, nonnull) NSArray <KKImageInfo *> *images;
@property (readonly, strong, nonatomic, nonnull) NSArray <KKTrackInfo *> *tracks;
@property (readonly, strong, nonatomic, nonnull) NSString *lastUpdateDate;
@end

@interface KKFeaturedPlaylistCategory : KKBOXOpenAPIObject
@property (readonly, strong, nonatomic, nonnull) NSString *categoryID;
@property (readonly, strong, nonatomic, nonnull) NSString *categoryTitle;
@property (readonly, strong, nonatomic, nonnull) NSArray <KKImageInfo *> *images;
@end

@interface KKRadioStation : KKBOXOpenAPIObject
@property (readonly, strong, nonatomic, nonnull) NSString *stationID;
@property (readonly, strong, nonatomic, nonnull) NSString *stationName;
@property (readonly, strong, nonatomic, nullable) NSString *stationCategory;
@property (readonly, strong, nonatomic, nonnull) NSArray <KKImageInfo *> *images;
@end

@interface KKSearchResults : KKBOXOpenAPIObject
@property (readonly, strong, nonatomic, nullable) NSArray <KKTrackInfo *> *tracks;
@property (readonly, strong, nonatomic, nullable) KKPagingInfo *tracksPaging;
@property (readonly, strong, nonatomic, nullable) KKSummary *tracksSummary;
@property (readonly, strong, nonatomic, nullable) NSArray <KKAlbumInfo *> *albums;
@property (readonly, strong, nonatomic, nullable) KKPagingInfo *albumsPaging;
@property (readonly, strong, nonatomic, nullable) KKSummary *albumsSummary;
@property (readonly, strong, nonatomic, nullable) NSArray <KKArtistInfo *> *artists;
@property (readonly, strong, nonatomic, nullable) KKPagingInfo *artistsPaging;
@property (readonly, strong, nonatomic, nullable) KKSummary *artistsSummary;
@property (readonly, strong, nonatomic, nullable) NSArray <KKPlaylistInfo *> *playlists;
@property (readonly, strong, nonatomic, nullable) KKPagingInfo *playlistsPaging;
@property (readonly, strong, nonatomic, nullable) KKSummary *playlistsSummary;
@property (readonly, strong, nonatomic, nonnull) KKPagingInfo *paging;
@property (readonly, strong, nonatomic, nonnull) KKSummary *summary;
@end

@interface KKNewReleaseAlbumsCategory : KKBOXOpenAPIObject
@property (readonly, strong, nonatomic, nonnull) NSString *categoryID;
@property (readonly, strong, nonatomic, nonnull) NSString *categoryTitle;
@end

