//
//  FBAppDelegate.m
//  FaceBlend
//
//  Created by Akhildas on 7/31/13.
//  Copyright (c) 2013 QburstTechnologies. All rights reserved.
//

#import "FBAppDelegate.h"
#import "Constants.h"
#import "iRate.h"
#import "FBViewController.h"
#import <StoreKit/StoreKit.h>
#import "GAI.h"
#import "GAIDictionaryBuilder.h"

#include "stdint.h"

static NSString *const kTrackingId = @"UA-18645968-12";

@implementation FBAppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize dataHandler = _dataHandler;

+ (FBAppDelegate *)application
{
	return (FBAppDelegate *)[UIApplication sharedApplication].delegate;
}

- (void) copyFolder
{
    BOOL success1;
    NSFileManager *fileManager1 = [NSFileManager defaultManager];
    fileManager1.delegate = self;
    NSError *error1;
    NSArray *paths1 = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory1 = [paths1 objectAtIndex:0];
    NSString *writableDBPath1 = [documentsDirectory1 stringByAppendingPathComponent:@"/FaceBlendResources"];
    success1 = [fileManager1 fileExistsAtPath:writableDBPath1];
    if (success1 )
    {
        NSString *defaultDBPath1 = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"FaceBlendResources"];
        debugLog(@"default path %@",defaultDBPath1);
        if (![[NSFileManager defaultManager] fileExistsAtPath:writableDBPath1])
            [fileManager1 copyItemAtPath:defaultDBPath1 toPath:writableDBPath1 error:&error1];
    }
    else
    {
        if (![[NSFileManager defaultManager] fileExistsAtPath:writableDBPath1])
            [[NSFileManager defaultManager] createDirectoryAtPath:writableDBPath1 withIntermediateDirectories:NO attributes:nil error:&error1];
       
        NSString *stringPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0]stringByAppendingPathComponent:RESOURCE_FOLDER];

        NSError *error = nil;
        if (![[NSFileManager defaultManager] fileExistsAtPath:stringPath])
            [[NSFileManager defaultManager] createDirectoryAtPath:stringPath withIntermediateDirectories:NO attributes:nil error:&error];
        
        NSString *str;
        NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"FaceImages" inManagedObjectContext:self.managedObjectContext];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDesc];
        NSArray *objects=[self.managedObjectContext executeFetchRequest:request error:&error];
        int i = 0;
//        NSArray *imageNames = [NSArray arrayWithObjects:@"FB_1.jpg", @"FB_4.jpg", @"FB_5.jpg", @"FB_7.jpg", @"FB_9.jpg", @"FB_11.jpg", @"FB_12.jpg", @"FB_13.jpg", nil];
        for (NSManagedObject *info in objects)
        {
            NSString *path = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"FB_%d",i+1] ofType:@"jpg"];
            NSString *imageName = [NSString stringWithFormat:@"FB_%d.jpg",i+1];
//            NSString *imageName = [imageNames objectAtIndex:i];
            NSString *fileName = [stringPath stringByAppendingFormat:@"/%@",imageName];
            UIImage *image = [UIImage imageWithContentsOfFile:path];
            NSData *data = UIImageJPEGRepresentation(image, 1.0);
            [data writeToFile:fileName atomically:YES];
            
            str = [NSString stringWithFormat:@"%@",[info valueForKey:@"faceImage"]];
            [info setValue:fileName forKey:@"faceImage"];
            if (i == 2 || i == 3 || i == 1 || i == 7)
                [info setValue:[NSNumber numberWithBool:YES] forKey:@"isMom"];
            else
                [info setValue:[NSNumber numberWithBool:NO] forKey:@"isMom"];
            i++;
            if (![self.managedObjectContext save:&error])
            {
                NSLog(@"error: %@", [error localizedDescription]);
            }
        }

    }
}

- (BOOL)fileManager:(NSFileManager *)fileManager shouldProceedAfterError:(NSError *)error copyingItemAtPath:(NSString *)srcPath toPath:(NSString *)dstPath{
    if ([error code] == 516) //error code for: The operation couldn’t be completed. File exists
        return YES;
    else
        return NO;
}

- (void)copyFile:(NSString*)filename
{
    NSFileManager *fmngr = [[NSFileManager alloc] init];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:filename ofType:nil];
    NSError *error;
    
    NSString *stringPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0]stringByAppendingPathComponent:filename];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:stringPath])
    {
        if(![fmngr copyItemAtPath:filePath toPath:[NSString stringWithFormat:@"%@/Documents/%@", NSHomeDirectory(), filename] error:&error])
        {
            // handle the error
            NSLog(@"Error creating the database: %@", [error description]);
        }
    }
    else
    {
        NSLog(@"already have file");
    }
}

-(void)addSqliteFile
{
    [self copyFile:@"BabyMaker.sqlite-shm"];
    [self copyFile:@"BabyMaker.sqlite-wal"];
    [self copyFile:@"BabyMaker.sqlite"];
}

-(void)setWindowSize:(BOOL)increase
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {

        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        
        if(increase) {
                self.window.frame = CGRectMake(0, 0, self.window.frame.size.width,self.window.frame.size.height + 20);
        } else {
                //self.window.clipsToBounds =YES;

                self.window.frame = CGRectMake(0, 20, self.window.frame.size.width, self.window.frame.size.height - 20);
        }
    }
}

