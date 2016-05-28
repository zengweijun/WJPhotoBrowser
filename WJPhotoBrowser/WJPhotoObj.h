//
//  WJPhotoObj.h
//  WJPhotoBrowser
//
//  Created by 曾维俊 on 16/2/19.
//  Copyright © 2016年 曾维俊. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface WJPhotoObj : NSObject

// Must set properties
/** It's web URL、file URL or local image name */
@property (copy  , nonatomic) NSString    *photoURL;

/** It's the view that contain image object */
@property (strong, nonatomic) UIImageView *sourceImageView;


// Optional set properties
@property (strong, nonatomic) UIImage *placeholder;
@property (assign, nonatomic) BOOL     firstShow;


@end
