//
//  WebImageViewController.m
//  WJPhotoBrowser
//
//  Created by 曾维俊 on 16/5/26.
//  Copyright © 2016年 曾维俊. All rights reserved.
//



#import "WebImageViewController.h"
#import <UIImageView+WebCache.h>
#import "WJPhotoBrowser.h"

static inline NSArray *squareThumbImageUrls(){
    NSArray *array = @[
                       @{@"pic":@"http://testimg.isenba.com/upload/20151231/1_1451534440349434-1000-1348.jpg",
                         @"thumb":@"http://testimg.isenba.com/upload/20151231/1_1451534440349434-400-400.jpg"},
                       @{@"pic":@"http://testimg.isenba.com/upload/20151231/1_1451534443688732-980-1307.jpg",
                         @"thumb":@"http://testimg.isenba.com/upload/20151231/1_1451534443688732-400-400.jpg"},
                       @{@"pic":@"http://testimg.isenba.com/upload/20151231/1_1451534447533754-980-1307.jpg",
                         @"thumb":@"http://testimg.isenba.com/upload/20151231/1_1451534447533754-400-400.jpg"}
                       ];
    return array;
}

static NSString *bigImageUrl = @"http://testimg.isenba.com/upload/20160308/2_1457438058302737-1000-888.jpg";
static NSString *thumbImageUrl = @"http://testimg.isenba.com/upload/20160331/2_1459421861489562-372-255.jpg";

@interface WebImageViewController ()

@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *imageViews;

@end

@implementation WebImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    
    
    [self.imageViews enumerateObjectsUsingBlock:^(UIImageView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.userInteractionEnabled = YES;
        [obj addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewTap:)]];
        
        if (idx < 3) {
            [obj sd_setImageWithURL:[NSURL URLWithString:squareThumbImageUrls()[idx][@"thumb"]]];
        } else if (idx == 3) {
            [obj sd_setImageWithURL:[NSURL URLWithString:bigImageUrl]];
        } else if (idx == 4) {
            [obj sd_setImageWithURL:[NSURL URLWithString:thumbImageUrl]];
        }
        obj.tag = idx;
    }];
}

- (void)imageViewTap:(UITapGestureRecognizer *)gsr {
    NSUInteger currentIndex = gsr.view.tag;
#if 0
    // Normal type
    NSMutableArray *photos = [NSMutableArray array];
    for (NSInteger i = 0; i < self.imageViews.count; i++) {
        WJPhotoObj *photo = [[WJPhotoObj alloc] init];
        UIImageView *iv = self.imageViews[i];
        photo.sourceImageView = iv;
        if (i < 3) {
            photo.photoURL = squareThumbImageUrls()[i][@"pic"];
        } else if (i == 3) {
            photo.photoURL = bigImageUrl;
        } else if (i == 4) {
            photo.photoURL = thumbImageUrl;
        }
        [photos addObject:photo];
    }
    
    WJPhotoBrowser *browser = [[WJPhotoBrowser alloc] init];
    browser.currentIndex = currentIndex;
    browser.photos = photos;
    [browser show];
    
#else
    // Block type
    [WJPhotoBrowser show:currentIndex photosCb:^NSArray<WJPhotoObj *> *(WJPhotoBrowser *browser) {
//        browser.usePopAnimation = YES;
        
        // 返回数据源数组
        NSMutableArray *photos = [NSMutableArray array];
        for (NSInteger i = 0; i < self.imageViews.count; i++) {
            WJPhotoObj *photo = [[WJPhotoObj alloc] init];
            UIImageView *iv = self.imageViews[i];
            photo.sourceImageView = iv;
            if (i < 3) {
                photo.photoURL = squareThumbImageUrls()[i][@"pic"];
            } else if (i == 3) {
                photo.photoURL = bigImageUrl;
            } else if (i == 4) {
                photo.photoURL = thumbImageUrl;
            }
            [photos addObject:photo];
        }
        return photos;
    }];
#endif
}


@end
