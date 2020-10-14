//
//  YouTubeViewController.m
//  J-PopNavi
//
//  Created by Damon Lok on 11/9/11.
//  Copyright 2011 ios-dev.webs.com. All rights reserved.
//

#import "YouTubeViewController.h"
#import "NSString+HTMLUtil.h"
#import "UIButton+Property.h"

@implementation YouTubeViewController
@synthesize youtubeTable;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)startSpinner
{   
    spinner = [appDelegate getSpinner];
    [youtubeTable addSubview:spinner]; 
    [spinner startAnimating];   
}

- (void)stopSpinner
{
    [spinner stopAnimating];
    [spinner removeFromSuperview];
}

- (NSString *) getSID
{
    return [NSString stringWithFormat: @"SID=%@", [token objectForKey:@"SID"] ];
}

- (NSString *) getAuth
{
    return [NSString stringWithFormat: @"Auth=%@",[token objectForKey:@"Auth"]];
}

- (void)loginToObtainSID
{
    NSString *content = [NSString stringWithFormat:@"Email=%@&Passwd=%@&service=%@&source=%@", 
                         [[[NSBundle mainBundle] infoDictionary] valueForKey:@"I Parameter String"], 
                         [[[NSBundle mainBundle] infoDictionary] valueForKey:@"IS Parameter String"],
                         [[[NSBundle mainBundle] infoDictionary] valueForKey:@"YS Parameter String"],
                         [[[NSBundle mainBundle] infoDictionary] valueForKey:@"SU Parameter String"]];
    
    NSURL *authUrl = [NSURL URLWithString:[[[NSBundle mainBundle] infoDictionary] valueForKey:@"Login URL"]];
    
    NSMutableURLRequest *authRequest = [[NSMutableURLRequest alloc] initWithURL:authUrl];
    
    [authRequest setHTTPMethod:@"POST"];
    [authRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-type"];
    [authRequest setHTTPBody:[content dataUsingEncoding:NSASCIIStringEncoding]];
    
    NSHTTPURLResponse *authResponse;
    NSError *authError;
    NSData *authData = [NSURLConnection sendSynchronousRequest:authRequest returningResponse:&authResponse error:&authError];      
    
    NSString *authResponseBody = [[NSString alloc] initWithData:authData encoding:NSASCIIStringEncoding];
    
    NSArray *lines = [authResponseBody componentsSeparatedByString:@"\n"];
    token = [NSMutableDictionary dictionary];
    
    for (NSString *s in lines) {
        NSArray *kvpair = [s componentsSeparatedByString:@"="];
        if ([kvpair count]>1)
            [token setObject:[kvpair objectAtIndex:1] forKey:[kvpair objectAtIndex:0]];
    }
    
    if ([token objectForKey:@"Error"]) {
        NSLog(@"Error with response code: %d", [authResponse statusCode]);
        NSLog(@"Error description: %@", [token objectForKey:@"Error"]);
    };  
    
    [authRequest release];
    [authResponseBody release];
    
    NSLog(@"Successfully logged in via ClientLogin from google at the end of method: %s", __PRETTY_FUNCTION__);
}

- (void)getTokenWithSID
{
    NSString *tokenRequestString = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"Token URL"];
    
    NSURL *tokenAuthUrl = [NSURL URLWithString:tokenRequestString];
    
    NSMutableURLRequest *tokenAuthRequest = [[NSMutableURLRequest alloc] initWithURL:tokenAuthUrl];
    
    [tokenAuthRequest setHTTPMethod:@"GET"];
    
    [tokenAuthRequest addValue:[self getSID] forHTTPHeaderField:@"Cookie"];
    
    NSHTTPURLResponse *authResponse;
    
    NSError *authError;
    
    NSData *tokenData = [NSURLConnection sendSynchronousRequest:tokenAuthRequest returningResponse:&authResponse error:&authError];      
    
    NSString *tokenString = [[NSString alloc] initWithData:tokenData encoding:NSASCIIStringEncoding];     
    
    if (tokenString.length >0)
        [token setObject:tokenString forKey:@"Token"];
    else
        NSLog(@"Failed to obtain token");
    
    [tokenAuthRequest release];
    [tokenString release];
    NSLog(@"Successfully obtained token via SID at the end of method: %s", __PRETTY_FUNCTION__);
}

