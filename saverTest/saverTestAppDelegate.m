#import "saverTestAppDelegate.h"
#import "FlickrSavrView.h"

@interface saverTestAppDelegate ()
@property (strong) NSWindow *window;
@property (strong) ScreenSaverView *view;
- (void)redrawView;
@end

@implementation saverTestAppDelegate

@synthesize window = window_;
@synthesize view = view_;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    CGRect windowRect = CGRectMake(100, 100, 800, 800);
    self.window = [[NSWindow alloc] initWithContentRect:windowRect styleMask:NSTitledWindowMask backing:NSBackingStoreBuffered defer:NO];
    self.view = [[FlickrSavrView alloc] initWithFrame:self.view.frame isPreview:NO];
    [self.window setContentView:self.view];
    [self.window makeKeyAndOrderFront:nil];
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(redrawView) userInfo:nil repeats:YES];
}

- (void)redrawView
{
    self.view.needsDisplay = YES;
}

@end
