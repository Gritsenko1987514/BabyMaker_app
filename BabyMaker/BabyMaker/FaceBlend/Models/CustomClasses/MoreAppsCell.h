//
//  MoreAppsCell.h
//  FaceBlend
//
//  Created by user on 21/08/13.
//  Copyright (c) 2013 QburstTechnologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MoreAppsCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel *appNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *appDescLabel;
@property (nonatomic, weak) IBOutlet UIImageView *appThumbnailImageView;
- (IBAction)appButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *appButton;

@end
