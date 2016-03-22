//
//  WJPhotoView.h
//  WJPhotoBrowser
//
//  Created by 曾维俊 on 16/2/17.
//  Copyright © 2016年 曾维俊. All rights reserved.
//

#define WJPhotoViewAnimationDuration 0.4

#import <UIKit/UIKit.h>
@class WJPhotoView, WJPhoto, WJPhotoBrowser;
@protocol WJPhotoViewDelegate <NSObject>
@optional
- (void)dismissPhotoBrowser:(WJPhotoView *)photoView;
@end

@interface WJPhotoView : UICollectionViewCell
@property (weak, nonatomic) id<WJPhotoViewDelegate> delegate;
@property (weak, nonatomic) WJPhotoBrowser *browser;
@property (copy, nonatomic) WJPhoto *photo;

- (void)saveImage;

@end
