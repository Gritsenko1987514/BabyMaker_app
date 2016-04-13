//
//  FBMoreAppsViewController.h
//  FaceBlend
//
//  Created by user on 21/08/13.
//  Copyright (c) 2013 QburstTechnologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QBInAppPurchaseManager.h"

@interface FBMoreAppsViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,QBInAppPurchaseDelegate>
{
    QBInAppPurchaseManager *purchaseManager;
}
@property (weak, nonatomic) IBOutlet UILabel *viewTitle;
@property (strong, nonatomic) IBOutlet UITableView *appListTableView;
- (IBAction)backButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *bgView;

@end
