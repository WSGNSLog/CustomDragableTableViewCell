//
//  EditContentCell.m
//  eCamera
//
//  Created by wsg on 2016/11/21.
//  Copyright © 2016年 coder. All rights reserved.
//

#import "EditContentCell.h"

@implementation EditContentCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.btnView.hidden = YES;
    self.isBtnViewHide = YES;
    self.btnViewHeightConstraint.constant = 0.0;
    
    UITapGestureRecognizer *picViewTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(picViewTapGesture:)];
    [self.picView addGestureRecognizer:picViewTap];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    [self layoutIfNeeded];
    self.cellTapBlock();
}
- (void)picViewTapGesture:(UITapGestureRecognizer *)tap{
    self.picViewTapBlock();
}
- (IBAction)buttonClick:(UIButton *)sender {
    self.btnClickBlock(sender.tag);
}


- (void)screenTap:(UITapGestureRecognizer *)tap{
    
    self.cellTapBlock();
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    
}
- (void)setBtnViewHideOrNot:(BOOL)isHidden{
    [self layoutIfNeeded];
    self.btnView.hidden = isHidden;
    for (UIView *subV in self.btnView.subviews) {
        subV.hidden = isHidden;
        NSLog(@"========%@",subV);
    }
}
- (void)setBtnView:(UIView *)btnView{
    _btnView = btnView;
    [self layoutIfNeeded];
    
    btnView.hidden = _isBtnViewHide;
}
- (CGFloat)cellHeight{
    
    [self layoutIfNeeded];
    return 35 + 60 + self.btnViewHeightConstraint.constant + 35 + 28;
}
@end
