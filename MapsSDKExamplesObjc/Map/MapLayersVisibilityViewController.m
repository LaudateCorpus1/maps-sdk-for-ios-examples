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

#import "MapLayersVisibilityViewController.h"
#import <TomTomOnlineSDKMaps/TomTomOnlineSDKMaps.h>

@interface MapLayersVisibilityViewController ()
@property TTMapStyle* currentStyle;
@end

@implementation MapLayersVisibilityViewController

- (void)onMapReady {
    self.currentStyle = self.mapView.styleManager.currentStyle;
    [self turnOffLayers];
}

- (void)setupCenterOnWillHappen {
    [self.mapView centerOnCoordinate:[TTCoordinate BERLIN] withZoom:8];
}

- (OptionsView *)getOptionsView {
    return [[OptionsViewMultiSelect alloc] initWithLabels:@[@"Road network", @"Woodland", @"Build-up"] selectedID:-1];
}

- (void)displayExampleWithID:(NSInteger)ID on:(BOOL)on {
    [super displayExampleWithID:ID on:on];
    TTMapLayerVisibility visibility = on ? TTMapLayerVisibilityVisible : TTMapLayerVisibilityNone;
    NSArray<TTMapLayer*>* layers;
    switch (ID) {
        case 2:
            layers = [self.currentStyle getLayersBySourceLayerRegex:@"Built-up area"];
            break;
        case 1:
            layers = [self.currentStyle getLayersBySourceLayerRegex:@"Woodland.*"];
            break;
        default:
            layers = [self.currentStyle getLayersBySourceLayerRegexs:@[@".*[rR]oad.*", @".*[mM]otorway.*"]];
            break;
    }
    [self changeLayers:layers visibility:visibility];
}

- (void)changeLayers:(NSArray<TTMapLayer*>*)layers visibility:(TTMapLayerVisibility)visibility {
    for(TTMapLayer* layer in layers) {
        layer.visibility = visibility;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)turnOffLayers {
    NSArray<NSString*>* regexs = @[@"Built-up area", @"Woodland.*", @".*[rR]oad.*", @".*[mM]otorway.*"];
    NSArray<TTMapLayer*>* layers = [self.currentStyle getLayersBySourceLayerRegexs:regexs];
    [self changeLayers:layers visibility:TTMapLayerVisibilityNone];
}


@end
