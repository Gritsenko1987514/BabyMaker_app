//
//  FBMoreAppsViewController.m
//  FaceBlend
//
//  Created by user on 21/08/13.
//  Copyright (c) 2013 QburstTechnologies. All rights reserved.
//

#import "FBMoreAppsViewController.h"
#import "MoreAppsCell.h"
#import "Constants.h"
#import "FBAppDelegate.h"

@interface FBMoreAppsViewController () {
    NSArray * appNames;
    NSArray * appDescription;
    NSArray * appThumbNails;
    NSArray * appUrls;
}

@end

@implementation FBMoreAppsViewController

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        [self setNeedsStatusBarAppearanceUpdate];
    }
    [self setTitleForBlendViewController];
    [self setMoreApplicationInformations];
	
}

-(void)setTitleForBlendViewController
{
    self.viewTitle.font = [UIFont fontWithName:APPLICATION_FONT size:24];
}

-(void)viewDidAppear:(BOOL)animated
{
    [[FBAppDelegate application] logGoogleAnalytics:@"UI" action:@"ViewSwitch" label:@"MoreApps - FBMoreAppsViewController" value:nil];
    
    self.navigationController.navigationBarHidden = YES;
    CGRect tableFrame = self.appListTableView.frame;
    //tableFrame.size = self.appListTableView.contentSize;
    self.appListTableView.frame = tableFrame;
}

-(void)setMoreApplicationInformations
{
    
    appNames = [NSArray arrayWithObjects: @"BABY MAKER PRO", @"WORKTIME", @"MY BRACKET", @"BUBBLE", @"LOCK", nil];
    appDescription = [NSArray arrayWithObjects: @"SAVE ALL OF YOUR MARKED FACES FOR FUTURE BLENDS", @"WORK SCHEDULE, SHIFT CALENDAR & JOB MANAGER", @"TOURNAMENT CREATOR AND MANAGER FOR AMATEUR SPORTS", @"ADD COMIC SPEECH BUBBLES TO YOUR PHOTOS", @"HIDE PHOTO+VIDEO AND STORE SECRET NOTES WITH MY PRIVATE PICTURE VAULT", nil];
    appThumbNails = [NSArray arrayWithObjects: @"icon_upgrade.png", @"icon_worktime.png", @"icon_bracket.png", @"icon_bubble.png", @"icon_lock.png", nil];
    appUrls = [NSArray arrayWithObjects: @"", @"itms://itunes.apple.com/us/app/worktime-work-schedule-shift/id594764457?mt=8", @"itms://itunes.apple.com/us/app/my-bracket-tournament-creator/id570129169?mt=8", @"itms://itunes.apple.com/us/app/bubble-speech-text-on-photos/id630851451?mt=8", @"itms://itunes.apple.com/us/app/lock-hide-photo+video-store/id664720821?mt=8", nil];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)appButtonClicked:(UIButton *)button
{
    debugLog(@"%d",button.tag);
    if (button.tag == 0)
    {
            debugLog(@"Upgrade required");
        purchaseManager = [[QBInAppPurchaseManager alloc]initWithNibName:@"QBAlertInAppPurchaseManager" bundle:nil];
        purchaseManager.moreAppPage = YES;
        purchaseManager.delegate = self;
        purchaseManager.view.frame = self.view.frame;
        [self.view addSubview:purchaseManager.view];
        
    }
    else
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[appUrls objectAtIndex:button.tag]]];
    }
}

#pragma UITableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [appNames count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"MoreAppsCell";
    
    MoreAppsCell *cell = (MoreAppsCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MoreAppsCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    if(indexPath.row>=[appNames count])
    {
        [cell.appButton setHidden:YES];
    } else
    {
        if(indexPath.row==0)
        {
            NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
            BOOL isProVersion = [settings boolForKey:PRO_UPGRADE_ID];
            if (isProVersion)
            {
                [cell.appButton removeFromSuperview];
            }
            else
            {
                [cell.appButton setBackgroundImage:[UIImage imageNamed:@"btn_upgrade.png"] forState:UIControlStateNormal];
            }
            cell.appButton.tag = indexPath.row;
        }
        else
        {
            [cell.appButton setBackgroundImage:[UIImage imageNamed:@"btn_free.png"] forState:UIControlStateNormal];

        }
        [cell.appButton addTarget:self action:@selector (appButtonClicked:)
                 forControlEvents:UIControlEventTouchUpInside];

        [cell.appButton setHidden:NO];
        [cell.appButton setTag:indexPath.row];
 

        cell.appNameLabel.text = [appNames objectAtIndex:indexPath.row];
        cell.appDescLabel.text = [appDescription objectAtIndex:indexPath.row];
        [cell.appThumbnailImageView setImage:[UIImage imageNamed: [appThumbNails objectAtIndex:indexPath.row]]];
        cell.appNameLabel.font = [UIFont fontWithName:APPLICATION_FONT size:15];
        cell.appDescLabel.font = [UIFont fontWithName:APPLICATION_FONT size:10];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)viewDidUnload {
    [self setViewTitle:nil];
    [super viewDidUnload];
}

-(void)purchaseCompletedSuccessfully
{
    [self.appListTableView reloadData];
    CGRect tableFrame = self.appListTableView.frame;
    //tableFrame.size = self.appListTableView.contentSize;
    self.appListTableView.frame = tableFrame;
}

- (void)productRequestCompleted
{
    
}

@end
