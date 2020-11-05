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

#import <Foundation/Foundation.h>
#import "ButtonsBaseViewController.h"
#import <TomTomOnlineSDKMaps/TomTomOnlineSDKMaps.h>

@interface MapBaseViewController : ButtonsBaseViewController

@property(nonatomic, weak) ETAView *etaView;
@property(nonatomic, weak) TTMapView *mapView;
@property(nonatomic) UIButton *snapshotButton;
- (void)setupEtaView;
- (void)setupMap;
- (void)setupInitialCameraPosition;
- (void)onMapReady;
- (void)setupSnapshotButton;
- (void)snapshotClicked:(UIButton *)sender;

@end
