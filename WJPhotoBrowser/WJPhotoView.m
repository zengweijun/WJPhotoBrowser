//
//  WJPhotoView.m
//  WJPhotoBrowser
//
//  Created by 曾维俊 on 16/2/17.
//  Copyright © 2016年 曾维俊. All rights reserved.
//

#define kRatio .98

#import "WJPhotoView.h"
#import "WJTapDetectingImageView.h"
#import "WJTapDetectingView.h"
#import "UIImageView+WebCache.h"
#import "WJPhotoPic.h"
#import "WJPhotoBrowser.h"
#import "MBProgressHUD+WJ.h"

@interface WJPhotoView() <
UIScrollViewDelegate,
WJTapDetectingViewDelegate,
WJTapDetectingImageViewDelegate
> {
    WJTapDetectingView *_tapView;
    WJTapDetectingImageView *_photoImageView;
    UIScrollView *_zoomScrollView;
    UIViewController *_topViewController;
    
    UIView *_interruptView; // 防止图片未加载完成时发生browser重复创建的情况
}

@property (strong, nonatomic) UIImage *showImage;

@end

@implementation WJPhotoView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self commitInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commitInit];
    }
    return self;
}

- (void)commitInit {
    _zoomScrollView = [[UIScrollView alloc] init];
    _zoomScrollView.delegate = self;
    _zoomScrollView.showsHorizontalScrollIndicator = NO;
    _zoomScrollView.showsVerticalScrollIndicator = NO;
    _zoomScrollView.decelerationRate = UIScrollViewDecelerationRateFast;
    _zoomScrollView.backgroundColor = [UIColor clearColor];
    _zoomScrollView.frame = self.bounds;
    _zoomScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.contentView addSubview:_zoomScrollView];
    
    _tapView = [[WJTapDetectingView alloc] initWithFrame:_zoomScrollView.bounds];
    _tapView.tapDelegate = self;
    _tapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_zoomScrollView addSubview:_tapView];
    
    _photoImageView = [[WJTapDetectingImageView alloc] initWithFrame:CGRectZero];
    _photoImageView.tapDelegate = self;
    _photoImageView.contentMode = UIViewContentModeScaleAspectFit;
    _photoImageView.backgroundColor = [UIColor clearColor];
    [_zoomScrollView addSubview:_photoImageView];
    
    UIWindow *window = [self getWindow];
    _interruptView = [[UIView alloc] initWithFrame:window.bounds];
    _interruptView.backgroundColor = [UIColor clearColor];
    _interruptView.userInteractionEnabled = YES;
    [_interruptView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(interruptViewTap:)]];
    
    UISwipeGestureRecognizer *swip = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(interruptViewSwip:)];
    swip.direction =
    UISwipeGestureRecognizerDirectionUp|
    UISwipeGestureRecognizerDirectionDown;
    [_interruptView addGestureRecognizer:swip];
    
    [window addSubview:_interruptView];
}

- (void)setPhoto:(WJPhotoPic *)photo {
    _photo = photo;
    
    [self adjustFrame];
    
    __weak __typeof(self) ws = self;
    UIImage *placeholder = photo.placeholder?photo.placeholder:[self getImageFromView:photo.sourceImageView];
    [_photoImageView sd_setImageWithURL:[NSURL URLWithString:photo.photoURL] placeholderImage:placeholder completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        [ws adjustFrame];
        [ws setNeedsLayout];
        [ws setNeedsDisplay];
        ws.showImage = image;
    }];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.showImage = nil;
}

- (void)saveImage {
    if (!self.showImage) {
        [MBProgressHUD showError:@"图片下载完成后才能保存"];
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImageWriteToSavedPhotosAlbum(self.showImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    });
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error) {
        [MBProgressHUD showError:@"保存失败"];
    } else {
        [MBProgressHUD showSuccess:@"图片已保存"];
    }
}

- (void)adjustFrame {
    if (_photoImageView.image == nil) return;
    
    [_interruptView removeFromSuperview]; // 来到这里说明有图片存在
    
    CGSize  boundsSize = self.bounds.size;
    CGFloat boundsWidth = boundsSize.width;
    CGFloat boundsHeight = boundsSize.height;
    
    CGSize  imageSize = _photoImageView.image.size;
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
    
    if (_photo.isFirstShow) {
        _photo.isFirstShow = NO;
        
        CGRect sourceRect = [_photo.sourceImageView convertRect:_photo.sourceImageView.bounds toView:nil];
        _photoImageView.frame = sourceRect;
        
        CGAffineTransform newTransform = CGAffineTransformScale(self.browser.windowTransform, kRatio, kRatio);
        
        UIImageView *resizeImageView = [[UIImageView alloc] initWithFrame:sourceRect];
        resizeImageView.contentMode = _photo.sourceImageView.contentMode;
        resizeImageView.clipsToBounds = _photo.sourceImageView.clipsToBounds;
        resizeImageView.image = _photo.sourceImageView.image;
        [[self getWindow] addSubview:resizeImageView];
        
        _photo.sourceImageView.hidden = YES;
        [UIView animateWithDuration:WJPhotoViewAnimationDuration animations:^{
            resizeImageView.frame = imageRect;
            _photoImageView.frame = imageRect;
            self.browser.view.alpha = 1.0;
            if (self.browser.zoomUnderView) {
                [[self topViewController].view setTransform:newTransform];
            }
        } completion:^(BOOL finished) {
            _photo.sourceImageView.hidden = NO;
            [resizeImageView removeFromSuperview];
        }];
    } else {
        _photoImageView.frame = imageRect;
    }
}

