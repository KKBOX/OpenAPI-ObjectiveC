//
// KKBOXOpenAPIObjects.m
//
// Copyright (c) 2017 KKBOX Taiwan Co., Ltd. All Rights Reserved.
//

#import "KKBOXOpenAPIObjects.h"
#import "KKBOXOpenAPI.h"

@interface KKBOXOpenAPIObject ()
- (void)handleDictionary;

@property (strong, nonatomic, nullable) NSDictionary *dictionary;
@end

@interface KKPagingInfo ()
@property (assign, nonatomic) NSInteger limit;
@property (assign, nonatomic) NSInteger offset;
@property (strong, nonatomic, nullable) NSString *previous;
@property (strong, nonatomic, nullable) NSString *next;
@end

@interface KKSummary ()
@property (assign, nonatomic) NSInteger total;
@end

@interface KKImageInfo ()
@property (assign, nonatomic) CGFloat width;
@property (assign, nonatomic) CGFloat height;
@property (strong, nonatomic, nullable) NSURL *imageURL;
@end

@interface KKArtistInfo ()
@property (strong, nonatomic, nonnull) NSString *artistID;
@property (strong, nonatomic, nonnull) NSString *artistName;
@property (strong, nonatomic, nullable) NSURL *artistURL;
@property (strong, nonatomic, nonnull) NSArray <KKImageInfo *> *images;
@end

@interface KKAlbumInfo ()
@property (strong, nonatomic, nonnull) NSString *albumID;
@property (strong, nonatomic, nonnull) NSString *albumName;
@property (strong, nonatomic, nullable) NSURL *albumURL;
@property (strong, nonatomic, nonnull) KKArtistInfo *artist;
@property (strong, nonatomic, nonnull) NSArray <KKImageInfo *> *images;
@property (strong, nonatomic, nonnull) NSString *releaseDate;
@property (assign, nonatomic) BOOL explicitness;
@property (strong, nonatomic, nonnull) NSSet <NSNumber *> *territoriesThatAvailanbleAt;
@end

@interface KKTrackInfo ()
@property (strong, nonatomic, nonnull) NSString *trackID;
@property (strong, nonatomic, nonnull) NSString *trackName;
@property (strong, nonatomic, nullable) NSURL *trackURL;
@property (strong, nonatomic, nullable) KKAlbumInfo *album;
@property (assign, nonatomic) NSTimeInterval duration;
@property (assign, nonatomic) NSInteger trackOrderInAlbum;
@property (assign, nonatomic) BOOL explicitness;
@property (strong, nonatomic, nonnull) NSSet <NSNumber *> *territoriesThatAvailanbleAt;
@end

@interface KKUserInfo ()
@property (strong, nonatomic, nonnull) NSString *userID;
@property (strong, nonatomic, nonnull) NSString *userName;
@property (strong, nonatomic, nonnull) NSString *userDescription;
@property (strong, nonatomic, nonnull) NSURL *userURL;
@property (strong, nonatomic, nonnull) NSArray <KKImageInfo *> *images;
@end

@interface KKPlaylistInfo ()
@property (strong, nonatomic, nonnull) NSString *playlistID;
@property (strong, nonatomic, nonnull) NSString *playlistTitle;
@property (strong, nonatomic, nonnull) NSString *playlistDescription;
@property (strong, nonatomic, nonnull) NSURL *playlistURL;
@property (strong, nonatomic, nonnull) KKUserInfo *playlistOwner;
@property (strong, nonatomic, nonnull) NSArray <KKImageInfo *> *images;
@property (strong, nonatomic, nonnull) NSArray <KKTrackInfo *> *tracks;
@property (strong, nonatomic, nonnull) NSString *lastUpdateDate;
@end

@interface KKFeaturedPlaylistCategory ()
@property (strong, nonatomic, nonnull) NSString *categoryID;
@property (strong, nonatomic, nonnull) NSString *categoryTitle;
@property (strong, nonatomic, nonnull) NSArray <KKImageInfo *> *images;
@end

