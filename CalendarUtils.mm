//
//  CalendarUtils.m
//  PreferenceTest
//
//  Created by Richard Dyer on 5/21/11.
//  Copyright 2011 Personal. All rights reserved.
//

#import "CalendarUtils.h"
static NSString *databasePath = @"/private/var/mobile/Library/Calendar/Calendar.sqlitedb";
static NSString *pListPath = @"/private/var/mobile/Library/Preferences/com.apple.accountsettings.plist";

@implementation CalendarUtils
+(SavedCalendar*) loadCalendar: (NSNumber*) inID{
    SavedCalendar* calendar = nil;
    sqlite3 *database;
    if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
        //const char *sqlStatement = "select store_id,title,color_r,color_g from calendar";
        const char *sqlStatement = [[NSString stringWithFormat: @"select c.store_id,s.external_id,c.title,c.color_r,c.color_g,c.color_b from Store s,Calendar c where s.rowid=c.store_id and c.store_id=%@",inID ]  UTF8String];
        sqlite3_stmt *compiledStatement;
        if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
            // Loop through the results and add them to the feeds array
            if(sqlite3_step(compiledStatement) == SQLITE_ROW) {
                //grab the calendar name - we don't want the default calendar...
                NSString *aName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 2)];
                if(![aName isEqualToString:@"Default"]){
                    //NSLog(@"Getting CalendarID: %d\n",sqlite3_column_int(compiledStatement, 0));
                    NSNumber *storeId = [NSNumber numberWithInt:sqlite3_column_int(compiledStatement, 0)];
                    // NSLog(@"Using: %@",storeId);
                    NSInteger *red = (NSInteger*)sqlite3_column_int(compiledStatement, 3);
                    NSInteger *green = (NSInteger*)sqlite3_column_int(compiledStatement, 4);
                    NSInteger *blue = (NSInteger*)sqlite3_column_int(compiledStatement, 5);
                    calendar = [[SavedCalendar alloc] initWithValues:storeId title:aName account:nil red:red green:green blue:blue];
                }
            }
        }
        // Release the compiled statement from memory
        sqlite3_finalize(compiledStatement);
    }
    sqlite3_close(database);
    return [calendar retain];
    
}

