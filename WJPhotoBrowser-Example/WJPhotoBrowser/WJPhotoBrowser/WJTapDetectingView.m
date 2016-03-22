//
//  WJTapDetectingView.m
//  WJPhotoPickerController
//
//  Created by 曾维俊 on 15/12/24.
//  Copyright © 2015年 曾维俊. All rights reserved.
//

#import "WJTapDetectingView.h"

@implementation WJTapDetectingView
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self commitInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self commitInit];
    }
    return self;
}

- (void)commitInit {
    self.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
//    singleTap.delaysTouchesBegan = YES;
    singleTap.numberOfTapsRequired = 1;
    [self addGestureRecognizer:singleTap];
    
//    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
//    doubleTap.numberOfTapsRequired = 2;
//    [singleTap requireGestureRecognizerToFail:doubleTap];
//    [self addGestureRecognizer:doubleTap];
}

- (void)handleSingleTap:(UITapGestureRecognizer *)tap {
    CGPoint touchPoint = [tap locationInView:self];
    if ([_tapDelegate respondsToSelector:@selector(view:singleTapDetected:)])
        [_tapDelegate view:self singleTapDetected:touchPoint];
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)tap {
    CGPoint touchPoint = [tap locationInView:self];
    if ([_tapDelegate respondsToSelector:@selector(view:doubleTapDetected:)]) {
        [_tapDelegate view:self doubleTapDetected:touchPoint];
    }
}

@end
