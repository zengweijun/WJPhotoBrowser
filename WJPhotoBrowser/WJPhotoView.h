//
//  WJPhotoView.h
//  WJPhotoBrowser
//
//  Created by 曾维俊 on 16/5/26.
//  Copyright © 2016年 曾维俊. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WJPhotoItem.h"

@class WJPhotoBrowser;
@interface WJPhotoView : UICollectionViewCell
@property (nonatomic, weak, readonly) UIImageView *imageView;
@property (nonatomic, weak) WJPhotoBrowser *browser;
@property (nonatomic, strong) id<WJPhotoItem> photo;
@property (nonatomic, assign) NSUInteger index;
@property (nonatomic, copy) void(^dismiss)(void);
@property (nonatomic, copy) void(^longPressCb)(WJPhotoView *thePhotoView, UIImage *image);
@property (nonatomic, copy) void(^loadImageCb)(WJPhotoView *thePhotoView, UIImageView *imageView, void(^loadFinished)(NSUInteger atIndex, UIImage *image));

- (void)hidePhotoBrowser;

@end

UIKIT_EXTERN NSString *const kWJPhotoBrowserShouldUpdateStatusBar;
