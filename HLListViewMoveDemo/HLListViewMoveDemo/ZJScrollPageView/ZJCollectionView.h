//
//  ZJScrollView.h
//  ZJScrollPageView
//
//  Created by ZeroJ on 16/10/24.
//  Copyright © 2016年 ZeroJ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZJCollectionView : UICollectionView
@property (nonatomic, assign) BOOL shouldRecognizeSimultaneously;
//是否不可以左右滑动
@property (nonatomic, assign)BOOL noSlide;

typedef BOOL(^ZJScrollViewShouldBeginPanGestureHandler)(ZJCollectionView *collectionView, UIPanGestureRecognizer *panGesture);

- (void)setupScrollViewShouldBeginPanGestureHandler:(ZJScrollViewShouldBeginPanGestureHandler)gestureBeginHandler;

@end
