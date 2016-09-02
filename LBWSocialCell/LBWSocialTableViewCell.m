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
        _cellHeight = 65;
        _content = @"";
        _repostContent = @"";
        _contentSize = CGSizeMake(0, 0);
        _repostContentSize = CGSizeMake(0, 0);
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
- (void)setContentWitURL:(NSString *)url Type:(NSString *)type;

@end

@implementation ImageLayer

- (void)setContentWitURL:(NSString *)url Type:(NSString *)type
{
    if ([type isEqualToString:@"Icon"])
    {
        self.cornerRadius = self.frame.size.width/2;
    }

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
#define URLRegular @"(http|https)://(t.cn/|weibo.com/)+(([a-zA-Z0-9/])*)"
#define AccountRegular @"@[\u4e00-\u9fa5a-zA-Z0-9_-]{2,30}"

@interface ContentManager : NSObject

@property (nonatomic,strong)NSString * string;

@property (nonatomic,strong)UIFont * font;

@property (nonatomic,strong)UIColor * textColor;

@property (nonatomic,assign)ContentAlignment contentAlignment;

@property (nonatomic,assign)UIEdgeInsets margin;

@property (nonatomic,assign)CGFloat fontAscent;

@property (nonatomic,assign)CGFloat fontDescent;

@property (nonatomic,assign)CGSize maxSize;

@property (nonatomic,assign)CGSize textSize;

@property (nonatomic,assign)CGPoint position;

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
        _font             = [UIFont systemFontOfSize:17];
        _textColor        = [UIColor blackColor];
        _contentAlignment = ContentAlignmentCenter;
        
        _attachments      = [NSMutableArray array];
        
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
    manager.font             = font;
    manager.textColor        = textColor;
    manager.contentAlignment = contentAlignment;
    manager.maxSize          = maxSize;
    manager.string           = string;
    
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
    _position = position;
    _textSize = textSize;
    
    //init _attributeString
    NSDictionary * attributes = [NSDictionary attributesWithFont:_font textColor:_textColor linkBreakMode:kCTLineBreakByCharWrapping];
    _attributeString = [[[NSAttributedString alloc] initWithString:self.string attributes:attributes] mutableCopy];
    
    /* emoji */
    
    //find emoji text position
    NSArray* matches = [[NSRegularExpression regularExpressionWithPattern:EmojiRegular options:NSRegularExpressionDotMatchesLineSeparators error:nil] matchesInString:self.attributeString.string options:0 range:NSMakeRange(0,[self.attributeString.string length])];

    //save rang.location offset
    NSInteger emojiStringOffset = 0;
    
    for(NSTextCheckingResult * match in matches)
    {
        NSRange currentRange = NSMakeRange(match.range.location - emojiStringOffset, match.range.length);
        
        NSString * imageName = [self.string substringWithRange:match.range];
        imageName = [imageName substringWithRange:NSMakeRange(1, imageName.length -2)];
        
        AttributeStringAttachment *attachment = [AttributeStringAttachment attachmentWith:[UIImage imageNamed:imageName]
                                                                                   margin:_margin
                                                                                alignment:_contentAlignment
                                                                                  maxSize:CGSizeMake(20, 20)];
    
        [self appendAttributeStringEmojiAttachment:attachment Range:currentRange];
        
        //get the sub string's offset so that we can get current range in the next setup
        emojiStringOffset = emojiStringOffset  + match.range.length - 1;
    }
    
    
    /* url */
    NSArray* urlMatches = [[NSRegularExpression regularExpressionWithPattern:URLRegular options:NSRegularExpressionDotMatchesLineSeparators error:nil] matchesInString:self.attributeString.string options:0 range:NSMakeRange(0,[self.attributeString.string length])];

    NSInteger urlStringOffset = 0;
    for(NSTextCheckingResult * match in urlMatches)
    {
        NSRange currentRange = NSMakeRange(match.range.location - urlStringOffset, match.range.length);
        
        AttributeStringAttachment *attachment = [AttributeStringAttachment attachmentWith:[UIImage imageNamed:@"urlIcon"]
                                                                                   margin:_margin
                                                                                alignment:_contentAlignment
                                                                                  maxSize:CGSizeMake(22, 22)];
//        NSString * urlString = [self.string substringWithRange:match.range];
        [self appendAttributeStringUrlAttachment:attachment Range:currentRange];
        
        urlStringOffset = urlStringOffset + match.range.length - 5;
    }
    
    /* user account */
    NSArray* accountMatches = [[NSRegularExpression regularExpressionWithPattern:AccountRegular options:NSRegularExpressionDotMatchesLineSeparators error:nil] matchesInString:self.attributeString.string options:0 range:NSMakeRange(0,[self.attributeString.string length])];
    
    NSDictionary * colorAttributes = [NSDictionary attributesWithFont:_font textColor:[UIColor colorWithRed:106/255.0 green:140/255.0 blue:181/255.0 alpha:1] linkBreakMode:kCTLineBreakByCharWrapping];
    
    for(NSTextCheckingResult * match in accountMatches)
    {
        [self.attributeString setAttributes:colorAttributes range:match.range];
    }
    
    //replace placeholder
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(position.x, -position.y, textSize.width, textSize.height));
    
    CFAttributedStringRef cfAttributeStringRef = (__bridge CFAttributedStringRef)_attributeString;
    CTFramesetterRef frameSetterRef = CTFramesetterCreateWithAttributedString(cfAttributeStringRef);
    CTFrameRef frameRef = CTFramesetterCreateFrame(frameSetterRef, CFRangeMake(0, 0), path, NULL);

    
    //draw
    [_attributeString drawTextOnContext:context position:position textSize:textSize];
    
    [self drawAttachments:context frame:frameRef];
}

