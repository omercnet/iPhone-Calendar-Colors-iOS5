/* 
 * View controller for the actual settings - this is what actually creates the list of calendars
 * and then sets up the list
 */

#import <Preferences/Preferences.h>
#import <UIKit/UIAlert.h>
#import <sqlite3.h> // Import the SQLite database framework
#import "CalendarUtils.h"


@interface PSViewController (OS32)
@property (nonatomic, retain) UIView *view;
- (void)viewDidLoad;
@end

@interface UIDevice (OS32)
- (BOOL)isWildcat;
@end

@interface CalendarColorsListController: PSListController {
	NSMutableDictionary* calendarMappings;
}
-(SavedCalendar*) currentlySelectedCalendar;
-(void) buildSpecifierForCalendarNamed: (NSString*) title items: (NSMutableArray*)items specifiers: (NSMutableArray*) inSpecs section:(NSInteger) inSection;
@end




@interface CalendarColorPSViewController : PSViewController <UITableViewDelegate, UITableViewDataSource> {
    UIView *_wrapperView;   // for < 3.2
    UITableView *tableView;
	UILabel* redLabel; UILabel* greenLabel; UILabel* blueLabel;
	UISlider* redSlider; UISlider* greenSlider; UISlider* blueSlider;
	SavedCalendar* calendar;
	CalendarPreview* preview;
    BOOL initialized;
}
@property (nonatomic,retain) SavedCalendar* calendar;
@property (nonatomic,retain) CalendarPreview* calPreview;
@property (nonatomic,retain) CalendarPreview* liPreview;
@property (nonatomic,retain) UILabel* redLabel;
@property (nonatomic,retain) UILabel* greenLabel;
@property (nonatomic,retain) UILabel* blueLabel;
@property (nonatomic,retain) UISlider* redSlider;
@property (nonatomic,retain) UISlider* greenSlider;
@property (nonatomic,retain) UISlider* blueSlider;
@end

@implementation CalendarColorPSViewController
@synthesize redLabel,greenLabel,blueLabel;
@synthesize redSlider,blueSlider,greenSlider;
@synthesize calendar;
@synthesize calPreview,liPreview;
- (id)initForContentSize:(CGSize)size
{
    NSLog(@"initForContentSize");
    initialized = NO;
        if ([PSViewController instancesRespondToSelector:@selector(initForContentSize:)]) {
                if ((self = [super initForContentSize:size])) {
                        CGRect frame;
                        frame.origin.x = 0.0f;
                        frame.origin.y = 0.0f;
                        frame.size = size;
                        _wrapperView = [[UIView alloc] initWithFrame:frame];
                }
                return self;
        }

        return [super init];
}

- (void)dealloc
{
    NSLog(@"Deallocating");
	if(initialized){
    	tableView.dataSource = nil;
    	tableView.delegate   = nil;
    	[tableView release];
    	[_wrapperView release];
		[calPreview release];
		[liPreview release];
	}
    initialized = NO;
	NSLog(@"Deallocation Complete");
	[super dealloc];
}
 
- (UIView *)view
{
	return [super view] ? [super view] : _wrapperView;
}

