//
//  WJTapDetectingView.h
//  WJPhotoPickerController
//
//  Created by 曾维俊 on 15/12/24.
//  Copyright © 2015年 曾维俊. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol WJTapDetectingViewDelegate;
@interface WJTapDetectingView : UIView
@property (weak, nonatomic) IBOutlet id<WJTapDetectingViewDelegate> tapDelegate;

@end
@protocol WJTapDetectingViewDelegate <NSObject>
@optional
- (void)view:(UIView *)view singleTapDetected:(CGPoint)touchPoint;
- (void)view:(UIView *)view doubleTapDetected:(CGPoint)touchPoint;

@end