//
//  YouTubeViewController.h
//  J-PopNavi
//
//  Created by Damon Lok on 11/9/11.
//  Copyright 2011 ios-dev.webs.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSON.h"
#import "J_PopNaviAppDelegate.h"

#define kUITag1 1
#define kUITag2 2
#define kUITag3 3
#define kUITag4 4

@interface YouTubeViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    J_PopNaviAppDelegate *appDelegate;
    GADBannerView *adBanner;
    UIActivityIndicatorView *spinner;
    NSMutableDictionary* token;
    NSMutableArray *updatedDataArray;
    NSMutableArray *descriptionDataArray;      
    NSMutableArray *displayDataTitleArray; 
    NSMutableArray *mediaContentDataArray; 
    NSMutableArray *mediaThumbnailDataArray; 
    UITableView *youtubeTable;
}
@property (nonatomic, retain) IBOutlet UITableView *youtubeTable;

@end
