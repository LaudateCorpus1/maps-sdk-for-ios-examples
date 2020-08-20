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

#import "SearchChargingStationsViewController.h"
#import <TomTomOnlineSDKSearch/TomTomOnlineSDKSearch.h>
#import <TomTomOnlineSDKMaps/TomTomOnlineSDKMaps.h>
#import <TomTomOnlineSDKRouting/TomTomOnlineSDKRouting.h>
#import <MapKit/MapKit.h>

@interface SearchChargingStationsViewController () <TTAnnotationDelegate>
@property(nonatomic, strong) EVChargingStationService *service;
@property(nonatomic, strong) TTRoute *planner;

@end

@implementation SearchChargingStationsViewController

- (OptionsView *)getOptionsView {
    return [[OptionsViewSingleSelect alloc] initWithLabels:@[ @"Along the route", @"Fuzzy", @"Geometry" ] selectedID:-1];
}

- (void)setupInitialCameraPosition {
    [self.mapView centerOnCoordinate:[TTCoordinate AMSTERDAM_A10] withZoom:10];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.service = [[EVChargingStationService alloc] initWithApiKey:Key.Search];

    self.mapView.annotationManager.delegate = self;
    self.planner = [[TTRoute alloc] initWithKey:Key.Routing];
}

#pragma mark OptionsViewDelegate

- (void)displayExampleWithID:(NSInteger)ID on:(BOOL)on {
    [super displayExampleWithID:ID on:on];
    [self.progress show];

    [self.mapView.annotationManager removeAllAnnotations];
    [self.mapView.annotationManager removeAllOverlays];
    [self.mapView.routeManager removeAllRoutes];

    switch (ID) {
    case 2:
        [self searchGeometry];
        break;
    case 1:
        [self searchFuzzy];
        break;
    default:
        [self searchAlongTheRoute];
        break;
    }
}
- (void)draw:(TTFullRoute *)route {
    TTMapRoute *mapRoute = [TTMapRoute routeWithCoordinatesData:route withRouteStyle:TTMapRouteStyle.defaultActiveStyle imageStart:TTMapRoute.defaultImageDeparture imageEnd:TTMapRoute.defaultImageDestination];
    [self.mapView.routeManager addRoute:mapRoute];
}

- (void)searchForChargingStationsAlong:(TTFullRoute *)route {

    NSMutableArray<CLLocation *> *routeLocations = [@[] mutableCopy];
    for (NSValue *value in route.coordinatesData) {
        CLLocation *location = [[CLLocation alloc] init:[value MKCoordinateValue]];
        [routeLocations addObject:location];
    }
    __weak SearchChargingStationsViewController *weakSelf = self;
    [self.service searchWithRoute:routeLocations
                       completion:^(NSArray<ChargingStationDetails *> *_Nullable result, NSError *_Nullable error) {
                         SearchChargingStationsViewController *strongSelf = weakSelf;
                         if (result != NULL && strongSelf != NULL) {
                             [strongSelf searchCompletedWithResult:result];
                         }
                       }];
}

#pragma mark Examples

- (void)searchFuzzy {
    __weak SearchChargingStationsViewController *weakSelf = self;
    [self.service searchWithTopLeft:[TTCoordinate AMSTERDAM_TOP_LEFT]
                        bottomRight:[TTCoordinate AMSTERDAM_BOTTOM_RIGHT]
                         completion:^(NSArray<ChargingStationDetails *> *_Nullable result, NSError *_Nullable error) {
                           SearchChargingStationsViewController *strongSelf = weakSelf;
                           if (result != NULL && strongSelf != NULL) {
                               [strongSelf searchCompletedWithResult:result];
                           }
                         }];
}

- (void)searchAlongTheRoute {
    TTRouteQuery *query = [[TTRouteQueryBuilder createWithDest:[TTCoordinate HAARLEM] andOrig:[TTCoordinate AMSTERDAM]] build];
    __weak SearchChargingStationsViewController *weakSelf = self;

    [self.planner planRouteWithQuery:query
                   completionHandler:^(TTRouteResult *_Nullable result, TTResponseError *_Nullable error) {
                     SearchChargingStationsViewController *strongSelf = weakSelf;

                     if (result.routes.firstObject != NULL) {
                         TTFullRoute *route = result.routes.firstObject;
                         [strongSelf draw:route];
                         [strongSelf searchForChargingStationsAlong:route];
                     }
                   }];
}

