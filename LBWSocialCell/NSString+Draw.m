//
//  NSString+Draw.m
//  LBWSocialCell
//
//  Created by 李博文 on 16/7/23.
//  Copyright © 2016年 李博文. All rights reserved.
//

#import "NSString+Draw.h"


@implementation NSString (Draw)

-(void)drawTextOnContext:(CGContextRef)context position:(CGPoint)position font:(UIFont *)font textColor:(UIColor *)textColor textSize:(CGSize)textSize lineBreakMode:(CTLineBreakMode)lineBreakMode
{
    //change coordation
    /* 
     
     in NS/UI foundation the coordation zero point is in top-left
     it is different from CT foundation that zero point is in bottom-left
     
     */
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, textSize.height);
    CGContextScaleCTM(context,1.0, -1.0);
    
    NSMutableDictionary * attributes = [[NSDictionary attributesWithFont:font?font:[UIFont systemFontOfSize:17] textColor:textColor?textColor:[UIColor blackColor] linkBreakMode:lineBreakMode] mutableCopy];
    
    //set draw path rect
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(position.x, -position.y, textSize.width, textSize.height));
    
    //create attribute string
    NSMutableAttributedString * attributeString = [[NSMutableAttributedString alloc] initWithString:self?self:@"" attributes:attributes];
    CFAttributedStringRef cfAttributeStringRef = (__bridge CFAttributedStringRef)attributeString;
    
    //draw frame
    CTFramesetterRef frameSetterRef = CTFramesetterCreateWithAttributedString(cfAttributeStringRef);
    CTFrameRef frameRef = CTFramesetterCreateFrame(frameSetterRef, CFRangeMake(0, 0), path, NULL);
    CTFrameDraw(frameRef, context);
    
    //release
    CGPathRelease(path);
    CFRelease(frameSetterRef);
    CFRelease(frameRef);
    
    //reset CTM and attributeString so that it will not affect next step
    [[attributeString mutableString] setString:@""];
    
    CGContextSetTextMatrix(context,CGAffineTransformIdentity);
    CGContextTranslateCTM(context,0, textSize.height);
    CGContextScaleCTM(context,1.0,-1.0);
}

- (CGSize)textSizeWithConstrainedOfMaxSize:(CGSize)maxSize font:(UIFont *)font lineSpace:(CGFloat)lineSpace lineBreakMode:(CTLineBreakMode)lineBreakMode
{
    NSDictionary * attributes = [NSDictionary attributesWithFont:font textColor:nil linkBreakMode:lineBreakMode];
    
    NSMutableAttributedString * attributeString = [[NSMutableAttributedString alloc] initWithString:self attributes:attributes];
    CFAttributedStringRef attributeStringRef = (__bridge CFAttributedStringRef)attributeString;
    
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString(attributeStringRef);
    
    CGSize result = CTFramesetterSuggestFrameSizeWithConstraints(frameSetter, CFRangeMake(0, [attributeString length]), NULL, maxSize, NULL);
    
    //release
    CFRelease(frameSetter);
    
    //the code i copy use MRC ?
    attributeString = nil;
    attributes = nil;
    
    return result;
}

@end
