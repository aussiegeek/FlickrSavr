#import <Foundation/Foundation.h>

@interface AFFlickrPhoto : NSObject
- (id)initWithDictionary:(NSDictionary *)dict;
- (NSURL *)url;
- (NSString *)title;
- (void)downloadPhotoWithCompletionBlock:(void(^)())block;
- (NSString *)photoPath;
- (NSString *)ownerName;
- (NSURL *)buddyIconURL;
- (NSString *)buddyIconPath;
@end
