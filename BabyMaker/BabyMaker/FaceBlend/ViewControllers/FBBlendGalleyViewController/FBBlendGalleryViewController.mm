//
//  FBBlendGalleryViewController.m
//  FaceBlend
//
//  Created by user on 22/08/13.
//  Copyright (c) 2013 QburstTechnologies. All rights reserved.
//

#import "FBBlendGalleryViewController.h"
#import "UzysGridViewCustomCell.h"
#import "Constants.h"
#import "ImageUtils.h"
#import "FBBlendImages.h"
#import "FBMoreAppsViewController.h"
#import "UIImage+FixOrientation.h"
#import "FBAppDelegate.h"

#define TITLE_SIZE 24 
#define NO_OF_COLUMNS 4
#define CELL_MARGIN 2


@interface FBBlendGalleryViewController () {
    NSMutableArray * galleryImages;
    
}

@end

@implementation FBBlendGalleryViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

#pragma mark- View Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    purchaseManager = [[QBInAppPurchaseManager alloc]initWithNibName:@"QBInAppPurchaseManager" bundle:nil];
    purchaseManager.delegate = self;
    purchaseManager.moreAppPage = NO;

    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        [self setNeedsStatusBarAppearanceUpdate];
    }

    [self setTitleForBlendViewController];
    [self setNoGalleryImageText];
    [self.noGalleryImageLabel setHidden:YES];
    [self setUpGalleryView];

    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getGalleryImagesAndAddtoScrollView];
    if (![[NSUserDefaults standardUserDefaults] boolForKey:PRO_UPGRADE_ID] == YES) {
        [self.proButton setHidden:NO];
    }
    else {
        [self.proButton setHidden:YES];
    }
        
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[FBAppDelegate application] logGoogleAnalytics:@"UI" action:@"ViewSwitch" label:@"HomvView - FBViewController" value:nil];
    
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidUnload {
    [self setTitle:nil];
    [self setGalleryViewFrame:nil];
    [super viewDidUnload];
}

- (IBAction)proButtonPressed:(id)sender
{
    [[[UIAlertView alloc] initWithTitle:@"Upgrade Application" message:@"Upgrade to pro" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Upgrade", @"Restore", nil] show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 1:
            [self showPlayHaven:@"store_open"];
            break;
        case 2:
            [purchaseManager restorePurchase:self];
            break;
        default:
            break;
    }
}


- (void)request:(PHPublisherContentRequest *)request makePurchase:(PHPurchase *)purchase
{
    [purchaseManager buyNow:self];
}

#pragma mark- Set text with font

-(void)setTitleForBlendViewController
{
    self.viewTitle.font = [UIFont fontWithName:APPLICATION_FONT size:TITLE_SIZE];
}

-(void)setNoGalleryImageText
{
    self.noGalleryImageLabel.text = [NSString stringWithFormat:@"You have not created any blends yet! Tap + to create one."];
    self.noGalleryImageLabel.font = [UIFont fontWithName:APPLICATION_FONT size:16];
}

#pragma mark- Show Alert

-(void)showNoGalleryImageAlert {
    
    [self.noGalleryImageLabel setHidden:NO];
    [self.view bringSubviewToFront:self.noGalleryImageLabel];
    
}


#pragma mark- Fetch and show gallery Images

-(void)getGalleryImagesAndAddtoScrollView
{
    [self getImagesFromDocumentsFolder];
//    [self removeInnerViews];
    if(galleryImages != nil && galleryImages.count > 0) {
       
            NSInteger noOfRows =  [galleryImages count]% NO_OF_COLUMNS  == 0 ? [galleryImages count]/NO_OF_COLUMNS :[galleryImages count]/NO_OF_COLUMNS + 1;
        
         self.galleryView.numberOfColumns = NO_OF_COLUMNS;
         self.galleryView.numberOfRows = noOfRows;
        [self.galleryView reloadData];
    } else {
        [self showNoGalleryImageAlert];
    }
}


-(void)getImagesFromDocumentsFolder
{
    NSArray * fileNames = [ImageUtils getImagesPathsFromDocumentsFolder:YES];
    NSEnumerator*   reverseEnumerator = [fileNames reverseObjectEnumerator];

    galleryImages = [[NSMutableArray alloc]init];
    for ( NSString *fileName in reverseEnumerator) {
        //        UIImage *img = [UIImage imageWithContentsOfFile:fileName];
        [galleryImages addObject:fileName];
        
    }
    
    
    
}

-(void)removeInnerViews {
    for(UIScrollView * sv in self.galleryView.subviews) {
        for(UzysGridViewCustomCell * uzygrid in sv.subviews) {
            for(UIImageView * iv in uzygrid.subviews) {
                if([iv class] == [UIImageView class] )
                    iv.image = nil;
            }
        
        }
        
    }

}

-(void)setUpGalleryView
{

    [self.galleryView.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    [self.galleryView removeFromSuperview];
    NSInteger noOfRows =  [galleryImages count]% NO_OF_COLUMNS  == 0 ? [galleryImages count]/NO_OF_COLUMNS :[galleryImages count]/NO_OF_COLUMNS + 1;
    
     CGRect frame = CGRectMake(self.galleryViewFrame.frame.origin.x + 8, self.galleryViewFrame.frame.origin.y + 4, self.galleryViewFrame.frame.size.width - 8, self.galleryViewFrame.frame.size.height - 8);
    self.galleryView = [[UzysGridView alloc] initWithFrame:frame numOfRow:noOfRows numOfColumns:NO_OF_COLUMNS cellMargin:CELL_MARGIN];
//    self.galleryView.frame.origin = CGPointMake(self.galleryViewFrame.frame.origin.x+4,self.galleryViewFrame.frame.origin.y);
    self.galleryView.center = self.galleryViewFrame.center;
    self. galleryView.delegate = self;
    self.galleryView.dataSource = self;
//    self.galleryView.backgroundColor = [UIColor blackColor];
    [self.view addSubview: self.galleryView];
}




#pragma mark- UzysGridViewDataSource


-(NSInteger) numberOfCellsInGridView:(UzysGridView *)gridview
{
    return [galleryImages count];
}

-(UzysGridViewCell *)gridView:(UzysGridView *)gridview cellAtIndex:(NSUInteger)index
{
    NSString *thumbName = [galleryImages objectAtIndex:index];
    
    NSString *thumbFilePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0]stringByAppendingPathComponent:RESULT_THUMBS_FOLDER];
    
    NSError *error = nil;
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:thumbFilePath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:thumbFilePath withIntermediateDirectories:NO attributes:nil error:&error];
    }
    
    
    NSString *thumbFileName = [thumbFilePath stringByAppendingFormat:@"/%@",thumbName];
    
    UIImage * thumbImage = [UIImage imageWithContentsOfFile:thumbFileName];
    CGSize newSize = thumbImage.size;
    
    UzysGridViewCustomCell *cell = [[UzysGridViewCustomCell alloc] initWithFrame:CGRectMake(0, 0, newSize.width, newSize.height)];
    cell.notRearrangable = YES;
    cell.deletable = YES;
    cell.frame = CGRectMake(0, 0, newSize.width, newSize.height);
    thumbImage = [thumbImage imageWithImage:thumbImage cornerRadius:10 withSize:newSize];
    cell.backGroundImageView.image = thumbImage;
    [cell.backGroundImageView setHighlighted:NO];
    
    return cell;
}

