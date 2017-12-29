//
//  WJPhotoView.m
//  WJPhotoBrowser
//
//  Created by 曾维俊 on 16/5/26.
//  Copyright © 2016年 曾维俊. All rights reserved.
//

#import "WJPhotoView.h"
#import "WJPhotoBrowser.h"
#import "POP.h"

#define WJPhotoViewAnimationDuration 0.4
#define kLimitHeightDissmiss 60
#define kRatio .96

@interface WJPhotoView() <UIScrollViewDelegate, UIGestureRecognizerDelegate>
@property (nonatomic, weak) UIImageView             *imageView;
@property (nonatomic, weak) UIScrollView            *zoomScrollView;
@property (nonatomic, weak) UIActivityIndicatorView *indicatorView;
@property (nonatomic, weak) UIWindow                *keyWindow;

@property (nonatomic, strong) UIViewController      *topViewController;

@property (nonatomic, assign) BOOL imageDownloadComplete;
@property (nonatomic, assign) BOOL performingLayout;
@property (nonatomic, assign) BOOL scrollViewEndDragging;
@property (nonatomic, assign) BOOL performingTapGesture;
@property (nonatomic, assign) BOOL showWebImage;

@property (nonatomic, assign) CGPoint startDragginCenter;

@end

@implementation WJPhotoView

#pragma mark - Initialize
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UIScrollView *zoomScrollView = [[UIScrollView alloc] init];
        self.zoomScrollView = zoomScrollView;
        zoomScrollView.delegate = self;
        zoomScrollView.showsHorizontalScrollIndicator = NO;
        zoomScrollView.showsVerticalScrollIndicator = NO;
        zoomScrollView.decelerationRate = UIScrollViewDecelerationRateFast;
        zoomScrollView.backgroundColor = [UIColor clearColor];
        zoomScrollView.frame = self.bounds;
        zoomScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        zoomScrollView.alwaysBounceVertical = YES;
        [self.contentView addSubview:zoomScrollView];
        
        // Gesture
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        [zoomScrollView addGestureRecognizer:singleTap];
        UITapGestureRecognizer * doubleTap = [[UITapGestureRecognizer alloc]
                                              initWithTarget:self
                                              action:@selector(handleDoubleTap:)];
        doubleTap.numberOfTapsRequired = 2;
        [singleTap requireGestureRecognizerToFail:doubleTap];
        [zoomScrollView addGestureRecognizer:doubleTap];
        
        
        UIImageView *imageView = [[UIImageView alloc] init];
        self.imageView = imageView;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.backgroundColor = [UIColor clearColor];
        [zoomScrollView addSubview:imageView];
        imageView.frame = zoomScrollView.bounds;
        
        imageView.userInteractionEnabled = YES;
        UILongPressGestureRecognizer *longGsr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longGsr:)];
        [imageView addGestureRecognizer:longGsr];
        
        UIView *view = [[UIApplication sharedApplication].windows lastObject];
        UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        indicatorView.frame = CGRectMake(0, 0, 40, 40);
        indicatorView.alpha = 0.0;
        [view addSubview:indicatorView];
        self.indicatorView = indicatorView;
    }
    return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
}

#pragma mark - IndicatorView
- (void)showIndicatorView {[self.indicatorView startAnimating];}
- (void)hideIndicatorView {[self.indicatorView stopAnimating];}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (!self.browser.slidingCloseGesture) return;
    self.scrollViewEndDragging = NO;
    self.startDragginCenter = scrollView.center;
    [self hideSourceImageView];
    self.browser.navBar.hidden = YES;
    self.browser.toolBar.hidden = YES;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!self.browser.slidingCloseGesture) return;
    CGFloat viewHalfHeight = scrollView.bounds.size.height / 2;
    if(scrollView.center.y > viewHalfHeight+kLimitHeightDissmiss ||
       scrollView.center.y < viewHalfHeight-kLimitHeightDissmiss) {
        // Automatic Dismiss View
        [self handleSingleTap:nil];
    } else {
        // Continue Showing View
        [UIView animateWithDuration:WJPhotoViewAnimationDuration
                         animations:^{
                             self.browser.view.backgroundColor = [UIColor colorWithWhite:0 alpha:1];
                             [scrollView setCenter:self.startDragginCenter];
                         } completion:^(BOOL finished) {
                             [self showSourceImageView];
                         }];
        self.browser.navBar.hidden = NO;
        self.browser.toolBar.hidden = NO;
        [self setStatusBarHidden:YES animation:YES];
    }
    self.scrollViewEndDragging = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!self.browser.slidingCloseGesture) return;
    if (scrollView.zoomScale != scrollView.minimumZoomScale) return;
    if (self.performingLayout||self.scrollViewEndDragging||self.performingTapGesture) return;
    if (scrollView.contentOffset.y < 0) [self panGsr:scrollView];
    if (scrollView.contentOffset.y > 0) {
        CGFloat boundsHeight = [UIScreen mainScreen].bounds.size.height;
        CGFloat contentHeight = scrollView.contentSize.height;
        CGFloat tempValue = boundsHeight - contentHeight;
        if ((scrollView.contentOffset.y + tempValue) > 0) [self panGsr:scrollView];
    }
}

