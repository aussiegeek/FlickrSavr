#import "FlickrSavrView.h"
#import "AFFlickrManager.h"
#import "AFFlickrPhoto.h"
#include "math.h"

@interface FlickrSavrView ()
@property (strong) AFFlickrManager *flickrManager;
- (CGRect)resizeImage:(CGImageRef)image toBounds:(CGRect)bounds;
@end

@implementation FlickrSavrView
@synthesize flickrManager = flickrManager_;

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {
        [self setAnimationTimeInterval:10];
        NSLog(@"initial frame %@", NSStringFromRect(frame));
        self.flickrManager = [[AFFlickrManager alloc] init];
    }
    return self;
}

- (void)animateOneFrame
{
    [self setNeedsDisplay:YES];
}

-(void)drawRect:(NSRect)rect
{
    AFFlickrPhoto *currentPhoto = [self.flickrManager randomPhoto];
    NSLog(@"photo attributes: %@", [self.flickrManager description]);
    NSLog(@"wanting to load photo: %@", [currentPhoto photoPath]);
    CGContextRef context = [[NSGraphicsContext currentContext] 
                                    graphicsPort];
    
    CGDataProviderRef imageDataProvider = CGDataProviderCreateWithFilename([[currentPhoto photoPath] cStringUsingEncoding:NSUTF8StringEncoding]);
    CGImageRef image = CGImageCreateWithJPEGDataProvider(imageDataProvider, NULL, NO, kCGRenderingIntentDefault);
    
    CGDataProviderRef buddyIconDataProvider = CGDataProviderCreateWithFilename([[currentPhoto buddyIconPath] cStringUsingEncoding:NSUTF8StringEncoding]);
    CGImageRef buddyImage = CGImageCreateWithJPEGDataProvider(buddyIconDataProvider, NULL, NO, kCGRenderingIntentDefault);
    
    CGRect imageRect = [self resizeImage:image toBounds:rect];
    
    CGContextSetRGBFillColor(context, 0, 0, 0, 1);
    CGContextFillRect(context, rect);
    CGContextDrawImage(context, imageRect, image);
    
    CGPoint basePoint = CGPointMake(10, 10);

    // draw buddy icon
    CGRect buddyIconRect = CGRectMake(basePoint.x, basePoint.y, CGImageGetWidth(buddyImage), CGImageGetHeight(buddyImage));
    CGContextDrawImage(context, buddyIconRect, buddyImage);
    
    NSPoint baseTextPoint = CGPointMake(basePoint.x + buddyIconRect.size.width + 5, basePoint.y);
    
    //draw from bottom up
    NSDictionary *fontAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[NSColor whiteColor], NSForegroundColorAttributeName,
                                    nil];
    //show description
    NSString *owner = [currentPhoto ownerName];
    CGSize ownerSize = [owner sizeWithAttributes:fontAttributes];
    [owner drawAtPoint:baseTextPoint withAttributes:fontAttributes];

    //show title
    CGPoint titlePoint = CGPointMake(baseTextPoint.x, baseTextPoint.y + ownerSize.height + 5);
    NSString *title = [currentPhoto title];
    //CGSize titleSize = [title sizeWithAttributes:fontAttributes];
    [title drawAtPoint:titlePoint withAttributes:fontAttributes];
    
}

- (CGRect)resizeImage:(CGImageRef)image toBounds:(CGRect)bounds
{
    float hfactor = CGImageGetWidth(image) / bounds.size.width;
    float vfactor = CGImageGetHeight(image) / bounds.size.height;
    
    float factor = MAX(hfactor, vfactor);
    
    // Divide the size by the greater of the vertical or horizontal shrinkage factor
    float newWidth = CGImageGetWidth(image) / factor;
    float newHeight = CGImageGetHeight(image) / factor;
    
    // Then figure out if you need to offset it to center vertically or horizontally
    float leftOffset = (bounds.size.width - newWidth) / 2;
    float topOffset = (bounds.size.height - newHeight) / 2;
    
    return CGRectMake(leftOffset, topOffset, newWidth, newHeight);
}
- (BOOL)hasConfigureSheet
{
    return NO;
}

- (NSWindow *)configureSheet
{
    return nil;
}

- (void)mouseUp:(NSEvent *)theEvent
{
    [self setNeedsDisplay:YES];
}
@end
