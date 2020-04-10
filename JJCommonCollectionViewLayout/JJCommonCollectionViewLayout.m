//
//  JJCommonCollectionViewLayout.h
//  通用Layout
//
//  Created by 房俊杰 on 2015/3/2.
//  Copyright © 2015年 房俊杰. All rights reserved.
//
//  通过简单的设置就能得到意想不到的布局


#import "JJCommonCollectionViewLayout.h"

#define CollectionViewWidth self.collectionView.frame.size.width
#define CollectionViewHeight self.collectionView.frame.size.height

#pragma mark - 默认属性
/** 每一个分区的列数 */
NSInteger    const DefaultColumnsOfSection = 2;
/** 整体的内边距 */
UIEdgeInsets const DefaultEdgeInsetsOfOverall = {0,0,0,0};
/** 每一分区的内边距 */
UIEdgeInsets const DefaultEdgeInsetsOfSection = {0,0,0,0};
/** 每一列的间距 */
CGFloat      const DefaultMarginOfColumn = 5;
/** 每一行的间距 */
CGFloat      const DefaultMarginOfRow = 5;
/** 区头，区尾的高度 */
CGFloat      const DefalutHeightOfHeaderOrFooter = 0;
/** 区头，区尾的内边距 */
UIEdgeInsets const DefaultEdgeInsetsOfHeaderOrFooter = {0,0,0,0};



@interface JJCommonCollectionViewLayout ()

/** 布局元素数组 二维数组 */
@property (nonatomic,strong) NSMutableArray *attributesArray;
/** 每一列的高度 */
@property (nonatomic,strong) NSMutableArray *columnHeightArray;
/** 记录内容高度 */
@property (nonatomic,assign) CGFloat contentHeight;
/** 数据源代理 */
@property (nonatomic,weak) __weak id<JJCommonCollectionViewLayoutDataSource>dataSource;

@end

@implementation JJCommonCollectionViewLayout

- (instancetype)initWithDataSource:(__weak id<JJCommonCollectionViewLayoutDataSource>)dataSource {
    if (self == [super init]) {
        self.dataSource = dataSource;
    }
    return self;
}

#pragma mark - 懒加载
/** 布局元素数组 二维数组 */
- (NSMutableArray *)attributesArray {
    if (_attributesArray == nil) {
        _attributesArray = [NSMutableArray array];
    }
    return _attributesArray;
}
/** 每一列的高度 */
- (NSMutableArray *)columnHeightArray {
    if (_columnHeightArray == nil) {
        _columnHeightArray = [NSMutableArray array];
    }
    return _columnHeightArray;
}
#pragma mark - layout基本设置

/**
 初始化工作
 */