#pragma mark - Gesture recognizer handle
- (void)panGsr:(UIScrollView *)scrollView {
    CGFloat viewHeight = scrollView.frame.size.height;
    CGFloat viewHalfHeight = viewHeight/2;
    
    UIPanGestureRecognizer *panGsr = scrollView.panGestureRecognizer;
    CGPoint translatedPoint = [panGsr translationInView:scrollView];
    
    translatedPoint = CGPointMake(self.startDragginCenter.x+translatedPoint.x, self.startDragginCenter.y+translatedPoint.y);
    [scrollView setCenter:translatedPoint];
    
    CGFloat newY = scrollView.center.y - viewHalfHeight;
    CGFloat newAlpha = 1 - fabs(newY)/viewHeight * 3.8; // fabs(newY)/viewHeight;
    newAlpha = newAlpha >= 0.3? newAlpha: 0.3;
    self.browser.view.opaque = YES;
    self.browser.view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:newAlpha];
    [self setStatusBarHidden:NO animation:NO];
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)gsr {
    self.performingTapGesture = YES;
    if (self.zoomScrollView.zoomScale != self.zoomScrollView.minimumZoomScale) {
        [self.zoomScrollView setZoomScale:self.zoomScrollView.minimumZoomScale animated:YES];
    } else {
        CGFloat newZoomScale = (self.zoomScrollView.maximumZoomScale + self.zoomScrollView.minimumZoomScale) / 2;
        CGFloat xSize = self.bounds.size.width / newZoomScale;
        CGFloat ySize = self.bounds.size.height / newZoomScale;
        CGPoint touchPoint = [gsr locationInView:self.imageView];
        [self.zoomScrollView zoomToRect:CGRectMake(touchPoint.x - xSize / 2, touchPoint.y - ySize / 2, xSize, ySize) animated:YES];
    }
    self.performingTapGesture = NO;
}

- (void)handleSingleTap:(UITapGestureRecognizer *)gsr {
    self.browser.navBar.hidden = YES;
    self.browser.toolBar.hidden = YES;
    
    [self setStatusBarHidden:NO animation:NO];
    
    // 延迟80毫秒，以防statusBar还未完成显示操作
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.08 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 关闭其他手势
        self.zoomScrollView.userInteractionEnabled = NO;
        [(UIScrollView *)self.superview setScrollEnabled:NO];
        
        // 开始动画
        self.performingTapGesture = YES;
        self.imageView.image = self.photo.sourceImageView.image;
        wj_weakify(self)
        CGRect destRect = [self.imageView convertRect:self.imageView.bounds toView:nil];
        [self maskImageView:[self maskImageView:destRect] animationToFrame:[self sourceRect] backgroudAlpha:0.0 completion:^{
            wj_strongify(self)
            if (self.dismiss) self.dismiss();
        }];
        [self hideAll];
        self.performingTapGesture = NO;
    });
}

- (void)longGsr:(UILongPressGestureRecognizer *)longGsr {
    if (longGsr.state == UIGestureRecognizerStateBegan) {
        UIImageView *imageView = (UIImageView *)longGsr.view;
        if (imageView.image) {
            if (self.longPressCb) {
                self.longPressCb(self, imageView.image);
            }
        }
    }
}

