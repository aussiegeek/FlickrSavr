//
//  main.m
//  saverTest
//
//  Created by Alan Harper on 20/08/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "saverTestAppDelegate.h"

int main(int argc, char *argv[])
{
    [NSApplication sharedApplication];
    [NSApplication sharedApplication].delegate = [[saverTestAppDelegate alloc] init];
    [NSApp run];
    //return NSApplicationMain(argc, (const char **)argv);
}
