//
//  WJPhotoItem.h
//  WJPhotoBrowser
//
//  Created by 曾维俊 on 2017/12/25.
//  Copyright © 2017年 曾维俊. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WJPhotoItem <NSObject>

/** 必须设置，要显示的图片原来所在的imageView */
@property (nonatomic, strong) UIImageView *sourceImageView;

/** 加载本地图片或者占位图 */
@property (nonatomic, strong) UIImage *image;

/** 此属性无需设置 */
@property (nonatomic, assign) BOOL firstShow;

@end
