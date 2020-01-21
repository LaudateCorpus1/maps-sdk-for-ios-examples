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
#import "SearchPoiCategoriesViewController.h"
#import <TomTomOnlineSDKSearch/TomTomOnlineSDKSearch.h>

@interface SearchPoiCategoriesViewController () <TTPoiCategoriesDelegate>
@property(nonatomic, strong) TTPoiCategories *poiCategoriesService;
@property(nonatomic, strong) NSArray<TTPoiCategory *> *categories;
@end

@implementation SearchPoiCategoriesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.progress show];
    _poiCategoriesService = [[TTPoiCategories alloc] init];

    _poiCategoriesService.delegate = self;
    TTPoiCategoriesQuery *query = [[TTPoiCategoriesQueryBuilder create] build];
    [_poiCategoriesService requestCategoriesWithQuery:query];
}

- (void)poiCategories:(TTPoiCategories *)poiCategories completedWithResponse:(TTPoiCategoriesResponse *_Nonnull)response {
    _categories = response.results;
    [self displayResults:_categories];
    [self.progress hide];
}

- (void)poiCategories:(TTPoiCategories *)poiCategories failedWithError:(TTResponseError *)error {
    [self handleError:error];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TTPoiCategory *category = (TTPoiCategory *)self.results[indexPath.row];
    if (category.children.count == 0) {
        return;
    }
    UINavigationController *parent = self.navigationController;
    TableBaseViewController *table = [[TableBaseViewController alloc] init];
    table.results = category.children;
    table.name = category.name;
    [parent pushViewController:table animated:YES];
}

@end
