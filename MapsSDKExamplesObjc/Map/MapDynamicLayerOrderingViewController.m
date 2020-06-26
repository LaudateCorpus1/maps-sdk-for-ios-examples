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

#import "MapDynamicLayerOrderingViewController.h"

#define GEOJSON_SOURCE @"geojson-source"

@interface MapDynamicLayerOrderingViewController () <TTRouteResponseDelegate>

@property TTMapStyle *currentStyle;
@property TTRoute *routePlanner;

@end

@implementation MapDynamicLayerOrderingViewController

- (void)viewDidLoad {
    [self.progress show];
    [super viewDidLoad];
    self.routePlanner = [[TTRoute alloc] initWithKey:Key.Routing];
}

- (void)setupInitialCameraPosition {
    [self.mapView centerOnCoordinate:TTCoordinate.SAN_JOSE withZoom:7.5];
}

- (OptionsView *)getOptionsView {
    return [[OptionsViewSingleSelect alloc] initWithLabels:@[ @"Images", @"GeoJSON", @"Roads" ] selectedID:0];
}

- (void)onMapReady {
    self.routePlanner.delegate = self;
    [self planRoute];
    self.currentStyle = self.mapView.styleManager.currentStyle;

    NSString *path = [NSBundle.mainBundle pathForResource:@"layer_road" ofType:@"json"];
    NSString *layerJSON = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    TTMapLayer *layerMap = [TTMapLayer createWithStyleJSON:layerJSON withMap:self.mapView];
    layerMap.visibility = TTMapLayerVisibilityVisible;
    [self.currentStyle addLayer:layerMap];

    [self addImagesSource];
}

- (void)planRoute {
    TTRouteQuery *query = [[TTRouteQueryBuilder createWithDest:TTCoordinate.SANTA_CRUZ andOrig:TTCoordinate.SAN_FRANCISCO] build];
    [self.routePlanner planRouteWithQuery:query];
}

- (void)addImagesSource {
    [self addImage:1 withCoordinates:TTCoordinate.SAN_JOSE_IMG1 withImage:[UIImage imageNamed:@"img1"]];
    [self addImage:2 withCoordinates:TTCoordinate.SAN_JOSE_IMG2 withImage:[UIImage imageNamed:@"img2"]];
    [self addImage:3 withCoordinates:TTCoordinate.SAN_JOSE_IMG3 withImage:[UIImage imageNamed:@"img3"]];
}

- (void)addImage:(int)index withCoordinates:(CLLocationCoordinate2D)coordinates withImage:(UIImage *)uiImage {
    TTLatLngQuad *quad = [self quadWithDelta:coordinates withDelta:0.25];
    NSMutableString *imageID = [NSMutableString stringWithFormat:@"img-source-%d", index];
    TTMapImageSource *sourceMap = [TTMapImageSource createWithID:imageID image:uiImage coordinates:quad];
    [self.currentStyle addSource:sourceMap];

    NSMutableString *rasterID = [NSMutableString stringWithFormat:@"img-id-%d", index];
    NSMutableString *sourceID = [NSMutableString stringWithFormat:@"img-source-%d", index];
    TTMapLayer *layerMap = [TTMapLayer createRasterWithID:rasterID withSourceID:sourceID withMap:self.mapView];
    [self.currentStyle addLayer:layerMap];
}

#pragma mark TTRouteResponseDelegate

- (void)route:(TTRoute *)route completedWithResult:(TTRouteResult *)result {
    TTFullRoute *fullRoute = result.routes[0];
    TTGeoJSONLineString *geoJsonLine = [[TTGeoJSONLineString alloc] initWithCoordinatesData:[fullRoute coordinatesData] withBoundingBox:nil];
    TTMapGeoJSONSource *geoJsonSource = [TTMapGeoJSONSource createWithID:GEOJSON_SOURCE];
    [geoJsonSource setGeoJSONObject:geoJsonLine];
    [self.currentStyle addSource:geoJsonSource];
    [self.progress hide];
}

- (void)route:(TTRoute *)route completedWithResponseError:(TTResponseError *)responseError {
    [self handleError:responseError];
}

#pragma mark OptionsViewDelegate

- (void)displayExampleWithID:(NSInteger)ID on:(BOOL)on {
    [super displayExampleWithID:ID on:on];
    switch (ID) {
    case 2: {
        NSArray<TTMapLayer *> *layersRoads = [self.currentStyle getLayersBySourceLayerRegexs:[NSArray arrayWithObjects:@".*[rR]oad.*", @".*[mM]otorway.*", nil]];
        for (TTMapLayer *layer in layersRoads) {
            [self.currentStyle moveLayerToFront:layer];
        }
        break;
    }
    case 1: {
        TTMapLayer *layerRoute = [self.currentStyle getLayerByID:@"layer-line-id"];
        [self.currentStyle moveLayerToFront:layerRoute];
        break;
    }
    default: {
        NSArray<TTMapLayer *> *layersImages = [self.currentStyle getLayersByRegex:@"img-id.*"];
        for (TTMapLayer *layer in layersImages) {
            [self.currentStyle moveLayerToFront:layer];
        }
        break;
    }
    }
}

#pragma mark private

- (TTLatLngQuad *)quadWithDelta:(CLLocationCoordinate2D)coordinate withDelta:(double)delta {

    return [[TTLatLngQuad alloc] initWithTopLeft:CLLocationCoordinate2DMake(coordinate.latitude + delta / 2, coordinate.longitude - delta)
                                    withTopRight:CLLocationCoordinate2DMake(coordinate.latitude + delta / 2, coordinate.longitude + delta)
                                 withBottomRight:CLLocationCoordinate2DMake(coordinate.latitude - delta / 2, coordinate.longitude - delta)
                                  withBottomLeft:CLLocationCoordinate2DMake(coordinate.latitude - delta / 2, coordinate.longitude + delta)];
}

@end
