//
//  CYLineLayout.m
//  自定义流水布局
//
//  Created by 葛聪颖 on 15/11/13.
//  Copyright © 2015年 聪颖不聪颖. All rights reserved.
//

#import "CYLineLayout.h"

#define ITEM_SIZE 380.0
#define ACTIVE_DISTANCE 240
#define ZOOM_FACTOR 0.6

@implementation CYLineLayout

- (instancetype)init
{
    if (self = [super init]) {
    }
    return self;
}

/**
 * 当collectionView的显示范围发生改变的时候，是否需要重新刷新布局
 * 一旦重新刷新布局，就会重新调用下面的方法：
 1.prepareLayout
 2.layoutAttributesForElementsInRect:方法
 */
- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}

/**
 * 用来做布局的初始化操作（不建议在init方法中进行布局的初始化操作）
 */
- (void)prepareLayout
{
    [super prepareLayout];
//    self.itemSize = CGSizeMake(ACTIVE_DISTANCE, self.view.frame.size.height-300);
    // 水平滚动
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;

    self.sectionInset = UIEdgeInsetsMake(10, 70, 10, 70);
    if (ON_IPAD) {
        if (_itemS == 2) {
            self.sectionInset = UIEdgeInsetsMake(10, 200, 10, 50);
        }else if (_itemS == 1) {
                self.sectionInset = UIEdgeInsetsMake(10, 350, 10, 250);
        }else{
            self.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
        }
    }
    //  每个item在水平方向的最小间距
    self.minimumLineSpacing = 0;
}

/**
 UICollectionViewLayoutAttributes *attrs;
 1.一个cell对应一个UICollectionViewLayoutAttributes对象
 2.UICollectionViewLayoutAttributes对象决定了cell的frame
 */
/**
 * 这个方法的返回值是一个数组（数组里面存放着rect范围内所有元素的布局属性）
 * 这个方法的返回值决定了rect范围内所有元素的排布（frame）
 */
- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    //0.计算可见的矩形框属性
    CGRect visiableRect;
    visiableRect.size = self.collectionView.frame.size;
    visiableRect.origin = self.collectionView.contentOffset;
    
    // 获得super已经计算好的布局属性
    NSArray *array = [super layoutAttributesForElementsInRect:rect] ;

    // 计算collectionView最中心点的x值
    CGFloat centerX = self.collectionView.contentOffset.x + self.collectionView.frame.size.width * 0.5;
    
    // 在原有布局属性的基础上，进行微调
    for (UICollectionViewLayoutAttributes *attrs in array) {
        //如果遍历的item和可见的矩形框的frame不相交,即不e是可见的,就直接跳过,只对可见的item进行放缩
        if (!CGRectIntersectsRect(visiableRect, attrs.frame)) continue;
        // cell的中心点x 和 collectionView最中心点的x值 的间距
        CGFloat delta = ABS(attrs.center.x - centerX);
        float maxScalce = 1.4;
        if (ON_IPAD) {
            maxScalce = 1.2;
        }
        // 根据间距值 计算 cell的缩放比例 1.4
        CGFloat scale = maxScalce - delta / self.collectionView.frame.size.width;
        if (scale>1) {
            scale = 1;
        }
        // 设置缩放比例
        attrs.transform = CGAffineTransformMakeScale(scale,scale);

    }
    return array;
}

/**
 * 这个方法的返回值，就决定了collectionView停止滚动时的偏移量
 
 */
- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity
{
    // 计算出最终显示的矩形框
    CGRect rect;
    rect.origin.y = 0;
    rect.origin.x = proposedContentOffset.x;
    rect.size = self.collectionView.frame.size;
    
    // 获得super已经计算好的布局属性
    NSArray *array = [super layoutAttributesForElementsInRect:rect];
    
    // 计算collectionView最中心点的x值
    CGFloat centerX = proposedContentOffset.x + self.collectionView.frame.size.width * 0.5;
    
    // 存放最小的间距值
    CGFloat minDelta = MAXFLOAT;
    for (UICollectionViewLayoutAttributes *attrs in array) {
        if (ABS(minDelta) > ABS(attrs.center.x - centerX)) {
            minDelta = attrs.center.x - centerX;
        }
    }
    
    // 修改原有的偏移量
    proposedContentOffset.x += minDelta;
    
    return proposedContentOffset;
}

@end