- (void)prepareLayout {
    [super prepareLayout];
    
    //设置每一列的高度
    [self setupColumnHeight];
    
    //设置布局元素
    [self setupAttributes];
    
}
/** 设置每一列的高度 */
- (void)setupColumnHeight {
    [self.columnHeightArray removeAllObjects];
    
    //如果设置了代理 - (NSInteger)commonCollectionViewLayout:(JJCommonCollectionViewLayout *)layout numberOfColumnsInSection:(NSInteger)section;
    //应该添加最大的列数的数组，防止数组越界
    // 找出列数做多的分区
    NSInteger maxColumnOfSection = 0;
    //获取一共多少列
    NSInteger sections = [self.collectionView numberOfSections];
    for (NSInteger section = 0;section < sections;section++) {
        NSInteger column = [self numberOfColumnsInSection:section];
        if (column > maxColumnOfSection) {
            maxColumnOfSection = column;
        }
    }
    
    self.contentHeight = [self edgeInsetsOfOverall].top;
    
    //添加默认值，加上整体内边距的top值
    for (NSInteger i = 0;i < maxColumnOfSection;i++) {
        [self.columnHeightArray addObject:@(self.contentHeight)];
    }
}
/** 设置布局元素 */
- (void)setupAttributes {
    [self.attributesArray removeAllObjects];
    
    //获取有几个分区
    NSInteger sections = [self.collectionView numberOfSections];
    //设置布局元素的属性 - 位置frame
    for (NSInteger section = 0;section < sections;section++) {
        
        NSMutableArray *array = [NSMutableArray array];
        //设置区头
        [array addObject:[self setupHeaderInSection:section]];
        
        //每一分区中的item
        NSInteger rows = [self.collectionView numberOfItemsInSection:section];
        for (NSInteger row = 0;row < rows;row++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
            UICollectionViewLayoutAttributes *attribute = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            //设置每一个分区的item
            //找出高度最短的那一列
            NSInteger minHeightColumn = 0;
            CGFloat minHeight = [self.columnHeightArray[0] doubleValue];
            for (NSInteger i = 1;i < [self numberOfColumnsInSection:section];i++) {
                CGFloat columnHeight = [self.columnHeightArray[i] doubleValue];
                if (columnHeight < minHeight) {
                    minHeight = columnHeight;
                    minHeightColumn = i;
                }
            }
            
            //1.设置宽度
            CGFloat width = (CollectionViewWidth - [self edgeInsetsOfOverall].left - [self edgeInsetsOfOverall].right - ([self numberOfColumnsInSection:section] - 1) * [self marginOfColumnInSection:section] - [self edgeInsetsInSection:section].left - [self edgeInsetsInSection:section].right) / [self numberOfColumnsInSection:section];
            //2.设置x
            CGFloat x = 0 + [self edgeInsetsOfOverall].left + minHeightColumn * (width + [self marginOfColumnInSection:section]) + [self edgeInsetsInSection:section].left;
            //3.设置y
            CGFloat y = [self.columnHeightArray[minHeightColumn] doubleValue];
            
            //排除第一行多加[self marginOfRowInSection:section]
            if (row / [self numberOfColumnsInSection:section]) {
                y += [self marginOfRowInSection:section];
            }
            
            //4.设置高度 通过代理设置
            CGFloat height = [self.dataSource commonCollectionViewLayout:self heightForItemAtIndexPath:indexPath itemWidth:width rowMargin:[self marginOfRowInSection:section]];
            attribute.frame = CGRectMake(x, y, width, height);
            
            
            //更新最短那列的高度
            self.columnHeightArray[minHeightColumn] = @(CGRectGetMaxY(attribute.frame));
            //找出最大高度
            CGFloat columnHeight = [self.columnHeightArray[minHeightColumn] doubleValue];
            if (self.contentHeight < columnHeight) {
                self.contentHeight = columnHeight;
            }
            [array addObject:attribute];
        }
        //设置区尾
        [array addObject:[self setupFooterInSection:section]];
        [self.attributesArray addObject:array];
    }
}
/** 设置区头 */
- (UICollectionViewLayoutAttributes *)setupHeaderInSection:(NSInteger)section {
    //区头
    UICollectionViewLayoutAttributes *headerAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader withIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
    CGFloat headerX = 0 + [self edgeInsetsOfOverall].left + [self edgeInsetsInSection:section].left + [self edgeInsetsForSupplementaryViewInSection:section supplementaryViewOfKind:UICollectionElementKindSectionHeader].left;
    CGFloat headerY = self.contentHeight + [self edgeInsetsInSection:section].top + [self edgeInsetsForSupplementaryViewInSection:section supplementaryViewOfKind:UICollectionElementKindSectionHeader].top;
    CGFloat headerWidth = CollectionViewWidth - [self edgeInsetsOfOverall].left - [self edgeInsetsOfOverall].right - [self edgeInsetsInSection:section].left - [self edgeInsetsInSection:section].right - [self edgeInsetsForSupplementaryViewInSection:section supplementaryViewOfKind:UICollectionElementKindSectionHeader].left - [self edgeInsetsForSupplementaryViewInSection:section supplementaryViewOfKind:UICollectionElementKindSectionHeader].right;
    CGFloat headerHeight = [self heightForSupplementaryViewInSection:section supplementaryViewOfKind:UICollectionElementKindSectionHeader];
    headerAttributes.frame = CGRectMake(headerX, headerY, headerWidth, headerHeight);
    self.contentHeight = CGRectGetMaxY(headerAttributes.frame) + [self edgeInsetsForSupplementaryViewInSection:section supplementaryViewOfKind:UICollectionElementKindSectionHeader].bottom;
    //下一次遍历section时，用上一个section中最大的高度覆盖掉存放每一列高度的数组
    for (NSInteger i = 0;i < self.columnHeightArray.count;i++) {
        self.columnHeightArray[i] = @(self.contentHeight);
    }
    //    NSLog(@"%f",CGRectGetMaxY(headerAttributes.frame));
    
    return headerAttributes;
}
/** 设置区尾 */
- (UICollectionViewLayoutAttributes *)setupFooterInSection:(NSInteger)section {
    UICollectionViewLayoutAttributes *footerAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter withIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
    CGFloat footerX = 0 + [self edgeInsetsOfOverall].left + [self edgeInsetsInSection:section].left + [self edgeInsetsForSupplementaryViewInSection:section supplementaryViewOfKind:UICollectionElementKindSectionFooter].left;
    CGFloat footerY = self.contentHeight + [self edgeInsetsForSupplementaryViewInSection:section supplementaryViewOfKind:UICollectionElementKindSectionFooter].top;
    CGFloat footerWidth = CollectionViewWidth - [self edgeInsetsOfOverall].left - [self edgeInsetsOfOverall].right - [self edgeInsetsInSection:section].left - [self edgeInsetsInSection:section].right - [self edgeInsetsForSupplementaryViewInSection:section supplementaryViewOfKind:UICollectionElementKindSectionFooter].left - [self edgeInsetsForSupplementaryViewInSection:section supplementaryViewOfKind:UICollectionElementKindSectionFooter].right;
    CGFloat footerHeight = [self heightForSupplementaryViewInSection:section supplementaryViewOfKind:UICollectionElementKindSectionFooter];
    footerAttributes.frame = CGRectMake(footerX, footerY, footerWidth, footerHeight);
    self.contentHeight = CGRectGetMaxY(footerAttributes.frame) + [self edgeInsetsInSection:section].bottom + [self edgeInsetsForSupplementaryViewInSection:section supplementaryViewOfKind:UICollectionElementKindSectionFooter].bottom;
    //下一次遍历section时，用上一个section中最大的高度覆盖掉存放每一列高度的数组
    for (NSInteger i = 0;i < self.columnHeightArray.count;i++) {
        self.columnHeightArray[i] = @(self.contentHeight);
    }
    return footerAttributes;
}
/** 返回indexPat位置的cell对应的布局属性 */
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.attributesArray[indexPath.section][indexPath.row];
}
/** 返回布局元素的数组 */
- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *array = [NSMutableArray array];
    for (NSInteger section = 0;section < self.attributesArray.count;section++) {
        NSArray *rowArray = self.attributesArray[section];
        for (NSInteger row = 0;row < rowArray.count;row++) {
            [array addObject:rowArray[row]];
        }
    }
    return array;
}
/** 返回区头、区尾布局元素 */
- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    return [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:elementKind withIndexPath:indexPath];
}
/** 返回装饰布局元素 */
- (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    return [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:elementKind withIndexPath:indexPath];
}
/** 返回内容大小 */
- (CGSize)collectionViewContentSize {
    CGFloat height = (self.contentHeight + [self edgeInsetsOfOverall].bottom > CollectionViewHeight ? self.contentHeight + [self edgeInsetsOfOverall].bottom : CollectionViewHeight + 1);
    
    return CGSizeMake(0, height);
}

