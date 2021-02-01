/**
 * Copyright (c) 2020 TomTom N.V. All rights reserved.
 *
 * This software is the proprietary copyright of TomTom N.V. and its
 * subsidiaries and may be used for internal evaluation purposes or commercial
 * use strictly subject to separate licensee agreement between you and TomTom.
 * If you are the licensee, you are only permitted to use this Software in
 * accordance with the terms of your license agreement. If you are not the
 * licensee then you are not authorised to use this software in any manner and
 * should immediately return it to TomTom N.V.
 */

#import "MapTrafficAlongTheRouteViewController.h"

@interface MapTrafficAlongTheRouteViewController () <TTRouteResponseDelegate>
@property(nonatomic, strong) TTRoute *routePlanner;
@end

@implementation MapTrafficAlongTheRouteViewController

- (OptionsView *)getOptionsView {
    return [[OptionsViewSingleSelect alloc] initWithLabels:@[ @"London", @"Los Angeles" ] selectedID:-1];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.routePlanner = [[TTRoute alloc] initWithKey:Key.Routing];
    self.routePlanner.delegate = self;
}

- (NSArray<TTRouteTrafficStyle *> *)trafficStyleMapping {
    NSMutableArray<TTRouteTrafficStyle *> *styleMapping = [[NSMutableArray<TTRouteTrafficStyle *> alloc] init];
    TTRouteTrafficStyle *style6 = [[TTRouteTrafficStyle alloc] initWithRouteStyle:[NSArray arrayWithObject:[[[[TTMapRouteStyleLayerBuilder alloc] init] withColor:[[UIColor alloc] initWithRed:0.8 green:0.6 blue:0.0 alpha:1.0]] build]]];
    [styleMapping addObject:style6];
    TTRouteTrafficStyle *style5 = [[TTRouteTrafficStyle alloc] initWithRouteStyle:[NSArray arrayWithObject:[[[[TTMapRouteStyleLayerBuilder alloc] init] withColor:[[UIColor alloc] initWithRed:1.0 green:1.0 blue:0.0 alpha:1.0]] build]]];
    [styleMapping addObject:style5];
    TTRouteTrafficStyle *style4 = [[TTRouteTrafficStyle alloc] initWithRouteStyle:[NSArray arrayWithObject:[[[[TTMapRouteStyleLayerBuilder alloc] init] withColor:[[UIColor alloc] initWithRed:1.0 green:0.6 blue:0.0 alpha:1.0]] build]]];
    [styleMapping addObject:style4];
    TTRouteTrafficStyle *style3 = [[TTRouteTrafficStyle alloc] initWithRouteStyle:[NSArray arrayWithObject:[[[[TTMapRouteStyleLayerBuilder alloc] init] withColor:[[UIColor alloc] initWithRed:1.0 green:0.2 blue:0.0 alpha:1.0]] build]]];
    [styleMapping addObject:style3];
    TTRouteTrafficStyle *style2 = [[TTRouteTrafficStyle alloc] initWithRouteStyle:[NSArray arrayWithObject:[[[[TTMapRouteStyleLayerBuilder alloc] init] withColor:[[UIColor alloc] initWithRed:0.6 green:0.2 blue:0.0 alpha:1.0]] build]]];
    [styleMapping addObject:style2];
    TTRouteTrafficStyle *style1 = [[TTRouteTrafficStyle alloc] initWithRouteStyle:[NSArray arrayWithObject:[[[[TTMapRouteStyleLayerBuilder alloc] init] withColor:[[UIColor alloc] initWithRed:1.0 green:1.0 blue:1.0 alpha:1.0]] build]]];
    [styleMapping addObject:style1];
    return styleMapping;
}

- (void)setupInitialCameraPosition {
    [self.mapView centerOnCoordinate:[TTCoordinate HEATHROW_AIRPORT] withZoom:5];
}

#pragma mark OptionsViewDelegate

- (void)displayExampleWithID:(NSInteger)ID on:(BOOL)on {
    [super displayExampleWithID:ID on:on];
    [self.mapView.routeManager removeAllRoutes];
    [self.progress show];
    switch (ID) {
    case 1:
        [self displayLongRoute];
        break;
    default:
        [self displayShortRute];
        break;
    }
}

#pragma mark Examplea

- (void)displayShortRute {
    CLLocationCoordinate2D *waypoints = malloc(sizeof(CLLocationCoordinate2D) * 2);
    waypoints[0] = [TTCoordinate TOWER_OF_LONDON];
    waypoints[1] = [TTCoordinate THE_NATIONAL_GALLERY];
    TTRouteQuery *query = [[[[[TTRouteQueryBuilder createWithDest:[TTCoordinate HEATHROW_AIRPORT] andOrig:[TTCoordinate LONDON_CITY_AIRPORT]] withWayPoints:waypoints count:2] withSectionType:TTSectionTypeTraffic] withTraffic:false] build];
    [self.routePlanner planRouteWithQuery:query];
    free(waypoints);
}

- (void)displayLongRoute {
    CLLocationCoordinate2D *waypoints = malloc(sizeof(CLLocationCoordinate2D) * 3);
    waypoints[0] = [TTCoordinate DOWN_TOWN_LOS_ANGELES];
    waypoints[1] = [TTCoordinate BEVERLY_HILS];
    waypoints[2] = [TTCoordinate SANTA_MONICA];
    TTRouteQuery *query = [[[[[TTRouteQueryBuilder createWithDest:[TTCoordinate ONTARIO_INTERNATIONAL_AIRPORT] andOrig:[TTCoordinate LOS_ANGELES_INTERNATIONAL_AIRPORT]] withWayPoints:waypoints count:3] withSectionType:TTSectionTypeTraffic] withTraffic:false] build];
    [self.routePlanner planRouteWithQuery:query];
    free(waypoints);
}

#pragma mark TTRouteResponseDelegate

- (void)route:(TTRoute *)route completedWithResult:(TTRouteResult *)result {
    TTFullRoute *plannedRoute = result.routes.firstObject;
    if (!plannedRoute) {
        return;
    }

    NSArray<TTRouteTrafficStyle *> *trafficStyleMapping = [self trafficStyleMapping];
    NSMutableDictionary<TTRouteTrafficStyle *, NSMutableArray<TTTrafficData *> *> *styling = [@{} mutableCopy];
    NSArray<TTRouteSection *> *sections = plannedRoute.sections;
    for (TTRouteSection *section in sections) {
        NSInteger density = section.magnitudeOfDelayValue >= 0 ? section.magnitudeOfDelayValue : 5;
        TTRouteTrafficStyle *style = trafficStyleMapping[density];
        NSMutableArray<TTTrafficData *> *array = styling[style];
        if (array == NULL) {
            array = [@[] mutableCopy];
        }
        [array addObject:[[TTTrafficData alloc] initWithStartPointIndex:section.startPointIndexValue andEndPointIndex:section.endPointIndexValue]];
        styling[style] = array;
    }

    TTMapRoute *mapRoute = [TTMapRoute routeWithCoordinatesData:plannedRoute withRouteStyle:TTMapRouteStyle.defaultActiveStyle imageStart:TTMapRoute.defaultImageDeparture imageEnd:TTMapRoute.defaultImageDestination];
    [self.mapView.routeManager addRoute:mapRoute];
    [self.mapView.routeManager showTrafficOnRoute:mapRoute withStyling:styling];
    [self displayRouteOverview];
    [self.progress hide];
}

- (void)route:(TTRoute *)route completedWithResponseError:(TTResponseError *)responseError {
    [self handleError:responseError];
}

@end
