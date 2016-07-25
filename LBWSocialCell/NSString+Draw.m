//
//  NSString+Draw.m
//  LBWSocialCell
//
//  Created by 李博文 on 16/7/23.
//  Copyright © 2016年 李博文. All rights reserved.
//

#import "NSString+Draw.h"
#import "NSDictionary+AttributeString.h"

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
    
    NSMutableDictionary * attributes = [[NSDictionary attributesWithFont:font textColor:textColor linkBreakMode:lineBreakMode] mutableCopy];
    
    //set draw path rect
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(position.x, -position.y, textSize.width, textSize.height));
    
    //create attribute string
    NSMutableAttributedString * attributeString = [[NSMutableAttributedString alloc] initWithString:self attributes:attributes];
    CFAttributedStringRef cfAttributeStringRef = (__bridge CFAttributedStringRef)attributeString;
    
    //draw frame
    CTFramesetterRef frameSetterRef = CTFramesetterCreateWithAttributedString(cfAttributeStringRef);
    CTFrameRef frameRef = CTFramesetterCreateFrame(frameSetterRef, CFRangeMake(0, 0), path, NULL);
    CTFrameDraw(frameRef, context);
    
    //release
    CGPathRelease(path);
    CFRelease(frameSetterRef);
    CFRelease(frameRef);
}

@end
