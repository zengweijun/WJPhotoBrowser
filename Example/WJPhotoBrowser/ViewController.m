//
//  ViewController.m
//  WJPhotoBrowser
//
//  Created by 曾维俊 on 16/2/17.
//  Copyright © 2016年 曾维俊. All rights reserved.
//

#import "ViewController.h"
#import "WJPhotoBrowser.h"
#import "WJPhoto.h"

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
    
    // 1.请在此处构造数据源,数据源需遵循 'WJPhotoItem' 协议
    NSMutableArray<id<WJPhotoItem>> *photos = [NSMutableArray<id<WJPhotoItem>> array];
    [self.imageViews enumerateObjectsUsingBlock:^(UIImageView *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        WJPhoto *photo = [WJPhoto new];
        photo.sourceImageView = obj;
        [photos addObject:photo];
    }];
    
    // 2.展示大图
    wj_weakify(self)
    WJPhotoBrowser *browser = [WJPhotoBrowser show:photos currentIndex:currentIndex].loadImageCb(^(WJPhotoBrowser *theBrowser, NSUInteger atIndex, UIImageView *imageView, void(^loadFinished)(NSUInteger atIndex, UIImage *image)){
        // __strong __typeof(&*ws) sf = ws;
        
        // 3.加载图片(选择各自模块的加载方式)。eg.
        WJPhoto *photo = theBrowser.photos[atIndex];
        
        // 4.加载完成后请回调(网络or本地)
        loadFinished(atIndex, photo.sourceImageView.image);
        
    }).longPressCb(^(WJPhotoBrowser *theBrowser, NSUInteger atIndex, UIImage *image){
        wj_strongify(self)
        // 长按图片手势回调
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"保存图片" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"保存图片");
        }];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:action];
        [self presentViewController:alertController animated:YES completion:NULL];
    }).didDismissCb(^{
        // __strong __typeof(&*ws) sf = ws;
        
        // 图片浏览器销毁回调
    });
    
    // 自定义底部条
    [browser setSetupToolBar:^UIView *(WJPhotoBrowser *theBrowser, UIView *spuerView) {
        if (theBrowser.photos.count <= 1) {
            return nil;
        }
        CGFloat pageControlW = 200;
        CGFloat pageControlH = 20;
        CGFloat pageControlX = ([UIScreen mainScreen].bounds.size.width - pageControlW)*0.5;
        CGFloat pageControlY = [UIScreen mainScreen].bounds.size.height - pageControlH - 20;
        UIPageControl *pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(pageControlX, pageControlY, pageControlW, pageControlH)];
        pageControl.numberOfPages = theBrowser.photos.count;
        pageControl.currentPage = theBrowser.currentIndex;
        pageControl.userInteractionEnabled = NO;
        [spuerView addSubview:pageControl];
        return pageControl;
    }];
    
    [browser setPageDidChangeToIndex:^(WJPhotoBrowser *theBrowser, NSUInteger atIndex, UIImage *image) {
        UIPageControl *pageControl = (UIPageControl *)theBrowser.toolBar;
        pageControl.currentPage = atIndex;
    }];
    
    // 自定义顶部条
    [browser setSetupNavBar:^UIView *(WJPhotoBrowser *theBrowser, UIView *superView) {
        // custom the view and return it
        return nil;
    }];
}

@end
