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
#import "WJPhoto.h"

@interface WebImageViewController ()

@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *imageViews;

@end

@implementation WebImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.imageViews enumerateObjectsUsingBlock:^(UIImageView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.userInteractionEnabled = YES;
        [obj addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewTap:)]];
        obj.tag = idx;
//        [obj sd_setImageWithURL:[NSURL URLWithString:@"imageUrl"] completed:NULL];
    }];
}

- (void)imageViewTap:(UITapGestureRecognizer *)gsr {
    NSUInteger currentIndex = gsr.view.tag;

    // 1.请在此处构造数据源,数据源需遵循 'WJPhotoItem' 协议
    NSMutableArray<id<WJPhotoItem>> *photos = [NSMutableArray<id<WJPhotoItem>> array];
    [self.imageViews enumerateObjectsUsingBlock:^(UIImageView *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        WJPhoto *photo = [WJPhoto new];
        photo.sourceImageView = obj;
        [photos addObject:photo];
    }];
    
    // 2.展示大图
     wj_weakify(self);
    [WJPhotoBrowser show:photos currentIndex:currentIndex].loadImageCb(^(WJPhotoBrowser *theBrowser, NSUInteger atIndex, UIImageView *imageView, void(^loadFinished)(NSUInteger atIndex, UIImage *image)){
        wj_strongify(self)
        // __strong __typeof(&*ws) sf = ws;
        
        // 3.加载图片(选择各自模块的加载方式)。eg.
        uint64_t seconds = 0;
        WJPhoto *photo = theBrowser.photos[atIndex];
        if (photo.firstShow) {
            seconds = 2;
        }
        NSString *path = [self imageUrls][atIndex];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            UIImage *image = [UIImage imageWithContentsOfFile:path];
            
            // 4.加载完成后请回调
            loadFinished(atIndex, image);
        });
    });
}

- (NSArray<NSString *> *)imageUrls {
    return @[
             [[NSBundle mainBundle] pathForResource:@"0" ofType:@"png"],
             [[NSBundle mainBundle] pathForResource:@"1" ofType:@"png"],
             [[NSBundle mainBundle] pathForResource:@"2" ofType:@"png"],
             [[NSBundle mainBundle] pathForResource:@"3" ofType:@"png"],
             [[NSBundle mainBundle] pathForResource:@"4" ofType:@"png"],
             [[NSBundle mainBundle] pathForResource:@"5" ofType:@"png"],
             [[NSBundle mainBundle] pathForResource:@"6" ofType:@"png"]
             ];
}

@end
