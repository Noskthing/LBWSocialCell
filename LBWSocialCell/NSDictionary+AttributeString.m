//
//  NSDictionary+AttributeString.m
//  test
//
//  Created by ml on 16/7/19.
//  Copyright © 2016年 ml. All rights reserved.
//

#import "NSDictionary+AttributeString.h"

@implementation NSDictionary (AttributeString)


+ (NSDictionary *)attributesWithFont:(UIFont *)font textColor:(UIColor *)color linkBreakMode:(CTLineBreakMode)linkBreakMode
{
    //font
    CTFontRef ctFont = CTFontCreateWithName((__bridge CFStringRef)font.fontName, font.pointSize, NULL);
    
    //alignment
    CTTextAlignment alignment = kCTTextAlignmentLeft;
    
    //lineSpace
    CGFloat linespace = 3;
    
    //paragraph style
    CTParagraphStyleRef style = CTParagraphStyleCreate((CTParagraphStyleSetting[3])
    {
        {kCTParagraphStyleSpecifierAlignment,sizeof(CTTextAlignment),&alignment},
        {kCTParagraphStyleSpecifierLineSpacingAdjustment,sizeof(CGFloat),&linespace},
        {kCTParagraphStyleSpecifierLineBreakMode,sizeof(CTLineBreakMode),&linkBreakMode}
    }, 3);
    
    NSMutableDictionary * attributeDict = [NSMutableDictionary dictionary];
    attributeDict[(id)kCTForegroundColorAttributeName] = (id)color.CGColor;
    attributeDict[(id)kCTFontAttributeName] = (__bridge id)ctFont;
    attributeDict[(id)kCTParagraphStyleAttributeName] = (__bridge id)style;
    
    //struct need release .but CTTextAlignment is enum.
    CFRelease(ctFont);
    CFRelease(style);
    
    return attributeDict;
}
@end