- (void)hidePhotoBrowser {
    [self handleSingleTap:nil];
}

#pragma mark - Layout
- (void)setPhoto:(id<WJPhotoItem>)photo {
    if (_photo == photo) {
        return;
    }
    
    _photo = photo;
    
    self.showWebImage = YES;
    if ([photo respondsToSelector:@selector(sourceImageView)]) {
        self.imageView.image = photo.sourceImageView.image;
    }
    if ([photo respondsToSelector:@selector(image)]) {
        if (photo.image) {
            self.imageView.image = photo.image;
            // NSUInteger cost = photo.image.size.height * photo.image.size.width * photo.image.scale * photo.image.scale;
        }
    }
    
    self.imageDownloadComplete = NO;
    if (self.loadImageCb) {
        [self showIndicatorView];
        wj_weakify(self)
        self.loadImageCb(self, self.imageView, ^(NSUInteger atIndex, UIImage *image) {
            wj_strongify(self)
            
            dispatch_block_t setImage = ^{
                if (atIndex == self.index) {
                    self.imageDownloadComplete = YES;
                    if (image) {
                        self.imageView.image = image;
                    }
                    [self adjustFrame];
                    [self hideIndicatorView];
                }
            };
            
            if (![[NSThread currentThread] isMainThread]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    setImage();
                });
            } else {
                setImage();
            }
        });
    }
    
    // 先给imageView布局
    [self adjustFrame];
}

- (void)adjustFrame {
    if (self.imageView.image == nil) return;
    self.performingLayout = YES;
    
    CGSize  boundsSize = self.bounds.size;
    CGFloat boundsWidth = boundsSize.width;
    CGFloat boundsHeight = boundsSize.height;
    
    CGSize  imageSize = self.imageView.image.size;
    CGFloat imageWidth = imageSize.width;
    CGFloat imageHeight = imageSize.height;
    // In cass crash
    if (imageWidth == 0) imageWidth = 40.;
    if (imageHeight == 0) imageHeight = 40.;
    
    // The min scale / max scale
    CGFloat minScale = boundsWidth / imageWidth;
    if (minScale > 1.0) minScale = 1.0;
    CGFloat maxScale = 3;
    
    _zoomScrollView.maximumZoomScale = maxScale;
    _zoomScrollView.minimumZoomScale = minScale;
    _zoomScrollView.zoomScale = minScale;
    
    CGRect imageRect = CGRectMake(0, 0, boundsWidth, imageHeight * boundsWidth / imageWidth);
    _zoomScrollView.contentSize = CGSizeMake(boundsWidth, imageRect.size.height);
    
    if (imageRect.size.width < boundsSize.width) {
        imageRect.origin.x = floorf((boundsSize.width - imageRect.size.width) / 2.0);
    } else {
        imageRect.origin.x = 0;
    }
    
    if (imageRect.size.height < boundsHeight) {
        imageRect.origin.y = floor((boundsHeight - imageRect.size.height) / 2.0);
    } else {
        imageRect.origin.y = 0;
    }
    
    self.imageView.frame = imageRect;
    if (self.photo.firstShow) {
        self.photo.firstShow = NO;
        self.browser.view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
        UIImageView *maskImageView = [self maskImageView:[self sourceRect]];
        wj_weakify(self)
        [self maskImageView:maskImageView animationToFrame:imageRect backgroudAlpha:1.0 completion:^{
            wj_strongify(self)
            [self setStatusBarHidden:YES animation:NO];
        }];
    }
    
    self.performingLayout = NO;
}

- (void)adjustImageCenter {
    // adjust image center
    // Center the image as it becomes smaller than the size of the screen
    CGSize boundsSize = self.bounds.size;
    CGRect imageFrame = self.imageView.frame;
    
    // Horizontally
    if (imageFrame.size.width < boundsSize.width) {
        imageFrame.origin.x = floorf((boundsSize.width - imageFrame.size.width) / 2.0);
    } else {
        imageFrame.origin.x = 0;
    }
    
    // Vertically
    if (imageFrame.size.height < boundsSize.height) {
        imageFrame.origin.y = floorf((boundsSize.height - imageFrame.size.height) / 2.0);
    } else {
        imageFrame.origin.y = 0;
    }
    
    // Center
    if (!CGRectEqualToRect(self.imageView.frame, imageFrame)) {
        self.imageView.frame = imageFrame;
    }
}

