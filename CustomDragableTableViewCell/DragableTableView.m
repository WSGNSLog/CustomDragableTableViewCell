




//
//  DragableTableView.m
//  eCamera
//
//  Created by wsg on 2016/11/21.
//  Copyright © 2016年 coder. All rights reserved.
//

#import "DragableTableView.h"

typedef enum {
    SnapshotMeetsEdgeTop,
    SnapshotMeetsEdgeBottom,
}SnapshotMeetsEdge;


@interface DragableTableView ()

/** 被选中的cell的截图*/
@property(nonatomic,weak) UIView *snapShot;
/** 被选中的cell的原始位置 */
@property(nonatomic,strong)NSIndexPath *originalIndexPath;
/** 被选中的cell的新位置 */
@property(nonatomic,strong)NSIndexPath *relocatedIndexPath;
/** 定时器 */
@property(nonatomic,strong)CADisplayLink *disPlayLink;
/** 记录手指所在的位置 */
@property(nonatomic,assign)CGPoint fingerLocation;
/** 自动滚动的方向 */
@property(nonatomic,assign)SnapshotMeetsEdge autoScrollDirection;



@end


@implementation DragableTableView

@dynamic delegate;
@dynamic dataSource;

# pragma mark - initialization methods
- (instancetype)init{
    self = [super init];
    if (self) {
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressGestureRecognized:)];
        [self addGestureRecognizer:longPress];
    }
    return self;
}


# pragma mark - Gesture methods
- (void)longPressGestureRecognized:(id)sender{
    UILongPressGestureRecognizer *longPress = (UILongPressGestureRecognizer *)sender;
    UIGestureRecognizerState longPressState = longPress.state;
    _fingerLocation = [longPress locationInView:self];
    _relocatedIndexPath = [self indexPathForRowAtPoint:_fingerLocation];
    switch (longPressState) {
        case UIGestureRecognizerStateBegan:{
            _originalIndexPath = [self indexPathForRowAtPoint:_fingerLocation];
            if (_originalIndexPath) {
                [self cellSelectedAtIndexPath:_originalIndexPath];
            }
            break;
        }
        case UIGestureRecognizerStateChanged:{
            CGPoint center = _snapShot.center;
            center.y = _fingerLocation.y;
            _snapShot.center = center;
            if ([self checkIfSnapshotMeetsEdge]) {
                [self startAutoScrollTimer];
            }else{
                [self stopAutoScrollTimer];
            }
            _relocatedIndexPath = [self indexPathForRowAtPoint:_fingerLocation];
            if (_relocatedIndexPath && ![_relocatedIndexPath isEqual:_originalIndexPath]) {
                [self cellRelocatedToNewIndexPath:_relocatedIndexPath];
            }
            break;
        }
        default: {
            [self stopAutoScrollTimer];
            [self didEndDraging];
            break;
        }
    }
}

# pragma mark - timer methods
- (void)startAutoScrollTimer{
    if (!_disPlayLink) {
        _disPlayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(startAutoScroll)];
        [_disPlayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
}
- (void)stopAutoScrollTimer{
    if (_disPlayLink) {
        [_disPlayLink invalidate];
        _disPlayLink = nil;
    }
}

# pragma mark - Private methods
- (void)updateDataSource{
    
    NSMutableArray *tempArray = [NSMutableArray array];
    if ([self.dataSource respondsToSelector:@selector(originalArrayDataForTableView:)]) {
        [tempArray addObjectsFromArray:[self.dataSource originalArrayDataForTableView:self]];
    }
    //判断原始数据源是否为嵌套数组
    if ([self nestedArrayCheck:tempArray]) {
        if (_originalIndexPath.section == _relocatedIndexPath.section) {//在同一个section内
            [self moveObjectInMutableArray:tempArray[_originalIndexPath.section] fromIndex:_originalIndexPath.row toIndex:_relocatedIndexPath.row];
        }else{                                                          //不在同一个section内
            id originalObj = tempArray[_originalIndexPath.section][_originalIndexPath.item];
            [tempArray[_relocatedIndexPath.section] insertObject:originalObj atIndex:_relocatedIndexPath.item];
            [tempArray[_originalIndexPath.section] removeObjectAtIndex:_originalIndexPath.item];
        }
    }else{
        [self moveObjectInMutableArray:tempArray fromIndex:_originalIndexPath.row toIndex:_relocatedIndexPath.row];
    }

    if ([self.delegate respondsToSelector:@selector(tableView:newArrayDataForDataSource:)]) {
        [self.delegate tableView:self newArrayDataForDataSource:tempArray];
    }
}

- (BOOL)nestedArrayCheck:(NSArray *)array{
    for (id obj in array) {
        if ([obj isKindOfClass:[NSArray class]]) {
            return YES;
        }
    }
    return NO;
}

- (void)cellSelectedAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [self cellForRowAtIndexPath:indexPath];
    UIView *snapshot = [self customSnapshotFromView:cell];
    [self addSubview:snapshot];
    _snapShot = snapshot;
    cell.hidden = YES;
    CGPoint center = _snapShot.center;
    center.y = _fingerLocation.y;
    [UIView animateWithDuration:0.2 animations:^{
        _snapShot.transform = CGAffineTransformMakeScale(1.03, 1.03);
        _snapShot.alpha = 0.98;
        _snapShot.center = center;
    }];
}

