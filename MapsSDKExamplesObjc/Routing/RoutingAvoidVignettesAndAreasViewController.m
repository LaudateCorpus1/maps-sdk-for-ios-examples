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

#import "RoutingAvoidVignettesAndAreasViewController.h"
@interface RoutingAvoidVignettesAndAreasViewController () <TTRouteDelegate, TTAnnotationDelegate>

@property (nonatomic, strong) TTRoute *routePlannerBasic;
@property (nonatomic, strong) TTRoute *routePlannerAvoid;
@end

@implementation RoutingAvoidVignettesAndAreasViewController

- (void)setupCenterOnWillHappen {
    [self.mapView centerOnCoordinate:[TTCoordinate BUDAPEST_LOCATION] withZoom:4];
}

- (OptionsView *)getOptionsView {
    return [[OptionsViewSingleSelect alloc] initWithLabels:@[@"No avoids", @"Avoid Vignettes", @"Avoid area"] selectedID:-1];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.mapView.annotationManager.delegate = self;
    self.mapView.routeManager.delegate = self;
    self.routePlannerBasic = [TTRoute new];
    self.routePlannerAvoid = [TTRoute new];
}

- (void)displayExampleWithID:(NSInteger)ID on:(BOOL)on {
    [super displayExampleWithID:ID on:on];
    [self.mapView.routeManager removeAllRoutes];
    [self.progress show];
    switch (ID) {
        case 2:
            [self startRoutingAvoidArea];
            break;
        case 1:
            [self startRoutingAvoidsVignettes];
            break;
        default:
            [self startRoutingNoAvoids];
            break;
    }
}

#pragma mark No avoids
- (void)startRoutingNoAvoids {
    [self.mapView.annotationManager removeAllOverlays];
    TTRouteQuery *query = [[[TTRouteQueryBuilder createWithDest:TTCoordinate.ROMANIA andOrig:TTCoordinate.CZECH_REPUBLIC]
                            withTraffic:YES]
                           build];
    __weak RoutingAvoidVignettesAndAreasViewController *weakSelf = self;
    [self.routePlannerBasic planRouteWithQuery:query completionHandler:^(TTRouteResult * _Nullable result, TTResponseError * _Nullable error) {
        if (error != nil){
            [weakSelf handleError:error];
            [weakSelf.routePlannerBasic cancel];
        }else {
            if (result != nil) {
                TTFullRoute *plannedRoute = result.routes.firstObject;
                [weakSelf displayRoute:@"No avoids" plannedRoute:plannedRoute routeStyle:[TTMapRouteStyle defaultActiveStyle]];
                [weakSelf.progress hide];
            }
        }
    }];
}

#pragma mark Avoid Vignettes
- (void)startRoutingAvoidsVignettes {
    [self.mapView.annotationManager removeAllOverlays];
    dispatch_group_t group = dispatch_group_create();
    TTRouteQuery *query = [[[TTRouteQueryBuilder createWithDest:TTCoordinate.ROMANIA andOrig:TTCoordinate.CZECH_REPUBLIC]
                            withTraffic:YES]
                           build];
    
    dispatch_group_enter(group);
    __weak RoutingAvoidVignettesAndAreasViewController *weakSelf = self;
    [self.routePlannerBasic planRouteWithQuery:query completionHandler:^(TTRouteResult * _Nullable result, TTResponseError * _Nullable error) {
        if (error != nil){
            [weakSelf handleError:error];
        }else {
            if (result != nil) {
                TTFullRoute *plannedRoute = result.routes.firstObject;
                [weakSelf displayRoute:@"No avoids" plannedRoute:plannedRoute routeStyle:[TTMapRouteStyle defaultActiveStyle]];
            }
        }
        dispatch_group_leave(group);
    }];
    NSArray<NSString*>* vignettesArray = @[@"HUN",@"CZE",@"SVK"];
    TTRouteQuery *query2 = [[[[TTRouteQueryBuilder createWithDest:TTCoordinate.ROMANIA andOrig:TTCoordinate.CZECH_REPUBLIC]
                              withTraffic:YES]
                             withAvoidVignettesArray:vignettesArray]
                            build];
    dispatch_group_enter(group);
    [self.routePlannerAvoid planRouteWithQuery:query2 completionHandler:^(TTRouteResult * _Nullable result, TTResponseError * _Nullable error) {
        if (error != nil){
            [weakSelf handleError:error];
            [weakSelf.routePlannerBasic cancel];
        }else {
            if (result != nil) {
                TTFullRoute *plannedRoute = result.routes.firstObject;
                [weakSelf displayRoute:@"Avoids Vignettes" plannedRoute:plannedRoute routeStyle: [weakSelf setRouteStyle:[TTColor Pink] outlineColor:[TTColor Purple]]];
            }
        }
        dispatch_group_leave(group);
    }];
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        [weakSelf.progress hide];
    });
}

