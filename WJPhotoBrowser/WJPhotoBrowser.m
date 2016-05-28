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
#import "WJPhotoBrowserPrivate.h"

static NSString *const cellID = @"com.nius.photo_browser.id";

@interface WJPhotoBrowser () <
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout
>

@property (nonatomic, weak) UICollectionView *collectionView;
@property (nonatomic, weak) WJPhotoToolbar   *toolbar;

@property (nonatomic, assign) CGAffineTransform windowTransform;
@property (nonatomic, strong) UIColor *windowColor;

@end

@implementation WJPhotoBrowser

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        _currentIndex = 0;
        _usePopAnimation = NO;
        _animatedZoomUnderView = YES;
        
        _windowColor = [UIColor whiteColor];
        _windowTransform = CGAffineTransformIdentity;
    }
    return self;
}

+ (void)show:(NSUInteger)currentIndex photosCb:(NSArray<WJPhotoObj *> *(^)(WJPhotoBrowser *))photosCb {
    WJPhotoBrowser *browser = [[self alloc] init];
    NSArray<WJPhotoObj *> *photos = nil;
    if (photosCb) {photos =  photosCb(browser);}
    browser.currentIndex = currentIndex;
    browser.photos = photos;
    [browser show];
}

- (void)show {
    NSAssert(self.photos.count > 0, @"photos不能为空!");
    __weak __typeof(&*self) ws = self;
    [self.photos enumerateObjectsUsingBlock:^(WJPhotoObj * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.firstShow = (idx == ws.currentIndex)?YES:NO;
    }];
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self.view];
    [window.rootViewController addChildViewController:self];
    _windowColor = window.backgroundColor;
    _windowTransform = window.transform;
    _toolbar.photos = _photos;
    _toolbar.currentIndex = _currentIndex;
}

- (void)dismiss {
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    window.backgroundColor = _windowColor;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // views
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
    flow.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flow.minimumInteritemSpacing = SPACE;
    flow.itemSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width + SPACE, [UIScreen mainScreen].bounds.size.height) collectionViewLayout:flow];
    collectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, SPACE);
    collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.pagingEnabled = YES;
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.backgroundColor = [UIColor clearColor];
    [collectionView registerClass:[WJPhotoView class] forCellWithReuseIdentifier:cellID];
    [self.view addSubview:collectionView];
    self.collectionView = collectionView;
    
    CGFloat barHeight = 44;
    CGFloat barWidth = self.view.frame.size.width;
    CGFloat barY = self.view.frame.size.height - barHeight;
    WJPhotoToolbar *toolbar = [[WJPhotoToolbar alloc] initWithFrame:CGRectMake(0, barY, barWidth, barHeight)];
    toolbar.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:toolbar];
    
    __weak __typeof(_collectionView) weakCollectionView = _collectionView;
    toolbar.saveImage = ^ (NSUInteger index){
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
        WJPhotoView *cell = (WJPhotoView *)[weakCollectionView cellForItemAtIndexPath:indexPath];
        [cell saveImage];
    };
    self.toolbar = toolbar;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    if (!_photos.count) return;
    [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_currentIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _photos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    WJPhotoView *photoView = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    WJPhotoObj *photo = _photos[indexPath.item];
    photoView.browser = self;
    photoView.photo = photo;
    __weak __typeof(&*self) ws = self;
    photoView.dismiss = ^ {[ws dismiss];};
    return photoView;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // update tool bar
    NSUInteger page = scrollView.contentOffset.x / scrollView.bounds.size.width;
    _toolbar.currentIndex = page;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"%s", __func__);
}

- (void)dealloc {
    NSLog(@"%s", __func__);
    _collectionView.delegate = nil;
    _collectionView.dataSource = nil;
    _windowColor = nil;
}

@end
