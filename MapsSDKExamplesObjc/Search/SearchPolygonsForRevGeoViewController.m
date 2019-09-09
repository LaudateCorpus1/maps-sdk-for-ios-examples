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

#import "SearchPolygonsForRevGeoViewController.h"
#import <TomTomOnlineSDKSearch/TomTomOnlineSDKSearch.h>
#import <TomTomOnlineSDKMaps/TomTomOnlineSDKMaps.h>

@interface PolygonAdditionalDataVisitior
    : NSObject <TTGeoJSONObjectVisitor, TTGeoJSONGeoVisitor>
@property(nonatomic, strong) NSMutableArray<TTGeoJSONLineString *> *lineStrings;
@end

@interface SearchPolygonsForRevGeoViewController () <
    TTMapViewDelegate, TTAnnotationDelegate, TTReverseGeocoderDelegate,
    TTAdditionalDataSearchDelegate>

@property(nonatomic, strong) TTAdditionalDataSearch *searchAdditionalData;
@property(nonatomic, strong) TTReverseGeocoder *reverseGeocoder;
@property(nonatomic, strong) NSString *geocoderResult;
@property(nonatomic, strong) TTAnnotation *annotation;
@property(nonatomic, strong) NSString *entityType;

@end

@implementation SearchPolygonsForRevGeoViewController

- (void)setupCenterOnWillHappen {
  [self.mapView centerOnCoordinate:[TTCoordinate LODZ] withZoom:3.2];
}

- (OptionsView *)getOptionsView {
  return [[OptionsViewSingleSelect alloc]
      initWithLabels:@[ @"Country", @"Municipality" ]
          selectedID:0];
}

- (void)onMapReady {
  [self.mapView setLanguage:@"NGT"];
}

- (void)displayExampleWithID:(NSInteger)ID on:(BOOL)on {
  [super displayExampleWithID:ID on:on];
  [self removeAllAnnotationAndOverlays];
  switch (ID) {
  case 1:
    self.entityType = @"Municipality";
    break;
  default:
    self.entityType = @"Country";
    break;
  }
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.reverseGeocoder = [TTReverseGeocoder new];
  self.mapView.delegate = self;
  self.searchAdditionalData = [TTAdditionalDataSearch new];
  self.searchAdditionalData.delegate = self;
  self.reverseGeocoder.delegate = self;
  self.mapView.annotationManager.delegate = self;
  self.entityType = @"Country";
  self.geocoderResult = @"Loading...";
  [self setupEtaView];
  [self.etaView updateWithText:@"Drop a pin to get a polygon"
                          icon:[UIImage imageNamed:@"info_small"]];
}

#pragma mark Example

- (void)resolveAddressForCoordinates:(CLLocationCoordinate2D)coordinate {
  TTReverseGeocoderQuery *query = [[[TTReverseGeocoderQueryBuilder
      createWithCLLocationCoordinate2D:coordinate]
      withEntityType:self.entityType] build];
  [self.reverseGeocoder reverseGeocoderWithQuery:query];
}

#pragma mark TTMapViewDelegate

- (void)mapView:(TTMapView *)mapView
    didLongPress:(CLLocationCoordinate2D)coordinate {
  [self removeAllAnnotationAndOverlays];
  self.annotation = [TTAnnotation annotationWithCoordinate:coordinate];
  [self.mapView.annotationManager addAnnotation:self.annotation];
  [self resolveAddressForCoordinates:coordinate];
}

#pragma mark TTAnnotationDelegate

- (UIView<TTCalloutView> *)annotationManager:(id<TTAnnotationManager>)manager
                   viewForSelectedAnnotation:
                       (TTAnnotation *)selectedAnnotation {
  return [[TTCalloutOutlineView alloc] initWithText:self.geocoderResult];
}

#pragma mark TTReverseGeocoderDelegate

- (void)reverseGeocoder:(TTReverseGeocoder *)reverseGeocoder
    completedWithResponse:(TTReverseGeocoderResponse *)response {
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

  if ([self geometryDataSourceFromResponse:response] != nil) {
    TTAdditionalDataSearchQuery *query = [[TTAdditionalDataSearchQueryBuilder
        createWithDataSource:[self geometryDataSourceFromResponse:response]]
        build];
    [_searchAdditionalData additionalDataSearchWithQuery:query];
  }
}

- (TTGeometryDataSource *_Nullable)geometryDataSourceFromResponse:
    (TTReverseGeocoderResponse *)response {
  if (response.result.addresses.firstObject != nil) {
    TTReverseGeocoderFullAddress *addressValue =
        [TTReverseGeocoderFullAddress alloc];
    addressValue = response.result.addresses.firstObject;
    if (addressValue.additionalDataSources) {
      TTAdditionalDataSources *additionalDataSources =
          [TTAdditionalDataSources alloc];
      additionalDataSources = addressValue.additionalDataSources;
      if (additionalDataSources.geometryDataSource) {
        return additionalDataSources.geometryDataSource;
      }
    }
  }
  return nil;
}

- (void)reverseGeocoder:(TTReverseGeocoder *)reverseGeocoder
        failedWithError:(TTResponseError *)error {
  [self handleError:error];
}

#pragma mark TTAdditionalDataSearchDelegate
- (void)additionalDataSearch:(TTAdditionalDataSearch *)additionalDataSearch
       completedWithResponse:(TTAdditionalDataSearchResponse *)response {
  [self.progress hide];
  TTAdditionalDataSearchResult *result = response.results.firstObject;
  if (!result) {
    return;
  }
  PolygonAdditionalDataVisitior *visitor = [PolygonAdditionalDataVisitior new];
  [result visitGeoJSONResult:visitor];
  NSMutableArray<TTPolygon *> *mapPolygons = [NSMutableArray new];
  for (TTGeoJSONLineString *lineString in visitor.lineStrings) {
    TTPolygon *mapPolygon =
        [TTPolygon polygonWithCoordinatesData:lineString
                                      opacity:0.7
                                        color:[TTColor Red]
                                 colorOutline:[TTColor Red]];
    [mapPolygons addObject:mapPolygon];
    [self.mapView.annotationManager addOverlay:mapPolygon];
  }
  [self.mapView zoomToCoordinatesDataCollection:mapPolygons];
}

- (void)additionalDataSearch:(TTAdditionalDataSearch *)additionalDataSearch
             failedWithError:(TTResponseError *)error {
  [self handleError:error];
}

- (void)removeAllAnnotationAndOverlays {
  [self.mapView.annotationManager removeAllOverlays];
  [self.mapView.annotationManager removeAllAnnotations];
}

@end
