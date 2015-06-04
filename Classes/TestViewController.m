    //
//  TestViewController.m
//  fStats
//
//  Created by Shawn Veader on 9/18/10.
//  Copyright 2010 V8 Labs, LLC. All rights reserved.
//

#import "TestViewController.h"
#import "Person.h"

//#define requestURL @"http://api.geonames.org/countryInfoJSON?username=PROGAB&country=GR"
#define SLIDINGBARLISTOFEVENTS @"http://slidingbar.com/api.listings/events-associations/retrieve"
#define requestURL @"http://api.geonames.org/countryInfoJSON"
//#define requestURL @"https://alpha-api.app.net/stream/0/posts/stream/global"

#define requestWeatherURL @"http://api.openweathermap.org/data/2.5/weather?q=London,uk"

#define londonWeatherUrl  @"http://api.openweathermap.org/data/2.5/weather?q=London,uk"


@implementation TestViewController

#pragma mark - iVars
int indexCount;

#pragma mark - Init/Dealloc
- (id)init {
	self = [super init];
	if (self) {
		self.titleArray = [NSMutableArray arrayWithObjects:@"All", @"Today", @"Thursday", @"Wednesday", @"Tuesday", @"Monday", nil];
		indexCount = 0;
	}
	return self;
}

- (void)saveObjectPlain{
    
    printf("==========================================\n");
    printf("saveObjectPlain===========================\n");
    printf("==========================================\n");
    
    //< Create and Save the Object
    {
        Person *obj = [[Person alloc] init];
        obj.stringValue = @"The String Value";
        obj.intValue    = 12345;
        obj.boolValue   = YES;
        [NSKeyedArchiver archiveRootObject:obj toFile:[self tempFilePath]];
        printf("Save: \n %s \n", [[obj description] cStringUsingEncoding:NSUTF8StringEncoding]);
    }
    
    //< Load and Print the Object
    {
        Person *obj = [NSKeyedUnarchiver unarchiveObjectWithFile:[self tempFilePath]];
        printf("Load: \n %s \n", [[obj description] cStringUsingEncoding:NSUTF8StringEncoding]);
    }
    
    printf("==========================================\n");
}

-(NSString*)tempFilePath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

-(void)callApiUsingNSURLSession{
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:[NSURL URLWithString:londonWeatherUrl]
            completionHandler:^(NSData *data,
                                NSURLResponse *response,
                                NSError *error) {
                // handle response
                //If data were received
                if (data) {
                    //Convert to string
                    NSString *result = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
                    NSLog(@"result %@",result);
                    //Create view controller and set its result/product/version
                }
                
            }] resume];
}

-(void)callApiWithParameter{
    //HTTP Authentication
   // NSString *authStr = [NSString stringWithFormat:@"%@:%@", @"PROGAB", @"GR"];
     NSString *authStr = [NSString stringWithFormat:@"%@", @"201"];
    NSData *authData = [authStr dataUsingEncoding:NSASCIIStringEncoding];
    NSString *authValue = [authData base64Encoding];
    
    //Set up Request:
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]init];
    [request setURL:[NSURL URLWithString:SLIDINGBARLISTOFEVENTS]];
    //...
    // Pack in the user credentials
    [request setValue:[NSString stringWithFormat:@"Basic %@",authValue] forHTTPHeaderField:@"Authorization"];
    
    // Send the asynchronous request as usual
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *responseCode, NSData *data, NSError *error) {
        
        //If data were received
        if (data) {
            //Convert to string
            NSString *result = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
            NSLog(@"result %@",result);
            //Create view controller and set its result/product/version
        }
        
    }
];
}