#pragma mark - 判断代理简写

/** 每一个分区有多少列 */
- (NSInteger)numberOfColumnsInSection:(NSInteger)section {
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(commonCollectionViewLayout:numberOfColumnsInSection:)]) {
        return [self.dataSource commonCollectionViewLayout:self numberOfColumnsInSection:section];
    } else {
        return DefaultColumnsOfSection;
    }
}
/** 整体的内边距 */
- (UIEdgeInsets)edgeInsetsOfOverall {
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(commonEdgeInsetsOfOverallInCollectionViewLayout:)]) {
        return [self.dataSource commonEdgeInsetsOfOverallInCollectionViewLayout:self];
    } else {
        return DefaultEdgeInsetsOfOverall;
    }
}
/** 每一分区的内边距 */
- (UIEdgeInsets)edgeInsetsInSection:(NSInteger)section {
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(commonCollectionViewLayout:edgeInsetsInSection:)]) {
        return [self.dataSource commonCollectionViewLayout:self edgeInsetsInSection:section];
    } else {
        return DefaultEdgeInsetsOfSection;
    }
}
/** 每一列的间距 */
- (CGFloat)marginOfColumnInSection:(NSInteger)section {
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(commonCollectionViewLayout:marginOfColumnInSection:)]) {
        return [self.dataSource commonCollectionViewLayout:self marginOfColumnInSection:section];
    } else {
        return DefaultMarginOfColumn;
    }
}
/** 每一行的间距 */
- (CGFloat)marginOfRowInSection:(NSInteger)section {
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(commonCollectionViewLayout:marginOfRowInSection:)]) {
        return [self.dataSource commonCollectionViewLayout:self marginOfRowInSection:section];
    } else {
        return DefaultMarginOfRow;
    }
}
/** 区头，区尾的高度 */
- (CGFloat)heightForSupplementaryViewInSection:(NSInteger)section supplementaryViewOfKind:(NSString *)elementKind {
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(commonCollectionViewLayout:heightForSupplementaryViewInSection:supplementaryViewOfKind:)]) {
        return [self.dataSource commonCollectionViewLayout:self heightForSupplementaryViewInSection:section supplementaryViewOfKind:elementKind];
    } else {
        return DefalutHeightOfHeaderOrFooter;
    }
}
/** 区头，区尾的内边距 */
- (UIEdgeInsets)edgeInsetsForSupplementaryViewInSection:(NSInteger)section supplementaryViewOfKind:(NSString *)elementKind {
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(commonCollectionViewLayout:edgeInsetsForSupplementaryViewInSection:supplementaryViewOfKind:)]) {
        return [self.dataSource commonCollectionViewLayout:self edgeInsetsForSupplementaryViewInSection:section supplementaryViewOfKind:elementKind];
    } else {
        return DefaultEdgeInsetsOfHeaderOrFooter;
    }
}
@end
