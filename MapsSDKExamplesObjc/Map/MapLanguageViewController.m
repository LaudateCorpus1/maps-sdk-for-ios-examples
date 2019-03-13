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

#import "MapLanguageViewController.h"

@implementation MapLanguageViewController

- (void)setupCenterOnWillHappen {
    [self.mapView centerOnCoordinate:[TTCoordinate LODZ] withZoom:3.2];
}

- (OptionsView *)getOptionsView {
    return [[OptionsViewSingleSelect alloc] initWithLabels:@[@"English", @"Russian", @"Dutch"] selectedID:0];
}

- (void)setupMap {
    [super setupMap];
    [self.mapView setLanguage:@"en-GB"];
}

#pragma mark OptionsViewDelegate

- (void)displayExampleWithID:(NSInteger)ID on:(BOOL)on {
    [super displayExampleWithID:ID on:on];
    switch (ID) {
        case 2:
            [self setLanguageDutch];
            break;
        case 1:
            [self setLanguageRussian];
            break;
        default:
            [self setLanguageEnglish];
            break;
    }
}

#pragma mark Examples

- (void)setLanguageEnglish {
    [self.mapView setLanguage:@"en-GB"];
}

- (void)setLanguageRussian {
    [self.mapView setLanguage:@"ru-RU"];
}

- (void)setLanguageDutch {
    [self.mapView setLanguage:@"nl-NL"];
}

@end
