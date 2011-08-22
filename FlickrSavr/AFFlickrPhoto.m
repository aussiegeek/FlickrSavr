#import "AFFlickrPhoto.h"
#import "ASIHTTPRequest.h"

@interface AFFlickrPhoto ()
@property (strong) NSMutableDictionary *photoAttributes;
@end

@implementation AFFlickrPhoto
AF_SYNTHESIZE(photoAttributes);

- (void)dealloc
{
    AF_RELEASE(photoAttributes);
    
    [super dealloc];
}

- (id)initWithDictionary:(NSDictionary *)dict
{
    if((self = [super init])) {
        self.photoAttributes = [NSMutableDictionary dictionaryWithDictionary:dict];
    }
    
    return self;
}

- (NSURL *)url
{
    NSString *urlString = [NSString stringWithFormat:@"http://farm%@.static.flickr.com/%@/%@_%@_b.jpg", 
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
    return [NSString stringWithFormat:@"/%@_%@_b.jpg", 
            NSTemporaryDirectory(),
            [self.photoAttributes objectForKey:@"id"],
            [self.photoAttributes objectForKey:@"secret"]];
}

- (void)downloadPhotoWithCompletionBlock:(ASIBasicBlock)completionBlock
{
    NSString *fileName = [self photoPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:fileName]) {
        // file already exists, so just run completion block
        completionBlock();
    } else {
        __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[self url]];
        [request setDownloadDestinationPath:fileName];
        [request setCompletionBlock:^{
            if(![request error]) {
                completionBlock();
            }
        }];
        [request startAsynchronous];
    };
    
    
    NSString *iconFileName = [self buddyIconPath];
    if(![fileManager fileExistsAtPath:iconFileName]) {
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[self buddyIconURL]];
        [request setDownloadDestinationPath:iconFileName];
        [request startAsynchronous];
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
    
    NSString *iconURLString = [NSString stringWithFormat:@"http://farm%@.static.flickr.com/%@/buddyicons/%@.jpg",
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
