//
//  FBAppDelegate.h
//  FaceBlend
//
//  Created by Akhildas on 7/31/13.
//  Copyright (c) 2013 QburstTechnologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "FBDataHandler.h"
#import "PlayHavenSDK.h"
#import "GAI.h"

@class FBViewController;

@interface FBAppDelegate : UIResponder <UIApplicationDelegate, PHPublisherContentRequestDelegate, ChartboostDelegate>
{
    PHNotificationView *_notificationView;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) PHPublisherContentRequest *request;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic) FBDataHandler *dataHandler;
@property (nonatomic, strong) id<GAITracker> tracker;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
+ (FBAppDelegate *)application;

- (void)setWindowSize:(BOOL)increase;
- (void)showPlayHaven:(NSString*)placement;
- (void)logGoogleAnalytics:(NSString*)category action:(NSString*)action label:(NSString*)label value:(NSString*)value;

@property (strong, nonatomic) FBViewController *viewController;

@end
