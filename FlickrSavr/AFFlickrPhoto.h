#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"

@interface AFFlickrPhoto : NSObject
- (id)initWithDictionary:(NSDictionary *)dict;
- (NSURL *)url;
- (NSString *)title;
- (void)downloadPhotoWithCompletionBlock:(ASIBasicBlock)completionBlock;
- (NSString *)photoPath;
- (NSString *)ownerName;
- (NSURL *)buddyIconURL;
- (NSString *)buddyIconPath;
@end
