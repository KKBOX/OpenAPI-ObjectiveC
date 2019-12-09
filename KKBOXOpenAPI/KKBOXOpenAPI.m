//
// KKBOXOpenAPI.m
//
// Copyright (c) 2016-2019 KKBOX Taiwan Co., Ltd. All Rights Reserved.
//

#import "KKBOXOpenAPI.h"
#import "KKBOXOpenAPI+Privates.h"

@interface KKAccessToken () <NSCoding>
@end

@implementation KKAccessToken

- (instancetype)init
{
	return [self initWithDictionary:@{}];
}

- (instancetype)initWithDictionary:(NSDictionary *)inDictionary
{
	NSParameterAssert([inDictionary[@"access_token"] isKindOfClass:[NSString class]]);
	self = [super init];
	if (self) {
		self.accessToken = inDictionary[@"access_token"];
		self.expiresIn = [inDictionary[@"expires_in"] doubleValue];
		self.tokenType = inDictionary[@"token_type"];
		self.scope = inDictionary[@"scope"];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject:self.accessToken forKey:@"access_token"];
	[aCoder encodeObject:@(self.expiresIn) forKey:@"expires_in"];
	[aCoder encodeObject:self.tokenType forKey:@"token_type"];
	[aCoder encodeObject:self.scope forKey:@"scope"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];
	if (self) {
		self.accessToken = [aDecoder decodeObjectForKey:@"access_token"];
		self.expiresIn = [[aDecoder decodeObjectForKey:@"expires_in"] doubleValue];
		self.tokenType = [aDecoder decodeObjectForKey:@"token_type"];
		self.scope = [aDecoder decodeObjectForKey:@"scope"];
	}
	return self;
}

@end

#pragma mark -

static NSString *const KKBOXAccessTokenSettingKey = @"KKBOX OPEN API Access Token";
static NSString *const KKOAuthTokenURLString = @"https://account.kkbox.com/oauth2/token";

NSString *const KKBOXOpenAPIErrorDomain = @"KKBOXOpenAPIErrorDomain";
NSString *const KKBOXOpenAPIDidLoginNotification = @"KKBOXOpenAPIDidLoginNotification";
NSString *const KKBOXOpenAPIDidRestoreAccessTokenNotification = @"KKBOXOpenAPIDidRestoreAccessTokenNotification";


@interface KKBOXOpenAPI ()
@property (nonatomic) KKScope requestScope;
@property (strong, nonnull, nonatomic) NSString *clientID;
@property (strong, nonnull, nonatomic) NSString *clientSecret;
@property (strong, nullable, nonatomic) KKAccessToken *accessToken;
@end

@implementation KKBOXOpenAPI

- (nonnull instancetype)initWithClientID:(nonnull NSString *)clientID secret:(nonnull NSString *)secret
{
	return [self initWithClientID:clientID secret:secret scope:KKScopeAll];
}

- (nonnull instancetype)initWithClientID:(nonnull NSString *)clientID secret:(nonnull NSString *)secret scope:(KKScope)scope
{
	self = [super init];
	if (self) {
		NSParameterAssert([clientID length] > 0);
		NSParameterAssert([secret length] > 0);
		self.clientID = clientID;
		self.clientSecret = secret;
		self.requestScope = scope;
		[self _restoreAccessToken];
	}
	return self;
}

- (void)logout
{
	if (!self.accessToken) {
		return;
	}
	self.accessToken = nil;
	NSString *key = [NSString stringWithFormat:@"%@_%@", KKBOXAccessTokenSettingKey, self.clientID];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
}

- (void)_saveAccessToken
{
	if (!self.accessToken) {
		return;
	}
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.accessToken];
	NSString *key = [NSString stringWithFormat:@"%@_%@", KKBOXAccessTokenSettingKey, self.clientID];
	[[NSUserDefaults standardUserDefaults] setObject:data forKey:key];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)_restoreAccessToken
{
	NSString *key = [NSString stringWithFormat:@"%@_%@", KKBOXAccessTokenSettingKey, self.clientID];
	NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:key];
	if (!data) {
		return;
	}
	KKAccessToken *accessToken = [NSKeyedUnarchiver unarchiveObjectWithData:data];
	if (!accessToken) {
		return;
	}
	self.accessToken = accessToken;
	[[NSNotificationCenter defaultCenter] postNotificationName:KKBOXOpenAPIDidRestoreAccessTokenNotification object:self];
}

- (NSString *)_scopeParameter:(KKScope)scope
{
	if (scope == KKScopeAll) {
		return @"all";
	}
	if (scope == KKScopeNone) {
		return @"";
	}
	NSMutableArray *components = [NSMutableArray array];
	NSDictionary *map = @{@(KKScopeUserProfile): @"user_profile", @(KKScopeUserTerritory): @"user_territory", @(KKScopeUserAccountStatus): @"user_account_status"};
	NSArray *scopes = [map allKeys];
	for (NSNumber *scopeNumber in scopes) {
		NSUInteger currentScope = [scopeNumber unsignedIntegerValue];
		if (scope & currentScope) {
			[components addObject:map[scopeNumber]];
		}
	}
	return [components componentsJoinedByString:@" "];
}

- (void (^)(id, NSError *))_loginHandlerWithCallback:(KKBOXOpenAPILoginCallback)callback
{
	return ^(id response, NSError *error) {
		if (error) {
			dispatch_async(dispatch_get_main_queue(), ^{
				callback(nil, error);
			});
			return;
		}
		if (![response isKindOfClass:[NSDictionary class]]) {
			NSError *e = [NSError errorWithDomain:KKBOXOpenAPIErrorDomain code:1 userInfo:@{NSLocalizedDescriptionKey: @"Invalid response"}];
			dispatch_async(dispatch_get_main_queue(), ^{
				callback(nil, e);
			});
			return;
		}
		if (![response[@"access_token"] isKindOfClass:[NSString class]] || ![response[@"access_token"] length]) {
			NSError *e = [NSError errorWithDomain:KKBOXOpenAPIErrorDomain code:2 userInfo:@{NSLocalizedDescriptionKey: @"Invalid response"}];
			dispatch_async(dispatch_get_main_queue(), ^{
				callback(nil, e);
			});
			return;
		}

		KKAccessToken *accessToken = [[KKAccessToken alloc] initWithDictionary:(NSDictionary *)response];
		self.accessToken = accessToken;
		[self _saveAccessToken];
		[[NSNotificationCenter defaultCenter] postNotificationName:KKBOXOpenAPIDidLoginNotification object:self];
		dispatch_async(dispatch_get_main_queue(), ^{
			callback(accessToken, nil);
		});
	};
}