- (void)appendAttributeStringEmojiAttachment:(AttributeStringAttachment *)attachment Range:(NSRange)range
{
    attachment.fontAscent                   = _fontAscent;
    attachment.fontDescent                  = _fontDescent;
    
    //placeholder
    unichar objectReplacementChar   = 0xFFFC;
    
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
    
    [_attributeString replaceCharactersInRange:range withAttributedString:attachText];
}

- (void)appendAttributeStringUrlAttachment:(AttributeStringAttachment *)attachment Range:(NSRange)range
{
    attachment.fontAscent                   = _fontAscent;
    attachment.fontDescent                  = _fontDescent;
    
    //placeholder
    unichar objectReplacementChar   = 0xFFFC;
    
    NSString *objectReplacementString       = [NSString stringWithCharacters:&objectReplacementChar length:1];
    NSMutableAttributedString *attachText   = [[NSMutableAttributedString alloc]initWithString:objectReplacementString];
    
    NSDictionary * attributes = [NSDictionary attributesWithFont:_font textColor:[UIColor colorWithRed:106/255.0 green:140/255.0 blue:181/255.0 alpha:1] linkBreakMode:kCTLineBreakByCharWrapping];
    [attachText appendAttributedString:[[NSAttributedString alloc] initWithString:@"网页链接" attributes:attributes]];
    
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
    
    [_attributeString replaceCharactersInRange:range withAttributedString:attachText];
}

