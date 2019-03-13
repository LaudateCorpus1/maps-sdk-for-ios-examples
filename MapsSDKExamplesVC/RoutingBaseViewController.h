/**
 * Copyright (c) 2019 TomTom N.V. All rights reserved.
 *
 * This software is the proprietary copyright of TomTom N.V. and its subsidiaries and may be used
 * for internal evaluation purposes or commercial use strictly subject to separate licensee
 * agreement between you and TomTom. If you are the licensee, you are only permitted to use
 * this Software in accordance with the terms of your license agreement. If you are not the
 * licensee then you are not authorised to use this software in any manner and should
 * immediately return it to TomTom N.V.
 */

#import <UIKit/UIKit.h>
#import <MapsSDKExamplesCommon/MapsSDKExamplesCommon-Swift.h>
#import "MapBaseViewController.h"
#import <TomTomOnlineSDKRouting/TomTomOnlineSDKRouting.h>

@interface RoutingBaseViewController : MapBaseViewController
@property (nonatomic, weak) ETAView *etaView;
@property (nonatomic, weak) MatrixETAView *matrixETAView;
- (void)showETA:(TTSummary *)summary;
- (void)hideEta;
- (void)displayRouteOverview;
- (void)zoomToAllMarkers;
- (void)showMatrixEta:(BOOL)oneToMany withMatrixResponse:(TTMatrixRouteResponse*)response;
- (void)hideMatrixEta;
@end
