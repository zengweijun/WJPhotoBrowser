//
//  WJTapDetectingImageView.h
//  WJPhotoPickerController
//
//  Created by 曾维俊 on 15/12/24.
//  Copyright © 2015年 曾维俊. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WJTapDetectingImageViewDelegate;
@interface WJTapDetectingImageView : UIImageView
@property (weak, nonatomic) IBOutlet id<WJTapDetectingImageViewDelegate> tapDelegate;

@end
@protocol WJTapDetectingImageViewDelegate <NSObject>
@optional
- (void)imageView:(UIImageView *)imageView singleTapDetected:(CGPoint)touchPoint;
- (void)imageView:(UIImageView *)imageView doubleTapDetected:(CGPoint)touchPoint;
@end