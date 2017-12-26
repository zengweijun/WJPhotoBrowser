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

@interface WJPhotoBrowser () < UICollectionViewDataSource, UICollectionViewDelegateFlowLayout >

@property (nonatomic, copy) WJLongPressAction longPressCbKey;
@property (nonatomic, copy) WJLoadImageAction loadImageCbKey;
@property (nonatomic, copy) WJDidDismissAction didDismissCbKey;

@property (nonatomic, assign) UIStatusBarStyle statusBarStyle;
@property (nonatomic, strong) UIColor *windowColor;

@property (nonatomic, weak) UICollectionView *collectionView;
@property (nonatomic, weak) WJPhotoView *displayPhotoView;

@property (nonatomic, assign) BOOL statusBarShouldUpdate;
@property (nonatomic, assign) BOOL statusBarHidden;
@property (nonatomic, assign) UIStatusBarAnimation statusBarAnimationType;

@end

@implementation WJPhotoBrowser

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self initialized];
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initialized];
    }
    return self;
}

- (void)initialized {
    _currentIndex = 0;
    _usePopAnimation = YES;
    _slidingCloseGesture = YES;
    _statusBarShouldUpdate = NO;
    _statusBarHidden = NO;
    _statusBarAnimationType = UIStatusBarAnimationNone;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateStatusBar:) name:kWJPhotoBrowserShouldUpdateStatusBar object:nil];
}

+ (WJPhotoBrowser *)show:(NSArray<id<WJPhotoItem>> *)photos currentIndex:(NSUInteger)currentIndex {
    WJPhotoBrowser *photoBrowser = [[WJPhotoBrowser alloc] init];
    photoBrowser.photos = photos;
    photoBrowser.currentIndex = currentIndex;
    return [photoBrowser show];
}

- (WJPhotoBrowser *(^)(WJLongPressAction))longPressCb {
    return ^ (WJLongPressAction action) {
        self.longPressCbKey = action;
        return self;
    };
}

- (WJPhotoBrowser *(^)(WJLoadImageAction))loadImageCb {
    return ^ (WJLoadImageAction action) {
        self.loadImageCbKey = action;
        return self;
    };
}

- (WJPhotoBrowser *(^)(WJDidDismissAction))didDismissCb {
    return ^ (WJDidDismissAction action) {
        self.didDismissCbKey = action;
        return self;
    };
}

- (WJPhotoBrowser *)show {
    NSAssert(self.photos.count > 0, @"请正确设置'photos' ! !");
    NSAssert(self.currentIndex < self.photos.count, @"请正确设置'currentIndex' !");
    [self.photos enumerateObjectsUsingBlock:^(id<WJPhotoItem>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.firstShow = idx == self.currentIndex;
    }];
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window.rootViewController.view addSubview:self.view];
    [window.rootViewController addChildViewController:self];
    [self didMoveToParentViewController:window.rootViewController];
    _windowColor = window.backgroundColor;
    window.backgroundColor = [UIColor blackColor];
    
    _statusBarStyle = [UIApplication sharedApplication].statusBarStyle;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    return self;
}

- (WJPhotoBrowser *)hide {
    if (self.displayPhotoView) {
        [self.displayPhotoView hidePhotoBrowser];
    }
    return self;
}

- (void)dismiss {
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
    UIWindow *window = [UIApplication sharedApplication].delegate.window;
    window.backgroundColor = _windowColor;
    [[UIApplication sharedApplication] setStatusBarStyle:_statusBarStyle];
    if (self.didDismissCbKey) {
        self.didDismissCbKey();
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    self.collectionView.delegate = nil;
    self.collectionView.dataSource = nil;
    self.collectionView = nil;
    self.longPressCbKey = nil;
    self.loadImageCbKey = nil;
    self.didDismissCbKey = nil;
    _windowColor = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    [collectionView registerClass:[WJPhotoView class] forCellWithReuseIdentifier:NSStringFromClass([WJPhotoView class])];
    [self.view addSubview:collectionView];
    self.collectionView = collectionView;
    
    if (self.setupNavBar && !_navBar) {
        _navBar = self.setupNavBar(self, self.view);
    }
    if (self.setupToolBar && !_toolBar) {
        _toolBar = self.setupToolBar(self, self.view);
    }
}

- (void)setSetupToolBar:(WJSetupToolBar)setupToolBar {
    _setupToolBar = setupToolBar;
    if (!_toolBar && setupToolBar) {
        _toolBar = setupToolBar(self, self.view);
    }
}

- (void)setSetupNavBar:(WJSetupNavBar)setupNavBar {
    _setupNavBar = setupNavBar;
    if (!_navBar && setupNavBar) {
        _navBar = setupNavBar(self, self.view);
    }
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    if (!_photos.count) return;
    [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_currentIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _photos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    WJPhotoView *photoView = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([WJPhotoView class]) forIndexPath:indexPath];
    id<WJPhotoItem> photo = _photos[indexPath.item];
    photoView.browser = self;
    photoView.index = indexPath.item;
    wj_weakify(self);
    photoView.dismiss = ^ {
        wj_strongify(self)
        [self dismiss];
    };
    
    photoView.longPressCb = ^(WJPhotoView *thePhotoView, UIImage *image) {
        wj_strongify(self)
        if (self.longPressCbKey) {
            self.longPressCbKey(self, thePhotoView.index, image);
        }
    };
    photoView.loadImageCb = ^(WJPhotoView *thePhotoView, UIImageView *imageView, void (^loadFinished)(NSUInteger atIndex, UIImage *image)) {
        wj_strongify(self)
        if (self.loadImageCbKey) {
            self.loadImageCbKey(self, thePhotoView.index, imageView, loadFinished);
        }
    };
    photoView.photo = photo;
    return photoView;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    self.displayPhotoView = (WJPhotoView *)cell;
    self.currentIndex = indexPath.item;
    
    if (self.pageDidChangeToIndex) {
        self.pageDidChangeToIndex(self, indexPath.item, self.displayPhotoView.imageView.image);
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath { }

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGPoint offset = self.collectionView.contentOffset;
    NSUInteger currentPage = offset.x / scrollView.bounds.size.width;
    self.currentIndex = currentPage;
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:currentPage inSection:0];
    self.displayPhotoView = (WJPhotoView *)[self.collectionView cellForItemAtIndexPath:indexPath];
    
    if (self.displayPhotoView && self.pageDidChangeToIndex) {
        self.pageDidChangeToIndex(self, currentPage, self.displayPhotoView.imageView.image);
    }
}

#pragma mark - Status Bar
- (void)updateStatusBar:(NSNotification *)notify {
    self.statusBarHidden = [notify.userInfo[@"hidden"] boolValue];
    self.statusBarAnimationType = [notify.userInfo[@"animationType"] integerValue];
    self.statusBarShouldUpdate = YES;
    [self setNeedsStatusBarAppearanceUpdate];
    self.statusBarShouldUpdate = NO;
}

- (BOOL)prefersStatusBarHidden {
    if (self.statusBarShouldUpdate == YES) {
        return self.statusBarHidden;
    }
    return [super prefersStatusBarHidden];
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    if (self.statusBarShouldUpdate == YES) {
        return self.statusBarAnimationType;
    }
    return [super preferredStatusBarUpdateAnimation];
}

@end
