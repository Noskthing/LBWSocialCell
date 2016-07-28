//
//  LBWSocialTableViewCell.m
//  LBWSocialCell
//
//  Created by ml on 16/7/22.
//  Copyright © 2016年 李博文. All rights reserved.
//

#import "LBWSocialTableViewCell.h"

#import "SDWebImageManager.h"


#pragma mark    LBWSocialTableViewModel Class
@implementation LBWSocialTableViewModel

-(instancetype)init
{
    if (self = [super init])
    {
        self.cellHeight = 65;
    }
    
    return self;
}
-(void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    
}

@end
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
    self.cornerRadius = self.frame.size.width/2;
    
    //UIImage.CGImage return CGImageRef type object so that u need use __bridge to change it.
    self.contents = (__bridge id)([UIImage imageNamed:@"placeHolder"].CGImage);
    
    //download image from network
    __weak __typeof(self)weakSelf = self;
    SDWebImageManager * manager = [SDWebImageManager sharedManager];
    [manager downloadImageWithURL:[NSURL URLWithString:url] options:SDWebImageCacheMemoryOnly progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (image)
        {
            //we will add image when rl is free so that it will not affect scrolling animation
            //kCFRunLoopBeforeWaiting | kCFRunLoopExit
            if (!_observe)
            {
                _observe = CFRunLoopObserverCreateWithHandler(kCFAllocatorDefault, kCFRunLoopBeforeWaiting | kCFRunLoopExit, true, 2000, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
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

-(void)dealloc
{
    CFRunLoopRemoveObserver(CFRunLoopGetCurrent(), _observe, kCFRunLoopCommonModes);
}
@end

#pragma mark    ContentManager

#define EmojiRegular @"(\\[\\w+\\])"

typedef enum {
    ContentAlignmentTop,
    ContentAlignmentCenter,
    ContentAlignmentBottom
}ContentAlignment;

@interface ContentManager : NSObject

@property (nonatomic,strong)NSString * string;

@property (nonatomic,strong)UIFont * font;

@property (nonatomic,strong)UIColor * textColor;

@property (nonatomic,assign)ContentAlignment contentAlignment;

@property (nonatomic,assign)UIEdgeInsets margin;

@property (nonatomic,assign)CGFloat fontAscent;

@property (nonatomic,assign)CGFloat fontDescent;

@property (nonatomic,assign)CGSize maxSize;

- (instancetype)initWithFont:(UIFont *)font
                   textColor:(UIColor *)textColor
            contentAlignment:(ContentAlignment)ContentAlignmentCenter
                     maxSize:(CGSize)maxSize
                      string:(NSString *)string;
@end

@implementation ContentManager

-(instancetype)init
{
    if (self = [super init])
    {
        _font = [UIFont systemFontOfSize:17];
        _textColor = [UIColor blackColor];
        _contentAlignment = ContentAlignmentCenter;
    }
    return self;
}

-(instancetype)initWithFont:(UIFont *)font textColor:(UIColor *)textColor contentAlignment:(ContentAlignment)contentAlignment maxSize:(CGSize)maxSize string:(NSString *)string
{
    NSAssert(font, @"Font can not be nil");
    NSAssert(textColor, @"TextColor can not be nil");
    NSAssert(contentAlignment, @"ContentAlignment can not be nil");
    
    ContentManager * manager = [self init];
    manager.font = font;
    manager.textColor = textColor;
    manager.contentAlignment = contentAlignment;
    manager.maxSize = maxSize;
    manager.string = string;
    
    return manager;
}

-(void)drawContentText
{
//    NSArray* matches = [[NSRegularExpression regularExpressionWithPattern:EmojiRegular options:NSRegularExpressionDotMatchesLineSeparators error:nil] matchesInString:self.string options:0 range:NSMakeRange(0,[self.string length])];
    
//    for(NSTextCheckingResult* match in matches)
//    {
////        [self.string substringWithRange:NS]
////        match. =
//    }
}

@end

#pragma mark    LBWSocialTableViewCell
@interface LBWSocialTableViewCell ()
{
    ImageLayer * _icon;
}
@end

static CGFloat kTopEdge = 20;
static CGFloat kIconLeftEdge = 10;
static CGFloat kIconSide = 40;

static CGFloat kNickNameLeftEdge = 60;
@implementation LBWSocialTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _icon = [ImageLayer layer];
        _icon.frame = CGRectMake(kIconLeftEdge, kTopEdge, kIconSide, kIconSide);
        [self.layer addSublayer:_icon];
    }
    return self;
}

-(void)drawContentWithModel:(LBWSocialTableViewModel *)model
{
    //get current context
    
    /*
     
     if u don't use UIGraphicsBeginImageContextWithOptions to create context , u will get warning about context that tell u context is invalid 0x0. 
     
     the advise that changing ur info.plist param view-baseController status style doesn't work. 
     
     because u can't use UIGraphicsGetCurrentContext to get context here. it works on drawRect: function.
     
     */
    UIGraphicsBeginImageContextWithOptions(self.frame.size, YES, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [[UIColor whiteColor] set];
    CGContextFillRect(context, CGRectMake(0, 0, self.frame.size.width, self.frame.size.height));
    
    //icon's layer is self.contentView's subLayer
    [_icon setContentWitURL:model.iconUrl];
    
    //draw text on context which is self.contentView.layer.content
    [model.nickName drawTextOnContext:context position:CGPointMake(kNickNameLeftEdge, kTopEdge) font:[UIFont systemFontOfSize:15] textColor:[UIColor blackColor] textSize:CGSizeMake(self.frame.size.width - kNickNameLeftEdge, 22) lineBreakMode:kCTLineBreakByTruncatingTail];
    
    [model.source drawTextOnContext:context position:CGPointMake(kNickNameLeftEdge, kTopEdge + 22) font:[UIFont systemFontOfSize:12] textColor:[UIColor lightGrayColor] textSize:CGSizeMake(self.frame.size.width - kNickNameLeftEdge, 18) lineBreakMode:kCTLineBreakByTruncatingTail];
    
    [model.content drawTextOnContext:context position:CGPointMake(kIconLeftEdge, kTopEdge + kIconSide + 5) font:[UIFont systemFontOfSize:15] textColor:[UIColor blackColor] textSize:model.contentSize lineBreakMode:kCTLineBreakByWordWrapping];
    
    //get image from context and set it as self.contentView.layer.content
    UIImage *contentImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.contentView.layer.contents = (__bridge id)contentImage.CGImage;
    
}

#pragma mark    -Touch Events

@end