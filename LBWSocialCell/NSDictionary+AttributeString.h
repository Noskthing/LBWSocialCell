//
//  NSDictionary+AttributeString.h
//  test
//
//  Created by ml on 16/7/19.
//  Copyright © 2016年 ml. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

@interface NSDictionary (AttributeString)

+ (NSDictionary *)attributesWithFont:(UIFont *)font textColor:(UIColor *)color linkBreakMode:(CTLineBreakMode)linkBreakMode;

@end
