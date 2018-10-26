/**
 * Copyright (c) 2018 TomTom N.V. All rights reserved.
 *
 * This software is the proprietary copyright of TomTom N.V. and its subsidiaries and may be used
 * for internal evaluation purposes or commercial use strictly subject to separate licensee
 * agreement between you and TomTom. If you are the licensee, you are only permitted to use
 * this Software in accordance with the terms of your license agreement. If you are not the
 * licensee then you are not authorised to use this software in any manner and should
 * immediately return it to TomTom N.V.
 */

#import "MapStaticImageViewController.h"
#import <TomTomOnlineSDKMapsStaticImage/TomTomOnlineSDKMapsStaticImage.h>

@implementation MapStaticImageViewController

- (UIImageView *)getImageViewForIndex:(NSInteger)index {
    switch (index) {
    case 5:
            return [self getAmsterdamNightWithZoomLevel8Image];
    case 4:
        return [self getAmsterdamWithAzureStyleImage];
    case 3:
        return [self getAmsterdamWithHybrydImage];
    case 2:
        return [self getAmsterdamWithZoomLevel15Image];
    case 1:
        return [self getAmsterdamNightImage];
    default:
        return [self getAmsterdamCustomImage];
    }
}

- (UIImageView *)getAmsterdamCustomImage {
    TTStaticImageQuery *query = [[[[[[[TTStaticImageQueryBuilder withCenter:[TTCoordinate AMSTERDAM]] withLayer:TTLayerTypeBasic] withStyle:TTStyleTypeMain] withExt:TTExtTypePNG] withHeight:512] withWidth:512] build];
    return [self performQuery:query];
}

- (UIImageView *)getAmsterdamNightImage {
    TTStaticImageQuery *query = [[[TTStaticImageQueryBuilder withCenter:[TTCoordinate AMSTERDAM]] withStyle:TTStyleTypeMain] build];
    return [self performQuery:query];
}

- (UIImageView *)getAmsterdamWithZoomLevel15Image {
    TTStaticImageQuery *query = [[[TTStaticImageQueryBuilder withCenter:[TTCoordinate AMSTERDAM]] withZoomLevel:15] build];
    return [self performQuery:query];
}

- (UIImageView *)getAmsterdamWithHybrydImage {
    TTStaticImageQuery *query = [[[TTStaticImageQueryBuilder withCenter:[TTCoordinate AMSTERDAM]] withLayer:TTLayerTypeHybrid] build];
    return [self performQuery:query];
}

- (UIImageView *)getAmsterdamWithAzureStyleImage {
    TTStaticImageQuery *query = [[[TTStaticImageQueryBuilder withCenter:[TTCoordinate AMSTERDAM]] withCustomStyle:@"main-azure"] build];
    return [self performQuery:query];
}

- (UIImageView *)getAmsterdamNightWithZoomLevel8Image {
    TTStaticImageQuery *query = [[[[TTStaticImageQueryBuilder withCenter:[TTCoordinate AMSTERDAM]] withStyle:TTStyleTypeNight] withZoomLevel:8] build];
    return [self performQuery:query];
}

- (UIImageView *)performQuery:(TTStaticImageQuery *)query {
    UIImageView *imageView = [[ProgressImageView alloc] initWithFrame:CGRectZero];
    TTStaticImage *staticImage = [TTStaticImage new];
    [staticImage imageForQuery:query completionHandler:^(UIImage * _Nullable image, TTResponseError * _Nullable error) {
        if(error) {
            return;
        }
        imageView.image = image;
    }];
    return imageView;
}

@end
