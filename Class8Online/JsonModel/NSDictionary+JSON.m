//
//  NSDictionary+JSON.h
//  IShowCatena
//
//  Created by chuliangliang on 15/4/9.
//  Copyright (c) 2015年 chuliangliang. All rights reserved.
//

#import "NSDictionary+JSON.h"

@implementation NSDictionary(JSON)

- (id)objectForKeyIgnoreNull:(id)aKey{
    id value = [self objectForKey:aKey];
    if(!value){
        return nil;
    }
    if([ value isEqual:[NSNull null]] || [ [value description]isEqualToString:@""] || [[value description] isEqualToString:@"<null>"]){
        return nil;
    }
    return value;
}
-(NSString *) stringForKey: (NSString *) key
{	
	id idObj = [self objectForKey:key];
	return (idObj && ![[idObj description] isEqualToString:@"<null>"] && ![[idObj description] isEqualToString:@"(null)"]) ? [idObj description] :@"";
}

-(int)intForKey: (NSString *) key
{	
	return (int) [self longForKey: key];

}
- (int)codeForKey:(NSString *)key
{
    if ([[self allKeys] containsObject:key]) {
        return [self intForKey:key];
    }
    return -1000;
}

-(NSArray *) arrayForKey: (NSString *) key
{	

	NSArray *aryReturn = [self objectForKey:key ];//:aryKeys notFoundMarker:[NSNull null]];
	return aryReturn;
}

-(BOOL) boolForKey: (NSString *)key
{	
	id idObj = [ self objectForKey:key];
	if(!idObj)
	{	
		return NO;
	}
	NSString *strReturn = [[idObj description] lowercaseString];
	return ([strReturn isEqualToString:@"1"] || [strReturn isEqualToString:@"true"] || [strReturn isEqualToString:@"yes"])?YES:NO;
}

-(long long) longForKey: (NSString *) key
{	
	NSString *strObj = [ self stringForKey:key];
	@try
	{	
		return [strObj longLongValue];
	}
	@
	catch (NSException *exception)
	{	
		return 0L;
	}

}

-(float) floatForKey:(NSString *)key
{
    NSString *strObj = [ self stringForKey:key];
	@try
	{
		return [strObj floatValue];
	}
	@
	catch (NSException *exception)
	{
		return 0.0f;
	}
}
-(float) doubleForKey:(NSString *)key
{
    NSString *strObj = [ self stringForKey:key];
	@try
	{
		return [strObj doubleValue];
	}
	@
	catch (NSException *exception)
	{
		return 0.0f;
	}
}
@end
