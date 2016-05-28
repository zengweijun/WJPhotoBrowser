//
//  WJPhotoView.h
//  WJPhotoBrowser
//
//  Created by 曾维俊 on 16/5/26.
//  Copyright © 2016年 曾维俊. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WJPhotoBrowser, WJPhotoObj;
@interface WJPhotoView : UICollectionViewCell

@property (weak, nonatomic) WJPhotoBrowser *browser;
@property (strong, nonatomic) WJPhotoObj *photo;

@property (nonatomic, copy) void(^dismiss)();

- (void)saveImage;

@end
