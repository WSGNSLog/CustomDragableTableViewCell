//
//  EditContentCell.h
//  eCamera
//
//  Created by wsg on 2016/11/21.
//  Copyright © 2016年 coder. All rights reserved.
//

#import <UIKit/UIKit.h>
static NSString *cellReuseId = @"EditCell";
typedef void(^CellTapBlock)();
typedef void(^PicViewTapBlock)();
typedef void(^BtnClickBlock)(NSInteger tag);
@interface EditContentCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *picView;
@property (weak, nonatomic) IBOutlet UIView *btnView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnViewHeightConstraint;


@property (nonatomic,assign) BOOL isBtnViewHide;
/** <#des#> */
@property (nonatomic,copy) CellTapBlock cellTapBlock;
/** <#des#> */
@property (nonatomic,copy) PicViewTapBlock picViewTapBlock;
@property (nonatomic,copy) BtnClickBlock btnClickBlock;
- (CGFloat)cellHeight;
- (void)setBtnViewHideOrNot:(BOOL)isHidden;

@end
