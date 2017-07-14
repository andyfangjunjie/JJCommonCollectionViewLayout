//
//  ComplexViewController.m
//  JJCommonCollectionViewLayoutDemo
//
//  Created by 房俊杰 on 2017/7/14.
//  Copyright © 2017年 房俊杰. All rights reserved.
//

#import "ComplexViewController.h"
#import "JJCommonCollectionViewLayout.h"

@interface ComplexViewController ()<JJCommonCollectionViewLayoutDataSource,UICollectionViewDelegate,UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation ComplexViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    JJCommonCollectionViewLayout *layout = [[JJCommonCollectionViewLayout alloc] initWithDataSource:self];
    self.collectionView.collectionViewLayout = layout;
}

#pragma mark - layout代理
- (CGFloat)commonCollectionViewLayout:(JJCommonCollectionViewLayout *)layout
             heightForItemAtIndexPath:(NSIndexPath *)indexPath
                            itemWidth:(CGFloat)itemWith
                            rowMargin:(CGFloat)rowMargin {
    return 100;
}
/** 每一个分区有多少列 */
- (NSInteger)commonCollectionViewLayout:(JJCommonCollectionViewLayout *)layout
               numberOfColumnsInSection:(NSInteger)section {
    return [@[@"1",@"2"][section] integerValue];
}
/** 区头，区尾的高度 */
- (CGFloat)commonCollectionViewLayout:(JJCommonCollectionViewLayout *)layout
  heightForSupplementaryViewInSection:(NSInteger)section
              supplementaryViewOfKind:(NSString *)elementKind {
    return 10;
}
#pragma mark - collectionView代理
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 2;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [@[@"3",@"6"][section] integerValue];
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor grayColor];
    
    return cell;
}

@end
