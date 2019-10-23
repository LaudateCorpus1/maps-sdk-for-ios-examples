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

#import "MapWithBuildingHeightsViewController.h"

@interface MapWithBuildingHeightsViewController ()

@property NSArray<TTMapLayer *> *layers;

@end

@implementation MapWithBuildingHeightsViewController

- (void)setupInitialCameraPosition {
  [self.mapView centerOnCoordinate:TTCoordinate.LONDON withZoom:17];
}

- (void)onMapReady {
  [super onMapReady];
  self.layers = [[self.mapView.styleManager currentStyle]
      getLayersByRegexs:
          [NSArray
              arrayWithObjects:@"Subway Station 3D", @"Place of worship 3D",
                               @"Railway Station 3D",
                               @"Government Administration Office 3D",
                               @"Other building 3D", @"School building 3D",
                               @"Other town block 3D", @"Factory building 3D",
                               @"Hospital building 3D", @"Hotel building 3D",
                               @"Cultural Facility 3D", nil]];
  [self buildingHeights];
}

- (OptionsView *)getOptionsView {
  return [[OptionsViewSingleSelect alloc]
      initWithLabels:@[ @"Heights", @"Footprints" ]
          selectedID:0];
}

#pragma mark OptionsViewDelegate

- (void)displayExampleWithID:(NSInteger)ID on:(BOOL)on {
  [super displayExampleWithID:ID on:on];
  switch (ID) {
  case 1:
    [self buildingFootprints];
    break;
  default:
    [self buildingHeights];
    break;
  }
}

#pragma mark Examples

- (void)buildingFootprints {
  [self changeLayers:self.layers visibility:TTMapLayerVisibilityNone];
  [self.mapView setPerspective3D:NO];
}

- (void)buildingHeights {
  [self changeLayers:self.layers visibility:TTMapLayerVisibilityVisible];
  [self.mapView setPerspective3D:YES];
}

- (void)changeLayers:(NSArray<TTMapLayer *> *)layers
          visibility:(TTMapLayerVisibility)visibility {
  for (TTMapLayer *layer in layers) {
    layer.visibility = visibility;
  }
}

@end