-(void)drawAttachments:(CGContextRef)context frame:(CTFrameRef)frame
{
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, _maxSize.height);
    CGContextScaleCTM(context,1.0, -1.0);
    
    //no attachment
    if (_attachments.count == 0)
    {
        return;
    }
    
    //get CTRun
    CFArrayRef lines = CTFrameGetLines(frame);
    CFIndex lineCount = CFArrayGetCount(lines);
    CGPoint lineOrigins[lineCount];  //C type?
    CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), lineOrigins);
    
    NSInteger numberOfLines = CFArrayGetCount(lines);
    
    for (CFIndex i = 0; i < numberOfLines; i++)
    {
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        CFArrayRef runs = CTLineGetGlyphRuns(line);
        CFIndex runCount = CFArrayGetCount(runs);
        CGPoint lineOrigin = lineOrigins[i];
        CGFloat lineAscent;
        CGFloat lineDescent;
        CTLineGetTypographicBounds(line, &lineAscent, &lineDescent, NULL);
        CGFloat lineHeight = lineAscent  + lineDescent;
        CGFloat lineBottomY = lineOrigin.y - lineDescent;
        
//        NSLog(@"x is %f  y is %f",lineOrigin.x,lineOrigin.y);
        
        
        for (CFIndex k = 0; k < runCount; k++)
        {
            CTRunRef run = CFArrayGetValueAtIndex(runs, k);
            NSDictionary * runAttributes = (NSDictionary *)CTRunGetAttributes(run);
            CTRunDelegateRef delegate = (__bridge CTRunDelegateRef)[runAttributes valueForKey:(id)kCTRunDelegateAttributeName];
            if (delegate == nil)
            {
                continue;
            }
            AttributeStringAttachment * attributedImage = (AttributeStringAttachment *)CTRunDelegateGetRefCon(delegate);
            
            CGFloat ascent = 0.0f;
            CGFloat descent = 0.0f;
            CGFloat width = (CGFloat)CTRunGetTypographicBounds(run,
                                                               CFRangeMake(0, 0),
                                                               &ascent,
                                                               &descent,
                                                               NULL);
            
            CGFloat imageBoxHeight = [attributedImage boxSize].height;
            
            CGFloat xOffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, nil);
            
            CGFloat imageBoxOriginY = 0.0f;
            switch (attributedImage.alignment)
            {
                case ContentAlignmentTop:
                    imageBoxOriginY = _maxSize.height - _position.y - _textSize.height + lineBottomY + lineHeight;
                    break;
                case ContentAlignmentCenter:
                    imageBoxOriginY = _maxSize.height - _position.y - _textSize.height + lineBottomY + 2;
                    break;
                case ContentAlignmentBottom:
                    imageBoxOriginY = _maxSize.height - _position.y - _textSize.height + lineBottomY - lineHeight;
                    break;
            }
            
            
            
//            CGFloat height =  _textSize.height - lineOrigin.y + 24;
            
            /*
             
             context原坐标点是左上角，同UI的坐标系。翻转平移成左下原点，上右为正的坐标系。
             
             content绘制的部分是左上顶点在_position位置 size为_textSize的一个矩形。它的原点是左下顶点。
             
             所以为了能够对齐，我们需要将原点横向平移_position.x 竖直方向向上平移_maxSize.height - _position.y - _textSize.height
             
             这样对齐以后我们就可以用获取的lineOrigin.y来设置图片的位置  但是因为lineOrigin.y多了一个底部的行间距，所以移除掉
             
             这样就对齐了
             
             英语水平不够实在憋不出来英文注释了。。。
             
            */
            CGRect rect = CGRectMake(xOffset + _position.x,imageBoxOriginY, width, imageBoxHeight);
            UIEdgeInsets flippedMargins = attributedImage.margin;
            CGFloat top = flippedMargins.top;
            flippedMargins.top = flippedMargins.bottom;
            flippedMargins.bottom = top;
            
            CGRect attatchmentRect = UIEdgeInsetsInsetRect(rect, flippedMargins);
            
            if (i == numberOfLines - 1 &&
                k >= runCount - 2)
            {
//                //最后行最后的2个CTRun需要做额外判断
//                CGFloat attachmentWidth = CGRectGetWidth(attatchmentRect);
//                const CGFloat kMinEllipsesWidth = attachmentWidth;
//                if (CGRectGetWidth(self.bounds) - CGRectGetMinX(attatchmentRect) - attachmentWidth <  kMinEllipsesWidth)
//                {
//                    continue;
//                }
            }
            
            id content = attributedImage.content;
            if ([content isKindOfClass:[UIImage class]])
            {
                CGContextDrawImage(context, attatchmentRect, ((UIImage *)content).CGImage);
            }
//            else if ([content isKindOfClass:[UIView class]])
//            {
//                UIView *view = (UIView *)content;
//                if (view.superview == nil)
//                {
//                    [self addSubview:view];
//                }
//                CGRect viewFrame = CGRectMake(attatchmentRect.origin.x,
//                                              self.bounds.size.height - attatchmentRect.origin.y - attatchmentRect.size.height,
//                                              attatchmentRect.size.width,
//                                              attatchmentRect.size.height);
//                [view setFrame:viewFrame];
//            }
            else
            {
                NSLog(@"Attachment Content Not Supported %@",content);
            }


        }
    }
    CGContextSetTextMatrix(context,CGAffineTransformIdentity);
    CGContextTranslateCTM(context,0, _maxSize.height);
    CGContextScaleCTM(context,1.0,-1.0);
}
@end

#pragma mark    UIButton Category
@interface UIButton (BottomWidget)

- (void) changeTitle:(NSString *)title forState:(UIControlState)state;

@end


@implementation UIButton (BottomWidget)

- (void) changeTitle:(NSString *)title forState:(UIControlState)state
{
    CGFloat space = 7;
    CGFloat edge = self.frame.size.height - space * 2;
    CGFloat inset = 30;
    
    CGSize titleSize = [title boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, edge) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.titleLabel.font} context:nil].size;
    
    [self setImageEdgeInsets:UIEdgeInsetsMake(space,(self.frame.size.width - edge - inset - titleSize.width)/2,space,self.frame.size.width - edge - (self.frame.size.width - edge - inset - titleSize.width)/2)];
    
    [self.titleLabel setBackgroundColor:[UIColor clearColor]];
    
    [self setTitleEdgeInsets:UIEdgeInsetsMake(0 , self.frame.size.width - (self.frame.size.width - edge - inset - titleSize.width)/2 - titleSize.width  - self.frame.size.width/2, 0 , (self.frame.size.width - edge - inset - titleSize.width)/2)];
    [self setTitle:title forState:state];
    
}
@end

