//
//  ViewController.m
//  HLTrelloDemo
//
//  Created by alin on 2019/7/8.
//  Copyright © 2019年 alin. All rights reserved.
//

#import "ViewController.h"
#import "UIView+HLListView.h"
#import "HLListViewMoveGestureCoordinator.h"
#import "ZJContentView.h"
#import "HLListViewMoveChildController.h"

#define kContentHeight (self.view.bounds.size.height - 80)
#define kPageWidth (kScreenWidth - margin*3)
#define kScreenWidth [UIScreen mainScreen].bounds.size.width

@interface ViewController ()<ZJScrollPageViewDelegate,UIScrollViewDelegate,HLListViewMoveDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong)ZJContentView *contentView;
@property (strong, nonatomic) UICollectionViewFlowLayout *collectionViewLayout;
@property (nonatomic, strong) NSMutableArray *childVCS;
@property (nonatomic, assign) BOOL zoomIn;
@property (nonatomic, assign) BOOL lastZoomIn;
@property (nonatomic, strong) HLListViewMoveGestureCoordinator *collectionViewMoveGes;
@property (nonatomic, strong) HLListViewMoveGestureCoordinator *tableViewMoveGes;
@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation ViewController
static const float margin = 15;
static const int listCount  = 6;

#pragma mark- getter
- (UIScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(margin*2, 25,kScreenWidth - margin*3 , kContentHeight*2)];
        _scrollView.delegate = self;
        _scrollView.maximumZoomScale = 1;
        _scrollView.minimumZoomScale = 0.5;
        _scrollView.clipsToBounds = NO;
        _scrollView.pagingEnabled = YES;
        [self.view addSubview:_scrollView];
    }
    return _scrollView;
}
- (UICollectionViewFlowLayout *)collectionViewLayout {
    if (_collectionViewLayout == nil) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.sectionInset = UIEdgeInsetsMake(0, margin*2, 0, margin*2);
        layout.minimumLineSpacing = margin;
        layout.itemSize = CGSizeMake(kScreenWidth - layout.sectionInset.left*2, kContentHeight);
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionViewLayout = layout;
    }
    
    return _collectionViewLayout;
}

- (ZJContentView *)contentView {
    if (_contentView == nil) {
        ZJContentView *content = [[ZJContentView alloc] initWithFrame:CGRectMake(0, 0, (kScreenWidth - margin*4 + margin)*listCount, kContentHeight*2) collectionViewflowlayout:self.collectionViewLayout segmentView:nil parentViewController:self delegate:self];
        _contentView = content;
    }
    return _contentView;
}
- (UICollectionView *)collectionView
{
    return self.contentView.collectionView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _childVCS = [NSMutableArray array];
        [self configDataArray];
//    [self configGroupDataArray];
    [self configLayout];
    [self scrollView];
    [self contentView];
    self.collectionView.frame = self.contentView.bounds;
    [self.scrollView addSubview:self.contentView];
    self.collectionView.pagingEnabled = NO;
    self.collectionView.scrollEnabled = NO;
    self.collectionView.backgroundColor = self.view.backgroundColor = [UIColor lightGrayColor];
    self.collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    self.collectionView.bounces = YES;
    UIGestureRecognizer *gesture = self.collectionView.pinchGestureRecognizer;
    [self.collectionView removeGestureRecognizer:gesture];
    __weak typeof(self) weakSelf = self;
    self.collectionView.dataSourceChangedBlock = ^(NSArray *dataSourceArray) {
        [weakSelf.dataArray removeAllObjects];
        [weakSelf.dataArray addObjectsFromArray:dataSourceArray];
        weakSelf.collectionView.dataSourceArray = [weakSelf.dataArray copy];
    };
    [self.scrollView setZoomScale:1];
    self.scrollView.pinchGestureRecognizer.enabled = NO;
    
    //添加手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapCollectionView:)];
    tap.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:tap];
    [self addMoveGestureForCollectionView];
}
#pragma mark- addGes
- (void)addMoveGestureForCollectionView
{
    HLDragArea *arena = [[HLDragArea alloc] initWithSuperview:self.collectionView containingCollections:@[self.collectionView]];
    HLListViewMoveGestureCoordinator *ges = [[HLListViewMoveGestureCoordinator alloc] initWithDragArea:arena];
    ges.delegate = self;
    ges.bottomScrollView = self.scrollView;
    ges.longPressPositionMaxY = 60;
    ges.mixMoveEnabled = NO;
    self.collectionViewMoveGes = ges;
}
- (void)addGestForAllGesWithTableViews:(NSArray *)tableViews
{
    HLDragArea *arena = [[HLDragArea alloc] initWithSuperview:self.contentView.collectionView containingCollections:tableViews];
    HLListViewMoveGestureCoordinator *ges = [[HLListViewMoveGestureCoordinator alloc] initWithDragArea:arena];
    ges.delegate = self;
    ges.bottomScrollView = self.scrollView;
    self.tableViewMoveGes = ges;
    [self.tableViewMoveGes.longPress requireGestureRecognizerToFail:self.collectionViewMoveGes.longPress];
}

