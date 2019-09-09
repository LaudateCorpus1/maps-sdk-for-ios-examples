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
#import "MapInteractiveLayersViewController.h"

@interface MapInteractiveLayersViewController () <TTMapViewDelegate,
                                                  TTMapViewCameraDelegate>
@property TTMapStyle *currentStyle;
@end

@implementation MapInteractiveLayersViewController

- (void)setupCenterOnWillHappen {
  [self.mapView centerOnCoordinate:[TTCoordinate LONDON] withZoom:9];
}

- (void)onMapReady {
  self.currentStyle = self.mapView.styleManager.currentStyle;
  self.mapView.delegate = self;
  [self addGeoJSONSource];
  TTMapLayer *geoLayer = [self.currentStyle getLayerByID:@"IL-test-source"];
  geoLayer.visibility = TTMapLayerVisibilityVisible;
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                               (int64_t)(self.toast.delayTime * NSEC_PER_SEC)),
                 dispatch_get_main_queue(), ^{
                   [self displayFeaturesToast];
                 });
}

- (void)addGeoJSONSource {
  NSString *path =
      [[NSBundle mainBundle] pathForResource:@"interactive_layers_data"
                                      ofType:@"json"];
  NSString *geojsonJSON =
      [NSString stringWithContentsOfFile:path
                                encoding:NSUTF8StringEncoding
                                   error:nil];
  TTMapSource *sourceMap = [TTMapSource createWithSourceJSON:geojsonJSON];
  [self.currentStyle addSource:sourceMap];

  NSString *outlinePath =
      [[NSBundle mainBundle] pathForResource:@"interactive_layers_outline_layer"
                                      ofType:@"json"];
  NSString *outlineLayerJson =
      [NSString stringWithContentsOfFile:outlinePath
                                encoding:NSUTF8StringEncoding
                                   error:nil];
  TTMapLayer *outlineLayer = [TTMapLayer createWithStyleJSON:outlineLayerJson
                                                     withMap:self.mapView];
  [self.currentStyle addLayer:outlineLayer];

  NSString *fillPath =
      [[NSBundle mainBundle] pathForResource:@"interactive_layers_fill_layer"
                                      ofType:@"json"];
  NSString *fillLayerJson =
      [NSString stringWithContentsOfFile:fillPath
                                encoding:NSUTF8StringEncoding
                                   error:nil];
  TTMapLayer *fillLayer = [TTMapLayer createWithStyleJSON:fillLayerJson
                                                  withMap:self.mapView];
  [self.currentStyle addLayer:fillLayer];
}

- (NSString *)listFeaturesIdsToString:
    (TTGeoJSONFeatureCollection *_Nonnull)geoJSONFeatureCollection {
  NSMutableString *list = [[NSMutableString alloc] init];
  NSMutableSet *uniqueFeaturesIds = [[NSMutableSet alloc] init];
  for (TTGeoJSONFeature *feature in geoJSONFeatureCollection.features) {
    [uniqueFeaturesIds addObject:feature.Id];
  }
  for (NSString *featureId in uniqueFeaturesIds) {
    [list appendString:featureId];
    [list appendString:@", "];
  }
  [list deleteCharactersInRange:NSMakeRange([list length] - 2, 2)];
  [list appendString:@"."];
  return list;
}

- (void)mapView:(TTMapView *_Nonnull)mapView
    didSingleTap:(CLLocationCoordinate2D)coordinate {

  TTGeoJSONFeatureCollection *geoJSONFeatures = [self.mapView
        featuresAtCoordinates:coordinate
      inStyleLayerIdentifiers:[NSSet setWithObject:@"IL-test-layer-outline"]];
  NSMutableString *message = [NSMutableString stringWithString:@"Tapped on: "];

  if (geoJSONFeatures.features.count == 0) {
    [message appendString:@"no features."];
  } else {
    [message appendString:[self listFeaturesIdsToString:geoJSONFeatures]];
  }
  [self.toast toastWithMessage:message];
}

- (void)mapView:(TTMapView *_Nonnull)mapView
    didChangCameraPosition:(TTCameraPosition *)cameraPosition {
  [self displayFeaturesToast];
}

- (void)displayFeaturesToast {
  TTGeoJSONFeatureCollection *geoJSONFeatures = [self.mapView
         featuresAtScreenRect:self.mapView.bounds
      inStyleLayerIdentifiers:[NSSet setWithObject:@"IL-test-layer-outline"]];
  NSMutableString *message =
      [NSMutableString stringWithString:@"Features in viewport: "];

  if (geoJSONFeatures.features.count == 0) {
    [message appendString:@"no features."];
  } else {
    [message appendString:[self listFeaturesIdsToString:geoJSONFeatures]];
  }
  [self.toast toastWithMessage:message];
}

@end