-(void)callAPI{
    //Create the URL request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:SLIDINGBARLISTOFEVENTS]];
    
    NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:@"201",
                              @"uid",nil];
    NSData *postData = [self encodeDictionary:postDict];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:[NSString stringWithFormat:@"%d", postData.length] forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    //Start the request for the data
    NSOperationQueue *Queue=[[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:request queue:Queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        //If data were received
        if (data) {
            //Convert to string
            NSString *result = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
            NSLog(@"result %@",result);
            //Create view controller and set its result/product/version
        }
        
        //No data received
        else {
            NSString *errorText;
            //Specific error
            if (error)
                errorText = [error localizedDescription];
            //Generic error
            else
                errorText = @"An error occurred when downloading the list of issues. Please check that you are connected to the Internet.";
            
            //Show error
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:errorText delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            
            //Hide activity indicator
        }
    }];
    
    
    NSLog(@"Done");

}

- (NSData*)encodeDictionary:(NSDictionary*)dictionary {
    NSMutableArray *parts = [[NSMutableArray alloc] init];
    for (NSString *key in dictionary) {
        NSString *encodedValue = [[dictionary objectForKey:key] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *encodedKey = [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *part = [NSString stringWithFormat: @"%@=%@", encodedKey, encodedValue];
        [parts addObject:part];
    }
    NSString *encodedDictionary = [parts componentsJoinedByString:@"&"];
    return [encodedDictionary dataUsingEncoding:NSUTF8StringEncoding];
}

- (void)dispatchCallPushed{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:SLIDINGBARLISTOFEVENTS]];
    
    //NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:@"201",
 //                             @"uid",nil];
    //NSData *postData = [self encodeDictionary:postDict];
    
    // Create the request
    //[request setHTTPMethod:@"POST"];
    //[request setValue:[NSString stringWithFormat:@"%d", postData.length] forHTTPHeaderField:@"Content-Length"];
    //[request setValue:@"application/x-www-form-urlencoded charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    //[request setHTTPBody:postData];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Peform the request
        NSURLResponse *response;
        NSError *error = nil;
        NSData *receivedData = [NSURLConnection sendSynchronousRequest:request
                                                     returningResponse:&response
                                                                 error:&error];
        if (error) {
            // Deal with your error
            if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
                NSLog(@"HTTP Error: %d %@", httpResponse.statusCode, error);
                return;
            }
            NSLog(@"Error %@", error);
            return;
        }
        
        NSString *responeString = [[NSString alloc] initWithData:receivedData
                                                        encoding:NSUTF8StringEncoding];
        
        NSLog(@"responeString %@", responeString);
        
        
        // When dealing with UI updates, they must be run on the main queue, ie:
              dispatch_async(dispatch_get_main_queue(), ^(void){
              // place your code to update ui
              });
    }); 
}

