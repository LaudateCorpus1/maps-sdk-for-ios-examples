/**
 * Copyright (c) 2019 TomTom N.V. All rights reserved.
 *
 * This software is the proprietary copyright of TomTom N.V. and its
 * subsidiaries and may be used for internal evaluation purposes or commercial
 * use strictly subject to separate licensee agreement between you and TomTom.
 * If you are the licensee, you are only permitted to use this Software in
 * accordance with the terms of your license agreement. If you are not the
 * licensee then you are not authorised to use this software in any manner and
 * should immediately return it to TomTom N.V.
 */

#import "CollectionBaseViewController.h"

static NSString *reusableID = @"CollectionBaseViewControllerCellID";

@interface CollectionBaseViewController ()
@property(nonatomic, weak) UICollectionView *collectionView;
@property(nonatomic, weak) UICollectionViewLayout *layout;
@end

@implementation CollectionBaseViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  [self setupCollectionView];
  [self setupControls];
}

- (void)setupCollectionView {
  UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
  self.layout = layout;
  UICollectionView *collectionView =
      [[UICollectionView alloc] initWithFrame:CGRectZero
                         collectionViewLayout:layout];
  self.collectionView = collectionView;
  collectionView.backgroundColor = [TTColor White];
  collectionView.delegate = self;
  collectionView.dataSource = self;
  [collectionView registerClass:[UICollectionViewCell class]
      forCellWithReuseIdentifier:reusableID];
  self.view = collectionView;
}

- (UIImageView *)getImageViewForIndex:(NSInteger)index {
  return [UIImageView new];
}

#pragma mark UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView
    didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
}

#pragma mark UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
  return 6;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  UICollectionViewCell *cell =
      [collectionView dequeueReusableCellWithReuseIdentifier:reusableID
                                                forIndexPath:indexPath];
  UIImageView *imageView = [self getImageViewForIndex:indexPath.row];
  imageView.translatesAutoresizingMaskIntoConstraints = NO;
  [cell addSubview:imageView];
  [cell addConstraints:[NSLayoutConstraint
                           constraintsWithVisualFormat:@"H:|-0-[v0]-0-|"
                                               options:0
                                               metrics:nil
                                                 views:@{@"v0" : imageView}]];
  [cell addConstraints:[NSLayoutConstraint
                           constraintsWithVisualFormat:@"V:|-0-[v0]-0-|"
                                               options:0
                                               metrics:nil
                                                 views:@{@"v0" : imageView}]];
  return cell;
}

#pragma mark UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView
                    layout:(UICollectionViewLayout *)collectionViewLayout
    sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
  CGFloat frame = self.view.frame.size.width < self.view.frame.size.height
                      ? self.view.frame.size.width
                      : self.view.frame.size.height;
  CGFloat width = frame * 0.480;
  return CGSizeMake(width, width);
}

@end