- (void)showChartboost:(NSString *)str
{
    Chartboost *cb = [Chartboost sharedChartboost];
    cb.appId = CHARTBOOST_APP_ID;
    cb.appSignature = CHARTBOOST_APP_SIGNATURE;
    cb.delegate = nil;
    [cb startSession];
    [cb showInterstitial:str];
}

#pragma mark- UzysGridViewDelegate

-(void) gridView:(UzysGridView *)gridView didSelectCell:(UzysGridViewCell *)cell atIndex:(NSUInteger)index
{
    [self showPlayHaven:@"taps_thumbnail"];
    [self showChartboost:@"taps_thumbnail"];
    FBBlendImages * objBlend = [[FBBlendImages alloc]initWithNibName:@"FBBlendImages" bundle:nil];
    objBlend.isGalleryFullView = YES;
    objBlend.shownImageIndex = index;
    
    [self.navigationController pushViewController:objBlend animated:YES];
}



#pragma mark- IBActions
- (IBAction)newButtonPressed:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)moreButtonPressed:(id)sender {
    
    [self showPlayHavenMoreApps];
    
//    FBMoreAppsViewController * moreAppsViewController = [[FBMoreAppsViewController alloc]initWithNibName:@"FBMoreAppsViewController" bundle:nil];
//    
//    [self.navigationController pushViewController:moreAppsViewController animated:YES];
}

- (void)showPlayHavenMoreApps
{
    PHPublisherContentRequest * request = [PHPublisherContentRequest requestForApp:@"42b68a73d0c14f1aaf6eb5e76ce3ac5c" secret:@"e1bf4489b19943e8b6258f1eaa2bcd44" placement:@"more_games" delegate:self];
    [request setShowsOverlayImmediately:YES];
    [request setAnimated:YES];
    [request send];

}

- (void)showPlayHaven:(NSString *)placement
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:PRO_UPGRADE_ID] == YES)
        return;
    
    PHPublisherContentRequest * request = [PHPublisherContentRequest requestForApp:@"42b68a73d0c14f1aaf6eb5e76ce3ac5c" secret:@"e1bf4489b19943e8b6258f1eaa2bcd44" placement:placement delegate:self];
    [request setShowsOverlayImmediately:YES];
    [request setAnimated:YES];
    [request send];
}
@end
