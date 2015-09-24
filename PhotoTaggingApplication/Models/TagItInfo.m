//
//  TagItInfo.m
//  PhotoTaggingApplication
//
//  Created by Weboniselab on 09/09/15.
//  Copyright (c) 2015 weboniselab. All rights reserved.
//

#import "TagItInfo.h"

@implementation TagItInfo

-(TagItInfo *)init{
    _uid=@"-1";
    _image = @"";
    _title = @"";
    _tag = @"";
    _latitude = @"";
    _longitude = @"";
    return self ;
}

@end