- (BOOL)loggedIn
{
	return self.accessToken != nil;
}

@end

@implementation KKBOXOpenAPI (LoginWithClientCredential)

- (NSURLSessionDataTask *)fetchAccessTokenByClientCredentialWithCallback:(KKBOXOpenAPILoginCallback)callback
{
	NSString *clientCredentialBase = [NSString stringWithFormat:@"%@:%@", self.clientID, self.clientSecret];
	NSString *clientCredential = [[clientCredentialBase dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
	NSDictionary *headers = @{@"Authorization": [NSString stringWithFormat:@"Basic %@", clientCredential]};
	NSDictionary < NSString *, NSString * > *parameters = @{@"grant_type": @"client_credentials", @"scope": [self _scopeParameter:self.requestScope]};
	return [self _postToURL:[NSURL URLWithString:KKOAuthTokenURLString] POSTParameters:parameters headers:headers callback:[self _loginHandlerWithCallback:callback]];
}

@end

@implementation KKBOXOpenAPI (API)

#define CALL_API [self _apiTaskWithURL:[NSURL URLWithString:URLString] callback:callback]
#define ESCAPE(X) [X stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLPathAllowedCharacterSet]]
#define ESCAPE_ARG(X) [X stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]

#pragma mark - Metadata
#pragma mark - Song Tracks

- (nonnull NSURLSessionDataTask *)fetchTrackWithTrackID:(nonnull NSString *)trackID territory:(KKTerritoryCode)territory callback:(nonnull void (^)(KKTrackInfo *_Nullable, NSError *_Nullable))inCallback
{
	NSString *URLString = [NSString stringWithFormat:@"https://api.kkbox.com/v1.1/tracks/%@?territory=%@", ESCAPE(trackID), KKStringFromTerritoryCode(territory)];
	KKBOXOpenAPIDataCallback callback = ^(NSDictionary *dictionary, NSError *error) {
		if (error) {
			inCallback(nil, error);
			return;
		}
		KKTrackInfo *info = [[KKTrackInfo alloc] initWithDictionary:dictionary];
		inCallback(info, nil);
	};
	return CALL_API;
}

#pragma mark - Albums

- (nonnull NSURLSessionDataTask *)fetchAlbumWithAlbumID:(nonnull NSString *)albumID territory:(KKTerritoryCode)territory callback:(nonnull nonnull void (^)(KKAlbumInfo *_Nullable, NSError *_Nullable))inCallback
{
	NSString *URLString = [NSString stringWithFormat:@"https://api.kkbox.com/v1.1/albums/%@?territory=%@", ESCAPE(albumID), KKStringFromTerritoryCode(territory)];
	KKBOXOpenAPIDataCallback callback = ^(NSDictionary *dictionary, NSError *error) {
		if (error) {
			inCallback(nil, error);
			return;
		}
		KKAlbumInfo *info = [[KKAlbumInfo alloc] initWithDictionary:dictionary];
		inCallback(info, nil);
	};
	return CALL_API;
}

- (nonnull NSURLSessionDataTask *)fetchTracksWithAlbumID:(nonnull NSString *)albumID territory:(KKTerritoryCode)territory callback:(nonnull void (^)(NSArray <KKTrackInfo *> *_Nullable, KKPagingInfo *_Nullable, KKSummary *_Nullable, NSError *_Nullable))inCallback
{
	return [self fetchTracksWithAlbumID:albumID territory:territory offset:0 limit:500 callback:inCallback];
}

- (nonnull NSURLSessionDataTask *)fetchTracksWithAlbumID:(nonnull NSString *)albumID territory:(KKTerritoryCode)territory offset:(NSInteger)offset limit:(NSInteger)limit callback:(nonnull void (^)(NSArray <KKTrackInfo *> *_Nullable, KKPagingInfo *_Nullable, KKSummary *_Nullable, NSError *_Nullable))inCallback
{
	NSString *URLString = [NSString stringWithFormat:@"https://api.kkbox.com/v1.1/albums/%@/tracks?territory=%@", ESCAPE(albumID), KKStringFromTerritoryCode(territory)];
	KKBOXOpenAPIDataCallback callback = ^(NSDictionary *dictionary, NSError *error) {
		if (error) {
			inCallback(nil, nil, nil, error);
			return;
		}
		NSMutableArray *tracks = [[NSMutableArray alloc] init];
		for (NSDictionary *d in dictionary[@"data"]) {
			KKTrackInfo *track = [[KKTrackInfo alloc] initWithDictionary:d];
			[tracks addObject:track];
		}
		KKPagingInfo *paging = [[KKPagingInfo alloc] initWithDictionary:dictionary[@"paging"]];
		KKSummary *summary = [[KKSummary alloc] initWithDictionary:dictionary[@"summary"]];
		inCallback(tracks, paging, summary, nil);
	};
	return CALL_API;
}

#pragma mark - Artists

- (nonnull NSURLSessionDataTask *)fetchArtistInfoWithArtistID:(nonnull NSString *)artistID territory:(KKTerritoryCode)territory callback:(nonnull void (^)(KKArtistInfo *_Nullable, NSError *_Nullable))inCallback
{
	NSString *URLString = [NSString stringWithFormat:@"https://api.kkbox.com/v1.1/artists/%@?territory=%@", ESCAPE(artistID), KKStringFromTerritoryCode(territory)];
	KKBOXOpenAPIDataCallback callback = ^(NSDictionary *dictionary, NSError *error) {
		if (error) {
			inCallback(nil, error);
			return;
		}
		KKArtistInfo *artist = [[KKArtistInfo alloc] initWithDictionary:dictionary];
		inCallback(artist, nil);
	};
	return CALL_API;
}

- (nonnull NSURLSessionDataTask *)fetchAlbumsBelongToArtistID:(nonnull NSString *)artistID territory:(KKTerritoryCode)territory callback:(nonnull void (^)(NSArray <KKAlbumInfo *> *_Nullable, KKPagingInfo *_Nullable, KKSummary *_Nullable, NSError *_Nullable))inCallback
{
	return [self fetchAlbumsBelongToArtistID:artistID territory:territory offset:0 limit:200 callback:inCallback];
}

- (nonnull NSURLSessionDataTask *)fetchAlbumsBelongToArtistID:(nonnull NSString *)artistID territory:(KKTerritoryCode)territory offset:(NSInteger)offset limit:(NSInteger)limit callback:(nonnull void (^)(NSArray <KKAlbumInfo *> *_Nullable, KKPagingInfo *_Nullable, KKSummary *_Nullable, NSError *_Nullable))inCallback
{
	NSString *URLString = [NSString stringWithFormat:@"https://api.kkbox.com/v1.1/artists/%@/albums?territory=%@&offset=%ld&limit=%ld", ESCAPE(artistID), KKStringFromTerritoryCode(territory), (long)offset, (long)limit];
	KKBOXOpenAPIDataCallback callback = ^(NSDictionary *dictionary, NSError *error) {
		if (error) {
			inCallback(nil, nil, nil, error);
			return;
		}
		NSMutableArray *albums = [[NSMutableArray alloc] init];
		for (NSDictionary *albumDictionary in dictionary[@"data"]) {
			KKAlbumInfo *album = [[KKAlbumInfo alloc] initWithDictionary:albumDictionary];
			[albums addObject:album];
		}
		KKPagingInfo *paging = [[KKPagingInfo alloc] initWithDictionary:dictionary[@"paging"]];
		KKSummary *summary = [[KKSummary alloc] initWithDictionary:dictionary[@"summary"]];
		inCallback(albums, paging, summary, nil);
	};
	return CALL_API;
}

- (nonnull NSURLSessionDataTask *)fetchTopTracksWithArtistID:(nonnull NSString *)artistID territory:(KKTerritoryCode)territory callback:(nonnull void (^)(NSArray <KKTrackInfo *> *_Nullable, KKPagingInfo *_Nullable, KKSummary *_Nullable, NSError *_Nullable))inCallback
{
	return [self fetchTopTracksWithArtistID:artistID territory:territory offset:0 limit:200 callback:inCallback];
}

- (nonnull NSURLSessionDataTask *)fetchTopTracksWithArtistID:(nonnull NSString *)artistID territory:(KKTerritoryCode)territory offset:(NSInteger)offset limit:(NSInteger)limit callback:(nonnull void (^)(NSArray <KKTrackInfo *> *_Nullable, KKPagingInfo *_Nullable, KKSummary *_Nullable, NSError *_Nullable))inCallback
{
	NSString *URLString = [NSString stringWithFormat:@"https://api.kkbox.com/v1.1/artists/%@/top-tracks?territory=%@&offset=%ld&limit=%ld", ESCAPE(artistID), KKStringFromTerritoryCode(territory), (long)offset, (long)limit];
	KKBOXOpenAPIDataCallback callback = ^(NSDictionary *dictionary, NSError *error) {
		if (error) {
			inCallback(nil, nil, nil, error);
			return;
		}
		NSMutableArray *tracks = [[NSMutableArray alloc] init];
		for (NSDictionary *trackDictionary in dictionary[@"data"]) {
			KKTrackInfo *track = [[KKTrackInfo alloc] initWithDictionary:trackDictionary];
			[tracks addObject:track];
		}
		KKPagingInfo *paging = [[KKPagingInfo alloc] initWithDictionary:dictionary[@"paging"]];
		KKSummary *summary = [[KKSummary alloc] initWithDictionary:dictionary[@"summary"]];
		inCallback(tracks, paging, summary, nil);
	};
	return CALL_API;
}

- (nonnull NSURLSessionDataTask *)fetchRelatedArtistsWithArtistID:(nonnull NSString *)artistID territory:(KKTerritoryCode)territory callback:(nonnull void (^)(NSArray <KKArtistInfo *> *_Nullable, KKPagingInfo *_Nullable, KKSummary *_Nullable, NSError *_Nullable))inCallback
{
	return [self fetchRelatedArtistsWithArtistID:artistID territory:territory offset:0 limit:20 callback:inCallback];
}

- (nonnull NSURLSessionDataTask *)fetchRelatedArtistsWithArtistID:(nonnull NSString *)artistID territory:(KKTerritoryCode)territory offset:(NSInteger)offset limit:(NSInteger)limit callback:(nonnull void (^)(NSArray <KKArtistInfo *> *_Nullable, KKPagingInfo *_Nullable, KKSummary *_Nullable, NSError *_Nullable))inCallback
{
	NSString *URLString = [NSString stringWithFormat:@"https://api.kkbox.com/v1.1/artists/%@/related-artists?territory=%@&offset=%ld&limit=%ld", ESCAPE(artistID), KKStringFromTerritoryCode(territory), (long)offset, (long)limit];
	KKBOXOpenAPIDataCallback callback = ^(NSDictionary *dictionary, NSError *error) {
		if (error) {
			inCallback(nil, nil, nil, error);
			return;
		}
		NSMutableArray *artists = [[NSMutableArray alloc] init];
		for (NSDictionary *d in dictionary[@"data"]) {
			KKArtistInfo *track = [[KKArtistInfo alloc] initWithDictionary:d];
			[artists addObject:track];
		}
		KKPagingInfo *paging = [[KKPagingInfo alloc] initWithDictionary:dictionary[@"paging"]];
		KKSummary *summary = [[KKSummary alloc] initWithDictionary:dictionary[@"summary"]];
		inCallback(artists, paging, summary, nil);
	};
	return CALL_API;
}

#pragma mark - Shared Playlists

- (nonnull NSURLSessionDataTask *)fetchPlaylistWithPlaylistID:(nonnull NSString *)playlistID territory:(KKTerritoryCode)territory callback:(nonnull void (^)(KKPlaylistInfo *_Nullable, KKPagingInfo *_Nullable, KKSummary *_Nullable, NSError *_Nullable))inCallback
{
	NSString *URLString = [NSString stringWithFormat:@"https://api.kkbox.com/v1.1/shared-playlists/%@?territory=%@", ESCAPE(playlistID), KKStringFromTerritoryCode(territory)];
	KKBOXOpenAPIDataCallback callback = ^(NSDictionary *dictionary, NSError *error) {
		if (error) {
			inCallback(nil, nil, nil, error);
			return;
		}
		KKPlaylistInfo *playlist = [[KKPlaylistInfo alloc] initWithDictionary:dictionary];
		KKPagingInfo *paging = [[KKPagingInfo alloc] initWithDictionary:dictionary[@"tracks"][@"paging"]];
		KKSummary *summary = [[KKSummary alloc] initWithDictionary:dictionary[@"tracks"][@"summary"]];
		inCallback(playlist, paging, summary, nil);
	};
	return CALL_API;
}

- (nonnull NSURLSessionDataTask *)fetchTracksInPlaylistWithPlaylistID:(nonnull NSString *)playlistID territory:(KKTerritoryCode)territory callback:(nonnull void (^)(NSArray <KKTrackInfo *> *_Nullable, KKPagingInfo *_Nullable, KKSummary *_Nullable, NSError *_Nullable))inCallback
{
	return [self fetchTracksInPlaylistWithPlaylistID:playlistID territory:territory offset:0 limit:20 callback:inCallback];
}

- (nonnull NSURLSessionDataTask *)fetchTracksInPlaylistWithPlaylistID:(nonnull NSString *)playlistID territory:(KKTerritoryCode)territory offset:(NSInteger)offset limit:(NSInteger)limit callback:(nonnull void (^)(NSArray <KKTrackInfo *> *_Nullable, KKPagingInfo *_Nullable, KKSummary *_Nullable, NSError *_Nullable))inCallback
{
	NSString *URLString = [NSString stringWithFormat:@"https://api.kkbox.com/v1.1/shared-playlists/%@/tracks?territory=%@&offset=%ld&limit=%ld", ESCAPE(playlistID), KKStringFromTerritoryCode(territory), (long)offset, (long)limit];
	KKBOXOpenAPIDataCallback callback = ^(NSDictionary *dictionary, NSError *error) {
		if (error) {
			inCallback(nil, nil, nil, error);
			return;
		}
		NSMutableArray *array = [[NSMutableArray alloc] init];
		if ([dictionary[@"data"] isKindOfClass:[NSArray class]]) {
			for (NSDictionary *trackDictionary in dictionary[@"data"]) {
				KKTrackInfo *track = [[KKTrackInfo alloc] initWithDictionary:trackDictionary];
				[array addObject:track];
			}
		}
		KKPagingInfo *paging = [[KKPagingInfo alloc] initWithDictionary:dictionary[@"paging"]];
		KKSummary *summary = [[KKSummary alloc] initWithDictionary:dictionary[@"summary"]];
		inCallback(array, paging, summary, nil);
	};
	return CALL_API;
}

#pragma mark - Featured Playlists

- (nonnull NSURLSessionDataTask *)fetchFeaturedPlaylistsForTerritory:(KKTerritoryCode)territory callback:(nonnull void (^)(NSArray <KKPlaylistInfo *> *_Nullable, KKPagingInfo *_Nullable, KKSummary *_Nullable, NSError *_Nullable))inCallback
{
	return [self fetchFeaturedPlaylistsForTerritory:territory offset:0 limit:100 callback:inCallback];
}

- (nonnull NSURLSessionDataTask *)fetchFeaturedPlaylistsForTerritory:(KKTerritoryCode)territory offset:(NSInteger)offset limit:(NSInteger)limit callback:(nonnull void (^)(NSArray <KKPlaylistInfo *> *_Nullable, KKPagingInfo *_Nullable, KKSummary *_Nullable, NSError *_Nullable))inCallback
{
	NSString *URLString = [NSString stringWithFormat:@"https://api.kkbox.com/v1.1/featured-playlists?territory=%@&offset=%ld&limit=%ld", KKStringFromTerritoryCode(territory), (long)offset, (long)limit];
	KKBOXOpenAPIDataCallback callback = ^(NSDictionary *dictionary, NSError *error) {
		if (error) {
			inCallback(nil, nil, nil, error);
			return;
		}
		NSMutableArray *playlists = [[NSMutableArray alloc] init];
		if ([dictionary[@"data"] isKindOfClass:[NSArray class]]) {
			for (NSDictionary *playlistDictionary in dictionary[@"data"]) {
				KKPlaylistInfo *playlist = [[KKPlaylistInfo alloc] initWithDictionary:playlistDictionary];
				[playlists addObject:playlist];
			}
		}
		KKPagingInfo *paging = [[KKPagingInfo alloc] initWithDictionary:dictionary[@"paging"]];
		KKSummary *summary = [[KKSummary alloc] initWithDictionary:dictionary[@"summary"]];
		inCallback(playlists, paging, summary, nil);
	};
	return CALL_API;
}

#pragma mark - New-Hits Playlists

- (nonnull NSURLSessionDataTask *)fetchNewHitsPlaylistsForTerritory:(KKTerritoryCode)territory callback:(nonnull void (^)(NSArray <KKPlaylistInfo *> *_Nullable, KKPagingInfo *_Nullable, KKSummary *_Nullable, NSError *_Nullable))inCallback
{
	return [self fetchNewHitsPlaylistsForTerritory:territory offset:0 limit:10 callback:inCallback];
}

- (nonnull NSURLSessionDataTask *)fetchNewHitsPlaylistsForTerritory:(KKTerritoryCode)territory offset:(NSInteger)offset limit:(NSInteger)limit callback:(nonnull void (^)(NSArray <KKPlaylistInfo *> *_Nullable, KKPagingInfo *_Nullable, KKSummary *_Nullable, NSError *_Nullable))inCallback
{
	NSString *URLString = [NSString stringWithFormat:@"https://api.kkbox.com/v1.1/new-hits-playlists?territory=%@&offset=%ld&limit=%ld", KKStringFromTerritoryCode(territory), (long)offset, (long)limit];
	KKBOXOpenAPIDataCallback callback = ^(NSDictionary *dictionary, NSError *error) {
		if (error) {
			inCallback(nil, nil, nil, error);
			return;
		}
		NSMutableArray *playlists = [[NSMutableArray alloc] init];
		if ([dictionary[@"data"] isKindOfClass:[NSArray class]]) {
			for (NSDictionary *playlistDictionary in dictionary[@"data"]) {
				KKPlaylistInfo *playlist = [[KKPlaylistInfo alloc] initWithDictionary:playlistDictionary];
				[playlists addObject:playlist];
			}
		}
		KKPagingInfo *paging = [[KKPagingInfo alloc] initWithDictionary:dictionary[@"paging"]];
		KKSummary *summary = [[KKSummary alloc] initWithDictionary:dictionary[@"summary"]];
		inCallback(playlists, paging, summary, nil);
	};
	return CALL_API;
}

#pragma mark - Featured Playlists Categories

- (nonnull NSURLSessionDataTask *)fetchFeaturedPlaylistCategoriesForTerritory:(KKTerritoryCode)territory callback:(nonnull void (^)(NSArray <KKFeaturedPlaylistCategory *> *_Nullable, KKPagingInfo *_Nullable, KKSummary *_Nullable, NSError *_Nullable))inCallback
{
	return [self fetchFeaturedPlaylistCategoriesForTerritory:territory offset:0 limit:100 callback:inCallback];
}

- (nonnull NSURLSessionDataTask *)fetchFeaturedPlaylistCategoriesForTerritory:(KKTerritoryCode)territory offset:(NSInteger)offset limit:(NSInteger)limit callback:(nonnull void (^)(NSArray <KKFeaturedPlaylistCategory *> *_Nullable, KKPagingInfo *_Nullable, KKSummary *_Nullable, NSError *_Nullable))inCallback
{
	NSString *URLString = [NSString stringWithFormat:@"https://api.kkbox.com/v1.1/featured-playlist-categories?territory=%@&offset=%ld&limit=%ld", KKStringFromTerritoryCode(territory), (long)offset, (long)limit];
	KKBOXOpenAPIDataCallback callback = ^(NSDictionary *dictionary, NSError *error) {
		if (error) {
			inCallback(nil, nil, nil, error);
			return;
		}
		NSMutableArray *array = [[NSMutableArray alloc] init];
		if ([dictionary[@"data"] isKindOfClass:[NSArray class]]) {
			for (NSDictionary *playlistDictionary in dictionary[@"data"]) {
				KKFeaturedPlaylistCategory *category = [[KKFeaturedPlaylistCategory alloc] initWithDictionary:playlistDictionary];
				[array addObject:category];
			}
		}
		KKPagingInfo *paging = [[KKPagingInfo alloc] initWithDictionary:dictionary[@"paging"]];
		KKSummary *summary = [[KKSummary alloc] initWithDictionary:dictionary[@"summary"]];
		inCallback(array, paging, summary, nil);
	};
	return CALL_API;
}

- (nonnull NSURLSessionDataTask *)fetchFeaturedPlaylistsInCategory:(nonnull NSString *)category territory:(KKTerritoryCode)territory callback:(nonnull void (^)(KKFeaturedPlaylistCategory *_Nullable, NSArray <KKPlaylistInfo *> *_Nullable, KKPagingInfo *_Nullable, KKSummary *_Nullable, NSError *_Nullable))inCallback
{
	return [self fetchFeaturedPlaylistsInCategory:category territory:territory offset:0 limit:100 callback:inCallback];
}

- (nonnull NSURLSessionDataTask *)fetchFeaturedPlaylistsInCategory:(nonnull NSString *)category territory:(KKTerritoryCode)territory offset:(NSInteger)offset limit:(NSInteger)limit callback:(nonnull void (^)(KKFeaturedPlaylistCategory *_Nullable, NSArray <KKPlaylistInfo *> *_Nullable, KKPagingInfo *_Nullable, KKSummary *_Nullable, NSError *_Nullable))inCallback
{
	NSString *URLString = [NSString stringWithFormat:@"https://api.kkbox.com/v1.1/featured-playlist-categories/%@?territory=%@&offset=%ld&limit=%ld", ESCAPE(category), KKStringFromTerritoryCode(territory), (long)offset, (long)limit];
	KKBOXOpenAPIDataCallback callback = ^(NSDictionary *dictionary, NSError *error) {
		if (error) {
			inCallback(nil, nil, nil, nil, error);
			return;
		}
		NSMutableDictionary *categoryDictionary = [[NSMutableDictionary alloc] init];
		categoryDictionary[@"id"] = dictionary[@"id"];
		categoryDictionary[@"title"] = dictionary[@"title"];
		categoryDictionary[@"images"] = dictionary[@"images"];
		KKFeaturedPlaylistCategory *category = [[KKFeaturedPlaylistCategory alloc] initWithDictionary:categoryDictionary];

		NSMutableArray *array = [[NSMutableArray alloc] init];
		if ([dictionary[@"playlists"] isKindOfClass:[NSDictionary class]] && [dictionary[@"playlists"][@"data"] isKindOfClass:[NSArray class]]) {
			for (NSDictionary *playlistDictionary in dictionary[@"playlists"][@"data"]) {
				KKPlaylistInfo *playlist = [[KKPlaylistInfo alloc] initWithDictionary:playlistDictionary];
				[array addObject:playlist];
			}
		}
		KKPagingInfo *paging = [[KKPagingInfo alloc] initWithDictionary:dictionary[@"playlists"][@"paging"]];
		KKSummary *summary = [[KKSummary alloc] initWithDictionary:dictionary[@"playlists"][@"summary"]];
		inCallback(category, array, paging, summary, nil);
	};
	return CALL_API;
}

#pragma mark - Radio
#pragma mark Mood Station

- (nonnull NSURLSessionDataTask *)fetchMoodStationsForTerritory:(KKTerritoryCode)territory callback:(nonnull void (^)(NSArray <KKRadioStation *> *_Nullable, KKPagingInfo *_Nullable, KKSummary *_Nullable, NSError *_Nullable))inCallback
{
	NSString *URLString = [NSString stringWithFormat:@"https://api.kkbox.com/v1.1/mood-stations?territory=%@", KKStringFromTerritoryCode(territory)];
	KKBOXOpenAPIDataCallback callback = ^(NSDictionary *dictionary, NSError *error) {
		if (error) {
			inCallback(nil, nil, nil, error);
			return;
		}

		NSMutableArray *stations = [[NSMutableArray alloc] init];
		if ([dictionary[@"data"] isKindOfClass:[NSArray class]]) {
			for (NSDictionary *playlistDictionary in dictionary[@"data"]) {
				KKRadioStation *radioStation = [[KKRadioStation alloc] initWithDictionary:playlistDictionary];
				[stations addObject:radioStation];
			}
		}
		KKPagingInfo *paging = [[KKPagingInfo alloc] initWithDictionary:dictionary[@"paging"]];
		KKSummary *summary = [[KKSummary alloc] initWithDictionary:dictionary[@"summary"]];
		inCallback(stations, paging, summary, nil);
	};
	return CALL_API;
}

- (nonnull NSURLSessionDataTask *)fetchMoodStationWithStationID:(nonnull NSString *)stationID territory:(KKTerritoryCode)territory callback:(nonnull void (^)(KKRadioStation *_Nullable, NSArray<KKTrackInfo *> *_Nullable, KKPagingInfo *_Nullable, KKSummary *_Nullable, NSError *_Nullable))inCallback
{
	return [self fetchMoodStationWithStationID:stationID territory:territory offset:0 limit:100 callback:inCallback];
}

- (nonnull NSURLSessionDataTask *)fetchMoodStationWithStationID:(nonnull NSString *)stationID territory:(KKTerritoryCode)territory offset:(NSInteger)offset limit:(NSInteger)limit callback:(nonnull void (^)(KKRadioStation *_Nullable, NSArray <KKTrackInfo *> *_Nullable, KKPagingInfo *_Nullable, KKSummary *_Nullable, NSError *_Nullable))inCallback
{
	NSString *URLString = [NSString stringWithFormat:@"https://api.kkbox.com/v1.1/mood-stations/%@?territory=%@&offset=%ld&limit=%ld", ESCAPE(stationID), KKStringFromTerritoryCode(territory), (long)offset, (long)limit];
	KKBOXOpenAPIDataCallback callback = ^(NSDictionary *dictionary, NSError *error) {
		if (error) {
			inCallback(nil, nil, nil, nil, error);
			return;
		}

		NSMutableDictionary *stationDictionary = [[NSMutableDictionary alloc] init];
		stationDictionary[@"id"] = dictionary[@"id"];
		stationDictionary[@"name"] = dictionary[@"name"];
		stationDictionary[@"images"] = dictionary[@"images"];

		KKRadioStation *station = [[KKRadioStation alloc] initWithDictionary:stationDictionary];

		NSMutableArray *tracks = [[NSMutableArray alloc] init];
		if ([dictionary[@"tracks"][@"data"] isKindOfClass:[NSArray class]]) {
			for (NSDictionary *playlistDictionary in dictionary[@"tracks"][@"data"]) {
				KKTrackInfo *radioStation = [[KKTrackInfo alloc] initWithDictionary:playlistDictionary];
				[tracks addObject:radioStation];
			}
		}
		KKPagingInfo *paging = [[KKPagingInfo alloc] initWithDictionary:dictionary[@"tracks"][@"paging"]];
		KKSummary *summary = [[KKSummary alloc] initWithDictionary:dictionary[@"tracks"][@"summary"]];
		inCallback(station, tracks, paging, summary, nil);
	};
	return CALL_API;
}

#pragma mark Genre Station

- (nonnull NSURLSessionDataTask *)fetchGenreStationsForTerritory:(KKTerritoryCode)territory callback:(nonnull void (^)(NSArray <KKRadioStation *> *_Nullable, KKPagingInfo *_Nullable, KKSummary *_Nullable, NSError *_Nullable))inCallback
{
	NSString *URLString = [NSString stringWithFormat:@"https://api.kkbox.com/v1.1/genre-stations?territory=%@", KKStringFromTerritoryCode(territory)];
	KKBOXOpenAPIDataCallback callback = ^(NSDictionary *dictionary, NSError *error) {
		if (error) {
			inCallback(nil, nil, nil, error);
			return;
		}

		NSMutableArray *stations = [[NSMutableArray alloc] init];
		if ([dictionary[@"data"] isKindOfClass:[NSArray class]]) {
			for (NSDictionary *playlistDictionary in dictionary[@"data"]) {
				KKRadioStation *radioStation = [[KKRadioStation alloc] initWithDictionary:playlistDictionary];
				[stations addObject:radioStation];
			}
		}
		KKPagingInfo *paging = [[KKPagingInfo alloc] initWithDictionary:dictionary[@"paging"]];
		KKSummary *summary = [[KKSummary alloc] initWithDictionary:dictionary[@"summary"]];
		inCallback(stations, paging, summary, nil);
	};
	return CALL_API;
}

- (nonnull NSURLSessionDataTask *)fetchGenreStationWithStationID:(nonnull NSString *)stationID territory:(KKTerritoryCode)territory callback:(nonnull void (^)(KKRadioStation *_Nullable, NSArray<KKTrackInfo *> *_Nullable, KKPagingInfo *_Nullable, KKSummary *_Nullable, NSError *_Nullable))inCallback
{
	return [self fetchGenreStationWithStationID:stationID territory:territory offset:0 limit:100 callback:inCallback];
}

- (nonnull NSURLSessionDataTask *)fetchGenreStationWithStationID:(nonnull NSString *)stationID territory:(KKTerritoryCode)territory offset:(NSInteger)offset limit:(NSInteger)limit callback:(nonnull void (^)(KKRadioStation *_Nullable, NSArray <KKTrackInfo *> *_Nullable, KKPagingInfo *_Nullable, KKSummary *_Nullable, NSError *_Nullable))inCallback
{
	NSString *URLString = [NSString stringWithFormat:@"https://api.kkbox.com/v1.1/genre-stations/%@?territory=%@&offset=%ld&limit=%ld", ESCAPE(stationID), KKStringFromTerritoryCode(territory), (long)offset, (long)limit];
	KKBOXOpenAPIDataCallback callback = ^(NSDictionary *dictionary, NSError *error) {
		if (error) {
			inCallback(nil, nil, nil, nil, error);
			return;
		}

		NSMutableDictionary *stationDictionary = [[NSMutableDictionary alloc] init];
		stationDictionary[@"id"] = dictionary[@"id"];
		stationDictionary[@"name"] = dictionary[@"name"];
		stationDictionary[@"images"] = dictionary[@"images"];

		KKRadioStation *station = [[KKRadioStation alloc] initWithDictionary:stationDictionary];

		NSMutableArray *tracks = [[NSMutableArray alloc] init];
		if ([dictionary[@"tracks"][@"data"] isKindOfClass:[NSArray class]]) {
			for (NSDictionary *playlistDictionary in dictionary[@"tracks"][@"data"]) {
				KKTrackInfo *raioStation = [[KKTrackInfo alloc] initWithDictionary:playlistDictionary];
				[tracks addObject:raioStation];
			}
		}
		KKPagingInfo *paging = [[KKPagingInfo alloc] initWithDictionary:dictionary[@"tracks"][@"paging"]];
		KKSummary *summary = [[KKSummary alloc] initWithDictionary:dictionary[@"tracks"][@"summary"]];
		inCallback(station, tracks, paging, summary, nil);
	};
	return CALL_API;
}

#pragma mark - Search

- (nonnull NSURLSessionDataTask *)searchWithKeyword:(nonnull NSString *)keyword searchTypes:(KKSearchType)searchTypes territory:(KKTerritoryCode)territory callback:(nonnull void (^)(KKSearchResults *_Nullable, NSError *_Nullable))inCallback
{
	NSParameterAssert(keyword);
	return [self searchWithKeyword:keyword searchTypes:searchTypes territory:territory offset:0 limit:50 callback:inCallback];
}

- (nonnull NSURLSessionDataTask *)searchWithKeyword:(nonnull NSString *)keyword searchTypes:(KKSearchType)searchTypes territory:(KKTerritoryCode)territory offset:(NSInteger)offset limit:(NSInteger)limit callback:(nonnull void (^)(KKSearchResults *_Nullable, NSError *_Nullable))inCallback
{
	NSParameterAssert(keyword);
	NSMutableArray *types = [NSMutableArray array];
	if (searchTypes & KKSearchTypeArtist) {
		[types addObject:@"artist"];
	}
	if (searchTypes & KKSearchTypeAlbum) {
		[types addObject:@"album"];
	}
	if (searchTypes & KKSearchTypeTrack) {
		[types addObject:@"track"];
	}
	if (searchTypes & KKSearchTypePlaylist) {
		[types addObject:@"playlist"];
	}
	NSMutableString *URLString = [NSMutableString stringWithFormat:@"https://api.kkbox.com/v1.1/search?q=%@&offset=%ld&limit=%ld", ESCAPE_ARG(keyword), (long)offset, (long)limit];
	if ([types count] > 0) {
		[URLString appendFormat:@"&type=%@", [types componentsJoinedByString:@","]];
	}
	[URLString appendFormat:@"&territory=%@", KKStringFromTerritoryCode(territory)];

	KKBOXOpenAPIDataCallback callback = ^(NSDictionary *dictionary, NSError *error) {
		if (error) {
			inCallback(nil, error);
			return;
		}
		KKSearchResults *results = [[KKSearchResults alloc] initWithDictionary:dictionary];
		inCallback(results, nil);
	};
	return CALL_API;
}

#pragma mark - New Releases

- (nonnull NSURLSessionDataTask *)fetchNewReleaseAlbumCategoriesForTerritory:(KKTerritoryCode)territory callback:(nonnull void (^)(NSArray <KKNewReleaseAlbumsCategory *> *_Nullable, KKPagingInfo *_Nullable, KKSummary *_Nullable, NSError *_Nullable))inCallback
{
	return [self fetchNewReleaseAlbumCategoriesForTerritory:territory offset:0 limit:100 callback:inCallback];
}

- (nonnull NSURLSessionDataTask *)fetchNewReleaseAlbumCategoriesForTerritory:(KKTerritoryCode)territory offset:(NSInteger)offset limit:(NSInteger)limit callback:(nonnull void (^)(NSArray <KKNewReleaseAlbumsCategory *> *_Nullable, KKPagingInfo *_Nullable, KKSummary *_Nullable, NSError *_Nullable))inCallback
{
	NSString *URLString = [NSString stringWithFormat:@"https://api.kkbox.com/v1.1/new-release-categories?territory=%@&offset=%ld&limit=%ld", KKStringFromTerritoryCode(territory), (long)offset, (long)limit];
	KKBOXOpenAPIDataCallback callback = ^(NSDictionary *dictionary, NSError *error) {
		if (error) {
			inCallback(nil, nil, nil, error);
			return;
		}

		NSMutableArray *categories = [[NSMutableArray alloc] init];
		if ([dictionary[@"data"] isKindOfClass:[NSArray class]]) {
			for (NSDictionary *categoryDictionary in dictionary[@"data"]) {
				KKNewReleaseAlbumsCategory *category = [[KKNewReleaseAlbumsCategory alloc] initWithDictionary:categoryDictionary];
				[categories addObject:category];
			}
		}
		KKPagingInfo *paging = [[KKPagingInfo alloc] initWithDictionary:dictionary[@"paging"]];
		KKSummary *summary = [[KKSummary alloc] initWithDictionary:dictionary[@"summary"]];
		inCallback(categories, paging, summary, nil);
	};
	return CALL_API;
}

- (nonnull NSURLSessionDataTask *)fetchNewReleaseAlbumsUnderCategory:(nonnull NSString *)categoryID territory:(KKTerritoryCode)territory callback:(nonnull void (^)(KKNewReleaseAlbumsCategory *_Nullable, NSArray

<KKAlbumInfo *> *_Nullable, KKPagingInfo *_Nullable, KKSummary *_Nullable, NSError *_Nullable))inCallback
{
	return [self fetchNewReleaseAlbumsUnderCategory:categoryID territory:territory offset:0 limit:200 callback:inCallback];
}

- (nonnull NSURLSessionDataTask *)fetchNewReleaseAlbumsUnderCategory:(nonnull NSString *)categoryID territory:(KKTerritoryCode)territory offset:(NSInteger)offset limit:(NSInteger)limit callback:(nonnull void (^)(KKNewReleaseAlbumsCategory *_Nullable, NSArray

<KKAlbumInfo *> *_Nullable, KKPagingInfo *_Nullable, KKSummary *_Nullable, NSError *_Nullable))inCallback
{
	NSString *URLString = [NSString stringWithFormat:@"https://api.kkbox.com/v1.1/new-release-categories/%@?territory=%@&offset=%ld&limit=%ld", categoryID, KKStringFromTerritoryCode(territory), (long)offset, (long)limit];

	KKBOXOpenAPIDataCallback callback = ^(NSDictionary *dictionary, NSError *error) {
		if (error) {
			inCallback(nil, nil, nil, nil, error);
			return;
		}

		NSMutableDictionary *categoryDictionary = [[NSMutableDictionary alloc] init];
		categoryDictionary[@"id"] = dictionary[@"id"];
		categoryDictionary[@"title"] = dictionary[@"title"];
		KKNewReleaseAlbumsCategory *category = [[KKNewReleaseAlbumsCategory alloc] initWithDictionary:categoryDictionary];

		NSMutableArray *albums = [[NSMutableArray alloc] init];
		if ([dictionary[@"albums"][@"data"] isKindOfClass:[NSArray class]]) {
			for (NSDictionary *albumDictionary in dictionary[@"albums"][@"data"]) {
				KKAlbumInfo *category = [[KKAlbumInfo alloc] initWithDictionary:albumDictionary];
				[albums addObject:category];
			}
		}
		KKPagingInfo *paging = [[KKPagingInfo alloc] initWithDictionary:dictionary[@"albums"][@"paging"]];
		KKSummary *summary = [[KKSummary alloc] initWithDictionary:dictionary[@"albums"][@"summary"]];
		inCallback(category, albums, paging, summary, nil);
	};

	return CALL_API;
}

#pragma mark - Charts

- (nonnull NSURLSessionDataTask *)fetchChartsForTerritory:(KKTerritoryCode)territory callback:(nonnull void (^)(NSArray <KKPlaylistInfo *> *_Nullable, KKPagingInfo *_Nullable, KKSummary *_Nullable, NSError *_Nullable))callback
{
	return [self fetchChartsForTerritory:territory offset:0 limit:50 callback:callback];
}

- (nonnull NSURLSessionDataTask *)fetchChartsForTerritory:(KKTerritoryCode)territory offset:(NSInteger)offset limit:(NSInteger)limit callback:(nonnull void (^)(NSArray <KKPlaylistInfo *> *_Nullable, KKPagingInfo *_Nullable, KKSummary *_Nullable, NSError *_Nullable))inCallback
{
	NSString *URLString = [NSString stringWithFormat:@"https://api.kkbox.com/v1.1/charts?territory=%@&offset=%ld&limit=%ld", KKStringFromTerritoryCode(territory), (long)offset, (long)limit];

	KKBOXOpenAPIDataCallback callback = ^(NSDictionary *dictionary, NSError *error) {
		if (error) {
			inCallback(nil, nil, nil, error);
			return;
		}

		NSMutableArray *playlists = [[NSMutableArray alloc] init];
		if ([dictionary[@"data"] isKindOfClass:[NSArray class]]) {
			for (NSDictionary *playlistDictionary in dictionary[@"data"]) {
				KKPlaylistInfo *category = [[KKPlaylistInfo alloc] initWithDictionary:playlistDictionary];
				[playlists addObject:category];
			}
		}
		KKPagingInfo *paging = [[KKPagingInfo alloc] initWithDictionary:dictionary[@"paging"]];
		KKSummary *summary = [[KKSummary alloc] initWithDictionary:dictionary[@"summary"]];
		inCallback(playlists, paging, summary, nil);
	};

	return CALL_API;
}

#pragma mark - Children Contents

- (nonnull NSURLSessionDataTask *)fetchChildrenCategories:(KKTerritoryCode)territory callback:(nonnull void (^)(NSArray <KKChildrenCategory *> *_Nullable, KKPagingInfo *_Nullable, KKSummary *_Nullable, NSError *_Nullable))inCallback
{
	NSString *URLString = [NSString stringWithFormat:@"https://api.kkbox.com/v1.1/children-categories?territory=%@", KKStringFromTerritoryCode(territory)];

	KKBOXOpenAPIDataCallback callback = ^(NSDictionary *dictionary, NSError *error) {
		if (error) {
			inCallback(nil, nil, nil, error);
			return;
		}

		NSMutableArray *categories = [[NSMutableArray alloc] init];
		if ([dictionary[@"data"] isKindOfClass:[NSArray class]]) {
			for (NSDictionary *playlistDictionary in dictionary[@"data"]) {
				KKChildrenCategory *category = [[KKChildrenCategory alloc] initWithDictionary:playlistDictionary];
				[categories addObject:category];
			}
		}
		KKPagingInfo *paging = [[KKPagingInfo alloc] initWithDictionary:dictionary[@"paging"]];
		KKSummary *summary = [[KKSummary alloc] initWithDictionary:dictionary[@"summary"]];
		inCallback(categories, paging, summary, nil);
	};

	return CALL_API;
}

- (nonnull NSURLSessionDataTask *)fetchChildrenCategory:(nonnull NSString *)categoryID territory:(KKTerritoryCode)territory callback:(nonnull void (^)(KKChildrenCategoryGroup *_Nullable, KKPagingInfo *_Nullable, KKSummary *_Nullable, NSError *_Nullable))inCallback
{
	NSString *URLString = [NSString stringWithFormat:@"https://api.kkbox.com/v1.1/children-categories/%@?territory=%@", categoryID, KKStringFromTerritoryCode(territory)];

	KKBOXOpenAPIDataCallback callback = ^(NSDictionary *dictionary, NSError *error) {
		if (error) {
			inCallback(nil, nil, nil, error);
			return;
		}

		KKChildrenCategoryGroup *group = [[KKChildrenCategoryGroup alloc] initWithDictionary:dictionary];
		KKPagingInfo *paging = [[KKPagingInfo alloc] initWithDictionary:dictionary[@"paging"]];
		KKSummary *summary = [[KKSummary alloc] initWithDictionary:dictionary[@"summary"]];
		inCallback(group, paging, summary, nil);
	};

	return CALL_API;
}


@end

#undef CALL_API
