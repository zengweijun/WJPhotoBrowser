//
//  WJPhotoToolbar.m
//  SenBa
//
//  Created by 曾维俊 on 16/3/2.
//  Copyright © 2016年 曾维俊. All rights reserved.
//

#import "WJPhotoToolbar.h"
#import "WJPhoto.h"

@implementation WJPhotoToolbar {
    UILabel *_indexLabel;
    UIButton *_saveBtn;
}
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithWhite:0. alpha:0.6];
        
        CGFloat saveBtnWH = self.bounds.size.height;
        CGFloat saveX = 10;
        _saveBtn = [[UIButton alloc] initWithFrame:CGRectMake(saveX, 0, saveBtnWH, saveBtnWH)];
        [_saveBtn setImage:[UIImage imageNamed:@"save_icon"] forState:UIControlStateNormal];
        [self addSubview:_saveBtn];
        [_saveBtn addTarget:self action:@selector(saveBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        
        CGFloat indexLabelW = self.bounds.size.width - 2*(saveX+saveBtnWH);
        CGFloat indexLabelX = CGRectGetMaxX(_saveBtn.frame);
        _indexLabel = [[UILabel alloc] initWithFrame:CGRectMake(indexLabelX, 0, indexLabelW, saveBtnWH)];
        _indexLabel.font = [UIFont boldSystemFontOfSize:20];
        _indexLabel.backgroundColor = [UIColor clearColor];
        _indexLabel.textColor = [UIColor whiteColor];
        _indexLabel.textAlignment = NSTextAlignmentCenter;
        _indexLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:_indexLabel];
        _indexLabel.hidden = YES;
    }
    return self;
}

- (void)setPhotos:(NSArray *)photos {
    _photos = photos;
    _indexLabel.hidden = (_photos.count <= 1);
}

- (void)setCurrentIndex:(NSUInteger)currentIndex {
    _currentIndex = currentIndex;
    _indexLabel.text = [NSString stringWithFormat:@"%zd / %zd", currentIndex+1,_photos.count];
}

- (void)saveBtnClicked {
    if (self.saveImage) self.saveImage(_currentIndex);
}

@end
