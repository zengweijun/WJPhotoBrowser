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
@property (assign, nonatomic) NSUInteger currentIndex;
@property (strong, nonatomic) NSArray<WJPhotoObj *> *photos;

// The background view is need to zoom animation when browser show, defaults is 'YES'.
@property (assign, nonatomic) BOOL animatedZoomUnderView;

/* 
  The image is displayed with pop animation, defaults is 'NO'.
  Note:if sourceImageView's image and this image that need to show are the same, you
        shuould to set the property in that better experience.
 */
@property (assign, nonatomic) BOOL usePopAnimation;

/*
  Add this gesture can be made easier for the user to close this photo browser, defaults is 'YES'
 */
@property (nonatomic, assign) BOOL slidingCloseGesture;

- (void)show;
+ (void)show:(NSUInteger)currentIndex photosCb:(NSArray<WJPhotoObj *> *(^)(WJPhotoBrowser *browser))photosCb;

@end
