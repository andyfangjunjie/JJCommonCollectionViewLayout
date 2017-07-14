//
//  SquareViewController.m
//  JJCommonCollectionViewLayoutDemo
//
//  Created by 房俊杰 on 2017/7/14.
//  Copyright © 2017年 房俊杰. All rights reserved.
//

#import "SquareViewController.h"
#import "JJCommonCollectionViewLayout.h"

@interface SquareViewController ()<JJCommonCollectionViewLayoutDataSource,UICollectionViewDelegate,UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation SquareViewController

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
#pragma mark - collectionView代理
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 30;
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor grayColor];
    
    return cell;
}


@end
