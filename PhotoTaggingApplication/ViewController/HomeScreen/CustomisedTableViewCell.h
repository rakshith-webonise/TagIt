//
//  CustomisedTableViewCell.h
//  PhotoTaggingApplication
//
//  Created by weboniselab1 on 07/09/2015.
//  Copyright (c) 2015 weboniselab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomisedTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelTag;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewCustomisedCell;

@end
