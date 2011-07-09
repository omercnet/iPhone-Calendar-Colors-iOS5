#import "CalendarColorPSViewController.h"
@implementation CalendarColorPSViewController

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
                        //_wrapperView = [[UIView alloc] initWithFrame:frame];
                }
                return self;
        }

        return [super init];
}

- (void)dealloc
{
    NSLog(@"dealloc");
    tableView.dataSource = nil;
    tableView.delegate   = nil;
    [tableView release];
    //[_wrapperView release];

    initialized = NO;
	[super dealloc];
}
 
- (UIView *)view
{
	return [super view];
//return [super view] ? [super view] : _wrapperView;
}

-(void)myInit{
    
    if (initialized) return;
    
    initialized = YES;
    
    NSLog(@"myInit");

    ((UINavigationItem*)[super navigationItem]).title = @"BTstack";
    
    UIView *view = [self view];

    
    tableView = [[UITableView alloc] initWithFrame:view.bounds style:UITableViewStyleGrouped];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    tableView.dataSource = self;
    tableView.delegate   = self;
    
    [view addSubview:tableView];
    
}

- (int) tableView:(UITableView *)tableView numberOfRowsInSection:(int)section {
	return 0;
}

- (id) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    return nil;
}

-(void)viewDidLoad
{
    NSLog(@"viewDidLoad");
        [super viewDidLoad];
    [self myInit];
}

- (void)viewWillBecomeVisible:(void *)source
{
    NSLog(@"viewWillBecomeVisible %@", source);
    [self myInit];
        [super viewWillBecomeVisible:source];
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"viewWillAppear");
    [self myInit];
}
@end