+(NSMutableDictionary*) loadCalendars{
	NSMutableDictionary *calendars = [[NSMutableDictionary alloc] init];
	 
    NSDictionary *dictionary = [[NSDictionary alloc] initWithContentsOfFile:pListPath];
    NSDictionary *accounts = [dictionary objectForKey: @"Accounts"];
    NSMutableDictionary *idMappings= [[NSMutableDictionary alloc] init];
    //find the name for each account ID - this is just to make the display look nice;
    for(id key in accounts){
        if([key objectForKey:@"DisplayName"] && [key objectForKey:@"Identifier"]){
            [idMappings setObject:[key objectForKey:@"DisplayName"] forKey:[key objectForKey:@"Identifier"]];
        }
    }

	sqlite3 *database;
     if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
         //const char *sqlStatement = "select store_id,title,color_r,color_g from calendar";
         const char *sqlStatement = "select c.store_id,s.external_id,c.title,c.color_r,c.color_g,c.color_b from Store s,Calendar c where s.rowid=c.store_id";
         sqlite3_stmt *compiledStatement;
         if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
             // Loop through the results and add them to the feeds array
             while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
                 //grab the calendar name - we don't want the default calendar...
                 NSString *aName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 2)];
                 if(![aName isEqualToString:@"Default"]){
                     NSNumber *storeId = [NSNumber numberWithInt:sqlite3_column_int(compiledStatement, 0)];
                     NSInteger *red = (NSInteger*)sqlite3_column_int(compiledStatement, 3);
                     NSInteger *green = (NSInteger*)sqlite3_column_int(compiledStatement, 4);
                     NSInteger *blue = (NSInteger*)sqlite3_column_int(compiledStatement, 5);
                     NSString *cId = nil;
					 NSString *account = nil;
                     if(sqlite3_column_text(compiledStatement, 1))
                        cId = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)];
                     if(cId){
                         if([idMappings objectForKey:cId])
                            account = [idMappings objectForKey:cId];
                     }
					if(!account)
						account=@"Other";
                     SavedCalendar* calendar = [[SavedCalendar alloc] initWithValues:storeId title:aName account:account red:red green:green blue:blue];
					if([calendars objectForKey:account]){
						[(NSMutableArray*)[calendars objectForKey: account] addObject: calendar];
					}else{
						NSMutableArray* acctCalendars = [[NSMutableArray alloc] init];
						[acctCalendars addObject: calendar];
						[calendars setObject: acctCalendars forKey:account];
					} 
					/*if(cId){
						 [calendars setObject:calendar forKey:@"cId"]
                         [calendars addObject: calendar];
                     }else{
                         [otherCalendars addObject: calendar];
                     }*/
                 }
             }
         }
         // Release the compiled statement from memory
         sqlite3_finalize(compiledStatement);
     }
     sqlite3_close(database);
	[idMappings release];
	[dictionary release];
	return [calendars retain];
}
+(BOOL) update:(SavedCalendar*) inCal{
    sqlite3 *database;
	sqlite3_stmt *update_statement;
    
	NSString *sqlStr = [NSString stringWithFormat:@"UPDATE calendar SET color_r='%d', color_g='%d', color_b='%d' WHERE store_id='%@'",[inCal red],[inCal green],[inCal blue],[inCal storeId]];
	//NSLog(@"UPDATE: %@\n",sqlStr);
	const char *sql = [sqlStr UTF8String];
	if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
		if (sqlite3_prepare_v2(database, sql, -1, &update_statement, NULL) != SQLITE_OK) {
			//printf("Serious Problem!\n");
			return NO;
		}
		int success = sqlite3_step(update_statement);	
		if (success == SQLITE_ERROR) {
			//printf("Update Error\n");
			return NO;
		}
		sqlite3_finalize(update_statement);
		//printf("Successfully Updated Database\n");
	}
	sqlite3_close(database);
    return YES;

}
@end

@implementation SavedCalendar
@synthesize title,storeId,accountTitle,red,green,blue;
-(id)initWithValues:(NSNumber *)inId title:(NSString *)inTitle account: (NSString *) inAccount red:(NSInteger*) inRed green:(NSInteger*) inGreen blue:(NSInteger*) inBlue{
    if((self = [super init])){
        [self setStoreId:inId];
        [self setTitle:inTitle];
        [self setRed:(inRed>0?inRed:0)];
        [self setBlue:(inBlue>0?inBlue:0)];
        [self setGreen:(inGreen>0?inGreen:0)];
        [self setAccountTitle:inAccount];
    }
    return self;
}
-(void)print{
    NSLog(@"Calendar: %@\n",[self storeId]);
    NSLog(@" Name: %@\n",[self  title]);
    NSLog(@" Color: (%d,%d,%d)\n",[self red],[self green], [self blue]);
}
@end

@implementation CalendarPreview
@synthesize color;
@synthesize useMask;
- (id)initWithFrame:(CGRect)frame {

	self = [super initWithFrame:frame];
	if (self) {
		[self setBackgroundColor: [UIColor whiteColor]];
		self.useMask = false;
	}
	return self;
}

-(void)drawRect:(CGRect) rect{
	[super drawRect:rect];
	//Create circle and fill it in
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGContextSaveGState(ctx);
	if([self useMask]){
		CGImageRef alphaMask = [[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/CalendarColors.bundle/dotmask.png"] CGImage];
		CGContextClipToMask(ctx, rect, alphaMask);
	}
	CGContextBeginPath(ctx);
	CGContextAddArc(ctx, 6, 6.0, 6.0, 0, 2*M_PI, 0);
	CGContextSetFillColorWithColor(ctx, [color CGColor]);
	CGContextFillPath(ctx);
	CGContextRestoreGState(ctx);
	//CGImageRelease(alphaMask);


}

- (void)dealloc
{
	if(color){
		[color release];
	}
	[super dealloc];
}
@end