- (void)maskImageView:(UIImageView *)maskImageView animationToFrame:(CGRect)rect backgroudAlpha:(CGFloat)alpha completion:(void (^)(void))completion {
    [self hideSourceImageView];
    self.imageView.hidden = YES;
    
    void(^aCompletion)(void) = ^ {
        self.indicatorView.alpha = 1.0;
        self.imageView.hidden = NO;
        [maskImageView removeFromSuperview];
        self.indicatorView.center = [self keyWindow].center;
        if (completion) completion();
        [self showSourceImageView];
    };
    
    if (self.browser.usePopAnimation) {
        [UIView animateWithDuration:WJPhotoViewAnimationDuration animations:^{
            [self adjustBackground:alpha];
        }];
        [self popAnimation:maskImageView toFrame:rect completion:^{
            if (aCompletion) aCompletion();
        }];
    } else {
        [UIView animateWithDuration:WJPhotoViewAnimationDuration animations:^{
            maskImageView.frame = rect;
            [self adjustBackground:alpha];
        } completion:^(BOOL finished) {
            if (aCompletion) aCompletion();
        }];
    }
}

- (void)adjustBackground:(CGFloat)alpha {
    self.browser.view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:alpha];
}

#pragma mark - pop Animation
- (void)popAnimation:(UIView *)view toFrame:(CGRect)frame completion:(void (^)(void))completion {
    POPSpringAnimation *animation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
    [animation setSpringBounciness:6];
    [animation setDynamicsMass:1];
    [animation setToValue:[NSValue valueWithCGRect:frame]];
    [view.layer pop_addAnimation:animation forKey:nil];
    if (completion) [animation setCompletionBlock:^(POPAnimation *animation, BOOL finished) { completion(); }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self adjustImageCenter];
    self.performingLayout = NO;
}

#pragma mark - Getter
- (UIWindow *)keyWindow {
    if (!_keyWindow) {
        _keyWindow = [UIApplication sharedApplication].keyWindow;
    }
    return _keyWindow;
}

- (CGRect)sourceRect {
    return [self.photo.sourceImageView convertRect:self.photo.sourceImageView.bounds toView:nil];
}

- (UIImage*)imageFromView:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, 2);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImageView *)maskImageView:(CGRect)rect {
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:rect];
    imageView.contentMode = self.photo.sourceImageView.contentMode;
    imageView.clipsToBounds = self.photo.sourceImageView.clipsToBounds;
    imageView.image = self.imageView.image;
    [[self keyWindow] addSubview:imageView];
    return imageView;
}

- (CGAffineTransform)origWindowTransform {return [self keyWindow].transform;}
- (CGAffineTransform)destWindowTransform {return CGAffineTransformScale([self origWindowTransform], kRatio, kRatio);}

#pragma mark - status bar
- (void)setStatusBarHidden:(BOOL)hidden animation:(BOOL)animation {
    UIStatusBarAnimation animationType = UIStatusBarAnimationNone;
    if (animation) {
        animationType = UIStatusBarAnimationSlide;
    }
    [[UIApplication sharedApplication] setStatusBarHidden:hidden withAnimation:animationType];
    [[NSNotificationCenter defaultCenter] postNotificationName:kWJPhotoBrowserShouldUpdateStatusBar object:self userInfo:
  @{
    @"hidden":@(hidden),
    @"animationType":@(animationType)
    }];
}

#pragma mark - helper
- (void)hideAll {
    [self hideIndicatorView];
}

- (void)hideSourceImageView {self.photo.sourceImageView.hidden = YES;}
- (void)showSourceImageView {self.photo.sourceImageView.hidden = NO;}

- (void)dealloc {[self hideAll];}
- (void)prepareForReuse {
    [super prepareForReuse];
    self.imageDownloadComplete = NO;
    [self hideAll];
}

@end

NSString *const kWJPhotoBrowserShouldUpdateStatusBar = @"kWJPhotoBrowserShouldUpdateStatusBar";