@interface KKRadioStation ()
@property (strong, nonatomic, nonnull) NSString *stationID;
@property (strong, nonatomic, nonnull) NSString *stationName;
@property (strong, nonatomic, nullable) NSString *stationCategory;
@property (strong, nonatomic, nonnull) NSArray <KKImageInfo *> *images;
@end

@interface KKSearchResults ()
@property (strong, nonatomic, nullable) NSArray <KKTrackInfo *> *tracks;
@property (strong, nonatomic, nullable) KKPagingInfo *tracksPaging;
@property (strong, nonatomic, nullable) KKSummary *tracksSummary;
@property (strong, nonatomic, nullable) NSArray <KKAlbumInfo *> *albums;
@property (strong, nonatomic, nullable) KKPagingInfo *albumsPaging;
@property (strong, nonatomic, nullable) KKSummary *albumsSummary;
@property (strong, nonatomic, nullable) NSArray <KKArtistInfo *> *artists;
@property (strong, nonatomic, nullable) KKPagingInfo *artistsPaging;
@property (strong, nonatomic, nullable) KKSummary *artistsSummary;
@property (strong, nonatomic, nullable) NSArray <KKPlaylistInfo *> *playlists;
@property (strong, nonatomic, nullable) KKPagingInfo *playlistsPaging;
@property (strong, nonatomic, nullable) KKSummary *playlistsSummary;
@property (strong, nonatomic, nonnull) KKPagingInfo *paging;
@property (strong, nonatomic, nonnull) KKSummary *summary;
@end

@interface KKNewReleaseAlbumsCategory ()
@property (strong, nonatomic, nonnull) NSString *categoryID;
@property (strong, nonatomic, nonnull) NSString *categoryTitle;
@end


#pragma mark -

@interface KKBOXOpenAPIObjectParsingHelper : NSObject
+ (NSSet <NSNumber *> *)territoriesFromArray:(NSArray *)array;

+ (NSArray <KKImageInfo *> *)imageArrayFromArray:(NSArray *)dictionayImages;
@end

@implementation KKBOXOpenAPIObjectParsingHelper
+ (NSSet <NSNumber *> *)territoriesFromArray:(NSArray *)array
{
	if (![array isKindOfClass:[NSArray class]]) {
		return [NSSet set];
	}

	NSMutableSet <NSNumber *> *set = [NSMutableSet set];
	for (NSString *s in array) {
		if (![s isKindOfClass:[NSString class]]) {
			continue;
		}
		if ([s isEqualToString:@"TW"]) {
			[set addObject:@(KKTerritoryCodeTaiwan)];
		}
		else if ([s isEqualToString:@"HK"]) {
			[set addObject:@(KKTerritoryCodeHongKong)];
		}
		else if ([s isEqualToString:@"SG"]) {
			[set addObject:@(KKTerritoryCodeSingapore)];
		}
		else if ([s isEqualToString:@"MY"]) {
			[set addObject:@(KKTerritoryCodeMalaysia)];
		}
		else if ([s isEqualToString:@"JP"]) {
			[set addObject:@(KKTerritoryCodeJapan)];
		}
		else if ([s isEqualToString:@"TH"]) {
			[set addObject:@(KKTerritoryCodeThailand)];
		}
	}
	return set;
}

+ (NSArray <KKImageInfo *> *)imageArrayFromArray:(NSArray *)dictionayImages
{
	NSMutableArray *images = [NSMutableArray array];
	if ([dictionayImages isKindOfClass:[NSArray class]]) {
		for (NSDictionary *imageDictionary in dictionayImages) {
			if ([imageDictionary isKindOfClass:[NSDictionary class]]) {
				KKImageInfo *imageInfo = [[KKImageInfo alloc] initWithDictionary:imageDictionary];
				[images addObject:imageInfo];
			}
		}
	}
	return images;
}

@end

@implementation KKBOXOpenAPIObject
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
{
	self = [super init];
	if (self) {
		if ([dictionary isKindOfClass:[NSDictionary class]]) {
			self.dictionary = dictionary;
			[self handleDictionary];
		}
	}
	return self;
}