-(void)createV8HorizontalPickerView{
    CGFloat margin = 00.0f;
    CGFloat width = (self.view.bounds.size.width - (margin * 1.0f));
    CGFloat pickerHeight = 100.0f;
    CGFloat x = margin;
    CGFloat y = 150.0f;
    CGFloat spacing = 25.0f;
    CGRect tmpFrame = CGRectMake(x, y, width, pickerHeight);
    
    //	CGFloat width = 200.0f;
    //	CGFloat x = (self.view.frame.size.width - width) / 2.0f;
    //	CGRect tmpFrame = CGRectMake(x, 150.0f, width, 40.0f);
    
    self.pickerView = [[V8HorizontalPickerView alloc] initWithFrame:tmpFrame];
    self.pickerView.backgroundColor   = [UIColor darkGrayColor];
    self.pickerView.selectedTextColor = [UIColor whiteColor];
    self.pickerView.textColor   = [UIColor grayColor];
    self.pickerView.delegate    = self;
    self.pickerView.dataSource  = self;
    self.pickerView.elementFont = [UIFont boldSystemFontOfSize:14.0f];
    self.pickerView.selectionPoint = CGPointMake(150, 0);
    
    // add carat or other view to indicate selected element
    UIImageView *indicator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"indicator"]];
    self.pickerView.selectionIndicatorView = indicator;
    //	pickerView.indicatorPosition = V8HorizontalPickerIndicatorTop; // specify indicator's location
    
    //	// add gradient images to left and right of view if desired
    //	UIImageView *leftFade = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"left_fade"]];
    //	self.pickerView.leftEdgeView = leftFade;
    //
    //	UIImageView *rightFade = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"right_fade"]];
    //	self.pickerView.rightEdgeView = rightFade;
    
    // add image to left of scroll area
    UIImageView *leftImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loopback"]];
    self.pickerView.leftScrollEdgeView = leftImage;
    self.pickerView.scrollEdgeViewPadding = 20.0f;
    
    UIImageView *rightImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"airplane"]];
    self.pickerView.rightScrollEdgeView = rightImage;
    
    [self.view addSubview:self.pickerView];
    
    //	self.nextButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    //	y = y + tmpFrame.size.height + spacing;
    //	tmpFrame = CGRectMake(x, y, width, 50.0f);
    //	self.nextButton.frame = tmpFrame;
    //	[self.nextButton addTarget:self action:@selector(nextButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    //	[self.nextButton	setTitle:@"Center Element 0" forState:UIControlStateNormal];
    //	self.nextButton.titleLabel.textColor = [UIColor blackColor];
    //	[self.view addSubview:self.nextButton];
    //
    //	self.reloadButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    //	y = y + tmpFrame.size.height + spacing;
    //	tmpFrame = CGRectMake(x, y, width, 50.0f);
    //	self.reloadButton.frame = tmpFrame;
    //	[self.reloadButton addTarget:self action:@selector(reloadButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    //	[self.reloadButton setTitle:@"Reload Data" forState:UIControlStateNormal];
    //	[self.view addSubview:self.reloadButton];
    //
    //	y = y + tmpFrame.size.height + spacing;
    //	tmpFrame = CGRectMake(x, y, width, 50.0f);
    //	self.infoLabel = [[UILabel alloc] initWithFrame:tmpFrame];
    //	self.infoLabel.backgroundColor = [UIColor blackColor];
    //	self.infoLabel.textColor = [UIColor whiteColor];
    //	self.infoLabel.textAlignment = UITextAlignmentCenter;
    //	[self.view addSubview:self.infoLabel];
    
}
#pragma mark - View Management Methods
- (void)viewDidLoad {
	[super viewDidLoad];
    //[self saveObjectPlain];
    [self createFBloginView];
   // [self callApiUsingNSURLSession];
    //[self callApiWithParameter];
   // [self callAPI];
    //[self dispatchCallPushed];
    //[self createV8HorizontalPickerView];

	self.view.backgroundColor = [UIColor blackColor];
	
}

- (void)viewDidUnload {
	[super viewDidUnload];
	// Release any retained subviews of the main view.
	self.pickerView = nil;
	self.nextButton = nil;
	self.infoLabel  = nil;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self.pickerView scrollToElement:0 animated:NO];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
//	(interfaceOrientation == UIInterfaceOrientationPortrait ||
//	 interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
//	 interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

//- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
//	CGFloat margin = 40.0f;
//	CGFloat width = (self.view.frame.size.width - (margin * 2.0f));
//	CGFloat height = 40.0f;
//	CGRect tmpFrame;
//	if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
//		toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
//		tmpFrame = CGRectMake(margin, 50.0f, width + 100.0f, height);
//	} else {
//		tmpFrame = CGRectMake(margin, 150.0f, width, height);
//	}
//	pickerView.frame = tmpFrame;
//}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	CGFloat margin = 40.0f;
	CGFloat width = (self.view.bounds.size.width - (margin * 2.0f));
	CGFloat x = margin;
	CGFloat y = 0.0f;
	CGFloat height = 40.0f;
	CGFloat spacing = 25.0f;
	CGRect tmpFrame;
	if (fromInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
		fromInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
		y = 150.0f;
		spacing = 25.0f;
		tmpFrame = CGRectMake(x, y, width, height);
	} else {
		y = 50.0f;
		spacing = 10.0f;
		tmpFrame = CGRectMake(x, y, width, height);
	}
	self.pickerView.frame = tmpFrame;
	
	y = y + tmpFrame.size.height + spacing;
	tmpFrame = self.nextButton.frame;
	tmpFrame.origin.y = y;
	self.nextButton.frame = tmpFrame;
	
	y = y + tmpFrame.size.height + spacing;
	tmpFrame = self.reloadButton.frame;
	tmpFrame.origin.y = y;
	self.reloadButton.frame = tmpFrame;
	
	y = y + tmpFrame.size.height + spacing;
	tmpFrame = self.infoLabel.frame;
	tmpFrame.origin.y = y;
	self.infoLabel.frame = tmpFrame;

}

