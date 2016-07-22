//
//  LBWSocialTableViewCell.m
//  LBWSocialCell
//
//  Created by ml on 16/7/22.
//  Copyright © 2016年 李博文. All rights reserved.
//

#import "LBWSocialTableViewCell.h"

#import "SDWebImageManager.h"
#import "UIImage+Filter.h"


#pragma mark    ImageLayer Class
@interface ImageLayer : CALayer
{
    CFRunLoopObserverRef _observe;
}
/**
 *  download form network.
 */
@property (nonatomic,strong)UIImage * orginImage;

/**
 *  mix originImage and grayColor and when u touch imageLayer it will show.
 */
@property (nonatomic,strong)UIImage * highLightImage;

/**
 *  it will be used in cell touch events. and ImageLayer.content will change with isTouched. default is NO.
 */
@property (nonatomic,assign)BOOL isTouched;

/**
 *  set url and download image from network.
 *
 *  @param url image url
 */
- (void)setContentWitURL:(NSString *)url;
@end

@implementation ImageLayer

- (void)setContentWitURL:(NSString *)url
{
    //UIImage.CGImage return CGImageRef type object so that u need use __bridge to change it.
    self.contents = (__bridge id)([UIImage imageNamed:@"placeHolder"].CGImage);
    
    //download image from network
    __weak __typeof(self)weakSelf = self;
    SDWebImageManager * manager = [SDWebImageManager sharedManager];
    [manager downloadImageWithURL:[NSURL URLWithString:url] options:SDWebImageCacheMemoryOnly progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (image)
        {
            //we will add image when rl is free so that it will nor affect scrolling animation
            //kCFRunLoopBeforeWaiting | kCFRunLoopExit
            if (!_observe)
            {
                _observe = CFRunLoopObserverCreateWithHandler(kCFAllocatorDefault, kCFRunLoopBeforeWaiting | kCFRunLoopExit, false, 2000, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
                    strongSelf.contents = (__bridge id)image.CGImage;
                });
            }
            if (_observe)
            {
                CFRunLoopAddObserver(CFRunLoopGetCurrent(), _observe, kCFRunLoopCommonModes);
            }
            
            strongSelf.orginImage = image;
        }
    }];
}

- (UIImage *)highLightImage
{
    if (!_highLightImage)
    {
        _highLightImage = [_orginImage filterImageWithColor:[UIColor grayColor]];
    }
    return _highLightImage;
}

-(void)setIsTouched:(BOOL)isTouched
{
    if (!_orginImage)
    {
        return;
    }
    
    _isTouched = isTouched;
    
    if (isTouched)
    {
        self.contents = (__bridge id)self.highLightImage.CGImage;
    }
    else
    {
        self.contents = (__bridge id)self.orginImage.CGImage;
    }
}
@end

@interface LBWSocialTableViewCell ()
{
    ImageLayer * _icon;
}
@end

@implementation LBWSocialTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _icon = [ImageLayer layer];
        _icon.frame = CGRectMake(10, 20, 40, 40);
        [_icon setContentWitURL:@"http://tva1.sinaimg.cn/crop.0.0.2048.2048.50/c0894007jw8eo090gvai2j21kw1kwgox.jpg"];
        [self.layer addSublayer:_icon];
    }
    return self;
}

-(void)drawContentWithModel:(LBWSocialTableViewModel *)model
{
    //icon
    [_icon setContentWitURL:model.iconUrl];
    
    //nickName
    
}

#pragma mark    Touch Events
@end
