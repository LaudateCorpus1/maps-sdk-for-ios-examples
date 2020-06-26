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

#import "GeofencingReportViewController.h"
#import <TomTomOnlineSDKGeofencing/TomTomOnlineSDKGeofencing.h>

@interface FenceAnnotation : TTAnnotation

@property(nonatomic) NSString *title;

@end

@implementation FenceAnnotation

@end

@interface GeofencingReportViewController () <TTAnnotationDelegate>

@property(nonatomic) TTGeofencingReportService *service;
@property(nonatomic) NSString *projectId1;
@property(nonatomic) NSString *projectId2;
@property(nonatomic) NSString *projectIdActive;
@property(nonatomic) TTAnnotation *draggableAnnotation;
@property(nonatomic) NSMutableArray<NSString *> *inside;
@property(nonatomic) NSMutableArray<NSString *> *outside;
@property(nonatomic) int range;

@end

@implementation GeofencingReportViewController

/**
 * This project ID's are related to the API key that you are using.
 * To make this example working, you must create a proper structure for your API
 * Key by running TomTomGeofencingProjectGenerator.sh script which is located in
 * the sampleapp/scripts folder. Script takes an API Key and Admin Key that you
 * generated from
 * https://developer.tomtom.com/geofencing-api-public-preview/geofencing-documentation-configuration-service/register-admin-key
 *
 * and creates two projects with fences like in this example. Use project ID's
 * returned by the script and update this two fields.
 */

- (void)viewDidLoad {
    [super viewDidLoad];
    _projectId1 = @"57287023-a968-492c-8473-7e049a606425";
    _projectId2 = @"fcf6d609-550d-49ff-bcdf-02bba08baa28";
    _inside = [NSMutableArray new];
    _outside = [NSMutableArray new];
    _range = 5000.0;

    _service = [[TTGeofencingReportService alloc] initWithKey:Key.Geofencing];

    self.mapView.annotationManager.delegate = self;
    [self.etaView updateWithText:@"Drag a pin inside/outside of a fence" icon:[UIImage imageNamed:@"info_small"]];
}

- (OptionsView *)getOptionsView {
    return [[OptionsViewSingleSelect alloc] initWithLabels:@[ @"One Fence", @"Two Fences" ] selectedID:-1];
}

#pragma mark OptionsViewDelegate

- (void)displayExampleWithID:(NSInteger)ID on:(BOOL)on {
    [super displayExampleWithID:ID on:on];
    [self.mapView.annotationManager removeAllOverlays];
    [self.mapView.annotationManager removeAllAnnotations];
    [self draggableAnnotationPin];
    switch (ID) {
    case 1:
        [self drawAmsterdamCircle:[TTCoordinate AMSTERDAM_CIRCLE_CENTER] withRadius:[TTLocationDistance AMSTERDAM_CIRCLE_CENTER_RADIUS]];
        [self drawAmsterdamPolygon];
        _projectIdActive = _projectId2;
        break;
    default:
        [self drawAmsterdamPolygon];
        _projectIdActive = _projectId1;
        break;
    }
    [self requestGeofencingReport:_draggableAnnotation.coordinate withProjectId:_projectIdActive];
}

- (void)requestGeofencingReport:(CLLocationCoordinate2D)coorinate withProjectId:(NSString *)projectId {
    __weak GeofencingReportViewController *weakSelf = self;
    TTGeofencingReportQuery *reportQuery = [[[[[TTGeofencingReportQueryBuilder alloc] initWithLocation:[[TTLocation alloc] initWithCoordinate:coorinate]] withProject:projectId] withRange:_range] build];

    [_service reportWithQuery:reportQuery
             completionHandle:^(TTGeofencingReport *_Nullable report, TTResponseError *_Nullable error) {
               [weakSelf responseGeofencing:report];
             }];
}

- (void)responseGeofencing:(TTGeofencingReport *)report {
    [self removeAnnotationFences];
    [report.inside enumerateObjectsUsingBlock:^(TTGeofencingReportFenceDetails *_Nonnull reportFenceDetails, NSUInteger idx, BOOL *_Nonnull stop) {
      [self addMarker:reportFenceDetails.closestPoint.coordinate withTitle:reportFenceDetails.entity.name];
      [self.inside addObject:reportFenceDetails.entity.name];
    }];
    [report.outside enumerateObjectsUsingBlock:^(TTGeofencingReportFenceDetails *_Nonnull reportFenceDetails, NSUInteger idx, BOOL *_Nonnull stop) {
      [self addMarker:reportFenceDetails.closestPoint.coordinate withTitle:reportFenceDetails.entity.name];
      [self.outside addObject:reportFenceDetails.entity.name];
    }];
    [self.mapView.annotationManager selectAnnotation:self.draggableAnnotation];
}

- (void)setupInitialCameraPosition {
    [self.mapView centerOnCoordinate:TTCoordinate.AMSTERDAM_CIRCLE_CENTER withZoom:12];
}

- (void)addMarker:(CLLocationCoordinate2D)coordinate withTitle:(NSString *)title {
    FenceAnnotation *annotation = [[FenceAnnotation alloc] initWithCoordinate:coordinate annotationImage:[TTAnnotationImage createPNGWithName:@"entry_point"] anchor:TTAnnotationAnchorBottom type:TTAnnotationTypeFocal];
    annotation.title = title;
    [self.mapView.annotationManager addAnnotation:annotation];
}

- (void)draggableAnnotationPin {
    _draggableAnnotation = [[TTAnnotation alloc] initWithCoordinate:TTCoordinate.AMSTERDAM];
    _draggableAnnotation.isDraggable = YES;
    [self.mapView.annotationManager addAnnotation:_draggableAnnotation];
}

- (void)annotationManager:(id<TTAnnotationManager>)manager draggingAnnotation:(TTAnnotation *)annotation stateDrag:(TTAnnotationDragState)state {
    [manager deselectAnnotation];
    if (state == TTAnnotationViewDragStateIdle) {
        [self requestGeofencingReport:annotation.coordinate withProjectId:_projectIdActive];
    }
}

- (UIView<TTCalloutView> *)annotationManager:(id<TTAnnotationManager>)manager viewForSelectedAnnotation:(TTAnnotation *)selectedAnnotation {
    if ([selectedAnnotation isKindOfClass:[FenceAnnotation class]]) {
        NSString *title = ((FenceAnnotation *)selectedAnnotation).title;
        return [[TTCalloutOutlineView alloc] initWithUIView:[self labelForText:[NSString stringWithFormat:@" This is the closest location "
                                                                                                          @"to \n   \"%@\" border",
                                                                                                          title]]];
    }
    return [[TTCalloutOutlineView alloc] initWithUIView:[self labelForText:[self createDescriptionWithInside:_inside withOutside:_outside]]];
}

- (void)removeAnnotationFences {
    NSMutableArray *annotationsToRemove = [NSMutableArray arrayWithArray:self.mapView.annotationManager.annotations];
    [annotationsToRemove removeObject:self.draggableAnnotation];
    [self.mapView.annotationManager removeAnnotations:annotationsToRemove];
    [_inside removeAllObjects];
    [_outside removeAllObjects];
}

@end