#pragma mark    LBWSocialTableViewCell
@interface LBWSocialTableViewCell ()
{
    ImageLayer * _icon;
    
    ContentManager * _contentManager;
    
    ContentManager * _repostManager;
    
    UIButton * _repostBtn;
    
    UIButton * _commentBtn;
    
    UIButton * _starBtn;
    
    CGFloat _btnWidth;
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
        
        _repostManager = [[ContentManager alloc] initWithFont:[UIFont systemFontOfSize:15] textColor:[UIColor blackColor] contentAlignment:ContentAlignmentCenter maxSize:self.frame.size string:@""];
        
        _repostBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        [_repostBtn setImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
        [_repostBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_repostBtn.titleLabel setFont:[UIFont systemFontOfSize:13.0]];
        [self addSubview:_repostBtn];
        
        _commentBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        [_commentBtn setImage:[UIImage imageNamed:@"comment"] forState:UIControlStateNormal];
        [_commentBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_commentBtn.titleLabel setFont:[UIFont systemFontOfSize:13.0]];
        [self addSubview:_commentBtn];
        
        _starBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        [_starBtn setImage:[UIImage imageNamed:@"star"] forState:UIControlStateNormal];
        [_starBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_starBtn.titleLabel setFont:[UIFont systemFontOfSize:13.0]];
        [self addSubview:_starBtn];
        
        _btnWidth = self.frame.size.width/3;
    }
    return self;
}

#pragma mark     -draw method
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
    [_icon setContentWitURL:model.iconUrl Type:@"Icon"];
    
    //draw text on context which is self.contentView.layer.content
    [model.nickName drawTextOnContext:context position:CGPointMake(kNickNameLeftEdge, kTopEdge) font:[UIFont systemFontOfSize:15] textColor:[UIColor blackColor] textSize:CGSizeMake(self.frame.size.width - kNickNameLeftEdge, 22) lineBreakMode:kCTLineBreakByTruncatingTail];
    
    [model.source drawTextOnContext:context position:CGPointMake(kNickNameLeftEdge, kTopEdge + 22) font:[UIFont systemFontOfSize:12] textColor:[UIColor lightGrayColor] textSize:CGSizeMake(self.frame.size.width - kNickNameLeftEdge, 18) lineBreakMode:kCTLineBreakByTruncatingTail];
    
    [self drawRectAngle:context frame:CGRectMake(0, kTopEdge + kIconSide + 10 + model.contentSize.height + 5, self.frame.size.width, model.repostContentSize.height + 10)];

    _contentManager.string = model.content;
    [_contentManager drawContentTextOnContext:context position:CGPointMake(kIconLeftEdge, kTopEdge + kIconSide + 10) textSize:model.contentSize];
    
    _repostManager.string = model.repostContent;
    [_repostManager drawContentTextOnContext:context position:CGPointMake(kIconLeftEdge, kTopEdge + kIconSide + 10 + model.contentSize.height + 10) textSize:model.repostContentSize];
    
    //get image from context and set it as self.contentView.layer.content
    UIImage *contentImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.contentView.layer.contents = (__bridge id)contentImage.CGImage;
    
    /* bottom widget */
    _repostBtn.frame = CGRectMake(0, self.frame.size.height - 30, _btnWidth, 30);
    [_repostBtn changeTitle:@"13" forState:UIControlStateNormal];
    
    _commentBtn.frame = CGRectMake(_btnWidth, self.frame.size.height - 30, _btnWidth, 30);
    [_commentBtn changeTitle:@"1223" forState:UIControlStateNormal];
    
    _starBtn.frame = CGRectMake(_btnWidth * 2, self.frame.size.height - 30, _btnWidth, 30);
    [_starBtn changeTitle:@"1万" forState:UIControlStateNormal];
}

-(void)drawRectAngle:(CGContextRef)context frame:(CGRect)rect
{
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGRect rectangle = rect;
   
    CGPathAddRect(path,NULL, rectangle);
   
    CGContextAddPath(context, path);
    
    [[UIColor colorWithRed:0.937f green:0.937f blue:0.957f alpha:1.00f] setFill];
    
    [[UIColor colorWithRed:0.937f green:0.937f blue:0.957f alpha:1.00f] setStroke];
    
    CGContextSetLineWidth(context,0.5f);
   
    CGContextDrawPath(context, kCGPathFillStroke);

    CGPathRelease(path);
}

@end




