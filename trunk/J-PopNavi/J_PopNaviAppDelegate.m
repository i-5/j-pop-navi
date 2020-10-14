//
//  J_PopNaviAppDelegate.m
//  InfoNavi
//
//  Created by Damon Lok on 9/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "J_PopNaviAppDelegate.h"
#import "WebBrowserViewController.h"

@implementation J_PopNaviAppDelegate

@synthesize window = _window;
@synthesize tabBarController = _tabBarController;
@synthesize webBrowserViewController = _webBrowserViewController;

+ (BOOL) isiPad
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        return TRUE;
    } else {
        return FALSE;
    }
    NSLog(@"Successfully detected the device type and it is %d for iPad at the end of method: %s",[J_PopNaviAppDelegate isiPad], __PRETTY_FUNCTION__); 
}

+ (NSString *)encodeURI:(NSString *)uri 
{
    NSString *encodedString = 
    (NSString *) CFURLCreateStringByAddingPercentEscapes(
                                                         kCFAllocatorDefault,
                                                         (CFStringRef)uri,
                                                         NULL,
                                                         (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                         kCFStringEncodingUTF8);
    return encodedString;
}

+ (NSString *)getYouTubeSearchURL:(NSString *)urlString
{
    NSString *searchCriteriaString = [J_PopNaviAppDelegate encodeURI:NSLocalizedString(@"YouTube Criteria", @"")];
    NSString *criteriaPartString = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"YouTube Search Criteria Part"];
    return [NSString stringWithFormat:@"%@%@%@", urlString, searchCriteriaString, criteriaPartString];
}

+ (NSString *)getSearchCriteria
{
    return NSLocalizedString(@"Search URL Criteria", @"");
}

+ (NSString *)getCloseButtonTitle
{
    return NSLocalizedString(@"Close Button Title", @"");
}

+ (NSString *)getTwitterURL:(NSString *)urlString
{
    NSString *searchCriteriaString = [J_PopNaviAppDelegate encodeURI:NSLocalizedString(@"Twitter Search Criteria", @"")];
    NSString *twitterSearchURL = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"Twitter Search URL Lang Part"];
    NSString *inSearchLangCriteria = NSLocalizedString(@"Twitter Language Criteria", @"");
    return [NSString stringWithFormat:@"%@%@%@%@", urlString, searchCriteriaString, twitterSearchURL, inSearchLangCriteria];
}

+ (NSString *)getYahooSearchURL:(NSString *)urlString
{
    NSString *yahooLangParam = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"Yahoo Lang Criteria"];
    return [NSString stringWithFormat:@"%@%@%@", urlString, yahooLangParam, NSLocalizedString(@"Yahoo Language Criteria", @"")];      
}

+ (NSString *)getReaderURL
{
    NSString *readerURL = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"Google Reader URL"];  
    return [NSString stringWithFormat:@"%@%@", readerURL, NSLocalizedString(@"Google Reader Language Criteria", @"")]; 
}

+ (NSString *)getGoogleSearchURL:(NSString *)urlString
{
    return [NSString stringWithFormat:@"%@%@", urlString, NSLocalizedString(@"Language parameter", @"")];  
}

+ (NSString *)getTableTitle:(int)tableNumber
{
    switch (tableNumber) {
        case kFIRST_TAB:
            return NSLocalizedString(@"First Tab Title String", @"");
            break;
        case kSECOND_TAB:
            return NSLocalizedString(@"Second Tab Title String", @"");
            break;
        case kTHIRD_TAB:
            return NSLocalizedString(@"Third Tab Title String", @"");
            break;
        case kFORTH_TAB:
            return NSLocalizedString(@"Forth Tab Title String", @"");
            break;
        case kFIFTH_TAB:
            return NSLocalizedString(@"Fifth Tab Title String", @"");
            break; 
        default:
            break;
    }
    return NSLocalizedString(@"First Tab Title String", @"");
}

- (NSURL *)getBaseURL
{
    return [NSURL URLWithString:@"http://ios-dev.webs.com"];
}

- (UIActivityIndicatorView *)getSpinner
{ 
    if (!spinner_)
        spinner_ = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    if ([J_PopNaviAppDelegate isiPad]) {
        screenWidth = kiPad_width; 
        screenHeight = kiPad_height;          
    } else {
        screenWidth = kiPhone_width; 
        screenHeight = kiPhone_height;                
    }    
    
    if ( self.window.rootViewController.interfaceOrientation == UIInterfaceOrientationPortrait )
        [spinner_ setCenter:CGPointMake(screenWidth/2.0, screenHeight/2.0)];
    else
        [spinner_ setCenter:CGPointMake(screenHeight/2.0, screenWidth/2.0)];    
    return spinner_;
}