- (void)handleDictionary
{
}

- (NSString *)description
{
	NSString *description = [NSString stringWithFormat:@"<%@ %p> %@", NSStringFromClass([self class]), self, [self.dictionary description]];
	return description;
}
@end

@implementation KKPagingInfo
- (void)handleDictionary
{
	NSDictionary *dictionary = self.dictionary;
	if ([dictionary[@"limit"] respondsToSelector:@selector(integerValue)]) {
		self.limit = [dictionary[@"limit"] integerValue];
	}
	if ([dictionary[@"offset"] respondsToSelector:@selector(integerValue)]) {
		self.offset = [dictionary[@"offset"] integerValue];
	}
	if ([dictionary[@"previous"] isKindOfClass:[NSString class]]) {
		self.previous = dictionary[@"previous"];
	}
	if ([dictionary[@"next"] isKindOfClass:[NSString class]]) {
		self.previous = dictionary[@"next"];
	}
}
@end

@implementation KKSummary
- (void)handleDictionary
{
	NSDictionary *dictionary = self.dictionary;
	if ([dictionary[@"total"] respondsToSelector:@selector(integerValue)]) {
		self.total = [dictionary[@"total"] integerValue];
	}
}
@end

@implementation KKImageInfo
- (void)handleDictionary
{
	NSDictionary *dictionary = self.dictionary;
	if ([dictionary[@"width"] respondsToSelector:@selector(floatValue)]) {
		self.width = [dictionary[@"width"] floatValue];
	}
	if ([dictionary[@"height"] respondsToSelector:@selector(floatValue)]) {
		self.height = [dictionary[@"height"] floatValue];
	}
	if ([dictionary[@"url"] isKindOfClass:[NSString class]]) {
		self.imageURL = [NSURL URLWithString:dictionary[@"url"]];
	}
}
@end

@implementation KKArtistInfo
- (void)handleDictionary
{
	NSDictionary *dictionary = self.dictionary;
	self.artistID = [dictionary[@"id"] isKindOfClass:[NSString class]] ? dictionary[@"id"] : @"";
	self.artistName = [dictionary[@"name"] isKindOfClass:[NSString class]] ? dictionary[@"name"] : @"";
	if ([dictionary[@"url"] isKindOfClass:[NSString class]]) {
		self.artistURL = [NSURL URLWithString:dictionary[@"url"]];
	}
	self.images = [KKBOXOpenAPIObjectParsingHelper imageArrayFromArray:dictionary[@"images"]];
}
@end

@implementation KKAlbumInfo
- (void)handleDictionary
{
	NSDictionary *dictionary = self.dictionary;
	self.albumID = [dictionary[@"id"] isKindOfClass:[NSString class]] ? dictionary[@"id"] : @"";
	self.albumName = [dictionary[@"name"] isKindOfClass:[NSString class]] ? dictionary[@"name"] : @"";
	if ([dictionary[@"url"] isKindOfClass:[NSString class]]) {
		self.albumURL = [NSURL URLWithString:dictionary[@"url"]];
	}
	self.artist = [[KKArtistInfo alloc] initWithDictionary:([dictionary[@"artist"] isKindOfClass:[NSDictionary class]] ? dictionary[@"artist"] : @{})];
	self.images = [KKBOXOpenAPIObjectParsingHelper imageArrayFromArray:dictionary[@"images"]];
	self.releaseDate = [dictionary[@"release_date"] isKindOfClass:[NSString class]] ? dictionary[@"release_date"] : @"";
	self.explicitness = [dictionary[@"explicitness"] respondsToSelector:@selector(boolValue)] ? [dictionary[@"explicitness"] boolValue] : NO;
	self.territoriesThatAvailanbleAt = [KKBOXOpenAPIObjectParsingHelper territoriesFromArray:dictionary[@"available_territories"]];
}
@end

