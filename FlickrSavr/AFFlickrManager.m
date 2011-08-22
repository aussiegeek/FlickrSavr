#import "AFFlickrManager.h"
#import "SBJson.h"
#import "AFFlickrPhoto.h"
#include <stdlib.h>
#import "ASIHTTPRequest.h"
#import "ASIDownloadCache.h"

#define API_KEY @"4a66fc1a7ab88035aabdeff1f230a971";
#define API_SECRET @"11e7a25980061c0b";

@interface AFFlickrManager ()
@property (strong) NSMutableArray *photos;
- (void)parseJson;
@end

@implementation AFFlickrManager
AF_SYNTHESIZE(photos);

- (void)dealloc
{
    AF_RELEASE(photos);
    
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {
        self.photos = [NSMutableArray array];
        [self parseJson];
    }
    
    return self;
}

- (void)parseJson
{
    NSString *interestingURLstring = [NSString stringWithFormat:@"http://api.flickr.com/services/rest/?method=flickr.interestingness.getList&api_key=4a66fc1a7ab88035aabdeff1f230a971&format=json&nojsoncallback=1&extras=owner_name,icon_server&per_page=100"];
    NSURL *interestingURL = [NSURL URLWithString:interestingURLstring];
    ASIDownloadCache *cache = [[[ASIDownloadCache alloc] init] autorelease];
    [cache setStoragePath:NSTemporaryDirectory()];
    [cache setShouldRespectCacheControlHeaders:NO];
    ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:interestingURL] autorelease];
    [request setDownloadCache:cache];
    [request setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
    [request setSecondsToCache:60*60*24];
    [request setCachePolicy:ASIOnlyLoadIfNotCachedCachePolicy|ASIFallbackToCacheIfLoadFailsCachePolicy];
    [request setCompletionBlock:^{
        SBJsonParser *jsonParser = [[[SBJsonParser alloc] init] autorelease];
        NSData *interestingJson = [request responseData];
        NSDictionary *json= [jsonParser objectWithData:interestingJson];
        NSDictionary *jsonPhotos = [json objectForKey:@"photos"];
        NSArray *jsonPhoto = [jsonPhotos objectForKey:@"photo"];
        [jsonPhoto enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            AFFlickrPhoto *flickrPhoto = [[[AFFlickrPhoto alloc] initWithDictionary:obj] autorelease];
            [flickrPhoto downloadPhotoWithCompletionBlock:^{
                [self.photos addObject:flickrPhoto]; 
            }];
        }];
    }];
    [request startAsynchronous];
}

- (AFFlickrPhoto *)randomPhoto
{
    int count = (int)[self.photos count];
    if (!count) {
        return nil;
    }
    int index = arc4random() % count;
    return [self.photos objectAtIndex:index];
}

- (NSString *)description
{
    return [self.photos description];
}
@end
