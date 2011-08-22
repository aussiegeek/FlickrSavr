#import "FlickrSavrView.h"
#import "AFFlickrManager.h"
#import "AFFlickrPhoto.h"
#include "math.h"

@interface FlickrSavrView ()
@property (strong) AFFlickrManager *flickrManager;
- (CGRect)resizeImage:(CGImageRef)image toBounds:(CGRect)bounds;
- (void)drawPhotoInfo:(AFFlickrPhoto *)photo;
- (void)drawRoundedRect:(CGRect)rect radius:(CGFloat)radius color:(CGColorRef)color inset:(CGFloat)inset;
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
    
    CGRect imageRect = [self resizeImage:image toBounds:rect];
    
    CGContextSetRGBFillColor(context, 0, 0, 0, 1);
    CGContextFillRect(context, rect);
    CGContextDrawImage(context, imageRect, image);
    
    [self drawPhotoInfo:currentPhoto];
}

- (void)drawPhotoInfo:(AFFlickrPhoto *)photo
{
    CGPoint basePoint = CGPointMake(10, 10);
    CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];

    // draw buddy icon
    CGDataProviderRef buddyIconDataProvider = CGDataProviderCreateWithFilename([[photo buddyIconPath] cStringUsingEncoding:NSUTF8StringEncoding]);
    CGImageRef buddyImage = CGImageCreateWithJPEGDataProvider(buddyIconDataProvider, NULL, NO, kCGRenderingIntentDefault);

    CGRect buddyIconRect = CGRectMake(basePoint.x, basePoint.y, CGImageGetWidth(buddyImage), CGImageGetHeight(buddyImage));
    CGContextDrawImage(context, buddyIconRect, buddyImage);
    
    NSPoint ownerPoint = CGPointMake(basePoint.x + buddyIconRect.size.width + 5, basePoint.y);
    
    NSDictionary *fontAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[NSColor whiteColor], NSForegroundColorAttributeName,
                                    nil];
    NSString *owner = [photo ownerName];
    CGSize ownerSize = [owner sizeWithAttributes:fontAttributes];
    
    CGPoint titlePoint = CGPointMake(ownerPoint.x, ownerPoint.y + ownerSize.height + 5);
    NSString *title = [photo title];
    CGSize titleSize = [title sizeWithAttributes:fontAttributes];


    // draw rounded rect
    CGRect ownerRect = CGRectMake(ownerPoint.x, titlePoint.y, ownerPoint.x + ownerSize.width, ownerPoint.y+ ownerSize.height);
    CGRect titleRect = CGRectMake(titlePoint.x, titlePoint.y, titlePoint.x + titleSize.width, titlePoint.y + titleSize.height);
    CGRect stringRect = CGRectUnion(ownerRect, titleRect);
    //CGRect roundedRect = CGRectUnion(buddyIconRect, stringRect);
    CGRect roundedRect = CGRectMake(basePoint.x, basePoint.y, ownerPoint.x + MAX(ownerSize.width, titleSize.width), basePoint.y + buddyIconRect.size.height);
    
    NSLog(@"\nowner %@\ntitle %@\nstring %@\nrounded %@", NSStringFromRect(ownerRect), NSStringFromRect(titleRect), NSStringFromRect(stringRect), NSStringFromRect(roundedRect));
    
    CGColorRef color = CGColorCreateGenericRGB(0.2, 0.2, 0.2, 0.5);
    [self drawRoundedRect:roundedRect radius:5 color:color inset:5];
    
    // now we have calculated text sizes write the text out
    [owner drawAtPoint:ownerPoint withAttributes:fontAttributes];
    [title drawAtPoint:titlePoint withAttributes:fontAttributes];

}

- (void)drawRoundedRect:(CGRect)rect radius:(CGFloat)radius color:(CGColorRef)color inset:(CGFloat)inset
{
    CGRect insetRect = CGRectInset(rect, 0 - inset, 0 - inset);
    CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
    CGContextSetFillColorWithColor(context, color);
    
    CGContextMoveToPoint(context, insetRect.origin.x, insetRect.origin.y + radius);
    CGContextAddLineToPoint(context, insetRect.origin.x, insetRect.origin.y + insetRect.size.height - radius);
    CGContextAddArc(context, insetRect.origin.x + radius, insetRect.origin.y + insetRect.size.height - radius, 
                    radius, M_PI, M_PI / 2, 1); //STS fixed
    CGContextAddLineToPoint(context, insetRect.origin.x + insetRect.size.width - radius, 
                            insetRect.origin.y + insetRect.size.height);
    CGContextAddArc(context, insetRect.origin.x + insetRect.size.width - radius, 
                    insetRect.origin.y + insetRect.size.height - radius, radius, M_PI / 2, 0.0f, 1);
    CGContextAddLineToPoint(context, insetRect.origin.x + insetRect.size.width, insetRect.origin.y + radius);
    CGContextAddArc(context, insetRect.origin.x + insetRect.size.width - radius, insetRect.origin.y + radius, 
                    radius, 0.0f, -M_PI / 2, 1);
    CGContextAddLineToPoint(context, insetRect.origin.x + radius, insetRect.origin.y);
    CGContextAddArc(context, insetRect.origin.x + radius, insetRect.origin.y + radius, radius, 
                    -M_PI / 2, M_PI, 1);
    CGContextFillPath(context);
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
