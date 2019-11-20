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

#import "MapRouteCustomisationViewController.h"
#import <TomTomOnlineSDKMaps/TomTomOnlineSDKMaps.h>
#import <TomTomOnlineSDKRouting/TomTomOnlineSDKRouting.h>

@interface MapRouteCustomisationViewController () <TTRouteResponseDelegate>
@property(nonatomic) TTRoute *routePlanner;
@property(nonatomic) TTMapRouteStyle *routeStyle;
@property(nonatomic) UIImage *iconStart;
@property(nonatomic) UIImage *iconEnd;
@property(nonatomic) BOOL isSegmented;
@end

@implementation MapRouteCustomisationViewController

- (OptionsView *)getOptionsView {
    return [[OptionsViewSingleSelect alloc] initWithLabels:@[ @"Basic", @"Custom", @"Segmented" ] selectedID:-1];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.routePlanner = [TTRoute new];
    self.routePlanner.delegate = self;
    self.routeStyle = [[TTMapRouteStyleBuilder new] build];
    self.iconStart = TTMapRoute.defaultImageDeparture;
    self.iconEnd = TTMapRoute.defaultImageDestination;
}

#pragma mark OptionsViewDelegate

- (void)displayExampleWithID:(NSInteger)ID on:(BOOL)on {
    [super displayExampleWithID:ID on:on];
    [self.mapView.routeManager removeAllRoutes];
    [self.progress show];
    self.isSegmented = false;
    switch (ID) {
    case 2:
        self.isSegmented = true;
        [self displaySegmentedRoute];
        break;
    case 1:
        [self displayCustomRoute];
        break;
    default:
        [self displayBasicRoute];
        break;
    }
}

#pragma mark Examples

- (void)displayBasicRoute {
    self.routeStyle = TTMapRouteStyle.defaultActiveStyle;
    self.iconStart = TTMapRoute.defaultImageDeparture;
    self.iconEnd = TTMapRoute.defaultImageDestination;
    [self planRoute];
}

- (void)displayCustomRoute {
    self.routeStyle = [[[[[TTMapRouteStyleBuilder new] withWidth:2.0] withFillColor:UIColor.blackColor] withOutlineColor:UIColor.redColor] build];
    self.iconStart = [UIImage imageNamed:@"Start"];
    self.iconEnd = [UIImage imageNamed:@"End"];
    [self planRoute];
}

- (void)displaySegmentedRoute {
    [self planSegmentedRoute];
}

- (void)planRoute {
    TTRouteQuery *query = [[[TTRouteQueryBuilder createWithDest:[TTCoordinate AMSTERDAM] andOrig:[TTCoordinate ROTTERDAM]] withTravelMode:TTOptionTravelModeCar] build];
    [self.routePlanner planRouteWithQuery:query];
}

#pragma mark TTRouteResponseDelegate
- (void)route:(TTRoute *)route completedWithResult:(TTRouteResult *)result {
    TTFullRoute *plannedRoute = result.routes.firstObject;
    if (!plannedRoute) {
        return;
    }

    if (self.isSegmented) {
        [self routeSegmentedPlanned:plannedRoute];
    } else {
        [self routePlanned:plannedRoute];
    }
}

- (void)arrayOfCoordinates:(TTFullRoute *)plannedRoute withStart:(NSInteger)startPoint withEnd:(NSInteger)endPoint withArray:(CLLocationCoordinate2D[])coordinateArray {

    NSInteger idx = 0;
    for (NSValue *value in [plannedRoute.coordinatesData subarrayWithRange:NSMakeRange(startPoint, endPoint - startPoint)]) {
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(0.0, 0.0);
        if (@available(iOS 11.0, *)) {
            [value getValue:&coordinate size:sizeof(CLLocationCoordinate2D)];
        } else {
            [value getValue:&coordinate];
        }
        coordinateArray[idx] = coordinate;
        idx++;
    }
}

- (void)routeSegmentedPlanned:(TTFullRoute *)plannedRoute {

    // Section 1
    TTMapRouteStyle *routeStyle1 = [[[[[TTMapRouteStyleBuilder new] withWidth:1.0] withFillColor:UIColor.blackColor] withOutlineColor:UIColor.blackColor] build];

    NSInteger startPoint1 = plannedRoute.sections[0].startPointIndexValue;
    NSInteger endPoint1 = plannedRoute.sections[0].endPointIndexValue;

    CLLocationCoordinate2D coordinateArray[endPoint1 - startPoint1];
    [self arrayOfCoordinates:plannedRoute withStart:startPoint1 withEnd:endPoint1 withArray:coordinateArray];

    TTMapRoute *mapRoute = [TTMapRoute routeWithCoordinates:coordinateArray count:endPoint1 withRouteStyle:routeStyle1 imageStart:self.iconStart imageEnd:self.iconEnd];

    // Section 2
    TTMapRouteStyle *routeStyle2 = [[[[[TTMapRouteStyleBuilder new] withWidth:1.0] withFillColor:UIColor.blueColor] withOutlineColor:UIColor.blueColor] build];

    NSInteger startPoint2 = plannedRoute.sections[1].startPointIndexValue;
    NSInteger endPoint2 = plannedRoute.sections[1].endPointIndexValue;

    CLLocationCoordinate2D coordinateArray2[endPoint2 - startPoint2];
    [self arrayOfCoordinates:plannedRoute withStart:startPoint2 withEnd:endPoint2 withArray:coordinateArray2];

    [mapRoute addCoordinates:coordinateArray2 count:endPoint2 - startPoint2 withRouteStyle:routeStyle2];

    // Section 3
    TTMapRouteStyle *routeStyle3 = [[[[[TTMapRouteStyleBuilder new] withWidth:1.0] withFillColor:UIColor.redColor] withOutlineColor:UIColor.redColor] build];

    NSInteger startPoint3 = plannedRoute.sections[2].startPointIndexValue;
    NSInteger endPoint3 = plannedRoute.sections[2].endPointIndexValue;

    CLLocationCoordinate2D coordinateArray3[endPoint3 - startPoint3];
    [self arrayOfCoordinates:plannedRoute withStart:startPoint3 withEnd:endPoint3 withArray:coordinateArray3];

    [mapRoute addCoordinates:coordinateArray3 count:endPoint3 - startPoint3 withRouteStyle:routeStyle3];

    [self.mapView.routeManager addRoute:mapRoute];

    [self displayRoute:plannedRoute];
}

- (void)routePlanned:(TTFullRoute *)plannedRoute {
    TTMapRoute *mapRoute = [TTMapRoute routeWithCoordinatesData:plannedRoute withRouteStyle:self.routeStyle imageStart:self.iconStart imageEnd:self.iconEnd];
    [self.mapView.routeManager addRoute:mapRoute];
    [self displayRoute:plannedRoute];
}

- (void)displayRoute:(TTFullRoute *)plannedRoute {
    [self.etaView showWithSummary:plannedRoute.summary style:ETAViewStylePlain];
    [self displayRouteOverview];
    [self.progress hide];
}

- (void)planSegmentedRoute {
    TTRouteQuery *query = [[[[TTRouteQueryBuilder createWithDest:[TTCoordinate AMSTERDAM] andOrig:[TTCoordinate LODZ]] withSectionType:TTSectionTypeCountry] withTraffic:NO] build];
    [self.routePlanner planRouteWithQuery:query];
}

- (void)route:(TTRoute *)route completedWithResponseError:(TTResponseError *)responseError {
    [self handleError:responseError];
}

@end
