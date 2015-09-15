//
//  CustomisedTableViewCell.m
//  PhotoTaggingApplication
//
//  Created by weboniselab1 on 07/09/2015.
//  Copyright (c) 2015 weboniselab. All rights reserved.
//

#import "CustomisedTableViewCell.h"

@implementation CustomisedTableViewCell
@synthesize imageViewCustomisedCell;
- (void)awakeFromNib {
    CALayer *imageLayer = [imageViewCustomisedCell layer];
    [imageLayer setCornerRadius:12];
    [imageLayer setBorderWidth:1];
    //on branch trail
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
