//
//  UIApplication+URLUtil.m
//  InfoNavi
//
//  Created by Damon Lok on 10/10/11.
//  Copyright 2011 ios-dev.webs.com. All rights reserved.
//

#import "UIApplication+URLUtil.h"
#import "J_PopNaviAppDelegate.h"

@implementation UIApplication (UIApplication_URLUtil)

- (BOOL)openURL:(NSURL *)url
{
    J_PopNaviAppDelegate *appDelegate = (((J_PopNaviAppDelegate*) [UIApplication sharedApplication].delegate)); 
    [appDelegate urlFlipAction:url flipActionOn:@"Flip To Homepage"];    
    
    return TRUE;
}

@end
