//
//  WJPhotoBrowser.m
//  WJPhotoBrowser
//
//  Created by 曾维俊 on 16/2/17.
//  Copyright © 2016年 曾维俊. All rights reserved.
//

#define SPACE 10

#import "WJPhotoBrowser.h"
#import "WJPhotoView.h"
#import "WJPhotoToolbar.h"

static NSString *const cellID = @"com.nius.photo_browser.id";

@interface WJPhotoBrowser () <
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout,
WJPhotoViewDelegate
> {
    UICollectionView *_collectionView;
    WJPhotoToolbar *_toolbar;
}

@end

@implementation WJPhotoBrowser

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        _sourceIndex = 0;
    }
    return self;
}

- (void)show {
    NSAssert(_photos.count > 0, @"photos不能为空!");
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self.view];
    [window.rootViewController addChildViewController:self];
    window.backgroundColor = [UIColor blackColor];
    
    _toolbar.photos = _photos;
    _toolbar.currentIndex = _sourceIndex;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // views
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
    flow.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flow.minimumInteritemSpacing = SPACE;
    flow.itemSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width + SPACE, [UIScreen mainScreen].bounds.size.height) collectionViewLayout:flow];
    _collectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, SPACE);
    _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.pagingEnabled = YES;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.showsVerticalScrollIndicator = NO;
    _collectionView.backgroundColor = [UIColor clearColor];
    [_collectionView registerClass:[WJPhotoView class] forCellWithReuseIdentifier:cellID];
    [self.view addSubview:_collectionView];
    
    self.view.backgroundColor = [UIColor blackColor];
    self.view.alpha = 0.0;
    
    CGFloat barHeight = 44;
    CGFloat barWidth = self.view.frame.size.width;
    CGFloat barY = self.view.frame.size.height - barHeight;
    _toolbar = [[WJPhotoToolbar alloc] initWithFrame:CGRectMake(0, barY, barWidth, barHeight)];
    _toolbar.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:_toolbar];
    
    __weak __typeof(_collectionView) weakCollectionView = _collectionView;
    _toolbar.saveImage = ^ (NSUInteger index){
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
        WJPhotoView *cell = (WJPhotoView *)[weakCollectionView cellForItemAtIndexPath:indexPath];
        [cell saveImage];
    };
}

- (UIImage *)getImageFromView:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    if (!_photos.count) return;
    [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_sourceIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _photos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    WJPhotoView *photoView = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    WJPhoto *photo = _photos[indexPath.item];
    photoView.delegate = self;
    photoView.browser = self;
    photoView.photo = photo;
    return photoView;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // update tool bar
    NSUInteger page = scrollView.contentOffset.x / scrollView.bounds.size.width;
    _toolbar.currentIndex = page;
}

- (void)dismissPhotoBrowser:(WJPhotoView *)photoView {
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    window.backgroundColor = [UIColor whiteColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"%s", __func__);
}

- (void)dealloc {
    NSLog(@"%s", __func__);
    _collectionView.delegate = nil;
    _collectionView.dataSource = nil;
}

@end
