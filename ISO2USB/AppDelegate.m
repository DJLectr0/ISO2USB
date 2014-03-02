//
//  AppDelegate.m
//  ISO2USB
//
//  Created by Leonardo Galli on 01.03.14.
//  Copyright (c) 2014 Leonardo Galli. All rights reserved.
//

#import "AppDelegate.h"
#import "NSString+LGAdditions.h"


@implementation AppDelegate
NSString* path;
 NSString *string;
NSUInteger devdiskn;
NSTimer *timer;
bool firsttime;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [_status setStringValue:@""];
    [_progress setIndeterminate:NO];
    [_progress setMinValue:0.0];
    [_progress setMaxValue:100.0];
    [_progress setDoubleValue:0.0];
   
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(taskFinished:) name:@"com.taskfinished"object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(taskFinished2:) name:@"com.taskfinished2"object:nil];
       // Insert code here to initialize your application
    NSTask *task;
    task = [[NSTask alloc] init];
    [task setLaunchPath: @"/usr/sbin/diskutil"];
    
    NSArray *arguments;
    arguments = [NSArray arrayWithObjects: @"list", nil];
    [task setArguments: arguments];
    
    NSPipe *pipe;
    pipe = [NSPipe pipe];
    [task setStandardOutput: pipe];
    
    [task setStandardInput:[NSPipe pipe]];
    
    NSFileHandle *file;
    file = [pipe fileHandleForReading];
    
    [task launch];
    
    NSData *data;
    data = [file readDataToEndOfFile];
    
   
    string = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    NSLog (@"grep returned:\n%@", string);
    NSArray *AllVolumes= [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/Volumes" error:nil];
    for (NSString *theString in AllVolumes) {
        NSLog(@"YOYO: %@",theString);
        [_usbList addItemWithTitle:theString];
    }
    


}
-(void)taskFinished2:(NSNotification *)notif{
 NSLog(@"so2: %@",notif.object);
    [timer invalidate];
    timer = nil;
    NSTask *task;
    task = [[NSTask alloc] init];
    [task setLaunchPath: @"/usr/sbin/diskutil"];
    
    NSArray *arguments;
    arguments = [NSArray arrayWithObjects: @"eject", [NSString stringWithFormat:@"/dev/disk%lu",(unsigned long)devdiskn], nil];
    [task setArguments: arguments];
    [task launch];
     [_progress incrementBy:30];
    [_status setStringValue:@"Done. You now can boot into your stick"];
}
-(void)taskFinished:(NSNotification *)notif{
    NSLog(@"so: %@",notif.object);
     [_progress incrementBy:30];
    NSTask *task;
    task = [[NSTask alloc] init];
    [task setLaunchPath: @"/bin/mv"];
    
    NSArray *arguments;
    arguments = [NSArray arrayWithObjects: [NSString stringWithFormat:@"%@/test.img.dmg",(NSString*)NSHomeDirectory()],[NSString stringWithFormat:@"%@/test.img",(NSString*)NSHomeDirectory()], nil];
    [task setArguments: arguments];
    
    NSPipe *pipe;
    pipe = [NSPipe pipe];
    [task setStandardOutput: pipe];
    
    [task setStandardInput:[NSPipe pipe]];
    
    NSFileHandle *file;
    file = [pipe fileHandleForReading];
    
    [task launch];
    
    NSData *data;
    data = [file readDataToEndOfFile];
     [_progress incrementBy:10];
    NSMutableArray* disks =  [string stringsBetweenString:@"dev/disk" andString:@"/"];
    NSUInteger i = 0;
    //find /dev/diskN to unmount
   devdiskn = -1;
    for (NSString *disk in disks) {
        NSLog(@"OK: %@", disk);
        NSString *disk11 = _usbList.selectedItem.title;
        if (_usbList.selectedItem.title.length >= 10) {
            
        
        disk11 = [_usbList.selectedItem.title substringToIndex:10];
        }
        if ([disk rangeOfString:disk11].location!=NSNotFound) {
            NSTask *task2;
            task2 = [[NSTask alloc] init];
            [task2 setLaunchPath: @"/usr/sbin/diskutil"];
            
            NSArray *arguments2;
            arguments2 = [NSArray arrayWithObjects: @"unmountDisk",[NSString stringWithFormat:@"/dev/disk%lu",(unsigned long)i], nil];
            [task2 setArguments: arguments2];
            
            [task2 launch];
            devdiskn = i;
            NSLog(@"JUP");
        }
        i++;
    }
    NSString *lastDisk = [string stringBetweenString:[NSString stringWithFormat:@"/dev/disk%lu",(unsigned long)disks.count] andString:@"disks"];
    NSLog(@"OP: %@",lastDisk)
    ;
    NSString *disk11 = _usbList.selectedItem.title;
    if (_usbList.selectedItem.title.length >= 10) {
        
        
        disk11 = [_usbList.selectedItem.title substringToIndex:10];
    }
    
    if ([lastDisk rangeOfString:disk11].location!=NSNotFound) {
        NSTask *task2;
        task2 = [[NSTask alloc] init];
        [task2 setLaunchPath: @"/usr/sbin/diskutil"];
        
        NSArray *arguments2;
        arguments2 = [NSArray arrayWithObjects: @"unmountDisk",[NSString stringWithFormat:@"/dev/disk%lu",(unsigned long)disks.count], nil];
        [task2 setArguments: arguments2];
        devdiskn = disks.count;
        [task2 launch];
        [task2 waitUntilExit];
        NSLog(@"JUP");
    }
     [_progress incrementBy:20];
    NSArray *arguments3;
    arguments3 = [NSArray arrayWithObjects: [NSString stringWithFormat:@"if=%@/test.img",(NSString*)NSHomeDirectory()], [NSString stringWithFormat:@"of=/dev/disk%lu",(unsigned long)devdiskn],@"bs=1m", [NSString stringWithFormat:@"2>&1 | tee %@/iso2usb.log",(NSString*)NSHomeDirectory()], nil];
    NSLog(@"JO: %@",[NSString stringWithFormat:@"%@/test.img",(NSString*)NSHomeDirectory()]);
    NSLog(@"ups: %lu,%lu",(unsigned long)devdiskn,(unsigned long)disks.count);
    
    NSString *iso2imgout2 = @"";
    NSString *error2 = @"";
    
    [_status setStringValue:[NSString stringWithFormat:@"Replacing contents of \"%@\" with contents of ISO",_usbList.selectedItem.title]];
    // Create authorization reference
    [self runProcessAsAdministrator:@"/bin/dd" withArguments:arguments3 output:&iso2imgout2 errorDescription:&error2 number:2];
    firsttime = true;
  timer =  [NSTimer scheduledTimerWithTimeInterval:30.0
                                     target:self
                                   selector:@selector(updateText:)
                                   userInfo:nil
                                    repeats:YES];

    
}
-(void)updateText:(NSTimer *)theTimer{
    NSLog(@"jaja");
    if (firsttime == true) {
        firsttime = false;
    }else{
    NSArray *arguments4;
    arguments4 = [NSArray arrayWithObjects: @"-SIGINFO",@"$(pgrep ^dd)", nil];
    NSLog(@"JO: %@",[NSString stringWithFormat:@"%@/test.img",(NSString*)NSHomeDirectory()]);
    
    
    NSString *iso2imgout3 = @"";
    NSString *error3 = @"";
    [self runProcessAsAdministratorSync:@"/bin/kill" withArguments:arguments4 output:&iso2imgout3 errorDescription:&error3];
        NSLog(@"LOLOL: %@",iso2imgout3);
    unsigned long long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil] fileSize];
    NSString *logString = [NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@/iso2usb.log",(NSString*)NSHomeDirectory()] encoding:NSUTF8StringEncoding error:nil];
    NSArray *bytesperseca = [logString stringsBetweenString:@"(" andString:@" bytes/"];
    NSArray *bytesa = [logString stringsBetweenString:@"out\n" andString:@" bytes t"];
    NSString *bytespersec = [bytesperseca lastObject];
    NSString *bytes = [bytesa lastObject];
    NSLog(@"%@ :AHA: %@",bytes,bytespersec);
    int sizeremaining = (int)fileSize - [bytes intValue];
    int timeremaining = sizeremaining/[bytespersec intValue];
    NSLog(@"Time remaining: %i",timeremaining);
    [@"" writeToFile:[NSString stringWithFormat:@"%@/iso2usb.log",(NSString*)NSHomeDirectory()] atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
}
- (BOOL) runProcessAsAdministratorSync:(NSString*)scriptPath
                     withArguments:(NSArray *)arguments
                            output:(NSString **)output
                  errorDescription:(NSString **)errorDescription {
    
    NSString * allArgs = [arguments componentsJoinedByString:@" "];
    NSString * fullScript = [NSString stringWithFormat:@"%@ %@", scriptPath, allArgs];
    
    NSDictionary *errorInfo = [NSDictionary new];
    NSString *script =  [NSString stringWithFormat:@"do shell script \"%@\" with administrator privileges", fullScript];
    
    NSAppleScript *appleScript = [[NSAppleScript new] initWithSource:script];
    NSAppleEventDescriptor * eventResult = [appleScript executeAndReturnError:&errorInfo];
    
    // Check errorInfo
    if (! eventResult)
    {
        // Describe common errors
        *errorDescription = nil;
        if ([errorInfo valueForKey:NSAppleScriptErrorNumber])
        {
            NSNumber * errorNumber = (NSNumber *)[errorInfo valueForKey:NSAppleScriptErrorNumber];
            if ([errorNumber intValue] == -128)
                *errorDescription = @"The administrator password is required to do this.";
        }
        
        // Set error message from provided message
        if (*errorDescription == nil)
        {
            if ([errorInfo valueForKey:NSAppleScriptErrorMessage])
                *errorDescription =  (NSString *)[errorInfo valueForKey:NSAppleScriptErrorMessage];
        }
        
        return NO;
    }
    else
    {
        // Set output to the AppleScript's output
        *output = [eventResult stringValue];
        
        return YES;
    }
}
- (IBAction)chooseISO:(id)sender {
    //this gives you a copy of an open file dialogue
    NSOpenPanel* openPanel = [NSOpenPanel openPanel];
    
    //set the title of the dialogue window
    openPanel.title = @"Choose an ISO image";
    
    //shoud the user be able to resize the window?
    openPanel.showsResizeIndicator = YES;
    
    //should the user see hidden files (for user apps - usually no)
    openPanel.showsHiddenFiles = NO;
    
    //can the user select a directory?
    openPanel.canChooseDirectories = NO;
    
    //can the user create directories while using the dialogue?
    openPanel.canCreateDirectories = YES;
    
    //should the user be able to select multiple files?
    openPanel.allowsMultipleSelection = NO;
    
    //an array of file extensions to filter the file list
    openPanel.allowedFileTypes = @[@"iso"];
    
    //this launches the dialogue
    [openPanel beginSheetModalForWindow:self.window
                      completionHandler:^(NSInteger result) {
                          
                          //if the result is NSOKButton
                          //the user selected a file
                          if (result==NSOKButton) {
                              
                              //get the selected file URLs
                              NSURL *selection = openPanel.URLs[0];
                              
                              //finally store the selected file path as a string
                              path = [[selection path] stringByResolvingSymlinksInPath];
                              
                              //here add yuor own code to open the file
                              
                          }
                          
                      }];
    
}
- (BOOL) runProcessAsAdministrator:(NSString*)scriptPath
                     withArguments:(NSArray *)arguments
                            output:(NSString **)output
                  errorDescription:(NSString **)errorDescription
                            number:(int)num{
    
    NSString * allArgs = [arguments componentsJoinedByString:@" "];
    NSString * fullScript = [NSString stringWithFormat:@"'%@' %@", scriptPath, allArgs];
    
   __block NSDictionary *errorInfo = [NSDictionary new];
    NSString *script =  [NSString stringWithFormat:@"do shell script \"%@\" with administrator privileges", fullScript];
    
    NSAppleScript *appleScript = [[NSAppleScript new] initWithSource:script];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"AHA: %i",num);
          NSAppleEventDescriptor * eventResult = [appleScript executeAndReturnError:&errorInfo];
        //download data here or perform long running task here
         NSLog(@"AHA2");
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //refresh user interface here
           NSLog(@"AHA3");
            
            // Check errorInfo
            if (! eventResult)
            {
                // Describe common errors
                *errorDescription = nil;
                if ([errorInfo valueForKey:NSAppleScriptErrorNumber])
                {
                    NSNumber * errorNumber = (NSNumber *)[errorInfo valueForKey:NSAppleScriptErrorNumber];
                    if ([errorNumber intValue] == -128)
                        *errorDescription = @"The administrator password is required to do this.";
                }
                
                // Set error message from provided message
                if (*errorDescription == nil)
                {
                    if ([errorInfo valueForKey:NSAppleScriptErrorMessage])
                        *errorDescription =  (NSString *)[errorInfo valueForKey:NSAppleScriptErrorMessage];
                }
                
               // return NO;
            }
            else
            {
                // Set output to the AppleScript's output
                *output = [eventResult stringValue];
                
                //return YES;
            }
            if (num==1) {
                
            
            [[NSNotificationCenter defaultCenter]postNotificationName:@"com.taskfinished" object:[eventResult stringValue]];
            }else if (num==2){
            [[NSNotificationCenter defaultCenter]postNotificationName:@"com.taskfinished2" object:[eventResult stringValue]];
            }
            NSLog(@"LOL: %@",[eventResult stringValue]);

            
        });
        
    });
    return YES;
}
- (IBAction)start:(id)sender {
    if (path==nil) {
        NSAlert *alert = [NSAlert alertWithMessageText:@"Error" defaultButton:@"OK" alternateButton:Nil otherButton:nil informativeTextWithFormat:@"Please choose an ISO image to start!"];
        [alert runModal];
    }
    [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@/test.img",(NSString*)NSHomeDirectory()] error:nil];
    //Convert ISO to img:
     [_status setStringValue:@"Converting ISO to IMG"];
    NSArray *arguments;
    arguments = [NSArray arrayWithObjects: @"convert",@"-format",@"UDRW",@"-o",[NSString stringWithFormat:@"%@/test.img",(NSString*)NSHomeDirectory()],path, nil];
    NSLog(@"JO: %@",[NSString stringWithFormat:@"%@/test.img",(NSString*)NSHomeDirectory()]);
   
   
    NSString *iso2imgout = @"";
    NSString *error = @"";
     [_progress incrementBy:10];
   
    // Create authorization reference
    [self runProcessAsAdministrator:@"/usr/bin/hdiutil" withArguments:arguments output:&iso2imgout errorDescription:&error number:1];
    /*
    NSLog(@"HAHA: %@",path);
    NSTask *task;
    task = [[NSTask alloc] init];
    [task setLaunchPath: @"/usr/bin/hdiutil"];
    
    NSArray *arguments;
    arguments = [NSArray arrayWithObjects: @"convert",@"-format",@"UDRW",@"-o",[NSString stringWithFormat:@"%@test.img",(NSString*)NSHomeDirectory()],path, nil];
    NSLog(@"JO: %@",[NSString stringWithFormat:@"%@/test.img",(NSString*)NSHomeDirectory()]);
    [task setArguments: arguments];
    
    NSPipe *pipe;
    pipe = [NSPipe pipe];
    [task setStandardOutput: pipe];
    
    [task setStandardInput:[NSPipe pipe]];
    
    NSFileHandle *file;
    file = [pipe fileHandleForReading];
    
    [task launch];
*/
    
 }
- (IBAction)refresh:(id)sender {
    [_usbList removeAllItems];
    NSTask *task;
    task = [[NSTask alloc] init];
    [task setLaunchPath: @"/usr/sbin/diskutil"];
    
    NSArray *arguments;
    arguments = [NSArray arrayWithObjects: @"list", nil];
    [task setArguments: arguments];
    
    NSPipe *pipe;
    pipe = [NSPipe pipe];
    [task setStandardOutput: pipe];
    
    [task setStandardInput:[NSPipe pipe]];
    
    NSFileHandle *file;
    file = [pipe fileHandleForReading];
    
    [task launch];
    
    NSData *data;
    data = [file readDataToEndOfFile];
    
    
    string = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    NSLog (@"grep returned:\n%@", string);
    NSArray *AllVolumes= [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/Volumes" error:nil];
    for (NSString *theString in AllVolumes) {
        NSLog(@"YOYO: %@",theString);
        [_usbList addItemWithTitle:theString];
    }

}
@end