#pragma mark Routing Avoid Area
- (void)startRoutingAvoidArea {
    dispatch_group_t group = dispatch_group_create();
    [self.mapView.annotationManager removeAllOverlays];
    CLLocationCoordinate2D coordinateArray[5];
    coordinateArray[0] = [TTCoordinate ARAD_TOP_LEFT_NEIGHBORHOOD];
    coordinateArray[1] = [TTCoordinate ARAD_TOP_RIGHT_NEIGHBORHOOD];
    coordinateArray[2] = [TTCoordinate ARAD_BOTTOM_RIGHT_NEIGHBORHOOD];
    coordinateArray[3] = [TTCoordinate ARAD_BOTTOM_LEFT_NEIGHBORHOOD];
    coordinateArray[4] = [TTCoordinate ARAD_TOP_LEFT_NEIGHBORHOOD];
    TTPolyline *polyline = [TTPolyline polylineWithCoordinates:coordinateArray count:5 opacity:1 width:4 color:[TTColor Blue]];
    [self.mapView.annotationManager addOverlay:polyline];
    
    TTRouteQuery *query = [[[TTRouteQueryBuilder createWithDest:TTCoordinate.ROMANIA andOrig:TTCoordinate.CZECH_REPUBLIC]
                            withTraffic:YES]
                           build];
    dispatch_group_enter(group);
    __weak RoutingAvoidVignettesAndAreasViewController *weakSelf = self;
    [self.routePlannerBasic planRouteWithQuery:query completionHandler:^(TTRouteResult * _Nullable result, TTResponseError * _Nullable error) {
        if (error != nil){
            [weakSelf handleError:error];
            [weakSelf.routePlannerAvoid cancel];
        }else {
            if (result != nil) {
                TTFullRoute *plannedRoute = result.routes.firstObject;
                [weakSelf displayRoute:@"Avoid area" plannedRoute:plannedRoute routeStyle:[weakSelf setRouteStyle:[TTColor BlueLight] outlineColor:[TTColor BlueLight]]];
            }
        }
        dispatch_group_leave(group);
    }];
    TTLatLngBounds boundingBox[1];
    boundingBox[0] = TTLatLngBoundsMake([TTCoordinate ARAD_TOP_LEFT_NEIGHBORHOOD], [TTCoordinate ARAD_BOTTOM_RIGHT_NEIGHBORHOOD]);
    TTRouteQuery *query2 = [[[[TTRouteQueryBuilder createWithDest:TTCoordinate.ROMANIA andOrig:TTCoordinate.CZECH_REPUBLIC]
                              withTraffic:YES]
                             withAvoidArea:boundingBox count:1]
                            build];
    dispatch_group_enter(group);
    [self.routePlannerAvoid planRouteWithQuery:query2 completionHandler:^(TTRouteResult * _Nullable result, TTResponseError * _Nullable error) {
        if (error != nil){
            [weakSelf handleError:error];
            [weakSelf.routePlannerBasic cancel];
        }else {
            if (result != nil) {
                TTFullRoute *plannedRoute = result.routes.firstObject;
                [weakSelf displayRoute:@"Avoids Vignettes" plannedRoute:plannedRoute routeStyle: [weakSelf setRouteStyle:[TTColor GreenBright] outlineColor:[TTColor GreenBright]]];
            }
        }
        dispatch_group_leave(group);
    }];
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        [weakSelf.progress hide];
    });
}

#pragma mark Drow route
- (void)displayRoute:(NSString*)etaView plannedRoute:(TTFullRoute*)plannedRout routeStyle:(TTMapRouteStyle*)routeStyle {
    TTMapRoute *mapRoute = [TTMapRoute routeWithCoordinatesData:plannedRout
                                                 withRouteStyle:routeStyle
                                                     imageStart:[TTMapRoute defaultImageDeparture]
                                                       imageEnd:[TTMapRoute defaultImageDestination]];
    
    [self.mapView.routeManager addRoute:mapRoute];
    [self.mapView.routeManager bringToFrontRoute:mapRoute];
    [self.etaView updateWithEta:etaView metersDistance:[plannedRout.summary lengthInMetersValue]];
    [self displayRouteOverview];
}

#pragma mark Drow route
- (TTMapRouteStyle*)setRouteStyle:(UIColor*)fillColor outlineColor:(UIColor*)outlineColor {
    TTMapRouteStyle *routeStyle = [[[[[[TTMapRouteStyleBuilder alloc] init]
                                      withWidth:1.0]
                                     withFillColor:fillColor]
                                    withOutlineColor:outlineColor]
                                   build];
    return routeStyle;
}

@end
