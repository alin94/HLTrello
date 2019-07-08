//
//  HLListViewMoveChildController.h
//  HLTrelloDemo
//
//  Created by alin on 2019/7/8.
//  Copyright © 2019年 alin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZJContentView.h"


@interface HLListViewMoveChildController : UIViewController <ZJScrollPageViewChildVcDelegate>
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, copy) NSString *titleText;
@end