+ (void)initialize
{
    //set the bundle ID. normally you wouldn't need to do this
    //as it is picked up automatically from your Info.plist file
    //but we want to test with an app that's actually on the store
    [iRate sharedInstance].applicationBundleID = @"com.totoventure.babymaker";
	[iRate sharedInstance].onlyPromptIfLatestVersion = NO;
    
    //enable preview mode
    [iRate sharedInstance].previewMode = YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self addSqliteFile];
    self.dataHandler = [[FBDataHandler alloc]init];
    
    //[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"FIRSTSTARTUP"];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.viewController = [[FBViewController alloc] initWithNibName:@"FBViewController" bundle:nil];
    UINavigationController *navigationController = [[UINavigationController alloc]initWithRootViewController:self.viewController];

    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];
    self.viewController.managedObjectContext = self.managedObjectContext;
    [self copyFolder];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        
        //[application setStatusBarStyle:UIStatusBarStyleLightContent];
        
        self.window.clipsToBounds =YES;
        
        
        self.window.frame = CGRectMake(0, 20, self.window.frame.size.width, self.window.frame.size.height - 20);
    }
    
    self.tracker = [[GAI sharedInstance] trackerWithName:@"BabyMaker"
                                              trackingId:kTrackingId];
 
    // TODO: Temp code to make app pro version
//    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
//    [settings setBool:YES forKey:PRO_UPGRADE_ID];
    
    [self showPlayHaven:@"app_launch"];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    [self showPlayHaven:@"app_launch"];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    Chartboost *cb = [Chartboost sharedChartboost];
    cb.appId = CHARTBOOST_APP_ID;
    cb.appSignature = CHARTBOOST_APP_SIGNATURE;
    cb.delegate = self;
    [cb startSession];
    [cb showInterstitial:@"app_launch"];
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[NSNotificationCenter defaultCenter] postNotificationName:@"appFrombackground" object:self];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"BabyMaker.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:@"YES", NSMigratePersistentStoresAutomaticallyOption, @"YES", NSInferMappingModelAutomaticallyOption, nil];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)showPlayHaven:(NSString*)placement
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:PRO_UPGRADE_ID] == YES)
        return;
    
    PHPublisherContentRequest * request = [PHPublisherContentRequest requestForApp:@"42b68a73d0c14f1aaf6eb5e76ce3ac5c" secret:@"e1bf4489b19943e8b6258f1eaa2bcd44" placement:placement delegate:self];
    [request setShowsOverlayImmediately:YES];
    [request setAnimated:YES];
    [request send];
    
    [self setRequest:request];
}

- (void)logGoogleAnalytics:(NSString*)category action:(NSString*)action label:(NSString*)label value:(NSString*)value
{
    NSMutableDictionary *event =
    [[GAIDictionaryBuilder createEventWithCategory:category
                                            action:action
                                             label:label
                                             value:nil] build];
    [[GAI sharedInstance].defaultTracker send:event];
    [[GAI sharedInstance] dispatch];
}

#pragma mark - PHPublisherContentRequestDelegate
- (void)requestWillGetContent:(PHPublisherContentRequest *)request
{
    NSString *message = [NSString stringWithFormat:@"Getting content for placement: %@", request.placement];
    NSLog(@"%@", message);
}

- (void)requestDidGetContent:(PHPublisherContentRequest *)request
{
    NSString *message = [NSString stringWithFormat:@"Got content for placement: %@", request.placement];
    NSLog(@"%@", message);
}

- (void)request:(PHPublisherContentRequest *)request contentWillDisplay:(PHContent *)content
{
    NSString *message = [NSString stringWithFormat:@"Preparing to display content: %@",content];
    
    NSLog(@"%@", message);
}

- (void)request:(PHPublisherContentRequest *)request contentDidDisplay:(PHContent *)content
{
    //This is a good place to clear any notification views attached to this request.
    [_notificationView clear];
    
    NSString *message = [NSString stringWithFormat:@"Displayed content: %@",content];
    NSLog(@"%@", message);
}

- (void)request:(PHPublisherContentRequest *)request contentDidDismissWithType:(PHPublisherContentDismissType *)type
{
    NSString *message = [NSString stringWithFormat:@"[OK] User dismissed request: %@ of type %@",request, type];
    NSLog(@"%@", message);
    
    [self finishRequest];
}

- (void)request:(PHPublisherContentRequest *)request didFailWithError:(NSError *)error
{
    NSString *message = [NSString stringWithFormat:@"[ERROR] Failed with error: %@", error];
    NSLog(@"%@", message);
    [self finishRequest];
}

- (void)request:(PHPublisherContentRequest *)request unlockedReward:(PHReward *)reward
{
    NSString *message = [NSString stringWithFormat:@"Unlocked reward: %dx %@", reward.quantity, reward.name];
    NSLog(@"%@", message);
}

- (void)request:(PHPublisherContentRequest *)request makePurchase:(PHPurchase *)purchase
{
    NSString *message = [NSString stringWithFormat:@"Initiating purchase for: %dx %@", purchase.quantity, purchase.productIdentifier];
    NSLog(@"%@", message);
}

- (void)finishRequest
{
    //Cleaning up after a completed request
    self.request = nil;
}

@end
