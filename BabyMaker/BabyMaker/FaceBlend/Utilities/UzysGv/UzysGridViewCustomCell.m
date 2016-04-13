//
//  UzysGridViewCustomCell.m
//  UzysGridView
//
//  Created by Uzys on 11. 11. 10..
//  Copyright (c) 2011 Uzys. All rights reserved.
//

#import "UzysGridViewCustomCell.h"
#import "Constants.h"

@implementation UzysGridViewCustomCell

@synthesize backgroundView;
@synthesize backGroundImageView;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        // Background view
        self.backgroundView = [[[UIImageView alloc] initWithFrame:frame] autorelease];
        self.backgroundView.backgroundColor = [UIColor clearColor];
        self.backgroundView.image = [UIImage imageNamed:@"bg_thumbnail.png"];
        [self addSubview:self.backgroundView];
        
        self.backGroundImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.backGroundImageView.center = self.center;
        self.backGroundImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.backGroundImageView.clipsToBounds = YES;
        self.backGroundImageView.layer.cornerRadius = 5;
        self.backgroundColor = [UIColor clearColor];

        self.backgroundView.backgroundColor = [UIColor clearColor];

        self.backGroundImageView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.backGroundImageView];
        [self bringSubviewToFront:self.ButtonDelete];
    }
    return self;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // Background view
    self.backgroundView.frame = self.bounds;

    // Layout label background
    CGRect f = CGRectMake(1, 1, self.frame.size.width - 2, self.frame.size.height - 2);

    CGRect frame = CGRectInset(f, 1, 1);
    
    self.backGroundImageView.frame = frame;
}

- (void)dealloc
{
    [backgroundView release];
    [super dealloc];
}

@end