- (UIImage *)loadImageFromURL:(NSString *)url
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"GET"];
    NSHTTPURLResponse *response;
    NSError *error;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];      
    return [UIImage imageWithData:responseData];
    [request release];
}

- (void)extractVideoData:(NSData *)responseData
{
    if (responseData.length > 0) {
        NSString *incomingSearchResultData = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        NSDictionary *result = [incomingSearchResultData JSONValue];
        NSArray *entries = (NSArray *)[[result objectForKey:@"feed"] valueForKey:@"entry"];   
        if (entries) {   
            for (NSDictionary* entry in entries) { 
                NSDictionary *updatedTime = [entry objectForKey:@"updated"];
                [updatedDataArray addObject:(NSString *)[updatedTime valueForKey:@"$t"]];
                NSString *mediaContent =  [[entry objectForKey:@"media$group"] valueForKey:@"media$content"];
                [mediaContentDataArray addObject:mediaContent]; 
                NSDictionary *description = [[entry objectForKey:@"media$group"] objectForKey:@"media$description"];
                [descriptionDataArray addObject:(NSString *)[description valueForKey:@"$t"]];
                NSString *mediaThumbnail = [[entry objectForKey:@"media$group"] valueForKey:@"media$thumbnail"];
                [mediaThumbnailDataArray addObject:mediaThumbnail]; 
                NSDictionary *title =  [[entry objectForKey:@"media$group"] objectForKey:@"media$title"];            
                [displayDataTitleArray addObject:(NSString *)[title valueForKey:@"$t"]];
            }
        }
    } else {
        NSLog(@"Response data does not contain YouTube videos.");
    }
}

- (void)loadVideo 
{
    NSString *youtubeSearchURL = [J_PopNaviAppDelegate getYouTubeSearchURL:[[[NSBundle mainBundle] infoDictionary] valueForKey:@"YouTube Search URL"]];
    NSString *extraGoogleProperties = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"Extra Google Properties"];
    NSURL *url = [NSURL URLWithString:youtubeSearchURL];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    NSString *cookie = [NSString stringWithFormat:@"%@%@", [self getAuth], extraGoogleProperties];
    [req setHTTPMethod:@"GET"];
    [req addValue:cookie forHTTPHeaderField:@"Cookie" ];   
    NSHTTPURLResponse *authResponse;
    NSError *authError;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:req returningResponse:&authResponse error:&authError];    
    
    [self extractVideoData:responseData];
    NSLog(@"Successfully loaded YouTube API response at the end of method: %s", __PRETTY_FUNCTION__);    
}

- (void)loadAdBanner
{
    CGRect adBannerFrame;
    
    if ([J_PopNaviAppDelegate isiPad]) {
        adBannerFrame = CGRectMake(0, 0, GAD_SIZE_728x90.width, GAD_SIZE_728x90.height);
    } else {
        if (UIInterfaceOrientationIsLandscape([UIDevice currentDevice].orientation)) {
            adBannerFrame = CGRectMake(0, 0, GAD_SIZE_468x60.width, GAD_SIZE_468x60.height);
        }  else {
            adBannerFrame = CGRectMake(0, 0, GAD_SIZE_320x50.width, GAD_SIZE_320x50.height);
        }
    }
    adBanner = [[GADBannerView alloc] initWithFrame:adBannerFrame];
    adBanner.adUnitID = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"AdMob Publisher ID"];
    adBanner.rootViewController = self;
    [self.view addSubview:adBanner];
    [adBanner loadRequest:[GADRequest request]];
}

