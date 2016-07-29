//
//  LBWSocialTableViewCell.h
//  LBWSocialCell
//
//  Created by ml on 16/7/22.
//  Copyright © 2016年 李博文. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSString+Draw.h"
#import "UIImage+Filter.h"
#import "NSAttributedString+Draw.h"

#pragma mark    LBWSocialTableViewModel Class
@interface LBWSocialTableViewModel : NSObject

@property (nonatomic,copy)NSString * iconUrl;

@property (nonatomic,copy)NSString * nickName;

@property (nonatomic,copy)NSString * source;

@property (nonatomic,copy)NSString * content;

@property (nonatomic,assign)CGSize contentSize;

@property (nonatomic,assign)CGFloat cellHeight;

@end

static const CGFloat kContentTextMaxWidthScale = 0.75;

#pragma mark    LBWSocialTableViewCell Class
@interface LBWSocialTableViewCell : UITableViewCell

/**
 *  cell will draw content with model.
 *
 *  @param model Data Model contants all data the cell need
 */
-(void)drawContentWithModel:(LBWSocialTableViewModel *)model;

@end