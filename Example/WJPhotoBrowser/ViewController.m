//
//  ViewController.m
//  WJPhotoBrowser
//
//  Created by 曾维俊 on 16/2/17.
//  Copyright © 2016年 曾维俊. All rights reserved.
//

#import "ViewController.h"
#import "WJPhotoBrowser.h"

@interface ViewController ()

@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *imageViews;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    [self.imageViews enumerateObjectsUsingBlock:^(UIImageView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.userInteractionEnabled = YES;
        obj.tag = idx;
        [obj addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewTap:)]];
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
        photo.photoURL = [NSString stringWithFormat:@"%zd", i];
        [photos addObject:photo];
    }
    
    WJPhotoBrowser *browser = [[WJPhotoBrowser alloc] init];
    browser.currentIndex = currentIndex;
    browser.photos = photos;
    browser.usePopAnimation = YES;
    [browser show];
    
#else
    // Block type
    [WJPhotoBrowser show:currentIndex photosCb:^NSArray<WJPhotoObj *> *(WJPhotoBrowser *browser) {
        browser.usePopAnimation = YES;
        //browser.slidingCloseGesture = NO;
        
        // 返回数据源数组
        NSMutableArray *photos = [NSMutableArray array];
        for (NSInteger i = 0; i < self.imageViews.count; i++) {
            WJPhotoObj *photo = [[WJPhotoObj alloc] init];
            UIImageView *iv = self.imageViews[i];
            photo.sourceImageView = iv;
            photo.photoURL = [NSString stringWithFormat:@"%zd", i];
            [photos addObject:photo];
        }
        return photos;
    }];
#endif
}

@end
