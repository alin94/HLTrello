//
//  HLListViewMoveChildController.m
//  HLTrelloDemo
//
//  Created by alin on 2019/7/8.
//  Copyright © 2019年 alin. All rights reserved.
//

#import "HLListViewMoveChildController.h"
#import "UIView+HLListView.h"

@interface HLListViewMoveChildController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UILabel *titleLabel;
@end

@implementation HLListViewMoveChildController
- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 300, 60)];
        _titleLabel.textColor = [UIColor redColor];
        _titleLabel.font = [UIFont boldSystemFontOfSize:18];
    }
    return _titleLabel;
}
- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        __weak typeof(self) weakSelf = self;
        _tableView.dataSourceChangedBlock = ^(NSArray *dataSourceArray) {
            [weakSelf.dataArray removeAllObjects];
            [weakSelf.dataArray addObjectsFromArray:dataSourceArray];
            weakSelf.tableView.dataSourceArray = [weakSelf.dataArray copy];
        };
        _tableView.dataSourceExchangedBlock = ^(NSIndexPath *originalIndexPath, NSIndexPath *currentIndexPath) {
            NSLog(@"数据源交换了位置");
        };
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorInset = UIEdgeInsetsMake(0, 20, 0, 0);
    }
    return _tableView;
}
- (void)setDataArray:(NSMutableArray *)dataArray
{
    _dataArray = dataArray;
    self.tableView.dataSourceArray = dataArray;
    [self.tableView reloadData];
}
- (void)setTitleText:(NSString *)titleText
{
    _titleText = titleText;
    self.titleLabel.text = titleText;
}

- (void)dealloc
{
    [_tableView removeObserver:self forKeyPath:@"contentSize"];
    [self.view removeObserver:self forKeyPath:@"frame"];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.titleLabel];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor = [UIColor clearColor];
    
    [self.tableView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
    [self.view addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];

}

- (BOOL)nestedArrayCheck:(nonnull NSArray *)array {
    for (id obj in array) {
        if ([obj isKindOfClass:[NSArray class]]) {
            return YES;
        }
    }
    return NO;
}
#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // 检测是不是嵌套数组
    if ([self nestedArrayCheck:self.dataArray]) {
        return self.dataArray.count;
    }
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // 检测是不是嵌套数组
    if ([self nestedArrayCheck:self.dataArray]) {
        NSArray *array = self.dataArray[section];
        return array.count;
    }
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSString *title;
    // 检测是不是嵌套数组
    if ([self nestedArrayCheck:self.dataArray]) {
        title = self.dataArray[indexPath.section][indexPath.row];
    } else {
        title = self.dataArray[indexPath.row];
    }
    cell.textLabel.text = title;
    cell.backgroundColor = [UIColor greenColor];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    // 检测是不是嵌套数组
    if ([self nestedArrayCheck:self.dataArray]) {
        return 30;
    }
    return 0.1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    // 检测是不是嵌套数组
    if ([self nestedArrayCheck:self.dataArray]) {
        return [NSString stringWithFormat:@"第%ld组", section + 1];
    }
    return nil;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if (([keyPath isEqualToString:@"contentSize"] && object == self.tableView) || ([keyPath isEqualToString:@"frame"] && object == self.view)) {
        if (!_tableView) {
            return;
        }
        CGFloat height = self.tableView.contentSize.height;
        CGFloat maxHeight = self.view.frame.size.height - 60;
        if (height > maxHeight) {
            height = maxHeight;
        }
        if (height < 5) {
            height = 5;
        }
        self.tableView.frame = CGRectMake(0, 60, self.view.frame.size.width , height);
    }
    else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
