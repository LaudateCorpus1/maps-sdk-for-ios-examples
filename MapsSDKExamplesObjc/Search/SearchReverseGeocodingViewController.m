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

#import "SearchReverseGeocodingViewController.h"
#import <TomTomOnlineSDKSearch/TomTomOnlineSDKSearch.h>
#import <TomTomOnlineSDKMaps/TomTomOnlineSDKMaps.h>

@interface SearchReverseGeocodingViewController () <TTMapViewDelegate, TTAnnotationDelegate, TTReverseGeocoderDelegate>
@property(nonatomic, strong) TTReverseGeocoder *reverseGeocoder;
@property(nonatomic, strong) NSString *geocoderResult;
@property(nonatomic, strong) TTAnnotation *annotation;
@end

@implementation SearchReverseGeocodingViewController

- (OptionsView *)getOptionsView {
    return [[OptionsViewSingleSelect alloc] initWithLabels:@[] selectedID:-1];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.reverseGeocoder = [TTReverseGeocoder new];
    self.mapView.delegate = self;
    self.reverseGeocoder.delegate = self;
    self.mapView.annotationManager.delegate = self;
    self.geocoderResult = @"Loading...";
    [self setupEtaView];
    [self.etaView updateWithText:@"Drop a pin on map" icon:[UIImage imageNamed:@"info_small"]];
}

#pragma mark Example

- (void)resolveAddressForCoordinates:(CLLocationCoordinate2D)coordinate {
    TTReverseGeocoderQuery *query = [[TTReverseGeocoderQueryBuilder createWithCLLocationCoordinate2D:coordinate] build];
    [self.reverseGeocoder reverseGeocoderWithQuery:query];
}

#pragma mark TTMapViewDelegate

- (void)mapView:(TTMapView *)mapView didLongPress:(CLLocationCoordinate2D)coordinate {
    [self.mapView.annotationManager removeAllAnnotations];
    self.annotation = [TTAnnotation annotationWithCoordinate:coordinate];
    [self.mapView.annotationManager addAnnotation:self.annotation];
    [self resolveAddressForCoordinates:coordinate];
}

#pragma mark TTAnnotationDelegate

- (UIView<TTCalloutView> *)annotationManager:(id<TTAnnotationManager>)manager viewForSelectedAnnotation:(TTAnnotation *)selectedAnnotation {
    return [[TTCalloutOutlineView alloc] initWithText:self.geocoderResult];
}

#pragma mark TTReverseGeocoderDelegate

- (void)reverseGeocoder:(TTReverseGeocoder *)reverseGeocoder completedWithResponse:(TTReverseGeocoderResponse *)response {
    TTReverseGeocoderFullAddress *address = response.result.addresses.firstObject;
    if (address) {
        NSString *freeFormAddress = address.address.freeformAddress;
        if (freeFormAddress) {
            self.geocoderResult = freeFormAddress;
        } else {
            self.geocoderResult = @"Cant resolve address";
        }
        [self.mapView.annotationManager selectAnnotation:self.annotation];
    }
}

- (void)reverseGeocoder:(TTReverseGeocoder *)reverseGeocoder failedWithError:(TTResponseError *)error {
    [self handleError:error];
}

@end
