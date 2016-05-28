//
//  WJPhotoView.m
//  WJPhotoBrowser
//
//  Created by 曾维俊 on 16/5/26.
//  Copyright © 2016年 曾维俊. All rights reserved.
//

#import "WJPhotoView.h"
#import "WJPhotoBrowser.h"
#import "WJPhotoObj.h"
#import "UIImageView+WebCache.h"
#import "MBProgressHUD.h"
#import "POP.h"

#define WJPhotoViewAnimationDuration 0.4
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
        self.zoomScrollView = zoomScrollView;
        
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.backgroundColor = [UIColor clearColor];
        [zoomScrollView addSubview:imageView];
        imageView.frame = zoomScrollView.bounds;
        self.imageView = imageView;
        
        UIView *view = [[UIApplication sharedApplication].windows lastObject];
        UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        indicatorView.frame = CGRectMake(0, 0, 40, 40);
        indicatorView.alpha = 0.0;
        [view addSubview:indicatorView];
        self.indicatorView = indicatorView;
    }
    return self;
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
    self.scrollViewEndDragging = NO;
    self.startDragginCenter = scrollView.center;
    [self hideSourceImageView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    CGFloat viewHalfHeight = scrollView.bounds.size.height / 2;
    if(scrollView.center.y > viewHalfHeight+40 ||
       scrollView.center.y < viewHalfHeight-40) {
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
    }
    self.scrollViewEndDragging = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.zoomScale != scrollView.minimumZoomScale) return;
    if (self.performingLayout) return;
    if (scrollView.contentOffset.y != 0 &&
        !self.scrollViewEndDragging &&
        !self.performingTapGesture) {
        [self panGsr:scrollView];
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
    CGFloat newAlpha = 1 - fabs(newY)/viewHeight; //abs(newY)/viewHeight * 1.8;
    self.browser.view.opaque = YES;
    self.browser.view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:newAlpha];
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
    self.performingTapGesture = YES;
    __weak __typeof(&*self) ws = self;
    CGRect destRect = [self.imageView convertRect:self.imageView.bounds toView:nil];
    [self maskImageView:[self maskImageView:destRect] animationToFrame:[self sourceRect] backgroudAlpha:0.0 completion:^{
        if (ws.dismiss) ws.dismiss();
    }];
    [self hideAll];
    self.performingTapGesture = NO;
}

#pragma mark - Layout
- (void)setPhoto:(WJPhotoObj *)photo {
    _photo = photo;
    
    self.imageDownloadComplete = NO;
    self.showWebImage = [photo.photoURL hasPrefix:@"http"]?YES:NO;
    if (!self.showWebImage) {
        self.imageView.image = [UIImage imageNamed:photo.photoURL];
        self.imageDownloadComplete = YES;
        [self hideIndicatorView];
    } else {
        [self showIndicatorView];
        UIImage *placeholderImage = photo.placeholder?photo.placeholder:[self imageFromView:photo.sourceImageView];
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:photo.photoURL] placeholderImage:placeholderImage options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            [self adjustFrame];
            [self hideIndicatorView];
            if (error) [self showMessage:@"图片下载失败!"];
            if (image) self.imageDownloadComplete = YES;
        }];
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
    
    // y值
    if (imageRect.size.height < boundsHeight) {
        imageRect.origin.y = floor((boundsHeight - imageRect.size.height) / 2.0);
    } else {
        imageRect.origin.y = 0;
    }
    
    if (self.photo.firstShow) {
        self.photo.firstShow = NO;
        self.browser.view.backgroundColor = [UIColor blackColor];
        self.browser.view.alpha = 0.0;
        UIImageView *maskImageView = [self maskImageView:[self sourceRect]];
        [self zoomInUnderView];
        [self maskImageView:maskImageView animationToFrame:imageRect backgroudAlpha:1.0 completion:NULL];
    } else {
        self.imageView.frame = imageRect;
    }
    
    self.performingLayout = NO;
}

- (void)maskImageView:(UIImageView *)maskImageView animationToFrame:(CGRect)rect backgroudAlpha:(CGFloat)alpha completion:(void (^)())completion {
    [self hideSourceImageView];
    self.imageView.hidden = YES;
    
    __weak __typeof(&*self) ws = self;
    void(^aCompletion)() = ^ {
        self.indicatorView.alpha = 1.0;
        self.imageView.hidden = NO;
        if (!ws.showWebImage) self.imageView.frame = rect;
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
    self.browser.view.alpha = alpha;
    if (self.browser.animatedZoomUnderView) (alpha > 0)?[self zoomOutUnderView]:[self zoomInUnderView];
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
    if (!CGRectEqualToRect(self.imageView.frame, imageFrame))
        self.imageView.frame = imageFrame;
    
    self.performingLayout = NO;
}

#pragma mark - Getter
- (UIViewController *)topViewController {
    if (!_topViewController) {
        UIWindow *window = [self keyWindow];
        UIViewController *topViewController = window.rootViewController;
        while (topViewController.presentedViewController) {
            topViewController = topViewController.presentedViewController;
        }
        _topViewController = topViewController;
    }
    return _topViewController;
}

- (UIWindow *)keyWindow {
    if (!_keyWindow) {
        _keyWindow = [UIApplication sharedApplication].keyWindow;
    }
    return _keyWindow;
}

- (CGRect)sourceRect {
    CGRect rect;
    [self zoomInUnderView];
    rect = [self.photo.sourceImageView convertRect:self.photo.sourceImageView.bounds toView:nil];
    [self zoomOutUnderView];
    return rect;
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

#pragma mark - save image
- (void)saveImage {
    if (!self.imageDownloadComplete) {
        [self showMessage:@"图片还没有下载完成!"];
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImageWriteToSavedPhotosAlbum(self.imageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    });
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    error?[self showMessage:@"保存失败"]:[self showMessage:@"图片已保存"];
}

#pragma mark - helper
- (void)showMessage:(NSString *)text {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.imageView animated:YES];
    hud.labelText = text;
    hud.mode = MBProgressHUDModeCustomView;
    hud.animationType = MBProgressHUDAnimationZoom;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:0.7];
}

- (void)hideAll {
    [MBProgressHUD hideHUDForView:self animated:YES];
    [self hideIndicatorView];
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:@"cancel the task"]];
}

- (void)zoomOutUnderView {[self.keyWindow.rootViewController.view setTransform:[self destWindowTransform]];}
- (void)zoomInUnderView {[self.keyWindow.rootViewController.view setTransform:[self origWindowTransform]];}

- (void)hideSourceImageView {self.photo.sourceImageView.hidden = YES;}
- (void)showSourceImageView {self.photo.sourceImageView.hidden = NO;}

- (void)dealloc {[self hideAll];};
- (void)prepareForReuse {
    [super prepareForReuse];
    self.imageDownloadComplete = NO;
    [self hideAll];
}

@end
