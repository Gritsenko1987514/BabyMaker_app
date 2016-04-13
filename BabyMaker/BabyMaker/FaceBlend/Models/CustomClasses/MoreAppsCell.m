//
//  MoreAppsCell.m
//  FaceBlend
//
//  Created by user on 21/08/13.
//  Copyright (c) 2013 QburstTechnologies. All rights reserved.
//

#import "MoreAppsCell.h"

@implementation MoreAppsCell
@synthesize appNameLabel;
@synthesize appDescLabel;
@synthesize appThumbnailImageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)appsButton:(id)sender {
}
- (IBAction)appButtonClicked:(id)sender {
}
@end
