//
//  LBWSocialTableViewCell.h
//  LBWSocialCell
//
//  Created by ml on 16/7/22.
//  Copyright © 2016年 李博文. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark    LBWSocialTableViewModel Class
@interface LBWSocialTableViewModel : NSObject

@property (nonatomic,copy)NSString * iconUrl;

@property (nonatomic,copy)NSString * nickName;

@end

#pragma mark    LBWSocialTableViewCell Class
@interface LBWSocialTableViewCell : UITableViewCell

/**
 *  cell will draw content with model.
 *
 *  @param model Data Model contants all data the cell need
 */
-(void)drawContentWithModel:(LBWSocialTableViewModel *)model;

@end