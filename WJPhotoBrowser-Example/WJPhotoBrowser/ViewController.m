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
@property (weak, nonatomic) IBOutlet UIImageView *imageView1;
@property (weak, nonatomic) IBOutlet UIImageView *imageView2;
@property (weak, nonatomic) IBOutlet UIImageView *imageView3;
@property (weak, nonatomic) IBOutlet UIImageView *imageView4;
@property (weak, nonatomic) IBOutlet UIImageView *imageView5;
@property (weak, nonatomic) IBOutlet UIImageView *imageView6;
@property (weak, nonatomic) IBOutlet UIImageView *imageView7;
@property (weak, nonatomic) IBOutlet UIImageView *imageView8;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSUInteger photoIndex = 0;
    UIImageView *orImageView = nil;
    
    UITouch *touch = touches.anyObject;
    if (touch.view == self.imageView1) {
        photoIndex = 0;
        orImageView = self.imageView1;
    } else if (touch.view == self.imageView2) {
        photoIndex = 1;
        orImageView = self.imageView2;
    } else if (touch.view == self.imageView3) {
        photoIndex = 2;
        orImageView = self.imageView3;
    } else if (touch.view == self.imageView4) {
        photoIndex = 3;
        orImageView = self.imageView4;
    } else if (touch.view == self.imageView5) {
        photoIndex = 4;
        orImageView = self.imageView5;
    } else if (touch.view == self.imageView6) {
        photoIndex = 5;
        orImageView = self.imageView6;
    } else if (touch.view == self.imageView7) {
        photoIndex = 6;
        orImageView = self.imageView7;
    } else if (touch.view == self.imageView8) {
        photoIndex = 7;
        orImageView = self.imageView8;
    } else {
        return;
    }
    
    
    WJPhotoObj *photo1 = [[WJPhotoObj alloc] init];
    photo1.sourceImageView = self.imageView1;
    photo1.photoIndex = 0;
    photo1.isFirstShow = NO;
    photo1.photoURL = @"1";
    
    WJPhotoObj *photo2 = [[WJPhotoObj alloc] init];
    photo2.sourceImageView = self.imageView2;
    photo2.photoIndex = 1;
    photo2.isFirstShow = NO;
    photo2.photoURL = @"2";
    
    WJPhotoObj *photo3 = [[WJPhotoObj alloc] init];
    photo3.sourceImageView = self.imageView3;
    photo3.photoIndex = 2;
    photo3.isFirstShow = NO;
    photo3.photoURL = @"3";
    
    WJPhotoObj *photo4 = [[WJPhotoObj alloc] init];
    photo4.sourceImageView = self.imageView4;
    photo4.photoIndex = 3;
    photo4.isFirstShow = NO;
    photo4.photoURL = @"4";
    
    WJPhotoObj *photo5 = [[WJPhotoObj alloc] init];
    photo5.sourceImageView = self.imageView5;
    photo5.photoIndex = 4;
    photo5.isFirstShow = NO;
    photo5.photoURL = @"5";
    
    WJPhotoObj *photo6 = [[WJPhotoObj alloc] init];
    photo6.sourceImageView = self.imageView6;
    photo6.photoIndex = 5;
    photo6.isFirstShow = NO;
    photo6.photoURL = @"6";
    
    WJPhotoObj *photo7 = [[WJPhotoObj alloc] init];
    photo7.sourceImageView = self.imageView7;
    photo7.photoIndex = 6;
    photo7.isFirstShow = NO;
    photo7.photoURL = @"7";
    
    WJPhotoObj *photo8 = [[WJPhotoObj alloc] init];
    photo8.sourceImageView = self.imageView8;
    photo8.photoIndex = 7;
    photo8.isFirstShow = NO;
    photo8.photoURL = @"8";
    
    NSArray *array = @[photo1,photo2,photo3,photo4,photo5,photo6,photo7,photo8];
    for (WJPhotoObj *photo in array) {
        if (photo.photoIndex == photoIndex) {
            photo.isFirstShow = YES;
        }
    }
    
    WJPhotoBrowser *browser = [[WJPhotoBrowser alloc] init];
    browser.sourceIndex = photoIndex;
    browser.photos = array;
    [browser show];
}





@end
