//
//  NSString+Draw.h
//  LBWSocialCell
//
//  Created by 李博文 on 16/7/23.
//  Copyright © 2016年 李博文. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "NSDictionary+AttributeString.h"

@interface NSString (Draw)

/**
 *  draw text on current context
 *
 *  @param context       current context. if u get wrong context u will be warning that ur context is invalid 0x0
 *  @param position      coordinate's zero point,in top-left
 *  @param font          text font. default is [UIFont systemOfSize:17]
 *  @param textColor     text color. default is black
 *  @param textSize      size for u drawing text. if size is less than min-Size real need context can not draw text
 *  @param lineBreakMode lineBreakMode
 */
-(void)drawTextOnContext:(CGContextRef)context
                position:(CGPoint)position
                    font:(UIFont *)font
               textColor:(UIColor *)textColor
                textSize:(CGSize)textSize
           lineBreakMode:(CTLineBreakMode)lineBreakMode;



/**
 *  ur text real size
 *
 *  @param maxSize       text size can not more than maxSize
 *  @param font          text font
 *  @param lineSpace     space between lines
 *  @param lineBreakMode lineBreakMode
 *
 *  @return size for ur text
 */
-(CGSize)textSizeWithConstrainedOfMaxSize:(CGSize)maxSize font:(UIFont *)font lineSpace:(CGFloat)lineSpace lineBreakMode:(CTLineBreakMode)lineBreakMode;
@end
