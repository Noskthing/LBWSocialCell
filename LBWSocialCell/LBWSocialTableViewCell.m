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
    self.masksToBounds = YES;
    
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

#pragma mark    AttributeStringAttachment Class
//this class copy from thirty lib 'M80AttributeLabel'
typedef enum {
    ContentAlignmentTop,
    ContentAlignmentCenter,
    ContentAlignmentBottom
}ContentAlignment;

/*
 
 CTRunDelegateCallback.
 
 */
void deallocCallback(void* ref);
CGFloat ascentCallback(void *ref);
CGFloat descentCallback(void *ref);
CGFloat widthCallback(void* ref);

@interface AttributeStringAttachment : NSObject

@property (nonatomic,strong)id content;

@property (nonatomic,assign)UIEdgeInsets margin;

@property (nonatomic,assign)ContentAlignment alignment;

@property (nonatomic,assign)CGFloat fontAscent;

@property (nonatomic,assign)CGFloat fontDescent;

@property (nonatomic,assign)CGSize maxSize;

+ (AttributeStringAttachment *)attachmentWith:(id)content
                                       margin:(UIEdgeInsets)margin
                                    alignment:(ContentAlignment)alignment
                                      maxSize:(CGSize)maxSize;

- (CGSize)boxSize;
@end

@implementation AttributeStringAttachment

void deallocCallback(void* ref)
{
    
}

CGFloat ascentCallback(void *ref)
{
    AttributeStringAttachment *image = (__bridge AttributeStringAttachment *)ref;
    CGFloat ascent = 0;
    CGFloat height = [image boxSize].height;
    switch (image.alignment)
    {
        case ContentAlignmentTop:
            ascent = image.fontAscent;
            break;
        case ContentAlignmentCenter:
        {
            CGFloat fontAscent  = image.fontAscent;
            CGFloat fontDescent = image.fontDescent;
            CGFloat baseLine = (fontAscent + fontDescent) / 2 - fontDescent;
            ascent = height / 2 + baseLine;
        }
            break;
        case ContentAlignmentBottom:
            ascent = height - image.fontDescent;
            break;
        default:
            break;
    }
    return ascent;
}

CGFloat descentCallback(void *ref)
{
    AttributeStringAttachment *image = (__bridge AttributeStringAttachment *)ref;
    CGFloat descent = 0;
    CGFloat height = [image boxSize].height;
    switch (image.alignment)
    {
        case ContentAlignmentTop:
        {
            descent = height - image.fontAscent;
            break;
        }
        case ContentAlignmentCenter:
        {
            CGFloat fontAscent  = image.fontAscent;
            CGFloat fontDescent = image.fontDescent;
            CGFloat baseLine = (fontAscent + fontDescent) / 2 - fontDescent;
            descent = height / 2 - baseLine;
        }
            break;
        case ContentAlignmentBottom:
        {
            descent = image.fontDescent;
            break;
        }
        default:
            break;
    }
    
    return descent;
}

CGFloat widthCallback(void* ref)
{
    AttributeStringAttachment *image  = (__bridge AttributeStringAttachment *)ref;
    return [image boxSize].width;
}



+ (AttributeStringAttachment *)attachmentWith:(id)content
                                       margin:(UIEdgeInsets)margin
                                    alignment:(ContentAlignment)alignment
                                      maxSize:(CGSize)maxSize
{
    AttributeStringAttachment *attachment    = [[AttributeStringAttachment alloc]init];
    attachment.content                          = content;
    attachment.margin                           = margin;
    attachment.alignment                        = alignment;
    attachment.maxSize                          = maxSize;
    return attachment;
}

- (CGSize)boxSize
{
    CGSize contentSize = [self attachmentSize];
    if (_maxSize.width > 0 && _maxSize.height > 0 &&
        contentSize.width > 0 && contentSize.height > 0)
    {
        contentSize = [self calculateContentSize];
    }
    return CGSizeMake(contentSize.width + _margin.left + _margin.right,
                      contentSize.height+ _margin.top  + _margin.bottom);
}

#pragma mark - supplementary methods
- (CGSize)calculateContentSize
{
    CGSize attachmentSize   = [self attachmentSize];
    CGFloat width           = attachmentSize.width;
    CGFloat height          = attachmentSize.height;
    CGFloat newWidth        = _maxSize.width;
    CGFloat newHeight       = _maxSize.height;
    if (width <= newWidth &&
        height<= newHeight)
    {
        return attachmentSize;
    }
    CGSize size;
    if (width / height > newWidth / newHeight)
    {
        size = CGSizeMake(newWidth, newWidth * height / width);
    }
    else
    {
        size = CGSizeMake(newHeight * width / height, newHeight);
    }
    return size;
}

- (CGSize)attachmentSize
{
    CGSize size = CGSizeZero;
    if ([_content isKindOfClass:[UIImage class]])
    {
        size = [((UIImage *)_content) size];
    }
    else if ([_content isKindOfClass:[UIView class]])
    {
        size = [((UIView *)_content) bounds].size;
    }
    return size;
}
@end


#pragma mark    ContentManager Class

#define EmojiRegular @"(\\[\\w+\\])"

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

@interface ContentManager()

@property (nonatomic,copy)NSMutableAttributedString * attributeString;