- (void)searchGeometry {

    CLLocationCoordinate2D coordinates[13];
    coordinates[0] = CLLocationCoordinate2DMake(52.37874, 4.90482);
    coordinates[1] = CLLocationCoordinate2DMake(52.37664, 4.92559);
    coordinates[2] = CLLocationCoordinate2DMake(52.37497, 4.94877);
    coordinates[3] = CLLocationCoordinate2DMake(52.36805, 4.97246);
    coordinates[4] = CLLocationCoordinate2DMake(52.34918, 4.95993);
    coordinates[5] = CLLocationCoordinate2DMake(52.34016, 4.95169);
    coordinates[6] = CLLocationCoordinate2DMake(52.32894, 4.91392);
    coordinates[7] = CLLocationCoordinate2DMake(52.34048, 4.88611);
    coordinates[8] = CLLocationCoordinate2DMake(52.33953, 4.84388);
    coordinates[9] = CLLocationCoordinate2DMake(52.37067, 4.8432);
    coordinates[10] = CLLocationCoordinate2DMake(52.38492, 4.84663);
    coordinates[11] = CLLocationCoordinate2DMake(52.40011, 4.85058);
    coordinates[12] = CLLocationCoordinate2DMake(52.38995, 4.89075);

    TTPolygon *mapPolygon = [TTPolygon polygonWithCoordinates:coordinates count:13 opacity:1 color:[TTColor RedSemiTransparent] colorOutline:[TTColor RedSemiTransparent]];
    [self.mapView.annotationManager addOverlay:mapPolygon];

    __weak SearchChargingStationsViewController *weakSelf = self;

    NSMutableArray *locations = [[NSMutableArray alloc] init];

    for (NSUInteger i = 0; i < 13; i++) {
        CLLocation *location = [[CLLocation alloc] init:coordinates[i]];
        [locations addObject:location];
    }
    PolygonShape *shape = [[PolygonShape alloc] initWithLocations:locations];
    [self.service searchWithShape:@[ shape ]
                       completion:^(NSArray<ChargingStationDetails *> *_Nullable result, NSError *_Nullable error) {
                         SearchChargingStationsViewController *strongSelf = weakSelf;
                         if (result != NULL && strongSelf != NULL) {
                             [strongSelf searchCompletedWithResult:result];
                         }
                       }];
}

- (void)searchCompletedWithResult:(NSArray<ChargingStationDetails *> *)stations {
    [self.progress hide];
    for (ChargingStationDetails *station in stations) {
        ChargeStationDetailsAnnotation *annotation = [[ChargeStationDetailsAnnotation alloc] initWithInfo:station];
        [self.mapView.annotationManager addAnnotation:annotation];
    }
}

- (void)annotationManager:(id<TTAnnotationManager>)manager annotationSelected:(TTAnnotation *)annotation {
    [self.mapView centerOnCoordinate:annotation.coordinate];
}

- (UIView<TTCalloutView> *)annotationManager:(id<TTAnnotationManager>)manager viewForSelectedAnnotation:(TTAnnotation *)selectedAnnotation {
    ChargeStationDetailsAnnotation *annotation = (ChargeStationDetailsAnnotation *)selectedAnnotation;
    if (annotation == NULL) {
        return [[TTCalloutOutlineView alloc] initWithText:@"-"];
    } else {
        NSString *address = [annotation freeFormAddress];
        NSString *availabilityText = [annotation readableAvailability];
        NSString *text = [NSString stringWithFormat:@"%@\n%@", address, availabilityText];
        ChargingStationCalloutView *contentView = [[ChargingStationCalloutView alloc] initWithText:text title:annotation.info.name height:100];
        contentView.iconView.image = [UIImage imageNamed:@"ic_ev_slow_charging"];
        return [[TTCalloutOutlineView alloc] initWithUIView:contentView];
    }
}

@end
