//
// KKBOXOpenAPI+Privates.m
//
// Copyright (c) 2016-2019 KKBOX Taiwan Co., Ltd. All Rights Reserved.
//

#import "KKBOXOpenAPI+Privates.h"
#import "NSData+LFHTTPFormExtensions.h"

static NSString *const KKUserAgent = @"KKBOX Open API iOS SDK";

NSString *KKStringFromTerritoryCode(KKTerritoryCode code) {
	switch (code) {
		case KKTerritoryCodeTaiwan:
			return @"TW";
		case KKTerritoryCodeHongKong:
			return @"HK";
		case KKTerritoryCodeSingapore:
			return @"SG";
		case KKTerritoryCodeMalaysia:
			return @"MY";
		case KKTerritoryCodeJapan:
			return @"JP";
		default:
			break;
	}
	return @"";
}

@implementation KKBOXOpenAPI (Privates)

- (NSURLSessionDataTask *)_postToURL:(NSURL *)URL POSTParameters:(NSDictionary *)parameters headers:(NSDictionary<NSString *, NSString *> *)headers callback:(void (^)(id, NSError *))callback
{
	NSMutableDictionary<NSString *, NSString *> *newHeaders = [headers mutableCopy];
	newHeaders[@"Content-type"] = @"application/x-www-form-urlencoded";
	NSData *POSTData = [NSData dataAsWWWURLEncodedFormFromDictionary:parameters];
	return [self _postToURL:URL POSTData:POSTData headers:newHeaders callback:callback];
}

- (NSURLSessionDataTask *)_postToURL:(NSURL *)URL POSTData:(NSData *)POSTData headers:(NSDictionary<NSString *, NSString *> *)headers callback:(void (^)(id, NSError *))callback
{
	NSParameterAssert(URL);
	NSParameterAssert(POSTData);
	NSParameterAssert(headers);
	NSParameterAssert(callback);

	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL];
	[request setHTTPMethod:@"POST"];

	for (NSString *key in headers.allKeys) {
		[request setValue:headers[key] forHTTPHeaderField:key];
	}
	[request setValue:KKUserAgent forHTTPHeaderField:@"User-Agent"];
	[request setHTTPBody:POSTData];

	NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *_Nullable data, NSURLResponse *_Nullable response, NSError *_Nullable error) {
		if (error) {
			dispatch_async(dispatch_get_main_queue(), ^{
				callback(nil, error);
			});
			return;
		}
		NSError *JSONError = nil;
		id JSONObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&JSONError];
		if (JSONError) {
			dispatch_async(dispatch_get_main_queue(), ^{
				callback(nil, JSONError);
			});
		}
		dispatch_async(dispatch_get_main_queue(), ^{
			callback(JSONObject, nil);
		});
	}];
	[task resume];
	return task;
}

- (nonnull NSURLSessionDataTask *)_apiTaskWithURL:(nonnull NSURL *)URL callback:(nonnull KKBOXOpenAPIDataCallback)callback;
{
	NSParameterAssert(self.accessToken);
	NSParameterAssert(URL);
	NSParameterAssert(callback);

	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL];
	[request setHTTPMethod:@"GET"];
	[request setValue:KKUserAgent forHTTPHeaderField:@"User-Agent"];
	NSString *auth = [NSString stringWithFormat:@"Bearer %@", self.accessToken.accessToken];
	[request setValue:auth forHTTPHeaderField:@"Authorization"];
	NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *_Nullable data, NSURLResponse *_Nullable response, NSError *_Nullable error) {
		if (error) {
			dispatch_async(dispatch_get_main_queue(), ^{
				callback(nil, error);
			});
			return;
		}
		NSError *JSONError = nil;
		id JSONObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&JSONError];
		if (JSONError) {
			dispatch_async(dispatch_get_main_queue(), ^{
				callback(nil, JSONError);
			});
			return;
		}
		NSDictionary *APIErrorDictionary = JSONObject[@"error"];
		if ([APIErrorDictionary isKindOfClass:[NSDictionary class]]) {
			NSInteger code = [APIErrorDictionary[@"code"] integerValue];
			NSString *errorMessage = APIErrorDictionary[@"message"] ?: @"API Error";
			NSError *APIError = [NSError errorWithDomain:@"KKBOXOpenAPIErrorDomain" code:code userInfo:@{NSLocalizedDescriptionKey: errorMessage}];
			dispatch_async(dispatch_get_main_queue(), ^{
				callback(nil, APIError);
			});
			return;
		}
		dispatch_async(dispatch_get_main_queue(), ^{
			callback(JSONObject, nil);
		});
	}];
	[task resume];
	return task;
}

@end