#pragma mark - Button Tap Handlers
- (void)nextButtonTapped:(id)sender {
	[self.pickerView scrollToElement:indexCount animated:NO];
	indexCount += 1;
	if ([self.titleArray count] <= indexCount) {
		indexCount = 0;
	}
	[self.nextButton setTitle:[NSString stringWithFormat:@"Center Element %d", indexCount]
					 forState:UIControlStateNormal];
}

- (void)reloadButtonTapped:(id)sender {
	// change our title array so we can see a change
	if ([self.titleArray count] > 1) {
		[self.titleArray removeLastObject];
	}

	[self.pickerView reloadData];
}

#pragma mark - HorizontalPickerView DataSource Methods
- (NSInteger)numberOfElementsInHorizontalPickerView:(V8HorizontalPickerView *)picker {
	return [self.titleArray count];
}

#pragma mark - HorizontalPickerView Delegate Methods
- (NSString *)horizontalPickerView:(V8HorizontalPickerView *)picker titleForElementAtIndex:(NSInteger)index {
	return [self.titleArray objectAtIndex:index];
}

- (NSInteger) horizontalPickerView:(V8HorizontalPickerView *)picker widthForElementAtIndex:(NSInteger)index {
	CGSize constrainedSize = CGSizeMake(MAXFLOAT, MAXFLOAT);
	NSString *text = [self.titleArray objectAtIndex:index];
	CGSize textSize = [text sizeWithFont:[UIFont boldSystemFontOfSize:14.0f]
					   constrainedToSize:constrainedSize
						   lineBreakMode:UILineBreakModeWordWrap];
	return textSize.width + 40.0f; // 20px padding on each side
}

- (void)horizontalPickerView:(V8HorizontalPickerView *)picker didSelectElementAtIndex:(NSInteger)index {
	//self.infoLabel.text = [NSString stringWithFormat:@"Selected index %d", index];
}



-(void)createFBloginView{
    // Create Login View so that the app will be granted "status_update" permission.
    FBLoginView *loginview = [[FBLoginView alloc] initWithReadPermissions:[NSArray arrayWithObjects:@"email",@"user_friends", nil]];
    
    loginview.frame = CGRectMake(35,310,250,38);
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        loginview.frame =CGRectMake(35,310,250,38);
    }
    [self.view addSubview:loginview];
    
    
   

}
#pragma mark - FBLoginView Delegate method implementation

#pragma mark - FBLoginViewDelegate

- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
    
    //    FBSession *session =[FBSession activeSession];
    //    if (session) {
    //        [session closeAndClearTokenInformation];
    //        session =Nil;
    //
    //    }
    
    // first get the buttons set for login mode
    
    // "Post Status" available when logged on and potentially when logged off.  Differentiate in the label.
}

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user {
    // here we use helper properties of FBGraphUser to dot-through to first_name and
    // id properties of the json response from the server; alternatively we could use
    // NSDictionary methods such as objectForKey to get values from the my json object
    self.view.userInteractionEnabled=FALSE;
    // }
    
}

- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
    // test to see if we can use the share dialog built into the Facebook application
    
    
    
    // "Post Status" available when logged on and potentially when logged off.  Differentiate in the label.
}

- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error {
    
    // see https://developers.facebook.com/docs/reference/api/errors/ for general guidance on error handling for Facebook API
    // our policy here is to let the login view handle errors, but to log the results
    NSLog(@"FBLoginView encountered an error=%@", error);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"test", nil)
                                                    message:NSLocalizedString(@"Facebook Login Fail", nil)
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    
}

@end
