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

#import "MapAdvancedMarkersViewController.h"

@implementation MapAdvancedMarkersViewController

- (OptionsView *)getOptionsView {
    return [[OptionsViewSingleSelect alloc] initWithLabels:@[ @"Animated", @"Draggable" ] selectedID:-1];
}

#pragma mark OptionsViewDelegate

- (void)displayExampleWithID:(NSInteger)ID on:(BOOL)on {
    [super displayExampleWithID:ID on:on];
    switch (ID) {
    case 1:
        [self displayDraggableMarker];
        break;
    default:
        [self displayAnimatedMarkers];
        break;
    }
}

#pragma mark Examples

- (void)displayAnimatedMarkers {
    [self.mapView.annotationManager removeAllAnnotations];
    for (int i = 0; i < 4; i++) {
        CLLocationCoordinate2D coordinate = [CLLocation makeRandomCoordinateForCenteroidWithCenter:[TTCoordinate AMSTERDAM]];
        TTAnnotationImage *customIcon = [TTAnnotationImage createGIFWithName:@"gif_annotation"];
        TTAnnotation *annotation = [TTAnnotation annotationWithCoordinate:coordinate annotationImage:customIcon anchor:TTAnnotationAnchorBottom type:TTAnnotationTypeDecal];
        annotation.selectable = NO;
        [self.mapView.annotationManager addAnnotation:annotation];
    }
}

- (void)displayDraggableMarker {
    self.mapView.bearing = 0;
    [self.mapView.annotationManager removeAllAnnotations];
    for (int i = 0; i < 4; i++) {
        CLLocationCoordinate2D coordinate = [CLLocation makeRandomCoordinateForCenteroidWithCenter:[TTCoordinate AMSTERDAM]];
        TTAnnotation *annotation = [TTAnnotation annotationWithCoordinate:coordinate];
        annotation.selectable = NO;
        annotation.isDraggable = YES;
        [self.mapView.annotationManager addAnnotation:annotation];
    }
}

@end