@implementation KKTrackInfo
- (void)handleDictionary
{
	NSDictionary *dictionary = self.dictionary;
	self.trackID = [dictionary[@"id"] isKindOfClass:[NSString class]] ? dictionary[@"id"] : @"";
	self.trackName = [dictionary[@"name"] isKindOfClass:[NSString class]] ? dictionary[@"name"] : @"";
	if ([dictionary[@"url"] isKindOfClass:[NSString class]]) {
		self.trackURL = [NSURL URLWithString:dictionary[@"url"]];
	}
	if ([dictionary[@"album"] isKindOfClass:[NSDictionary class]]) {
		self.album = [[KKAlbumInfo alloc] initWithDictionary:dictionary[@"album"]];
	}
	self.trackOrderInAlbum = [dictionary[@"track_number"] respondsToSelector:@selector(integerValue)] ? [dictionary[@"track_number"] integerValue] : 0;
	self.duration = [dictionary[@"duration"] respondsToSelector:@selector(doubleValue)] ? [dictionary[@"duration"] doubleValue] / 1000.0 : 0;
	self.explicitness = [dictionary[@"explicitness"] respondsToSelector:@selector(boolValue)] ? [dictionary[@"explicitness"] boolValue] : NO;
	self.territoriesThatAvailanbleAt = [KKBOXOpenAPIObjectParsingHelper territoriesFromArray:dictionary[@"available_territories"]];
}
@end

@implementation KKUserInfo
- (void)handleDictionary
{
	NSDictionary *dictionary = self.dictionary;
	self.userID = [dictionary[@"id"] isKindOfClass:[NSString class]] ? dictionary[@"id"] : @"";
	self.userName = [dictionary[@"name"] isKindOfClass:[NSString class]] ? dictionary[@"name"] : @"";
	if ([dictionary[@"url"] isKindOfClass:[NSString class]]) {
		self.userURL = [NSURL URLWithString:dictionary[@"url"]];
	}
	self.images = [KKBOXOpenAPIObjectParsingHelper imageArrayFromArray:dictionary[@"images"]];
}
@end

@implementation KKPlaylistInfo
- (void)handleDictionary
{
	NSDictionary *dictionary = self.dictionary;
	self.playlistID = dictionary[@"id"] ?: @"";
	self.playlistTitle = dictionary[@"title"] ?: @"";
	self.playlistDescription = dictionary[@"description"] ?: @"";
	if ([dictionary[@"url"] isKindOfClass:[NSString class]]) {
		self.playlistURL = [NSURL URLWithString:dictionary[@"url"]];
	}
	self.playlistOwner = [[KKUserInfo alloc] initWithDictionary:dictionary[@"owner"]];
	self.images = [KKBOXOpenAPIObjectParsingHelper imageArrayFromArray:dictionary[@"images"]];
	NSMutableArray *tracks = [[NSMutableArray alloc] init];
	if ([dictionary[@"tracks"][@"data"] isKindOfClass:[NSArray class]]) {
		for (NSDictionary *trackDictionary in dictionary[@"tracks"][@"data"]) {
			KKTrackInfo *track = [[KKTrackInfo alloc] initWithDictionary:trackDictionary];
			[tracks addObject:track];
		}
	}
	self.lastUpdateDate = [dictionary[@"updated_at"] isKindOfClass:[NSString class]] ? dictionary[@"updated_at"] : @"";
	self.tracks = tracks;
}
@end

@implementation KKFeaturedPlaylistCategory
- (void)handleDictionary
{
	NSDictionary *dictionary = self.dictionary;
	self.categoryID = dictionary[@"id"] ?: @"";
	self.categoryTitle = dictionary[@"title"] ?: @"";
	self.images = [KKBOXOpenAPIObjectParsingHelper imageArrayFromArray:dictionary[@"images"]];
}
@end

@implementation KKRadioStation
- (void)handleDictionary
{
	NSDictionary *dictionary = self.dictionary;
	self.stationCategory = dictionary[@"category"];
	self.stationID = dictionary[@"id"] ?: @"";
	self.stationName = dictionary[@"name"] ?: @"";
	self.images = [KKBOXOpenAPIObjectParsingHelper imageArrayFromArray:dictionary[@"images"]];
}
@end

