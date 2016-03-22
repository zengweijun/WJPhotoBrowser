//
//  WJPhotoToolbar.h
//  SenBa
//
//  Created by 曾维俊 on 16/3/2.
//  Copyright © 2016年 曾维俊. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WJPhotoToolbar : UIView
@property (strong, nonatomic) NSArray *photos;
@property (assign, nonatomic) NSUInteger currentIndex;
@property (copy, nonatomic) void(^saveImage)(NSUInteger index);

@end
