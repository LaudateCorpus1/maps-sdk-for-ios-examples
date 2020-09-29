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

#import "TableBaseViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <MapsSDKExamplesCommon/MapsSDKExamplesCommon-Swift.h>
#import <TomTomOnlineSDKRouting/TomTomOnlineSDKRouting.h>
#import <TomTomOnlineSDKSearch/TomTomOnlineSDKSearch.h>
#import <TomTomOnlineSDKTraffic/TomTomOnlineSDKTraffic.h>

@implementation TableBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UITableView *tableView = [UITableView new];
    self.tableView = tableView;
    tableView.delegate = self;
    tableView.dataSource = self;
    self.view = tableView;
    [self.tableView reloadData];
}

- (void)displayResults:(NSArray *)results {
    self.results = results;
    [self.tableView reloadData];
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UNUSED_PARAM UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.results.count;
}

- (UITableViewCell *)tableView:(UNUSED_PARAM UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [UITableViewCell new];
    if (self.results.count == 0) {
        return cell;
    }
    if ([self.results[indexPath.row] isKindOfClass:[NSString class]]) {
        NSString *text = (NSString *)self.results[indexPath.row];
        cell.textLabel.text = text;
    } else if ([self.results[indexPath.row] isKindOfClass:[TTInstruction class]]) {
        TTInstruction *instruction = (TTInstruction *)self.results[indexPath.row];
        ManeuverCell *maneuverCell = [[ManeuverCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"reusableManeuverCellID"];
        NSInteger distanceToManeuver = instruction.routeOffsetInMetersValue;
        maneuverCell.maneuverDistance.text = [FormatUtils formatDistanceWithMeters:distanceToManeuver];
        maneuverCell.maneuverDescription.text = instruction.message;
        maneuverCell.maneuverImageView.image = [ManeuverIconGenerator imageForInstruction:instruction];
        cell = maneuverCell;
    } else if ([self.results[indexPath.row] isKindOfClass:[TTSearchResult class]]) {
        TTSearchResult *searchResult = (TTSearchResult *)self.results[indexPath.row];
        double distance = 0;
        if (LocationManager.shared.lastLocation != nil) {
            distance = [LocationManager.shared.lastLocation distanceFromLocation:[[CLLocation alloc] init:searchResult.position]];
        }
        NSString *distanceAsText = [FormatUtils formatDistanceWithMeters:distance];
        NSString *text = [NSString stringWithFormat:@"%@ %@ %@ %@", distanceAsText, searchResult.address.country, searchResult.address.freeformAddress, searchResult.address.countryCode];
        cell.textLabel.numberOfLines = 4;
        cell.textLabel.text = text;
    } else if ([self.results[indexPath.row] isKindOfClass:[TTTrafficDetailBase class]]) {
        TrafficCell *trafficCell = [[TrafficCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"reusableTrafficCellID"];
        if ([self.results[indexPath.row] isKindOfClass:[TTTrafficDetail class]]) {
            TTTrafficDetail *detail = (TTTrafficDetail *)self.results[indexPath.row];
            trafficCell.trafficImageView.image = [TTTrafficDetailImage createWithTraffic:detail].medium;
            trafficCell.trafficDescription.text = [NSString stringWithFormat:@"(%@) / (%@)", detail.from, detail.to];
            trafficCell.trafficDelay.text = detail.delay == -1 ? @"---" : [FormatUtils formatTimeDelayWithSeconds:detail.delay];
            trafficCell.trafficLength.text = [FormatUtils formatDistanceWithMeters:detail.length];
        } else if ([self.results[indexPath.row] isKindOfClass:[TTTrafficDetailCluster class]]) {
            TTTrafficDetailCluster *cluster = (TTTrafficDetailCluster *)self.results[indexPath.row];
            trafficCell.trafficImageView.image = [TTTrafficDetailImage createWithTraffic:cluster].medium;
            trafficCell.trafficDescription.text = @"Multiple incidents";
            trafficCell.trafficLength.text = [FormatUtils formatDistanceWithMeters:cluster.length];
        }
        cell = trafficCell;
    } else if ([self.results[indexPath.row] isKindOfClass:[TTPoiCategory class]]) {
        TTPoiCategory *category = (TTPoiCategory *)self.results[indexPath.row];
        if (category.children.count > 0) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        cell.textLabel.text = category.name;
    }
    return cell;
}

@end