@implementation KKSearchResults
- (void)handleDictionary
{
	NSDictionary *dictionary = self.dictionary;

	if ([dictionary[@"tracks"] isKindOfClass:[NSDictionary class]] && [dictionary[@"tracks"][@"data"] isKindOfClass:[NSArray class]]) {
		NSMutableArray *tracks = [[NSMutableArray alloc] init];
		for (NSDictionary *trackDictionary in  dictionary[@"tracks"][@"data"]) {
			KKTrackInfo *track = [[KKTrackInfo alloc] initWithDictionary:trackDictionary];
			[tracks addObject:track];
		}
		self.tracks = tracks;
		self.tracksPaging = [[KKPagingInfo alloc] initWithDictionary:(dictionary[@"tracks"][@"paging"] ?: @{})];
		self.tracksSummary = [[KKSummary alloc] initWithDictionary:(dictionary[@"tracks"][@"summary"] ?: @{})];
	}

	if ([dictionary[@"albums"] isKindOfClass:[NSDictionary class]] && [dictionary[@"albums"][@"data"] isKindOfClass:[NSArray class]]) {
		NSMutableArray *albums = [[NSMutableArray alloc] init];
		for (NSDictionary *alkbumDictionary in  dictionary[@"albums"][@"data"]) {
			KKAlbumInfo *track = [[KKAlbumInfo alloc] initWithDictionary:alkbumDictionary];
			[albums addObject:track];
		}
		self.albums = albums;
		self.albumsPaging = [[KKPagingInfo alloc] initWithDictionary:(dictionary[@"albums"][@"paging"] ?: @{})];
		self.albumsSummary = [[KKSummary alloc] initWithDictionary:(dictionary[@"albums"][@"summary"] ?: @{})];
	}

	if ([dictionary[@"artists"] isKindOfClass:[NSDictionary class]] && [dictionary[@"artists"][@"data"] isKindOfClass:[NSArray class]]) {
		NSMutableArray *artists = [[NSMutableArray alloc] init];
		for (NSDictionary *artistDictionary in  dictionary[@"artists"][@"data"]) {
			KKArtistInfo *artist = [[KKArtistInfo alloc] initWithDictionary:artistDictionary];
			[artists addObject:artist];
		}
		self.artists = artists;
		self.artistsPaging = [[KKPagingInfo alloc] initWithDictionary:(dictionary[@"artists"][@"paging"] ?: @{})];
		self.artistsSummary = [[KKSummary alloc] initWithDictionary:(dictionary[@"artists"][@"summary"] ?: @{})];
	}

	if ([dictionary[@"playlists"] isKindOfClass:[NSDictionary class]] && [dictionary[@"playlists"][@"data"] isKindOfClass:[NSArray class]]) {
		NSMutableArray *playlists = [[NSMutableArray alloc] init];
		for (NSDictionary *playlistDictionary in  dictionary[@"playlists"][@"data"]) {
			KKPlaylistInfo *playlist = [[KKPlaylistInfo alloc] initWithDictionary:playlistDictionary];
			[playlists addObject:playlist];
		}
		self.playlists = playlists;
		self.playlistsPaging = [[KKPagingInfo alloc] initWithDictionary:(dictionary[@"playlists"][@"paging"] ?: @{})];
		self.playlistsSummary = [[KKSummary alloc] initWithDictionary:(dictionary[@"playlists"][@"summary"] ?: @{})];
	}

	self.paging = [[KKPagingInfo alloc] initWithDictionary:(dictionary[@"paging"] ?: @{})];
	self.summary = [[KKSummary alloc] initWithDictionary:(dictionary[@"summary"] ?: @{})];
}
@end

@implementation KKNewReleaseAlbumsCategory
- (void)handleDictionary
{
	NSDictionary *dictionary = self.dictionary;
	self.categoryID = dictionary[@"id"] ?: @"";
	self.categoryTitle = dictionary[@"title"] ?: @"";
}
@end
