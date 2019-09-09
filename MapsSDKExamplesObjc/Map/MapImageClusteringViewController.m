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

#import "MapImageClusteringViewController.h"
#import <TomTomOnlineSDKMaps/TomTomOnlineSDKMaps.h>

@interface MapImageClusteringViewController ()
@property TTMapStyle *currentStyle;
@end

@implementation MapImageClusteringViewController

- (void)onMapReady {
  self.currentStyle = self.mapView.styleManager.currentStyle;
  [self addStyleImages];
  [self setupClusterStyle];
}

- (void)setupCenterOnWillHappen {
  [self.mapView centerOnCoordinate:[TTCoordinate AMSTERDAM_CENTER_LOCATION]
                          withZoom:9];
}

- (void)addStyleImages {
  UIImage *jetAirPlainLanding = [UIImage imageNamed:@"jet_airplane_landing"];
  [self.currentStyle addImage:jetAirPlainLanding
                       withID:@"jet_airplane_landing"];
  UIImage *amsterdam = [UIImage imageNamed:@"amsterdam_netherlands"];
  UIImage *amsterdam2 = [UIImage imageNamed:@"amsterdam2"];
  UIImage *road_with_traffic = [UIImage imageNamed:@"road_with_traffic"];
  UIImage *tunnel = [UIImage imageNamed:@"tunnel"];
  UIImage *gasStation = [UIImage imageNamed:@"gas_station"];
  UIImage *photo4 = [UIImage imageNamed:@"photo4"];
  UIImage *traffic_light = [UIImage imageNamed:@"traffic_light"];
  UIImage *clusterBg = [UIImage imageNamed:@"ic_cluster"];

  [self.currentStyle addImage:amsterdam withID:@"amsterdam_netherlands"];
  [self.currentStyle addImage:amsterdam2 withID:@"amsterdam2"];
  [self.currentStyle addImage:road_with_traffic withID:@"road_with_traffic"];
  [self.currentStyle addImage:tunnel withID:@"tunnel"];
  [self.currentStyle addImage:gasStation withID:@"gas_station"];
  [self.currentStyle addImage:photo4 withID:@"photo4"];
  [self.currentStyle addImage:traffic_light withID:@"traffic_light"];
  [self.currentStyle addImage:clusterBg withID:@"ic_cluster"];
}

- (void)setupClusterStyle {
  NSString *path = [[NSBundle mainBundle] pathForResource:@"ic_app_test_source"
                                                   ofType:@"json"];
  NSString *geojsonJSON =
      [NSString stringWithContentsOfFile:path
                                encoding:NSUTF8StringEncoding
                                   error:nil];
  TTMapSource *sourceMap = [TTMapSource createWithSourceJSON:geojsonJSON];
  [self.currentStyle addSource:sourceMap];

  [self addLayerWithName:@"ic_app_test_layer"
                   toMap:self.mapView
                andStyle:self.currentStyle];
  [self addLayerWithName:@"ic_app_test_layer_cluster"
                   toMap:self.mapView
                andStyle:self.currentStyle];
  [self addLayerWithName:@"ic_app_test_layer_symbol_count"
                   toMap:self.mapView
                andStyle:self.currentStyle];
}

- (void)addLayerWithName:(NSString *_Nonnull)jsonStyleName
                   toMap:(TTMapView *_Nonnull)map
                andStyle:(TTMapStyle *_Nonnull)style {
  NSString *path = [[NSBundle mainBundle] pathForResource:jsonStyleName
                                                   ofType:@"json"];
  NSString *layerContentJSONString =
      [NSString stringWithContentsOfFile:path
                                encoding:NSUTF8StringEncoding
                                   error:nil];
  TTMapLayer *mapLayer = [TTMapLayer createWithStyleJSON:layerContentJSONString
                                                 withMap:map];
  [style addLayer:mapLayer];
}

@end
