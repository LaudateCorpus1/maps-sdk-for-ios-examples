//
/**
 * Copyright (c) 2020 TomTom N.V. All rights reserved.
 *
 * This software is the proprietary copyright of TomTom N.V. and its subsidiaries and may be used
 * for internal evaluation purposes or commercial use strictly subject to separate licensee
 * agreement between you and TomTom. If you are the licensee, you are only permitted to use
 * this Software in accordance with the terms of your license agreement. If you are not the
 * licensee then you are not authorised to use this software in any manner and should
 * immediately return it to TomTom N.V.
 */

#import "SearchPoiDetailsAndPhotosViewController.h"
#import <TomTomOnlineSDKSearch/TomTomOnlineSDKSearch.h>

@interface SearchPoiDetailsAndPhotosViewController () <TTAnnotationDelegate>
@property(nonatomic, strong) TTSearch *searchAPI;
@property(nonatomic, strong) PoiDetailsService *poiDetailsAPI;
@property(nonatomic, strong) PoiPhotosService *poiPhotosAPI;
@end

@implementation SearchPoiDetailsAndPhotosViewController

- (void)onMapReady {
    [super onMapReady];
    self.searchAPI = [[TTSearch alloc] initWithKey:Key.Search];
    self.poiDetailsAPI = [[PoiDetailsService alloc] initWithKey:Key.Search];
    self.poiPhotosAPI = [[PoiPhotosService alloc] initWithApiKey:Key.Search];
    self.mapView.annotationManager.delegate = self;
    [self searchPoi];
    [self.progress show];
}

- (void)searchPoi {
    __weak SearchPoiDetailsAndPhotosViewController *weakSelf = self;

    TTSearchQuery *searchQuery = [[[[[TTSearchQueryBuilder createWithTerm:@"Restaurant"] withPosition:TTCoordinate.AMSTERDAM] withLimit:200] withOpeningHours:TTOpeningHoursNextSevenDays] build];
    [self.searchAPI searchWithQuery:searchQuery
                   completionHandle:^(TTSearchResponse *_Nullable response, TTResponseError *_Nullable error) {
                     SearchPoiDetailsAndPhotosViewController *strongSelf = weakSelf;

                     if (!strongSelf)
                         return;

                     [strongSelf.progress hide];

                     if (response != nil && error == nil) {
                         for (TTSearchResult *annotationData in response.results) {
                             SearchResultAnnotation *annotation = [[SearchResultAnnotation alloc] initWithResult:annotationData];
                             [strongSelf.mapView.annotationManager addAnnotation:annotation];
                         }
                         [strongSelf.mapView zoomToAnnotations:strongSelf.mapView.annotationManager.annotations];
                     } else {
                         [strongSelf presentViewController:[TTErrorUIAlertController create] animated:YES completion:nil];
                     }
                   }];
}

- (void)fetchPhotosForAnnotation:(SearchResultAnnotation *)poiAnnotation poiDetailsResponse:(PoiDetails *_Nullable)poiDetailsResponse poiPhotoArray:(NSMutableArray<PoiPhoto *> *)poiPhotoArray {

    __weak SearchPoiDetailsAndPhotosViewController *weakSelf = self;

    [self.poiPhotosAPI getWithPhotos:poiPhotoArray
                          completion:^(NSArray<UIImage *> *_Nullable images, NSError *_Nullable error) {

                            SearchPoiDetailsAndPhotosViewController *strongSelf = weakSelf;
                            if (!strongSelf)
                                return;

                            [strongSelf.progress hide];

                            if (images.count != 0) {
                                PoiDetailsModel *detailsModel = [[PoiDetailsModel alloc] initWithPhotos:images annotationData:poiAnnotation poiDetails:poiDetailsResponse];
                                if (detailsModel == nil)
                                    return;
                                PoiDetailsViewController *vc = [[PoiDetailsViewController alloc] initWithModel:detailsModel];
                                [strongSelf presentViewController:vc animated:true completion:nil];
                            }
                          }];
}

- (void)annotationManager:(id<TTAnnotationManager>)manager annotationSelected:(TTAnnotation *)annotation {

    [self.mapView centerOnCoordinate:annotation.coordinate];
    [self.progress show];

    SearchResultAnnotation *poiAnnotation = (SearchResultAnnotation *)annotation;
    TTAdditionalDataSources *additionalData = poiAnnotation.result.additionalDataSources;
    NSString *dataSourceID = @"";
    for (TTPoiDetailsDataSource *poiDetailsDataSources in additionalData.poiDetailsDataSources) {
        if ([poiDetailsDataSources.sourceName isEqualToString:@"Foursquare"]) {
            dataSourceID = poiDetailsDataSources.dataSourceID;
        }
    }

    __weak SearchPoiDetailsAndPhotosViewController *weakSelf = self;

    AnnotationPoiDetailsSpecification *poiDetailsSpecification = [[AnnotationPoiDetailsSpecification alloc] initWithPoiDetailsID:dataSourceID];
    [self.poiDetailsAPI fetchPoiDetailsWithSpecification:poiDetailsSpecification
                                              completion:^(PoiDetails *_Nullable poiDetailsResponse, NSError *_Nullable error) {

                                                SearchPoiDetailsAndPhotosViewController *strongSelf = weakSelf;
                                                if (!strongSelf)
                                                    return;

                                                [strongSelf.progress hide];
                                                if (poiDetailsResponse != nil && error == nil) {

                                                    NSMutableArray<PoiPhoto *> *poiPhotoArray = [[NSMutableArray<PoiPhoto *> alloc] init];
                                                    for (Photo *photoObject in poiDetailsResponse.photos) {
                                                        PoiPhoto *photo = [[PoiPhoto alloc] initWithPhotoID:photoObject.photoID];
                                                        [poiPhotoArray addObject:photo];
                                                    }

                                                    [strongSelf fetchPhotosForAnnotation:poiAnnotation poiDetailsResponse:poiDetailsResponse poiPhotoArray:poiPhotoArray];
                                                } else {
                                                    [strongSelf presentViewController:[TTErrorUIAlertController create] animated:YES completion:nil];
                                                }
                                              }];
}

@end
