//
//  NSAttributedString+Draw.m
//  LBWSocialCell
//
//  Created by ml on 16/7/29.
//  Copyright © 2016年 李博文. All rights reserved.
//

#import "NSAttributedString+Draw.h"

@implementation NSAttributedString (Draw)

-(void)drawTextOnContext:(CGContextRef)context position:(CGPoint)position textSize:(CGSize)textSize
{
    //change coordation
    /*
     
     in NS/UI foundation the coordation zero point is in top-left
     it is different from CT foundation that zero point is in bottom-left
     
     */
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, textSize.height);
    CGContextScaleCTM(context,1.0, -1.0);
    
   
    
    //set draw path rect
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(position.x, -position.y, textSize.width, textSize.height));
    
    //create attribute string
    CFAttributedStringRef cfAttributeStringRef = (__bridge CFAttributedStringRef)self;
    
    //draw frame
    CTFramesetterRef frameSetterRef = CTFramesetterCreateWithAttributedString(cfAttributeStringRef);
    CTFrameRef frameRef = CTFramesetterCreateFrame(frameSetterRef, CFRangeMake(0, 0), path, NULL);
    CTFrameDraw(frameRef, context);
    
    //release
    CGPathRelease(path);
    CFRelease(frameSetterRef);
    CFRelease(frameRef);
    
    //reset CTM and attributeString so that it will not affect next step
    CGContextSetTextMatrix(context,CGAffineTransformIdentity);
    CGContextTranslateCTM(context,0, textSize.height);
    CGContextScaleCTM(context,1.0,-1.0);
}
@end