- (void)loadData
{    
    [youtubeTable setDelegate:self];
    displayDataTitleArray = [[NSMutableArray alloc] init];
    updatedDataArray = [[NSMutableArray alloc] init];
    descriptionDataArray = [[NSMutableArray alloc] init];
    mediaThumbnailDataArray = [[NSMutableArray alloc] init]; 
    mediaContentDataArray = [[NSMutableArray alloc] init]; 
    
    [self loginToObtainSID];
    [self loadVideo];
    [youtubeTable reloadData];
    [self stopSpinner];
    NSLog(@"Successfully populated YouTube videos data at the end of method: %s", __PRETTY_FUNCTION__);
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    displayDataTitleArray = nil;
    mediaThumbnailDataArray = nil;
    updatedDataArray = nil;
    descriptionDataArray = nil;
    mediaContentDataArray = nil;
    
    [super viewWillAppear:animated];
    if ([J_PopNaviAppDelegate isiPad]) {
        self.view.frame =  CGRectMake(0, 0, 768, 1028);
        youtubeTable.frame = CGRectMake(0, 90, 768, 950);
    } else {
        youtubeTable.frame = CGRectMake(0, 50, 320, 411);
    }
    appDelegate = (((J_PopNaviAppDelegate*) [UIApplication sharedApplication].delegate));
    [self startSpinner];
    [self performSelector:@selector(loadData) withObject:nil afterDelay:0];    
}

- (void)viewDidLoad
{
    [super viewDidLoad]; 
    [self loadAdBanner];
    [youtubeTable flashScrollIndicators];
    
    CGRect labelFrame;
    if ([J_PopNaviAppDelegate isiPad]) labelFrame = CGRectMake(0, 80, 650, 50);  
    else labelFrame = CGRectMake(0, 70, 280, 33);
    
    NSString *spaceString = @" ";
    NSString *dashString = @"-";
    NSString *themeTitle = [J_PopNaviAppDelegate getSearchCriteria]; 
    NSString *titleString = [J_PopNaviAppDelegate getTableTitle:5]; 
    NSString *tableHeaderText = [NSString stringWithFormat:@"%@%@%@%@%@", themeTitle, spaceString, dashString, spaceString, titleString];
    
    UILabel *label = [[[UILabel alloc] initWithFrame:labelFrame] autorelease];
    label.backgroundColor = [UIColor groupTableViewBackgroundColor];
    if ([J_PopNaviAppDelegate isiPad]) {
        label.font = [UIFont systemFontOfSize:20];
    } else {
        label.font = [UIFont systemFontOfSize:16];    
    }
    label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.8];
    label.textAlignment = UITextAlignmentCenter;
    label.textColor = [UIColor orangeColor];
    label.text = tableHeaderText;
    youtubeTable.tableHeaderView = label;
    
    CGRect refreshButtonFrame = CGRectMake(5, 5, 30, 30);    
    UIButton *refreshButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];  
    refreshButton.frame = refreshButtonFrame;
    [refreshButton setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    UIImage *refreshButtonImage = [UIImage imageNamed:@"refreshN30.png"];
    UIImage *refreshPressedButtonImage = [UIImage imageNamed:@"refreshP30.png"];
    [refreshButton setImage:refreshButtonImage forState:UIControlStateNormal];
    [refreshButton setImage:refreshPressedButtonImage forState:UIControlStateHighlighted];
    [refreshButton addTarget:self action:@selector(viewWillAppear:) forControlEvents: UIControlEventTouchUpInside];
    [youtubeTable addSubview:refreshButton];   
    
    NSLog(@"Successfully loaded YouTube video view at the end of method: %s", __PRETTY_FUNCTION__);
}

