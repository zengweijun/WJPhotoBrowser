//
//  WJPhotoBrowser.h
//  WJPhotoBrowser
//
//  Created by 曾维俊 on 16/2/17.
//  Copyright © 2016年 曾维俊. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WJPhotoObj.h"

@interface WJPhotoBrowser : UIViewController
@property (assign, nonatomic) NSUInteger sourceIndex;
@property (strong, nonatomic) NSArray *photos;

@property (assign, nonatomic) BOOL zoomUnderView;

- (void)show;

#pragma mark - private
@property (assign, nonatomic, readonly) CGAffineTransform windowTransform;

@end
