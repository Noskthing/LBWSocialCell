//
//  NSAttributedString+Draw.h
//  LBWSocialCell
//
//  Created by ml on 16/7/29.
//  Copyright © 2016年 李博文. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

@interface NSAttributedString (Draw)

-(void)drawTextOnContext:(CGContextRef)context position:(CGPoint)position textSize:(CGSize)textSize;
@end
