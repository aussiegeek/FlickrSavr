#import "AFFlickrManager.h"
#import "AFFlickrPhoto.h"
#include <stdlib.h>

#define API_KEY @"4a66fc1a7ab88035aabdeff1f230a971";

@interface AFFlickrManager ()
@property (strong) NSMutableArray *photos;
- (void)parseJson;
@end

@implementation AFFlickrManager
AF_SYNTHESIZE(photos);

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
    NSString *interestingURLstring = [NSString stringWithFormat:@"https://api.flickr.com/services/rest/?method=flickr.interestingness.getList&api_key=4a66fc1a7ab88035aabdeff1f230a971&format=json&nojsoncallback=1&extras=owner_name,icon_server&per_page=100"];
    NSURL *interestingURL = [NSURL URLWithString:interestingURLstring];

    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:interestingURL];
    
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSLog(@"connection error: %@", connectionError);
        NSLog(@"json: %@", [NSString stringWithUTF8String:[data bytes]]);
        NSDictionary *json=        [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSDictionary *jsonPhotos = [json objectForKey:@"photos"];
        NSArray *jsonPhoto = [jsonPhotos objectForKey:@"photo"];
        [jsonPhoto enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            AFFlickrPhoto *flickrPhoto = [[AFFlickrPhoto alloc] initWithDictionary:obj];
            [flickrPhoto downloadPhotoWithCompletionBlock:^{
                [self.photos addObject:flickrPhoto];
            }];
        }];
    
    }];
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
