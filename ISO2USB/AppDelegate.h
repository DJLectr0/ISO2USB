//
//  AppDelegate.h
//  ISO2USB
//
//  Created by Leonardo Galli on 01.03.14.
//  Copyright (c) 2014 Leonardo Galli. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>
@property (weak) IBOutlet NSTextField *status;
@property (weak) IBOutlet NSProgressIndicator *progress;
- (IBAction)refresh:(id)sender;

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSPopUpButton *usbList;
- (IBAction)chooseISO:(id)sender;
- (IBAction)start:(id)sender;

@end
