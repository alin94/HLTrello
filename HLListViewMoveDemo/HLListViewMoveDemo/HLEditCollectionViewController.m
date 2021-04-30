//
//  HLEditCollectionViewController.m
//  HLListViewMoveDemo
//
//  Created by alin on 2021/4/29.
//  Copyright © 2021 alin. All rights reserved.
//

#import "HLEditCollectionViewController.h"
#import "UIView+HLListView.h"
#import "HLListViewMoveGestureCoordinator.h"


#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width


@interface HLEditCollectionCell : UICollectionViewCell
@property (nonatomic, strong) UILabel *textLabel;

@end

@implementation HLEditCollectionCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self){
        UILabel *label = [[UILabel alloc] init];
        label.numberOfLines = 0;
        label.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:label];
        label.textColor = [UIColor blackColor];
        self.textLabel = label;
    }
    return self;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    self.textLabel.frame = self.bounds;
}

@end
@interface HLEditCollectionViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,HLListViewMoveDelegate>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) HLListViewMoveGestureCoordinator *collectionViewMoveGes;

@end

@implementation HLEditCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configDataSource];
    [self setupUI];
    [self addMoveGestureForCollectionView];
}
- (void)configDataSource {
    _dataArray = [NSMutableArray array];
    for (int i = 0; i < 3; i++) {
        NSMutableArray * childVCDataArray = [NSMutableArray array];
        for (int j = 0 ; j < 30; j++) {
            NSString * text = [NSString stringWithFormat:@"section%d cell:%d",i+1,j+1];
            [childVCDataArray addObject:text];
        }
        [_dataArray addObject:childVCDataArray];
    }
}
- (void)setupUI {
    //nav
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(backBtnClicked)];
    self.navigationItem.leftBarButtonItem = back;
    
    //collectionView
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake(SCREEN_WIDTH/4.f, 85);
    flowLayout.minimumLineSpacing = -0.5;
    flowLayout.minimumInteritemSpacing = -0.5;
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    collectionView.backgroundColor = [UIColor whiteColor];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    self.collectionView = collectionView;
    [self.view addSubview:collectionView];
    collectionView.frame = self.view.bounds;
    [collectionView registerClass:[HLEditCollectionCell class] forCellWithReuseIdentifier:@"HLEditCollectionCell"];
    
}
//添加手势管理
- (void)addMoveGestureForCollectionView {
    HLDragArea *arena = [[HLDragArea alloc] initWithSuperview:self.collectionView containingCollections:@[self.collectionView]];
    HLListViewMoveGestureCoordinator *ges = [[HLListViewMoveGestureCoordinator alloc] initWithDragArea:arena];
    ges.delegate = self;
    ges.mixMoveEnabled = YES;
    ges.bottomScrollView = self.collectionView;
    ges.rollingItemStyle = HLListViewDragItemStyle1;
    self.collectionViewMoveGes = ges;
    self.collectionView.dataSourceArray = [self.dataArray copy];
    __weak typeof(self) weakSelf = self;
    self.collectionView.dataSourceChangedBlock = ^(NSArray *dataSourceArray) {
        weakSelf.collectionView.dataSourceArray = [dataSourceArray mutableCopy];
    };
    
}
#pragma mark - <UICollectionViewDelegate,UICollectionViewDataSource>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.dataArray.count;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.dataArray[section] count];
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HLEditCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HLEditCollectionCell" forIndexPath:indexPath];
    cell.textLabel.text = self.dataArray[indexPath.section][indexPath.row];
    cell.layer.borderWidth = 0.5;
    cell.layer.borderColor = [UIColor redColor].CGColor;
    return cell;
}
#pragma mark - backBtnClicked
- (void)backBtnClicked{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark -
- (void)hl_listViewRollingCellDidEndScrollAtIndexPath:(NSIndexPath *)indexPath onListView:(UIView<HLListView> *)listView gestureCoordinator:(HLListViewMoveGestureCoordinator *)gestureCoordinator {
    NSLog(@"滚动到%@",indexPath);
}

@end