#pragma mark - event
- (void)doubleTapCollectionView:(UIGestureRecognizer *)sender
{
    CGPoint gesPoint =[sender locationInView:self.view];
    CGPoint containerPoint = [self.view convertPoint:gesPoint toView:self.contentView];
    NSInteger index = containerPoint.x/kPageWidth;
    self.zoomIn = !self.zoomIn;
    [self zoomAtPageIndex:index];
}

#pragma mark- dataSource
- (void)configDataArray
{
    _dataArray = [NSMutableArray array];
    for (int i = 0; i < listCount; i++) {
        NSMutableArray * childVCDataArray = [NSMutableArray array];
        for (int j = 0 ; j < 2; j++) {
            NSString * text = [NSString stringWithFormat:@"Controll %d cell:%d",i+1,j+1];
            [childVCDataArray addObject:text];
        }
        [_dataArray addObject:childVCDataArray];
    }
}
- (void)configGroupDataArray
{
    _dataArray = [NSMutableArray array];
    for (int i = 0; i < listCount; i++) {
        NSMutableArray * childVCDataArray = [NSMutableArray array];
        for (int j = 0 ; j < 5; j++) {
            NSMutableArray *sectionDataArray = [NSMutableArray array];
            for (int k = 0; k < 5; k++) {
                NSString * text = [NSString stringWithFormat:@"Controll %d section: %d  cell:%d",i+1,j+1,k+1];
                [sectionDataArray addObject:text];
            }
            [childVCDataArray addObject:sectionDataArray];
        }
        [_dataArray addObject:childVCDataArray];
    }
    
}

#pragma mark- zoom and scroll
- (void)scrollToCurrentPage
{
    int  currentPage = (int)(self.scrollView.contentOffset.x + self.scrollView.frame.size.width*0.5)/self.scrollView.frame.size.width;
    [UIView animateWithDuration:0.3 animations:^{
        [self.scrollView setContentOffset:CGPointMake(currentPage*kPageWidth, 0)];
    } completion:^(BOOL finished) {
    }];
}
- (void)zoomAtPageIndex:(NSInteger)index
{
    if (self.zoomIn) {
        if (index == listCount - 1 ) {
            index --;
        }
        self.scrollView.pagingEnabled = NO;
        [UIView animateWithDuration:0.3 animations:^{
            [self.scrollView setZoomScale:0.5];
            NSLog(@"设置偏移====%f",index*kPageWidth/2);
            [self.scrollView setContentOffset:CGPointMake(index*kPageWidth/2, 0)];
        } completion:^(BOOL finished) {
        }];
        [self configLayout];
        [self.collectionViewLayout invalidateLayout];
    }else{
        self.scrollView.pagingEnabled = YES;
        [UIView animateWithDuration:0.3 animations:^{
            [self.scrollView setZoomScale:1];
            NSLog(@"设置偏移====%f",index*kPageWidth/2);
            [self.scrollView setContentOffset:CGPointMake(index*kPageWidth, 0)];
            
        }completion:^(BOOL finished) {
            [self configLayout];
            [self.collectionViewLayout invalidateLayout];
        }];
    }
}
- (void)configLayout
{
    if (self.zoomIn) {
        self.collectionViewLayout.itemSize = CGSizeMake(kScreenWidth - margin*4, kContentHeight*2);
        self.collectionViewLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0,0);
    }else{
        self.collectionViewLayout.itemSize = CGSizeMake(kScreenWidth - margin*4, kContentHeight);
        self.collectionViewLayout.sectionInset = UIEdgeInsetsMake(0, 0, kContentHeight,0);
    }
}
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.contentView;
}

