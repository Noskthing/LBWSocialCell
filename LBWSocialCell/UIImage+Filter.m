//
//  UIImage+Filter.m
//  LBWSocialCell
//
//  Created by ml on 16/7/22.
//  Copyright © 2016年 李博文. All rights reserved.
//

#import "UIImage+Filter.h"

@implementation UIImage (Filter)

- (UIImage *)filterImageWithColor:(UIColor *)color
{
    //set context
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    
    //get context
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //change coordination
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextTranslateCTM(context, 0, -self.size.height);
    
    //save state
    CGContextSaveGState(context);
    
    //draw color filter
    CGRect filterRect = CGRectMake(0, 0, self.size.width, self.size.height);
    CGContextClipToMask(context, filterRect, self.CGImage);
    [color set];
    CGContextFillRect(context, filterRect);
    
    //popping the graphics state stack in the process.
    CGContextRestoreGState(context);
    
    //set blend mode
    CGContextSetBlendMode(context, kCGBlendModeMultiply);
    
    //draw origin image
    CGContextDrawImage(context, filterRect, self.CGImage);
    
    UIImage * resultImage = UIGraphicsGetImageFromCurrentImageContext();
    
    //end
    UIGraphicsEndImageContext();
    
    return resultImage;
}
@end
