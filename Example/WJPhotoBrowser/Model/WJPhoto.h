//
//  WJPhoto.h
//  WJPhotoBrowser
//
//  Created by 曾维俊 on 2017/12/25.
//  Copyright © 2017年 曾维俊. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WJPhotoItem.h"

@interface WJPhoto : NSObject<WJPhotoItem>

@property (nonatomic, strong) UIImageView *sourceImageView;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, assign) BOOL firstShow;

@end
