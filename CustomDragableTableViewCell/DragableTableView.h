//
//  DragableTableView.h
//  eCamera
//
//  Created by wsg on 2016/11/21.
//  Copyright © 2016年 coder. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DragableTableView;
@protocol  DragableTableViewDataSource<UITableViewDataSource>
@required
- (NSArray *)originalArrayDataForTableView:(DragableTableView *)tableView;
@end

@protocol DragableTableViewDelegate <UITableViewDelegate>
@required

- (void)tableView:(DragableTableView *)tableView newArrayDataForDataSource:(NSArray *)newArray;
@optional
- (void)tableView:(DragableTableView *)tableView cellReadyToMoveAtIndexPath:(NSIndexPath *)indexPath;

- (void)cellIsMovingInTableView:(DragableTableView *)tableView;

- (void)cellDidEndMovingInTableView:(DragableTableView *)tableView;

@end


@interface DragableTableView : UITableView

@property (nonatomic,assign) id<DragableTableViewDataSource> dataSource;

@property (nonatomic,assign) id<DragableTableViewDelegate> delegate;
@end
