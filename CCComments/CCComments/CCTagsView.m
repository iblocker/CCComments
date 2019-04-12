//
//  CCTagsView.m
//  CCComments
//
//  Created by admin on 2019/4/11.
//  Copyright © 2019 iBlocker. All rights reserved.
//

#import "CCTagsView.h"
#import "UIView+Extension.h"

@interface CCTagsHeaderView : UICollectionReusableView
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *leftLine;
@property (nonatomic, strong) UIView *rightLine;
@end
@implementation CCTagsHeaderView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.titleLabel];
        [self addSubview:self.leftLine];
        [self addSubview:self.rightLine];
    }
    return self;
}

#pragma mark - Getter
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.centerX - 80, self.centerY - 10, 160, 20)];
        _titleLabel.text = @"请对本次服务做出评价";
        _titleLabel.font = [UIFont systemFontOfSize:14];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

- (UIView *)leftLine {
    if (!_leftLine) {
        _leftLine = [[UIView alloc] initWithFrame:CGRectMake(0, self.centerY - 0.25, CGRectGetMinX(self.titleLabel.frame) - 10, 0.5)];
        _leftLine.backgroundColor = [UIColor lightGrayColor];
    }
    return _leftLine;
}

- (UIView *)rightLine {
    if (!_rightLine) {
        _rightLine = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.titleLabel.frame) + 10, self.centerY - 0.25, CGRectGetMinX(self.titleLabel.frame) - 10, 0.5)];
        _rightLine.backgroundColor = [UIColor lightGrayColor];
    }
    return _rightLine;
}

@end

@interface CCTagsItem : UICollectionViewCell
@property (nonatomic, strong) UILabel *tagLabel;
@property (nonatomic, assign) CCTagState tagState;
@end
@implementation CCTagsItem
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.tagLabel];
        self.tagState = CCTagStateDeSelected;
    }
    return self;
}

- (void)setTagState:(CCTagState)tagState {
    _tagState = tagState;
    switch (tagState) {
        case CCTagStateSelected: {
            //  已选中
            self.tagLabel.layer.borderColor = UIColor.greenColor.CGColor;
            self.tagLabel.backgroundColor = UIColor.greenColor;
            self.tagLabel.textColor = UIColor.whiteColor;
        }
            break;
        default: {
            //  未选中
            self.tagLabel.layer.borderColor = UIColor.lightGrayColor.CGColor;
            self.tagLabel.backgroundColor = UIColor.whiteColor;
            self.tagLabel.textColor = UIColor.lightGrayColor;
        }
            break;
    }
}

#pragma mark - Getter
- (UILabel *)tagLabel {
    if (!_tagLabel) {
        _tagLabel = [[UILabel alloc] initWithFrame:self.bounds];
        _tagLabel.font = [UIFont systemFontOfSize:14];
        _tagLabel.textAlignment = NSTextAlignmentCenter;
        _tagLabel.layer.cornerRadius = 8;
        _tagLabel.layer.masksToBounds = YES;
        _tagLabel.layer.borderWidth = 1;
    }
    return _tagLabel;
}

@end

@interface CCTagsView () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) UICollectionView *collectionView;
@end
@implementation CCTagsView

static NSString *const cltCellReuseIdentifier = @"cltCellReuseIdentifier";
static NSString *const cltHeaderReuseIdentifier = @"cltHeaderReuseIdentifier";

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.collectionView];
    }
    return self;
}

- (void)setDataSource:(NSArray<NSString *> *)dataSource {
    _dataSource = dataSource;
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CCTagsItem *item = [collectionView dequeueReusableCellWithReuseIdentifier:cltCellReuseIdentifier
                                                                 forIndexPath:indexPath];
    item.tagState = CCTagStateDeSelected;
    item.tagLabel.text = self.dataSource[indexPath.row];
    return item;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    CCTagsItem *item = (CCTagsItem *)[collectionView cellForItemAtIndexPath:indexPath];
    item.tagState = CCTagStateSelected;
    if (self.didSelectedBlock) {
        NSMutableArray *selectedTags = @[].mutableCopy;
        [collectionView.indexPathsForSelectedItems enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [selectedTags addObject:self.dataSource[obj.row]];
        }];
        self.didSelectedBlock(selectedTags);
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    CCTagsItem *item = (CCTagsItem *)[collectionView cellForItemAtIndexPath:indexPath];
    item.tagState = CCTagStateDeSelected;
    if (self.didSelectedBlock) {
        NSMutableArray *selectedTags = @[].mutableCopy;
        [collectionView.indexPathsForSelectedItems enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [selectedTags addObject:self.dataSource[obj.row]];
        }];
        self.didSelectedBlock(selectedTags);
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        //  HeaderView
        CCTagsHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                          withReuseIdentifier:cltHeaderReuseIdentifier
                                                                                 forIndexPath:indexPath];
        return headerView;
    }
    return nil;
}

#pragma mark - Getter
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        // !!!: flowLayout布局
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.headerReferenceSize = CGSizeMake(CGRectGetWidth(self.frame), 40);
        CGFloat width = (CGRectGetWidth(self.frame) - 2 * 15) / 3.0;
        flowLayout.itemSize = CGSizeMake(width, 35);
        flowLayout.minimumLineSpacing = 15;
        flowLayout.minimumInteritemSpacing = 15;
        // !!!: CollectionView
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds
                                             collectionViewLayout:flowLayout];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.delaysContentTouches = NO;
        _collectionView.backgroundColor = UIColor.whiteColor;
        //  实现多选必须要实现的方法
        _collectionView.allowsMultipleSelection = YES;
        
        [_collectionView registerClass:CCTagsItem.class
            forCellWithReuseIdentifier:cltCellReuseIdentifier];
        [_collectionView registerClass:CCTagsHeaderView.class
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:cltHeaderReuseIdentifier];
    }
    return _collectionView;
}

@end