#pragma mark- ZJScrollPageViewDelegate
- (NSInteger)numberOfChildViewControllers {
    return listCount;
}

- (UIViewController<ZJScrollPageViewChildVcDelegate> *)childViewController:(UIViewController<ZJScrollPageViewChildVcDelegate> *)reuseViewController forIndex:(NSInteger)index {
    HLListViewMoveChildController<ZJScrollPageViewChildVcDelegate> *childVc = (HLListViewMoveChildController *)reuseViewController;
    if (!childVc) {
        childVc = [[HLListViewMoveChildController alloc] init];
        childVc.titleText = [NSString stringWithFormat:@"Controller %d",index + 1];
        childVc.dataArray = self.dataArray[index];
        [_childVCS addObject:childVc];
        NSLog(@"轮到%d",index);
    }
    return childVc;
}
- (void)scrollPageController:(UIViewController *)scrollPageController childViewControllWillAppear:(UIViewController *)childViewController forIndex:(NSInteger)index;
{
    if (index == listCount - 1) {
        NSMutableArray *tableViews = [NSMutableArray array];
        NSInteger i = 0;
        for (HLListViewMoveChildController *vc in _childVCS) {
            vc.tableView.idString = [NSString stringWithFormat:@"list%d",i];
            [tableViews addObject:vc.tableView];
            i++;
        }
        [self addGestForAllGesWithTableViews:tableViews];
    }
}
#pragma mark- UIScrollViewRollViewDelegate

- (void)hl_listViewBeginLongPressAtIndexPath:(NSIndexPath *)indexPath onListView:(UIView<HLListView> *)listView gestureCoordinator:(HLListViewMoveGestureCoordinator *)gestureCoordinator{
    if (gestureCoordinator == self.collectionViewMoveGes) {
        self.lastZoomIn = self.zoomIn;
        if (!self.zoomIn) {
            self.zoomIn = YES;
            [self zoomAtPageIndex:indexPath.row];
        }
    }
}
- (void)hl_listViewRollingCellDidEndScrollAtIndexPath:(NSIndexPath *)indexPath onListView:(UIView<HLListView> *)listView gestureCoordinator:(HLListViewMoveGestureCoordinator *)gestureCoordinator{
    NSLog(@"listViewId===%@",listView.idString);
    if (gestureCoordinator == self.collectionViewMoveGes) {
        if (!self.lastZoomIn) {
            self.zoomIn = NO;
            [self zoomAtPageIndex:indexPath.row];
        }
    }else{
        if (!self.zoomIn) {
            [self scrollToCurrentPage];
        }
    }
}

#pragma mark- scrollview
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!self.zoomIn) {
        int  currentPage = (int)(self.scrollView.contentOffset.x + self.scrollView.frame.size.width*0.5)/self.scrollView.frame.size.width;
        NSLog(@"当前页面==%d",currentPage);
    }
}

@end
