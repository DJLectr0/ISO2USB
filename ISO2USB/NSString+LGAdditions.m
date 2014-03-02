//
//  NSString+LGAdditions.m
//  ISO2USB
//
//  Created by Leonardo Galli on 01.03.14.
//  Copyright (c) 2014 Leonardo Galli. All rights reserved.
//

#import "NSString+LGAdditions.h"

@implementation NSString (LGAdditions)
-(NSMutableArray*)stringsBetweenString:(NSString*)start andString:(NSString*)end
{
    
    NSMutableArray* strings = [NSMutableArray arrayWithCapacity:0];
    
    NSRange startRange = [self rangeOfString:start];
    
    for( ;; )
    {
        
        if (startRange.location != NSNotFound)
        {
            
            NSRange targetRange;
            
            targetRange.location = startRange.location + startRange.length;
            targetRange.length = [self length] - targetRange.location;
            
            NSRange endRange = [self rangeOfString:end options:0 range:targetRange];
            
            if (endRange.location != NSNotFound)
            {
                
                targetRange.length = endRange.location - targetRange.location;
                [strings addObject:[self substringWithRange:targetRange]];
                
                NSRange restOfString;
                
                restOfString.location = endRange.location + endRange.length;
                restOfString.length = [self length] - restOfString.location;
                
                startRange = [self rangeOfString:start options:0 range:restOfString];
                
            }
            else
            {
                break;
            }
            
        }
        else
        {
            break;
        }
        
    }
    
    return strings;
    
}
-(NSString*)stringBetweenString:(NSString*)start andString:(NSString *)end {
    NSRange startRange = [self rangeOfString:start];
    if (startRange.location != NSNotFound) {
        NSRange targetRange;
        targetRange.location = startRange.location + startRange.length;
        targetRange.length = [self length] - targetRange.location;
        NSRange endRange = [self rangeOfString:end options:0 range:targetRange];
        if (endRange.location != NSNotFound) {
            targetRange.length = endRange.location - targetRange.location;
            return [self substringWithRange:targetRange];
        }
    }
    return nil;
}
@end