- (UITableViewCell *) getCellContentView:(NSString *)cellIdentifier
{ 
    CGRect CellFrame;
    CGRect titleDataFrame; 
    CGRect descriptionDataFrame;
    CGRect mediaDataFrame;
    CGRect updatedDataFrame;
    
    if ([J_PopNaviAppDelegate isiPad]) {
        CellFrame = CGRectMake(0, 0, 700, 155);
        titleDataFrame = CGRectMake(15, 2, 650, 24); 
        descriptionDataFrame = CGRectMake(15, 25, 650, 30);  
        updatedDataFrame = CGRectMake(20, 56, 200, 17);
        mediaDataFrame  = CGRectMake(20, 74, 510, 80);        
    } else {    
        CellFrame = CGRectMake(0, 0, 300, 155);
        titleDataFrame = CGRectMake(15, 2, 260, 24); 
        descriptionDataFrame = CGRectMake(15, 25, 650, 30); 
        updatedDataFrame = CGRectMake(20, 56, 260, 17);
        mediaDataFrame = CGRectMake(10, 74, 290, 87);
    }
    
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithFrame:CellFrame reuseIdentifier:cellIdentifier] autorelease];

    UITextView *titleTextView = [[UITextView alloc] initWithFrame:titleDataFrame];
    titleTextView.backgroundColor = [UIColor whiteColor];
    if ([J_PopNaviAppDelegate isiPad]) {
        titleTextView.font = [UIFont systemFontOfSize:16];
    } else {
        titleTextView.font = [UIFont systemFontOfSize:12]; 
    }
    titleTextView.editable = NO;
    titleTextView.tag = kUITag1;
    [cell.contentView addSubview:titleTextView];
    [titleTextView release]; 
    
    UITextView *descriptionTextView = [[UITextView alloc] initWithFrame:descriptionDataFrame];
    descriptionTextView.backgroundColor = [UIColor whiteColor];
    descriptionTextView.editable = NO;
    descriptionTextView.tag = kUITag2;
    [descriptionTextView flashScrollIndicators];
    [cell.contentView addSubview:descriptionTextView];
    [descriptionTextView release];  
    
    UITextView *updatedTextView = [[UITextView alloc] initWithFrame:updatedDataFrame];
    updatedTextView.backgroundColor = [UIColor whiteColor];
    updatedTextView.editable = NO;
    updatedTextView.tag = kUITag3;
    [cell.contentView addSubview:updatedTextView];
    [updatedTextView release];    
    
    UIButton *contentTextView = [[UIButton alloc] initWithFrame:mediaDataFrame];
    [contentTextView setBackgroundColor:[UIColor whiteColor]];
    [contentTextView setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    contentTextView.tag = kUITag4;   
    [cell.contentView addSubview:contentTextView];
    [contentTextView release];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [mediaContentDataArray count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (IBAction)videoLinkClicked:(id)sender
{
    UIButton *clickableTitle = (UIButton *)sender;
    NSMutableArray *videoProperties = (NSMutableArray *)clickableTitle.property;   
    NSString *videoHyperlink = [videoProperties objectAtIndex:0];
    NSString *videoType = [videoProperties objectAtIndex:1];
    NSString *returningVideoURL = [NSString stringWithFormat:@"%@%@", videoHyperlink, [[[NSBundle mainBundle] infoDictionary] valueForKey:@"YouTube Developer ID"]];
    [appDelegate urlFlipAction:[NSURL URLWithString:returningVideoURL] flipActionOn:[NSString stringWithFormat:@"Flip To Play YouTube===%@",videoType]]; 
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    return 155;
}

- (int)extractFormat5Video:(NSArray *)videoArray
{
    int index;
    for (index = 0; index < videoArray.count; index++) {
        NSDictionary *videoEntry = (NSDictionary *)[videoArray objectAtIndex:index];
        if ((NSNumber *)[videoEntry objectForKey:@"yt$format"] == [NSNumber numberWithInt:5])break;
    }
    return index;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"displayDataCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (cell == nil) {
        cell = [self getCellContentView:cellID];   
        if ([J_PopNaviAppDelegate isiPad]) {
            cell.textLabel.font = [UIFont systemFontOfSize:16];
        }   else {  
            cell.textLabel.font = [UIFont systemFontOfSize:12];
        }
        cell.textLabel.numberOfLines = 2;
    }
    cell.backgroundColor = [UIColor whiteColor];
    @try {
        [(UITextView *)[cell viewWithTag:kUITag1] setText:[displayDataTitleArray objectAtIndex:indexPath.row]];
        [(UITextView *)[cell viewWithTag:kUITag2] setText:[descriptionDataArray objectAtIndex:indexPath.row]];
        [(UITextView *)[cell viewWithTag:kUITag3] setText:[updatedDataArray objectAtIndex:indexPath.row]];
        UIButton *videoLink = (UIButton *)[cell viewWithTag:kUITag4];  
    
        int index = [self extractFormat5Video:[mediaContentDataArray objectAtIndex:indexPath.row]]; 
        NSString *videoURLString = [[[mediaContentDataArray objectAtIndex:indexPath.row] objectAtIndex:index] valueForKey:@"url"];
        NSString *videoType = [[[mediaContentDataArray objectAtIndex:indexPath.row] objectAtIndex:index] valueForKey:@"type"];
        NSMutableArray *videoProperties = [[NSMutableArray alloc] init];
        [videoProperties addObject:videoURLString];
        [videoProperties addObject:videoType];
        videoLink.property = videoProperties;
        NSString *videoThumbnailURLString = [[[mediaThumbnailDataArray objectAtIndex:indexPath.row] objectAtIndex:0] valueForKey:@"url"];
        [videoLink setImage:[self loadImageFromURL:videoThumbnailURLString] forState:UIControlStateNormal];
        [videoLink addTarget:self action:@selector(videoLinkClicked:) forControlEvents:UIControlEventTouchUpInside];  
        [videoProperties release];
    } @catch (NSException *ex) { 
        [self viewWillAppear:TRUE];
    }
    NSLog(@"Successfully populated YouTude video cell data for title: %@ at row index %d at the end of method: %s", [displayDataTitleArray objectAtIndex:indexPath.row], indexPath.row, __PRETTY_FUNCTION__);
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"YouTube Video"
                                                    message:[[displayDataTitleArray objectAtIndex:indexPath.row] valueForKey:@"$t"]
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)changeBannerOrientation:(UIInterfaceOrientation)toOrientation 
{
    [adBanner removeFromSuperview];
    [adBanner release];   
    CGRect adBannerFrame;
    
    if ([J_PopNaviAppDelegate isiPad]) {
        CGRect landscapeFrame = youtubeTable.frame;
        landscapeFrame.origin.y = 90.0;
        youtubeTable.frame = landscapeFrame;
        adBannerFrame = CGRectMake(0, 0, GAD_SIZE_728x90.width, GAD_SIZE_728x90.height);       
    } else {
        if (UIInterfaceOrientationIsLandscape(toOrientation)) {
            CGRect landscapeFrame = youtubeTable.frame;
            landscapeFrame.origin.y = 60.0;
            youtubeTable.frame = landscapeFrame;
            adBannerFrame = CGRectMake(0, 0, GAD_SIZE_468x60.width, GAD_SIZE_468x60.height);
        }  else {
            CGRect portraitFrame =youtubeTable.frame;
            portraitFrame.origin.y = 50.0;
            youtubeTable.frame = portraitFrame;
            adBannerFrame = CGRectMake(0, 0, GAD_SIZE_320x50.width, GAD_SIZE_320x50.height);
        }
    }    
    adBanner = [[GADBannerView alloc] initWithFrame:adBannerFrame];
    adBanner.adUnitID = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"AdMob Publisher ID"];
    adBanner.rootViewController = self;
    [self.view addSubview:adBanner];
    [adBanner loadRequest:[GADRequest request]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{    
    return NO;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration 
{
    if (adBanner) {
        [self changeBannerOrientation:toInterfaceOrientation];
    }
}

- (void)viewDidUnload
{
    displayDataTitleArray = nil;
    mediaThumbnailDataArray = nil;
    updatedDataArray = nil;
    descriptionDataArray = nil;
    mediaContentDataArray = nil;
    [self setYoutubeTable:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc 
{
    if (adBanner) [adBanner release];   
    [token release];
    [mediaThumbnailDataArray release];
    [youtubeTable release];
    [updatedDataArray release];
    [displayDataTitleArray release]; 
    [descriptionDataArray release];
    [youtubeTable release];

    [super dealloc];
    NSLog(@"Successfully deallocated all Google Alert instance variables' memories at the end of method: %s",__PRETTY_FUNCTION__);
}

@end
