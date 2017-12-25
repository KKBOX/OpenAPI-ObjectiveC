//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

#import "KKBOXOpenAPI.h"


@interface KKBOXOpenAPI (Private)
- (NSString *)_scopeParamater:(KKScope)scope;
@property (strong, nullable, nonatomic) KKAccessToken *accessToken;
@end