@property (nonatomic,strong)NSMutableArray * attachments;
@end

@implementation ContentManager

-(instancetype)init
{
    if (self = [super init])
    {
        _font = [UIFont systemFontOfSize:17];
        _textColor = [UIColor blackColor];
        _contentAlignment = ContentAlignmentCenter;
        
        _attachments = [NSMutableArray array];
        
        [self resetFont];
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

-(void)setFont:(UIFont *)font
{
    _font = font;
    [self resetFont];
}


-(void)resetFont
{
    CTFontRef fontRef = CTFontCreateWithName((CFStringRef)self.font.fontName, self.font.pointSize, NULL);
    if (fontRef)
    {
        _fontAscent     = CTFontGetAscent(fontRef);
        _fontDescent    = CTFontGetDescent(fontRef);
        //            _fontHeight     = CTFontGetSize(fontRef);
        CFRelease(fontRef);
    }
}

-(void)drawContentTextOnContext:(CGContextRef)context position:(CGPoint)position textSize:(CGSize)textSize
{
    //reset _attributeString 
    _attributeString = [[NSMutableAttributedString alloc] init];
    
    //find emoji text position
    NSArray* matches = [[NSRegularExpression regularExpressionWithPattern:EmojiRegular options:NSRegularExpressionDotMatchesLineSeparators error:nil] matchesInString:self.string options:0 range:NSMakeRange(0,[self.string length])];
    
    NSMutableArray * imageNames = [NSMutableArray array];
    
    //get imageName from string and save them
    for(NSTextCheckingResult* match in matches)
    {
        NSString * imageName = [self.string substringWithRange:match.range];
        [imageNames addObject:imageName];
    }
    
    //replace emoji text by [^] so that we can component string
    for (int i = 0; i < imageNames.count; i++)
    {
        self.string = [self.string stringByReplacingOccurrencesOfString:imageNames[i] withString:@"[^]"];
    }
    
    NSArray * textArray = [self.string componentsSeparatedByString:@"[^]"];
    
    //attributeString text mosaic
    for (int i = 0 ; i < textArray.count; i ++)
    {
        //get attribute string
        NSDictionary * attributes = [NSDictionary attributesWithFont:_font textColor:_textColor linkBreakMode:kCTLineBreakByWordWrapping];
        NSAttributedString * attributeString = [[NSAttributedString alloc] initWithString:textArray[i] attributes:attributes];
        [_attributeString appendAttributedString:attributeString];
        
        //because imageNames.count is eauqls to textArray.count - 1
        if (i == textArray.count - 1)
        {
            break;
        }
        
        //attachment mosaic
        AttributeStringAttachment *attachment = [AttributeStringAttachment attachmentWith:[UIImage imageNamed:@"wheel"]
                                                                                margin:_margin
                                                                                alignment:_contentAlignment
                                                                                  maxSize:CGSizeMake(15, 15)];
        [self appendAttributeStringAttachment:attachment];
    }
    
    [_attributeString drawTextOnContext:context position:position textSize:textSize];
}

- (void)appendAttributeStringAttachment:(AttributeStringAttachment *)attachment
{
    attachment.fontAscent                   = _fontAscent;
    attachment.fontDescent                  = _fontDescent;
    
    //placeholder
    unichar objectReplacementChar           = 0xFFFC;
    NSString *objectReplacementString       = [NSString stringWithCharacters:&objectReplacementChar length:1];
    NSMutableAttributedString *attachText   = [[NSMutableAttributedString alloc]initWithString:objectReplacementString];
    
    //set callback
    CTRunDelegateCallbacks callbacks;
    callbacks.version       = kCTRunDelegateVersion1;
    callbacks.getAscent     = ascentCallback;
    callbacks.getDescent    = descentCallback;
    callbacks.getWidth      = widthCallback;
    callbacks.dealloc       = deallocCallback;
    
    CTRunDelegateRef delegate = CTRunDelegateCreate(&callbacks, (void *)attachment);
    NSDictionary *attr = [NSDictionary dictionaryWithObjectsAndKeys:(__bridge id)delegate,kCTRunDelegateAttributeName, nil];
    [attachText setAttributes:attr range:NSMakeRange(0, 1)];
    CFRelease(delegate);
    
    //keep attachment object will not be dealloced by system so that it will become NSCFType in callback
    [_attachments addObject:attachment];
    
    [_attributeString appendAttributedString:attachText];
}
@end

#pragma mark    LBWSocialTableViewCell
@interface LBWSocialTableViewCell ()
{
    ImageLayer * _icon;
    
    ContentManager * _contentManager;
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
        
        _contentManager = [[ContentManager alloc] initWithFont:[UIFont systemFontOfSize:15] textColor:[UIColor blackColor] contentAlignment:ContentAlignmentCenter maxSize:self.frame.size string:@""];
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
    
    _contentManager.string = model.content;
    [_contentManager drawContentTextOnContext:context position:CGPointMake(kIconLeftEdge, kTopEdge + kIconSide + 5) textSize:model.contentSize];
    
    //get image from context and set it as self.contentView.layer.content
    UIImage *contentImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.contentView.layer.contents = (__bridge id)contentImage.CGImage;
    
}

#pragma mark    -Touch Events

@end