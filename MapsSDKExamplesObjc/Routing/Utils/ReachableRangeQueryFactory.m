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

#import "ReachableRangeQueryFactory.h"
#import <MapsSDKExamplesCommon/MapsSDKExamplesCommon-Swift.h>

@implementation ReachableRangeQueryFactory

- (TTReachableRangeQuery* _Nonnull)createReachableRangeQueryForElectric {
    TTSpeedConsumption consumption[1];
    consumption[0] = TTSpeedConsumptionMake(50, 6.3);
    
    TTReachableRangeQuery *query = [[[[[[[[[[[[[TTReachableRangeQueryBuilder createWithCenterLocation:[TTCoordinate AMSTERDAM]] withSpeedConsumptionInkWhPairs:consumption count:1]
                                                      withVehicleWeight:1600]
                                                     withCurrentChargeInkWh:43]
                                                    withMaxChargeInkWh:85]
                                                   withAuxiliaryPowerInkW:1.7]
                                                  withAccelerationEfficiency:0.33]
                                                 withDecelerationEfficiency:0.33]
                                                withUphillEfficiency:0.33]
                                               withDownhillEfficiency:0.33]
                                              withVehicleEngineType:TTOptionVehicleEngineTypeElectric]
                                             withEnergyBudgetInKWh:5]
                                            build];
    return query;
}

- (TTReachableRangeQuery* _Nonnull)createReachableRangeQueryForElectricLimitTo2Hours {
    TTSpeedConsumption consumption[1];
    consumption[0] = TTSpeedConsumptionMake(50, 6.3);
    
    TTReachableRangeQuery *query = [[[[[[[[[[[[[TTReachableRangeQueryBuilder createWithCenterLocation:[TTCoordinate AMSTERDAM]] withSpeedConsumptionInkWhPairs:consumption count:1]
                                              withVehicleWeight:1600]
                                             withCurrentChargeInkWh:43]
                                            withMaxChargeInkWh:85]
                                           withAuxiliaryPowerInkW:1.7]
                                          withAccelerationEfficiency:0.33]
                                         withDecelerationEfficiency:0.33]
                                        withUphillEfficiency:0.33]
                                       withDownhillEfficiency:0.33]
                                      withVehicleEngineType:TTOptionVehicleEngineTypeElectric]
                                     withTimeBudgetInSeconds:7200]
                                    build];
    return query;
}

- (TTReachableRangeQuery* _Nonnull)createReachableRangeQueryForCombustion {
    TTSpeedConsumption consumption[1];
    consumption[0] = TTSpeedConsumptionMake(50, 6.3);
    TTReachableRangeQuery *query = [[[[[[[[[[[[[TTReachableRangeQueryBuilder createWithCenterLocation:[TTCoordinate AMSTERDAM]] withSpeedConsumptionInLitersPairs:consumption count:1]
                                              withVehicleWeight:1600]
                                             withCurrentFuelInLiters:43]
                                            withFuelEnergyDensityInMJoulesPerLiter:34.2]
                                           withCurrentAuxiliaryPowerInLitersPerHour:1.7]
                                          withAccelerationEfficiency:0.33]
                                         withDecelerationEfficiency:0.33]
                                        withUphillEfficiency:0.33]
                                       withDownhillEfficiency:0.33]
                                      withVehicleEngineType:TTOptionVehicleEngineTypeCombustion]
                                     withFuelBudgetInLiters:5]
                                    build];
    return query;
}

@end