-(void)myInit{
    if (initialized) return;
    NSLog(@"Initializing");
	calendar = [(CalendarColorsListController*)[super parentController] currentlySelectedCalendar];
	if(!calendar){
		NSLog(@"Parent: %@" ,[super parentController]);
		[[super parentController] reload];
		calendar = [(CalendarColorsListController*)[super parentController] currentlySelectedCalendar];
	}
	
	NSLog(@"Loading Calendar: %@",calendar);
	((UINavigationItem*)[super navigationItem]).title = [calendar title];
    UIView *view = [self view];
	for (UIView *subView in [self.view subviews]) {
	    [subView removeFromSuperview];
	}
    tableView = [[UITableView alloc] initWithFrame:view.bounds style:UITableViewStyleGrouped];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    tableView.dataSource = self;
    tableView.delegate   = self;

    [view addSubview:tableView];
    initialized = YES;
	NSLog(@"Initialization Complete");
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
	/*[tableView reloadData];*/
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch(section){
		case 0:
			return 2;
		case 1:
			return 3;
	}
	return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch(section){
		case 0:
			return @"Color Preview";
		case 1:
			return @"Color Values";
	}
	return nil;
}
-(void)sliderAction:(UISlider*)sender
{
	UILabel* tempLabel = nil;
	if(sender == redSlider){
		tempLabel = redLabel;
		[[self calendar] setRed:(NSInteger*)lroundf(sender.value)];
	}else if (sender == blueSlider){
		tempLabel=blueLabel;
		[[self calendar] setBlue:(NSInteger*)lroundf(sender.value)];
	}else if(sender == greenSlider){
		tempLabel=greenLabel;
		[[self calendar] setGreen:(NSInteger*)lroundf(sender.value)];
	}
	if(tempLabel){
		tempLabel.text = [NSString stringWithFormat:@"%d", (NSInteger*)lroundf(sender.value)];
		[CalendarUtils update:[self calendar]];	
		[calPreview setColor: [UIColor colorWithRed:(int)[[self calendar] red]/255.0 green:(int)[[self calendar] green]/255.0 blue:(int)[[self calendar] blue]/255.0 alpha:1.0]];
		[calPreview setNeedsDisplay];
		[liPreview setColor: [UIColor colorWithRed:(int)[[self calendar] red]/255.0 green:(int)[[self calendar] green]/255.0 blue:(int)[[self calendar] blue]/255.0 alpha:1.0]];
		[liPreview setNeedsDisplay];
	}
}
/*
	TODO : Change this code so that it correctly allocates the data and not reads elements on each draw
*/
- (UITableViewCell *)tableView:(UITableView *)inTable cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 
	static NSString *CellIdentifier = @"Cell";
 
	UITableViewCell *cell = [inTable dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}else{
		//need to correctly resize the elements
	}
	UIImageView* myImage;
	NSString *deviceType = [UIDevice currentDevice].model;
	int rightPadding = 0;
	int sliderPadding = 0;
	int widthPadding=0;
	if([deviceType isEqualToString:@"iPad"]){
		if([[UIApplication sharedApplication] statusBarOrientation] != UIInterfaceOrientationPortrait){
			rightPadding=370;
			widthPadding = 330;
			sliderPadding = 40;
		}else{
			rightPadding = 120;
			sliderPadding = 20;
			widthPadding = 100;
		}
	}
	switch(indexPath.section){
		case 0:
			switch(indexPath.row){
				case 0:
					myImage = [[UIImageView alloc] initWithFrame:CGRectMake(285+rightPadding,17,12,12)];
					[myImage setImage:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/CalendarColors.bundle/calmask.png"]];
					myImage.opaque = YES; 
					cell.textLabel.text = @"Calendar Color";
					/*cell.detailTextLabel.text=@"Tester";*/
					calPreview = [[CalendarPreview alloc ] initWithFrame:CGRectMake(285+rightPadding,17,12,12)];
					[calPreview setColor: [UIColor colorWithRed:(int)[[self calendar] red]/255.0 green:(int)[[self calendar] green]/255.0 blue:(int)[[self calendar] blue]/255.0 alpha:1.0]];
					[cell addSubview: calPreview ];
					[cell addSubview:myImage];
					[myImage release];
				break;
				case 1:
					myImage = [[UIImageView alloc] initWithFrame:CGRectMake(285+rightPadding,17,12,12)];
					[myImage setImage:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/CalendarColors.bundle/dotmask.png"]];
					myImage.opaque = YES; 
					cell.textLabel.text = @"LockInfo Color";
					liPreview = [[CalendarPreview alloc ] initWithFrame:CGRectMake(285+rightPadding,17,12,12)];
					[liPreview setColor: [UIColor colorWithRed:(int)[[self calendar] red]/255.0 green:(int)[[self calendar] green]/255.0 blue:(int)[[self calendar] blue]/255.0 alpha:1.0]];
					//[liPreview setUseMask: true];
					[cell addSubview: liPreview ];
					[cell addSubview:myImage];
					[myImage release];
				break;
			}
			break;
		case 1:
			NSInteger sliderValue = nil;
			UISlider *tempSlider = [ [ UISlider alloc ] initWithFrame: CGRectMake(80+sliderPadding, -3, 175+widthPadding, 50) ];
		 	tempSlider.minimumValue = 0.0;
		 	tempSlider.maximumValue = 255.0;
		 	tempSlider.tag = 0;
		 	
		 	tempSlider.continuous = YES;
		 	[tempSlider addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];

			UILabel* tempLabel = [[UILabel alloc] initWithFrame: CGRectMake(265+rightPadding,10,30,30)];
			tempLabel.backgroundColor = [UIColor clearColor];
			tempLabel.textAlignment = UITextAlignmentRight;
			
			NSString* cellValue = nil;
			switch(indexPath.row){
				case 0:
					cellValue=@"Red";
					redLabel = tempLabel;
					redSlider = tempSlider;
					sliderValue = (int)[[self calendar] red];
					break;
				case 1:
					cellValue=@"Green";
					greenSlider = tempSlider;
					greenLabel = tempLabel;
					sliderValue = (int)[[self calendar] green];
					break;
				case 2:
					cellValue=@"Blue";
					blueSlider = tempSlider;
					blueLabel = tempLabel;
					sliderValue = (int)[[self calendar] blue];
					break;
			}
			sliderValue = sliderValue<0?0:sliderValue;
			tempSlider.value = sliderValue;
			tempLabel.text = [NSString stringWithFormat: @"%d",sliderValue];
			// Set up the cell...
			cell.textLabel.text = cellValue;
			[cell addSubview: tempLabel];
			[cell addSubview: tempSlider ];
			break;
			
	}
	if(indexPath.section==0){
		
	}
	return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
	if(section==1)
		return @"Changes will appear when you respring.";
	else
		return nil;
}

-(void)viewDidLoad
{
    NSLog(@"Loading Application");
    [self myInit];
    [super viewDidLoad];

}

- (void)viewWillBecomeVisible:(void *)source
{
    NSLog(@"View Becoming Visible", source);
    [self myInit];
    [super viewWillBecomeVisible:source];
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"View Will Appear");
    [self myInit];
}
@end

