//
//  CalendarUtils.h
//  PreferenceTest
//
//  Created by Richard Dyer on 5/21/11.
//  Copyright 2011 Personal. All rights reserved.
//
#import <sqlite3.h> // Import the SQLite database framework


@interface SavedCalendar: NSObject{
    NSNumber* storeId;
    NSInteger* red;
    NSInteger* green;
    NSInteger* blue;
    NSString* title;
    NSString* accountTitle;
}
-(id)initWithValues:(NSNumber *)inId title:(NSString *)inTitle account: (NSString *) inAccount red:(NSInteger*) inRed green:(NSInteger*) inGreen blue:(NSInteger*) inBlue;
-(void)print;
@property (nonatomic, assign) NSNumber* storeId;
@property (nonatomic, assign) NSInteger* red;
@property (nonatomic, assign) NSInteger* green;
@property (nonatomic, assign) NSInteger* blue;
@property (nonatomic, copy) NSString* title;
@property (nonatomic, copy) NSString* accountTitle;
@end;

@interface CalendarUtils: NSObject{
}
+(NSMutableDictionary*) loadCalendars;
+(SavedCalendar*) loadCalendar:(NSNumber*) inID;
+(BOOL) update:(SavedCalendar*) inCal;
@end

@interface CalendarPreview: UIView{
	BOOL useMask;
	UIColor* color;
}
@property (nonatomic, retain) UIColor* color;
@property (nonatomic, assign) BOOL useMask;
@end;