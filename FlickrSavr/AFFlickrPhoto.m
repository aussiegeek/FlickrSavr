#import "AFFlickrPhoto.h"

@interface AFFlickrPhoto ()
@property (strong) NSMutableDictionary *photoAttributes;
@end

@implementation AFFlickrPhoto
AF_SYNTHESIZE(photoAttributes);

- (id)initWithDictionary:(NSDictionary *)dict
{
    if((self = [super init])) {
        self.photoAttributes = [NSMutableDictionary dictionaryWithDictionary:dict];
    }
    
    return self;
}

- (NSURL *)url
{
    NSString *urlString = [NSString stringWithFormat:@"https://farm%@.static.flickr.com/%@/%@_%@_b.jpg",
                           [self.photoAttributes objectForKey:@"farm"],
                           [self.photoAttributes objectForKey:@"server"],
                           [self.photoAttributes objectForKey:@"id"],
                           [self.photoAttributes objectForKey:@"secret"]];
    return [NSURL URLWithString:urlString];
}

- (NSString *)title
{
    return [self.photoAttributes objectForKey:@"title"];
}

- (NSString *)photoPath
{
    return [NSString stringWithFormat:@"%@/%@_%@_b.jpg",
            NSTemporaryDirectory(),
            [self.photoAttributes objectForKey:@"id"],
            [self.photoAttributes objectForKey:@"secret"]];
}

- (void)downloadPhotoWithCompletionBlock:(void(^)())completionBlock
{
    NSString *fileName = [self photoPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:fileName]) {
        // file already exists, so just run completion block
        completionBlock();
    } else {
        NSError        *error = nil;
        NSURLResponse  *response = nil;
        NSData *responseData = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:[self url]] returningResponse:&response error:&error];
        if(error) {
            NSLog(@"Error fetching photo: %@", error);
        } else {
            NSLog(@"Saving image to %@", fileName);
            [responseData writeToFile:fileName atomically:YES];
            completionBlock();
        }
    };
    
    
    NSString *iconFileName = [self buddyIconPath];
    if(![fileManager fileExistsAtPath:iconFileName]) {
        NSError        *error = nil;
        NSURLResponse  *response = nil;
        NSLog(@"Fetching buddy icon %@", [self buddyIconURL]);
        NSData *responseData = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:[self buddyIconURL]] returningResponse:&response error:&error];
        if(error){
            NSLog(@"Error fetching buddy icon: %@", error);
        } else {
            NSLog(@"Saving buddy icon to %@", [self buddyIconPath]);
            [responseData writeToFile:[self buddyIconPath] atomically:YES];
        }
        
    }
}

- (NSString *)ownerName
{
    return [self.photoAttributes objectForKey:@"ownername"];
}

- (NSURL *)buddyIconURL
{
    if(![[self.photoAttributes objectForKey:@"iconserver"] intValue] > 0) {
        return nil;
    }
    
    NSString *iconURLString = [NSString stringWithFormat:@"https://farm%@.static.flickr.com/%@/buddyicons/%@.jpg",
                               [self.photoAttributes objectForKey:@"iconfarm"],
                               [self.photoAttributes objectForKey:@"iconserver"],
                               [self.photoAttributes objectForKey:@"owner"]
                               ];
    return [NSURL URLWithString:iconURLString];
}

- (NSString *)buddyIconPath
{
    return [NSString stringWithFormat:@"%@/%@.jpg",
            NSTemporaryDirectory(),
            [self.photoAttributes objectForKey:@"owner"]];
}

- (NSString *)description
{
    return [self.photoAttributes description];
}


@end