- (void)applicationSetup
{
    self.window.rootViewController = self.tabBarController;
    self.tabBarController.delegate = self;
    
    NSString *fifthTabTitleString = [J_PopNaviAppDelegate getTableTitle:5]; 
    UIViewController *fifthTab = [self.tabBarController.viewControllers objectAtIndex:0];
    fifthTab.tabBarItem.title = fifthTabTitleString;
    fifthTab.view.tag = 0;
    
    NSString *thirdTabTitleString = [J_PopNaviAppDelegate getTableTitle:3]; 
    UIViewController *thirdTab = [self.tabBarController.viewControllers objectAtIndex:1];
    thirdTab.tabBarItem.title = thirdTabTitleString;    
    thirdTab.view.tag = 1; 
    
    NSString *secondTabTitleString = [J_PopNaviAppDelegate getTableTitle:2]; 
    UIViewController *secondTab = [self.tabBarController.viewControllers objectAtIndex:2];
    secondTab.tabBarItem.title = secondTabTitleString;    
    secondTab.view.tag = 2;
    
    NSString *forthTabTitleString = [J_PopNaviAppDelegate getTableTitle:4];
    UIViewController *forthTab = [self.tabBarController.viewControllers objectAtIndex:3];
    forthTab.tabBarItem.title = forthTabTitleString;
    forthTab.view.tag = 3;
    
    NSString *firstTabTitleString = [J_PopNaviAppDelegate getTableTitle:1]; 
    UIViewController *firstTab = [self.tabBarController.viewControllers objectAtIndex:4];
    firstTab.tabBarItem.title = firstTabTitleString;
    firstTab.view.tag = 4;

    WebBrowserViewController *webBrowserViewController = [[WebBrowserViewController alloc] initWithNibName:@"WebBrowserViewController" bundle:nil];
    [self setWebBrowserViewController:webBrowserViewController];
    [self.webBrowserViewController.view awakeFromNib];
    [webBrowserViewController release];
    
    currentViewTag = 0;
    [self.window makeKeyAndVisible];   
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    // Add the tab bar controller's current view as a subview of the window
    [self applicationSetup];
    NSLog(@"Successfully launched the app delegate and setup all the view controllers to populate to application window at the end of method: %s", __PRETTY_FUNCTION__); 
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (NSString *)getYouTubeHTMLString:(NSString *)url type:(NSString *)videoType
{
    NSString *httpURL = [url stringByReplacingOccurrencesOfString:@"https" withString:@"http"];  
    NSString *htmlString = 
    @"<html><head>"
    "<meta name = \"viewport\" content = \"initial-scale = 1.0, user-scalable = no, width = 212\"/></head>"
    "<body style=\"background:#000;margin-top:0px;margin-left:0px\">"
    "<div><object width=\"212\" height=\"172\">"
    "<param name=\"movie\" value=\"%@\"></param>"
    "<param name=\"wmode\" value=\"transparent\"></param>"
    "<embed id=\"yt\" src=\"%@\""
    //" type=\"application/x-shockwave-flash\" wmode=\"transparent\" width=\"318\" height=\"258\"></embed>"
    " type=\"%@\" wmode=\"transparent\" width=\"320\" height=\"440\"></embed>"
     " type=\"%@\" width=\"320\" height=\"258\"></embed>"
    "</object></div></body></html>";
    
    NSString *returningHtmlString = [NSString stringWithFormat:htmlString, httpURL, httpURL, videoType];
    return returningHtmlString;
}

- (void)handleFlipToGoogle
{
    [self urlFlipAction:nil flipActionOn:@"Flip To Google"];    
}

- (void)handleFlipBackToDataList
{
    [self urlFlipAction:nil flipActionOn:@"Flip Back To Data Tab"];  
}

- (void)urlFlipAction:(NSURL *)url flipActionOn:(NSString *)actionOn 
{    
    [UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:1.5];   
    if ([actionOn isEqualToString:@"Flip Back To Data Tab"]) {
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.window cache:YES]; 
        self.window.rootViewController = self.tabBarController;
        self.tabBarController.delegate = self;
        if (currentViewTag != 3) {
            [self.webBrowserViewController.webView removeFromSuperview];
            [self.window addSubview:self.window.rootViewController.view]; 
        }

    } else {
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.window cache:YES]; 
        self.window.rootViewController = (UIViewController *) self.webBrowserViewController;
        if ([actionOn isEqualToString:@"Flip To Homepage"]) {
            NSURLRequest *request = [NSURLRequest requestWithURL:url];
            [self.webBrowserViewController.webView loadRequest:request];
        }
        if ([actionOn rangeOfString:@"Flip To Play YouTube"].location != NSNotFound) {
            NSArray *chunks = [actionOn componentsSeparatedByString: @"==="];
            NSString *videoType = [chunks objectAtIndex:1];
            [self.webBrowserViewController.webView loadHTMLString:[self getYouTubeHTMLString:url.absoluteString type:videoType] baseURL:[self getBaseURL]];            
        }
        self.webBrowserViewController.webToolBar.hidden = FALSE;
        [self.window.rootViewController.view removeFromSuperview];        
        self.webBrowserViewController.webView.center = CGPointMake(screenWidth/2, screenHeight/2); 
        [self.window addSubview:self.webBrowserViewController.webView];
        [self.webBrowserViewController.webView addSubview:self.webBrowserViewController.webToolBar];
        self.webBrowserViewController.closeButton.title = [J_PopNaviAppDelegate getCloseButtonTitle];
        self.webBrowserViewController.closeButton.target = self;
        self.webBrowserViewController.closeButton.action = @selector(handleFlipBackToDataList);
    } 
    [UIView commitAnimations];    
    NSLog(@"Successfully performed the flip action for: %@ at the end of method: %s", actionOn, __PRETTY_FUNCTION__); 
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController 
{
    previousViewTag = currentViewTag;
    currentViewTag = viewController.view.tag;
    if(currentViewTag == 3) {  
        [self handleFlipToGoogle];
    }  
}

- (void)dealloc
{
    [_window release];
    [_tabBarController release];
    [_webBrowserViewController release];
    [spinner_ release];    
    [super dealloc];
}

@end