#pragma mark - scroll view delegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _photoImageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // Center the image as it becomes smaller than the size of the screen
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = _photoImageView.frame;
    
    // Horizontally
    if (frameToCenter.size.width < boundsSize.width) {
        frameToCenter.origin.x = floorf((boundsSize.width - frameToCenter.size.width) / 2.0);
    } else {
        frameToCenter.origin.x = 0;
    }
    
    // Vertically
    if (frameToCenter.size.height < boundsSize.height) {
        frameToCenter.origin.y = floorf((boundsSize.height - frameToCenter.size.height) / 2.0);
    } else {
        frameToCenter.origin.y = 0;
    }
    
    // Center
    if (!CGRectEqualToRect(_photoImageView.frame, frameToCenter))
        _photoImageView.frame = frameToCenter;
}

#pragma mark - tap InterruptView
- (void)interruptViewTap:(UITapGestureRecognizer *)tap {
    [self removePhotoBrowser];
}

- (void)interruptViewSwip:(UISwipeGestureRecognizer *)swip {
    [self removePhotoBrowser];
}

- (void)removePhotoBrowser {
    [_interruptView removeFromSuperview];
    if ([self.delegate respondsToSelector:@selector(dismissPhotoBrowser:)]) {
        [self.delegate dismissPhotoBrowser:self];
    }
}

#pragma mark - Tap Detection
- (void)handleSingleTap:(CGPoint)touchPoint {
    UIWindow *window = [self getWindow];
    CGRect sourceRect = [self getSourceRect];
    _photo.sourceImageView.hidden = YES;
    
    UIImageView *resizeImageView = [[UIImageView alloc] initWithFrame:_photoImageView.frame];
    resizeImageView.contentMode = _photo.sourceImageView.contentMode;
    resizeImageView.clipsToBounds = _photo.sourceImageView.clipsToBounds;
    resizeImageView.image = _photoImageView.image;
    [window addSubview:resizeImageView];
    [UIView animateWithDuration:WJPhotoViewAnimationDuration animations:^{
        self.browser.view.alpha = 0.0;
        _photoImageView.frame = sourceRect;
        resizeImageView.frame = sourceRect;
        if (self.browser.zoomUnderView) {
            [[self topViewController].view setTransform:self.browser.windowTransform];
        }
    } completion:^(BOOL finished) {
        [resizeImageView removeFromSuperview];
        if ([self.delegate respondsToSelector:@selector(dismissPhotoBrowser:)]) {
            [self.delegate dismissPhotoBrowser:self];
        }
        _photo.sourceImageView.hidden = NO;
    }];
}

- (void)handleDoubleTap:(CGPoint)touchPoint {
    if (_zoomScrollView.zoomScale != _zoomScrollView.minimumZoomScale) {
        [_zoomScrollView setZoomScale:_zoomScrollView.minimumZoomScale animated:YES];
    } else {
        CGFloat newZoomScale = (_zoomScrollView.maximumZoomScale + _zoomScrollView.minimumZoomScale) / 2;
        CGFloat xSize = self.bounds.size.width / newZoomScale;
        CGFloat ySize = self.bounds.size.height / newZoomScale;
        [_zoomScrollView zoomToRect:CGRectMake(touchPoint.x - xSize / 2, touchPoint.y - ySize / 2, xSize, ySize) animated:YES];
    }
}

// Image View
- (void)imageView:(UIImageView *)imageView singleTapDetected:(CGPoint)touchPoint {
    [self handleSingleTap:touchPoint];
}

- (void)imageView:(UIImageView *)imageView doubleTapDetected:(CGPoint)touchPoint {
    [self handleDoubleTap:touchPoint];
}

// Background View
- (void)view:(UIView *)view singleTapDetected:(CGPoint)touchPoint {
    // Translate touch location to image view location
    CGFloat touchX = touchPoint.x;
    CGFloat touchY = touchPoint.y;
    touchX *= 1/_zoomScrollView.zoomScale;
    touchY *= 1/_zoomScrollView.zoomScale;
    touchX += _zoomScrollView.contentOffset.x;
    touchY += _zoomScrollView.contentOffset.y;
    [self handleSingleTap:CGPointMake(touchX, touchY)];
}

- (void)view:(UIView *)view doubleTapDetected:(CGPoint)touchPoint {
    // Translate touch location to image view location
    CGFloat touchX = touchPoint.x;
    CGFloat touchY = touchPoint.y;
    touchX *= 1/_zoomScrollView.zoomScale;
    touchY *= 1/_zoomScrollView.zoomScale;
    touchX += _zoomScrollView.contentOffset.x;
    touchY += _zoomScrollView.contentOffset.y;
    [self handleDoubleTap:CGPointMake(touchX, touchY)];
}

#pragma mark - Getter
- (UIViewController *)topViewController {
    if (!_topViewController) {
        UIWindow *window = [self getWindow];
        UIViewController *topViewController = window.rootViewController;
        while (topViewController.presentedViewController) {
            topViewController = topViewController.presentedViewController;
        }
        _topViewController = topViewController;
    }
    return _topViewController;
}

- (UIWindow *)getWindow {
    return [[[UIApplication sharedApplication] delegate] window];
}

- (UIImage*)getImageFromView:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, 2);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (CGRect)getSourceRect {
    CGAffineTransform curTransform = [self topViewController].view.transform;
    if (self.browser.zoomUnderView) {
        [[self topViewController].view setTransform:self.browser.windowTransform];
    }
    
    CGRect rect = [_photo.sourceImageView convertRect:_photo.sourceImageView.bounds toView:nil];
    if (self.browser.zoomUnderView) {
        [[self topViewController].view setTransform:curTransform];
    }
    return rect;
}

- (void)dealloc {
    [_photoImageView sd_setImageWithURL:[NSURL URLWithString:@"cancelRequest"]];
    self.delegate = nil;
    NSLog(@"%s", __func__);
}


@end
