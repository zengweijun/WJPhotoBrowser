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
@property (copy, nonatomic) NSString *photoURL; // webURL/fileURL

@property (strong, nonatomic) UIImage *placeholder;
@property (strong, nonatomic) UIImageView *sourceImageView;
@property (assign, nonatomic) BOOL isFirstShow;
@property (assign, nonatomic) NSUInteger photoIndex;

@end
