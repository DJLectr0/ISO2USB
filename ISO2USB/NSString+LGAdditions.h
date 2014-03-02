//
//  NSString+LGAdditions.h
//  ISO2USB
//
//  Created by Leonardo Galli on 01.03.14.
//  Copyright (c) 2014 Leonardo Galli. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (LGAdditions)
-(NSMutableArray*)stringsBetweenString:(NSString*)start andString:(NSString*)end;
-(NSString*)stringBetweenString:(NSString*)start andString:(NSString*)end;
@end
