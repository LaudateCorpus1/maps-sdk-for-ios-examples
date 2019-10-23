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

#import "MapDynamicMapSourcesViewController.h"
#import <TomTomOnlineSDKMaps/TomTomOnlineSDKMaps.h>

#define GEO_LAYER_ID @"layer-line-id"
#define IMG_LAYER_ID @"layer-image-id"
#define IMG_SOURCE @"image-source"

@interface MapDynamicMapSourcesViewController () <TTMapViewDelegate>
@property TTMapStyle *currentStyle;
@end

@implementation MapDynamicMapSourcesViewController

- (void)onMapReady {
  self.currentStyle = self.mapView.styleManager.currentStyle;
  [self addImageSource];
  [self addGeoJSONSource];
  self.mapView.delegate = self;
}

- (void)setupInitialCameraPosition {
  [self.mapView centerOnCoordinate:[TTCoordinate BUCKINGHAM_PALACE_CENTER]
                          withZoom:16];
}

- (OptionsView *)getOptionsView {
  return
      [[OptionsViewMultiSelect alloc] initWithLabels:@[ @"GeoJson", @"Image" ]
                                          selectedID:-1];
}

- (void)addGeoJSONSource {
  NSString *path = [[NSBundle mainBundle] pathForResource:@"geojson_source"
                                                   ofType:@"json"];
  NSString *geojsonJSON =
      [NSString stringWithContentsOfFile:path
                                encoding:NSUTF8StringEncoding
                                   error:nil];
  TTMapSource *sourceMap = [TTMapSource createWithSourceJSON:geojsonJSON];
  [self.currentStyle addSource:sourceMap];
  path = [[NSBundle mainBundle] pathForResource:@"layer_fill" ofType:@"json"];
  NSString *layerJSON = [NSString stringWithContentsOfFile:path
                                                  encoding:NSUTF8StringEncoding
                                                     error:nil];
  TTMapLayer *layerMap = [TTMapLayer createWithStyleJSON:layerJSON
                                                 withMap:self.mapView];
  [self.currentStyle addLayer:layerMap];
}

- (void)addImageSource {
  UIImage *image = [UIImage imageNamed:@"buckingham_palace"];
  TTLatLngQuad *quad = [[TTLatLngQuad alloc]
      initWithTopLeft:TTCoordinate.BUCKINGHAM_PALACE_TOP_LEFT
         withTopRight:TTCoordinate.BUCKINGHAM_PALACE_TOP_RIGHT
      withBottomRight:TTCoordinate.BUCKINGHAM_PALACE_BOTTOM_LEFT
       withBottomLeft:TTCoordinate.BUCKINGHAM_PALACE_BOTTOM_RIGHT];
  TTMapImageSource *sourceMap = [TTMapImageSource createWithID:IMG_SOURCE
                                                         image:image
                                                   coordinates:quad];
  [self.currentStyle addSource:sourceMap];

  NSString *path = [[NSBundle mainBundle] pathForResource:@"layer_raster"
                                                   ofType:@"json"];
  NSString *layerJSON = [NSString stringWithContentsOfFile:path
                                                  encoding:NSUTF8StringEncoding
                                                     error:nil];
  TTMapLayer *layerMap = [TTMapLayer createWithStyleJSON:layerJSON
                                                 withMap:self.mapView];
  [self.currentStyle addLayer:layerMap];
}

- (void)displayExampleWithID:(NSInteger)ID on:(BOOL)on {
  [super displayExampleWithID:ID on:on];
  TTMapLayer *geoLayer = [self.currentStyle getLayerByID:GEO_LAYER_ID];
  TTMapLayer *imgLayer = [self.currentStyle getLayerByID:IMG_LAYER_ID];
  switch (ID) {
  case 1:
    imgLayer.visibility =
        on ? TTMapLayerVisibilityVisible : TTMapLayerVisibilityNone;
    break;
  default:
    geoLayer.visibility =
        on ? TTMapLayerVisibilityVisible : TTMapLayerVisibilityNone;
    break;
  }
}

- (void)mapView:(TTMapView *_Nonnull)mapView
    didSingleTap:(CLLocationCoordinate2D)coordinate {
  CGPoint tap = [mapView pointForCoordinate:coordinate];
  NSArray *geoJSONFeatures =
      [self.mapView featuresAtPoint:tap
            inStyleLayerIdentifiers:[NSSet setWithObject:GEO_LAYER_ID]]
          .features;
  if (geoJSONFeatures.count) {
    [self.toast toastWithMessage:@"GeoJSON Polygon clicked!"];
  }
}

@end