@implementation CalendarColorsListController
-(id) init{
	if ((self = [super init])){
		calendarMappings = [[NSMutableDictionary alloc] init];
	}
	return self;
	
}

-(void) buildSpecifierForCalendarNamed: (NSString*) title items: (NSMutableArray*)items specifiers: (NSMutableArray*) inSpecs section:(NSInteger) inSection{
	PSSpecifier *groupTitle =[PSSpecifier groupSpecifierWithName:title];
    [inSpecs addObject:groupTitle];
	NSInteger row = 0;
	for(SavedCalendar* calendar in items){
		PSSpecifier* cal = [PSSpecifier preferenceSpecifierNamed:[calendar title] target:self set:Nil get:Nil detail:[CalendarColorPSViewController class]   cell:PSLinkListCell edit:Nil];
        [cal setProperty:[[calendar storeId] copy] forKey:@"calendarID"];
        [inSpecs addObject:cal];
		[calendarMappings setObject:[calendar retain] forKey:[NSString stringWithFormat: @"%d-%d",inSection,row] ];
		NSLog(@"Setting Calendar For: %d-%d",inSection,row);
		row++;
	}
	[items release];
}
-(SavedCalendar *) currentlySelectedCalendar{
	NSIndexPath* path = [[self table] indexPathForSelectedRow] ;
	NSLog(@"Getting Calendar For: %d-%d",path.section,path.row);
	return [calendarMappings objectForKey: [NSString stringWithFormat: @"%d-%d",[path section],[path row]]];
/*	if(path){
		NSLog(@"Dictionary: %@",calendarMappings);
		
	}else
		return nil;*/
}
- (id)specifiers {
	if(_specifiers == nil) {
        NSMutableArray* specs = [[NSMutableArray alloc] init];
		NSMutableDictionary* calendars = [CalendarUtils loadCalendars];
		NSInteger section = 0;
		for(id key in calendars){
			if([(NSString*)key isEqualToString:@"Other"])
				continue;
			[self buildSpecifierForCalendarNamed:(NSString*) key items: [calendars objectForKey: key] specifiers: specs section: section];
			section = section+1;
		}
		if([calendars objectForKey: @"Other"]){
			[self buildSpecifierForCalendarNamed:@"Other" items: [calendars objectForKey: @"Other"] specifiers: specs section: section];
		}
        _specifiers = [specs retain];
        [calendars release];
    }
    
	return _specifiers;
}
- (void)dealloc
{
	if(calendarMappings){
		for(id key in calendarMappings){
			[[calendarMappings objectForKey: key] release];
		}
		[calendarMappings release];
	}
	[super dealloc];
}
@end

