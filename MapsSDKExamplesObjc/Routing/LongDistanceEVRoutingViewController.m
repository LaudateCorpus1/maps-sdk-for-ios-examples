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

#import "LongDistanceEVRoutingViewController.h"

@interface LongDistanceEVRoutingViewController () <TTAnnotationDelegate>
@property(nonatomic, strong) LongDistanceEVService *routePlanner;
@end

@implementation LongDistanceEVRoutingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.routePlanner = [[LongDistanceEVService alloc] initWithKey:Key.Routing];
    self.mapView.annotationManager.delegate = self;
    [self planRouteShortRange];
}

- (OptionsView *)getOptionsView {
    return [[OptionsViewSingleSelect alloc] initWithLabels:@[ @"Short Range Vehicle", @"Long Range Vehicle" ] selectedID:0];
}
#pragma mark OptionsViewDelegate
- (void)displayExampleWithID:(NSInteger)ID on:(BOOL)on {
    [super displayExampleWithID:ID on:on];
    switch (ID) {
    case 1:
        [self planRouteLongRange];
        break;
    case 0:
        [self planRouteShortRange];
        break;
    default:
        [self planRouteShortRange];
        break;
    }
}
- (void)planRouteLongRange {
    [self.progress show];
    [self.mapView.annotationManager removeAllAnnotations];
    [self.mapView.routeManager removeAllRoutes];
    CLLocationCoordinate2D origin = [TTCoordinate AMSTERDAM];
    CLLocationCoordinate2D destination = [TTCoordinate BERLIN];
    ElectricVehicle *vehicle = [ElectricVehicle longRange];
    RouteOptions *routeOptions = [RouteOptions fastestWithoutTraffic];
    LongRangeChargingSchema *shortRange = [[LongRangeChargingSchema alloc] init];

    __weak LongDistanceEVRoutingViewController *weakSelf = self;

    [self.routePlanner planRouteWithOrigin:origin
                               destination:destination
                           electricVehicle:vehicle
                                     route:routeOptions
                                  charging:shortRange
                                completion:^(NSArray<FullRouteEV *> *_Nullable result, NSError *_Nullable error) {
                                  LongDistanceEVRoutingViewController *strongSelf = weakSelf;
                                  if (strongSelf != NULL) {
                                      if (result != NULL && result.count > 0) {
                                          [strongSelf displayRoute:result[0] forVehicle:vehicle];
                                          [strongSelf drawChargingStation:result[0]];
                                      } else {
                                          [strongSelf handleNoRoutesFound];
                                      }
                                  }
                                }];
}
- (void)handleNoRoutesFound {
    [self.progress hide];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Info" message:@"Failed to fetch route info, please try again later." preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK"
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction *_Nonnull action) {
                                              [alert dismissViewControllerAnimated:YES completion:NULL];
                                            }]];
    [self presentViewController:alert animated:YES completion:NULL];
}

- (void)planRouteShortRange {
    [self.progress show];
    [self.mapView.annotationManager removeAllAnnotations];
    [self.mapView.routeManager removeAllRoutes];
    CLLocationCoordinate2D origin = [TTCoordinate AMSTERDAM];
    CLLocationCoordinate2D destination = [TTCoordinate BERLIN];
    ElectricVehicle *vehicle = [ElectricVehicle shortRange];
    RouteOptions *routeOptions = [RouteOptions fastestWithoutTraffic];
    __weak LongDistanceEVRoutingViewController *weakSelf = self;
    ShortRangeChargingSchema *shortRange = [[ShortRangeChargingSchema alloc] init];

    [self.routePlanner planRouteWithOrigin:origin
                               destination:destination
                           electricVehicle:vehicle
                                     route:routeOptions
                                  charging:shortRange
                                completion:^(NSArray<FullRouteEV *> *_Nullable result, NSError *_Nullable error) {
                                  LongDistanceEVRoutingViewController *strongSelf = weakSelf;
                                  if (strongSelf != NULL) {
                                      if (result != NULL && result.count > 0) {
                                          [strongSelf displayRoute:result[0] forVehicle:vehicle];
                                          [strongSelf drawChargingStation:result[0]];
                                      } else {
                                          [strongSelf handleNoRoutesFound];
                                      }
                                  }
                                }];
}

- (NSArray<ChargeStationAnnotation *> *)chargeStationAnnotations:(FullRouteEV *)route {
    NSMutableArray<ChargeStationAnnotation *> *arrayChargeStation = [[NSMutableArray<ChargeStationAnnotation *> alloc] init];
    for (LegEV *newLeg in route.legs) {
        if (newLeg.legSummary.chargingInformationAtEndOfLeg != NULL) {
            if (newLeg.legSummary.chargingInformationAtEndOfLeg.chargingTime > 0) {
                if (newLeg.points.lastObject != NULL) {
                    [arrayChargeStation addObject:[[ChargeStationAnnotation alloc] initWithInfo:newLeg.legSummary.chargingInformationAtEndOfLeg coordinate:newLeg.points.lastObject.coordinate]];
                }
            }
        }
    }
    return arrayChargeStation;
}

- (void)drawChargingStation:(FullRouteEV *)route {
    NSArray<TTAnnotation *> *annotations = [self chargeStationAnnotations:route];
    [self.mapView.annotationManager addAnnotations:annotations];
}

- (void)displayRoute:(FullRouteEV *)route forVehicle:(ElectricVehicle *)vehicle {
    TTMapRoute *mapRoute = [TTMapRoute routeWithCoordinatesData:route withRouteStyle:TTMapRouteStyle.defaultActiveStyle imageStart:TTMapRoute.defaultImageDeparture imageEnd:TTMapRoute.defaultImageDestination];
    [self.mapView.routeManager addRoute:mapRoute];
    [self.mapView.routeManager bringToFrontRoute:mapRoute];
    [self displayRouteOverview];
    [self.progress hide];

    if (route.summary != NULL) {
        [self.etaView showWithSummary:route.summary vehicle:vehicle];
    }
}

- (void)annotationManager:(id<TTAnnotationManager>)manager annotationSelected:(TTAnnotation *)annotation {
    [self.mapView centerOnCoordinate:annotation.coordinate];
}

- (UIView<TTCalloutView> *)annotationManager:(id<TTAnnotationManager>)manager viewForSelectedAnnotation:(TTAnnotation *)selectedAnnotation {
    ChargeStationAnnotation *annotation = (ChargeStationAnnotation *)selectedAnnotation;
    if (annotation == NULL) {
        return [[TTCalloutOutlineView alloc] initWithText:@"-"];
    } else {
        ChargingStationCalloutView *contentView = [[ChargingStationCalloutView alloc] initWithText:[NSString stringWithFormat:@"Wait time: %li minutes", (long)[@(annotation.info.chargingTime / 60.0) integerValue]] title:@"Charging station waypoint" height:70];
        return [[TTCalloutOutlineView alloc] initWithUIView:contentView];
    }
}

@end
