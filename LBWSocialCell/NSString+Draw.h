//
//  NSString+Draw.h
//  LBWSocialCell
//
//  Created by 李博文 on 16/7/23.
//  Copyright © 2016年 李博文. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (Draw)

-(void)drawTextOnContext:(CGContextRef)context position:(CGPoint)position font:(UIFont *)font
               textColor:(UIColor *)textColor textSize:(CGSize)textSize lineBreakMode:(CTLineBreakMode)lineBreakMode;
@end
