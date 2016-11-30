//
//  EditController.m
//  CustomDragableTableViewCell
//
//  Created by wsg on 2016/11/29.
//  Copyright © 2016年 wsg. All rights reserved.
//

#import "EditController.h"
#import "DragableTableView.h"
#import "CellModel.h"
#import "EditContentCell.h"

#define WWidth [UIScreen mainScreen].bounds.size.width
#define WHeight [UIScreen mainScreen].bounds.size.height

#define cellHeight 158
#define editCellHeight 218

@interface EditController ()<DragableTableViewDataSource,DragableTableViewDelegate>
@property (nonatomic, strong) NSArray *data;
@property (nonatomic,strong) DragableTableView * tableView;
//@property (nonatomic,strong) EditContentCell *editCell;
@property (assign, nonatomic) NSInteger editIndex;
@end

@implementation EditController

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.13f green:0.13f blue:0.13f alpha:1.00f];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17],NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.tabBarController.tabBar.hidden = YES;
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.90f green:0.91f blue:0.91f alpha:1.00f];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:20],NSForegroundColorAttributeName:[UIColor blackColor]}];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.13f green:0.13f blue:0.13f alpha:1.00f];
    self.title = @"功能：拖动cell改变顺序、复制、删除";
    self.editIndex = -1;
    
    DragableTableView *tableView = [[DragableTableView alloc]init];
    tableView.allowsSelection = YES;
    [self.view addSubview:tableView];
    tableView.frame = self.view.bounds;
    tableView.backgroundColor = [UIColor clearColor];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.dataSource = self;
    tableView.delegate = self;
    self.tableView = tableView;
    
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 28, WWidth, 56)];
    UIButton *headAddBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    headAddBtn.frame = CGRectMake(WWidth/2 -14, 14, 28, 28);
    [headAddBtn setImage:[UIImage imageNamed:@"AddNormal"] forState:UIControlStateNormal];
    [headerView addSubview:headAddBtn];
    tableView.tableHeaderView = headerView;
    

    
}


- (NSArray *)data{
    if (!_data) {
        NSMutableArray *arr = [NSMutableArray array];
        for (int j = 0; j < 10; j ++) {
            CellModel *model = [[CellModel alloc]init];
            [arr addObject:model];
            _data = arr;
        }
    }
    return _data;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.data.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    EditContentCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseId];
    if (cell==nil) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"EditContentCell" owner:self options:nil]lastObject];
        
    }
    
    cell.backgroundColor = [UIColor colorWithRed:0.13f green:0.13f blue:0.13f alpha:1.00f];
   
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    CellModel *model = self.data[indexPath.row];
    //Model的数据展示{...}
    
    
    if (self.editIndex == indexPath.row) {
        cell.btnViewHeightConstraint.constant = 60.0;
        cell.isBtnViewHide = NO;
        cell.btnView.hidden = NO;
    } else {
        cell.btnViewHeightConstraint.constant = 0.0;
        cell.isBtnViewHide = YES;
        cell.btnView.hidden = YES;
    }
    
    __weak typeof(cell) weakCell = cell;
    
    cell.picViewTapBlock =^(){
        NSIndexPath *tapCellIndex = [tableView indexPathForCell:weakCell];
        if (!weakCell.isBtnViewHide) {
            self.editIndex = -1;

        }else{
            self.editIndex = tapCellIndex.row;

        }
        
        NSLog(@"******%ld",(long)tapCellIndex.row);
        [self.tableView reloadData];
    };
    
    cell.cellTapBlock = ^(){
        self.editIndex = -1;

        [self.tableView reloadData];
    };
    
    cell.btnClickBlock = ^(NSInteger btnTag){
        
        if (btnTag == 10) {
            
            
        }else if (btnTag == 11){
            
            
        }else if (btnTag == 12){
            for (int i=0; i<self.data.count; i++) {
                NSIndexPath *tapCellIndex = [tableView indexPathForCell:weakCell];
                NSIndexPath *index = [NSIndexPath indexPathForRow:i inSection:0];
                if (tapCellIndex !=index) {
                    
                    EditContentCell *hideCell = [tableView cellForRowAtIndexPath:index];
                    hideCell.btnViewHeightConstraint.constant = 0.0;
                    hideCell.isBtnViewHide = YES;
                    hideCell.btnView.hidden = YES;
                }
            }
            
            NSMutableArray *newArr = [NSMutableArray arrayWithArray:self.data];
            CellModel *model = self.data[indexPath.row];
            [newArr insertObject:model atIndex:indexPath.row];
            _data = newArr;
            [self.tableView reloadData];
            
        }else if(btnTag == 13){
            
            NSMutableArray *newArr = [NSMutableArray arrayWithArray:self.data];
            [newArr removeObjectAtIndex:indexPath.row];
            _data = newArr;
            [self.tableView reloadData];
        }
    };
    
    return cell;
}
- (NSArray *)originalArrayDataForTableView:(DragableTableView *)tableView{
    
    return _data;
}

- (void)tableView:(DragableTableView *)tableView newArrayDataForDataSource:(NSArray *)newArray{
    self.editIndex = - 1;
    _data = newArray;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CGFloat height = cellHeight;
    if (self.editIndex == indexPath.row) {
        height = editCellHeight;
    }
    return height;
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
}

@end