- (void)cellRelocatedToNewIndexPath:(NSIndexPath *)indexPath{
    //更新数据源并返回给外部
    [self updateDataSource];
    //交换移动cell位置
    [self moveRowAtIndexPath:_originalIndexPath toIndexPath:indexPath];
    //更新cell的原始indexPath为当前indexPath
    _originalIndexPath = indexPath;
}

- (void)didEndDraging{
    UITableViewCell *cell = [self cellForRowAtIndexPath:_originalIndexPath];
    cell.hidden = NO;
    cell.alpha = 0;
    [UIView animateWithDuration:0.2 animations:^{
        _snapShot.center = cell.center;
        _snapShot.alpha = 0;
        _snapShot.transform = CGAffineTransformIdentity;
        cell.alpha = 1;
    } completion:^(BOOL finished) {
        cell.hidden = NO;
        [_snapShot removeFromSuperview];
        _snapShot = nil;
        _originalIndexPath = nil;
        _relocatedIndexPath = nil;
    }];
}

- (UIView *)customSnapshotFromView:(UIView *)inputView {

    UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, NO, 0);
    [inputView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIView *snapshot = [[UIImageView alloc] initWithImage:image];
    snapshot.center = inputView.center;
    snapshot.layer.masksToBounds = NO;
    snapshot.layer.cornerRadius = 0.0;
    snapshot.layer.shadowOffset = CGSizeMake(-5.0, 0.0);
    snapshot.layer.shadowRadius = 5.0;
    snapshot.layer.shadowOpacity = 0.4;
    
    return snapshot;
}
/**
 *  将可变数组中的一个对象移动到该数组中的另外一个位置
 */
- (void)moveObjectInMutableArray:(NSMutableArray *)array fromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex{
    if (fromIndex < toIndex) {
        for (NSInteger i = fromIndex; i < toIndex; i ++) {
            [array exchangeObjectAtIndex:i withObjectAtIndex:i + 1];
        }
    }else{
        for (NSInteger i = fromIndex; i > toIndex; i --) {
            [array exchangeObjectAtIndex:i withObjectAtIndex:i - 1];
        }
    }
}

- (BOOL)checkIfSnapshotMeetsEdge{
    CGFloat minY = CGRectGetMinY(_snapShot.frame);
    CGFloat maxY = CGRectGetMaxY(_snapShot.frame);
    if (minY < self.contentOffset.y) {
        _autoScrollDirection = SnapshotMeetsEdgeTop;
        return YES;
    }
    if (maxY > self.bounds.size.height + self.contentOffset.y) {
        _autoScrollDirection = SnapshotMeetsEdgeBottom;
        return YES;
    }
    return NO;
}
/**
 *  开始自动滚动
 */
- (void)startAutoScroll{
    CGFloat pixelSpeed = 4;
    if (_autoScrollDirection == SnapshotMeetsEdgeTop) {
        if (self.contentOffset.y > 0) {
            [self setContentOffset:CGPointMake(0, self.contentOffset.y - pixelSpeed)];
            _snapShot.center = CGPointMake(_snapShot.center.x, _snapShot.center.y - pixelSpeed);
        }
    }else{
        if (self.contentOffset.y + self.bounds.size.height < self.contentSize.height) {
            [self setContentOffset:CGPointMake(0, self.contentOffset.y + pixelSpeed)];
            _snapShot.center = CGPointMake(_snapShot.center.x, _snapShot.center.y + pixelSpeed);
        }
    }
    _relocatedIndexPath = [self indexPathForRowAtPoint:_snapShot.center];
    if (_relocatedIndexPath && ![_relocatedIndexPath isEqual:_originalIndexPath]) {
        [self cellRelocatedToNewIndexPath:_relocatedIndexPath];
    }
}
@end
