//
//  WJPhotoBrowser.h
//  WJPhotoBrowser
//
//  Created by 曾维俊 on 16/2/17.
//  Copyright © 2016年 曾维俊. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WJPhotoItem.h"

#define wj_weakify(var) __weak typeof(var) WJWeak_##var = var;
#define wj_strongify(var) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
__strong typeof(var) var = WJWeak_##var; \
_Pragma("clang diagnostic pop")

@class WJPhotoBrowser;
typedef void(^WJDidDismissAction)(void);
typedef void(^WJLongPressAction)(WJPhotoBrowser *theBrowser, NSUInteger atIndex, UIImage *image);
typedef void(^WJLoadImageAction)(WJPhotoBrowser *theBrowser, NSUInteger atIndex, UIImageView *imageView, void(^loadFinished)(NSUInteger atIndex, UIImage *image));

typedef UIView *(^WJSetupNavBar)(WJPhotoBrowser *theBrowser, UIView *superView);
typedef UIView *(^WJSetupToolBar)(WJPhotoBrowser *theBrowser, UIView *superView);
typedef void(^WJPageDidChangeToIndex)(WJPhotoBrowser *theBrowser, NSUInteger atIndex, UIImage *image);

/** 大图查看器，请参照使用步骤 */
@interface WJPhotoBrowser : UIViewController

@property (nonatomic, weak, readonly) UIView *navBar;
@property (nonatomic, weak, readonly) UIView *toolBar;

@property (nonatomic, strong) NSArray<id<WJPhotoItem>> *photos;
@property (nonatomic, assign) NSUInteger currentIndex;
@property (nonatomic, assign) BOOL slidingCloseGesture;
@property (nonatomic, assign) BOOL usePopAnimation;

@property (nonatomic, copy) WJSetupNavBar setupNavBar;
@property (nonatomic, copy) WJSetupToolBar setupToolBar;
@property (nonatomic, copy) WJPageDidChangeToIndex pageDidChangeToIndex;

+ (WJPhotoBrowser *)show:(NSArray<id<WJPhotoItem>> *)photos currentIndex:(NSUInteger)currentIndex;
- (WJPhotoBrowser *(^)(WJLongPressAction))longPressCb;
- (WJPhotoBrowser *(^)(WJLoadImageAction))loadImageCb;
- (WJPhotoBrowser *(^)(WJDidDismissAction))didDismissCb;
- (WJPhotoBrowser *)show;
- (WJPhotoBrowser *)hide;

@end
