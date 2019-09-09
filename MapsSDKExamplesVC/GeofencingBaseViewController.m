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

#import "GeofencingBaseViewController.h"

@interface GeofencingBaseViewController ()

@end

@implementation GeofencingBaseViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  [self setupEtaView];
}

- (void)setupEtaView {
  ETAView *etaView = [ETAView new];
  [self.view addSubview:etaView];
  self.etaView = etaView;
  etaView.translatesAutoresizingMaskIntoConstraints = NO;
  [self.view
      addConstraints:[NSLayoutConstraint
                         constraintsWithVisualFormat:@"H:|-0-[v0]-0-|"
                                             options:0
                                             metrics:nil
                                               views:@{@"v0" : etaView}]];
  [self.view
      addConstraints:[NSLayoutConstraint
                         constraintsWithVisualFormat:@"V:|-0-[v0(50)]"
                                             options:0
                                             metrics:nil
                                               views:@{@"v0" : etaView}]];
}

- (void)drawAmsterdamPolygon {
  UIColor *color = [UIColor redColor];
  NSInteger pointsCount = 4;
  CLLocationCoordinate2D *coordinates = (CLLocationCoordinate2D *)malloc(
      pointsCount * sizeof(CLLocationCoordinate2D));
  coordinates[0] = [TTCoordinate AMSTERDAM_POLYGON_A];
  coordinates[1] = [TTCoordinate AMSTERDAM_POLYGON_B];
  coordinates[2] = [TTCoordinate AMSTERDAM_POLYGON_C];
  coordinates[3] = [TTCoordinate AMSTERDAM_POLYGON_D];

  TTPolygon *polygon = [TTPolygon polygonWithCoordinates:coordinates
                                                   count:pointsCount
                                                 opacity:0.5
                                                   color:color
                                            colorOutline:color];
  [self.mapView.annotationManager addOverlay:polygon];
  free(coordinates);
}

- (void)drawAmsterdamCircle:(CLLocationCoordinate2D)coordinate
                 withRadius:(double)radius {
  UIColor *color = [UIColor greenColor];
  TTCircle *circle = [TTCircle circleWithCenterCoordinate:coordinate
                                                   radius:radius
                                                  opacity:0.5
                                                    width:10
                                                    color:color
                                                     fill:YES
                                              colorOutlet:color];
  [self.mapView.annotationManager addOverlay:circle];
}

- (NSString *)createDescriptionWithInside:(NSArray<NSString *> *)inside
                              withOutside:(NSArray<NSString *> *)outside {
  __block NSString *text = @" The location is";
  if (inside.count > 0) {
    text = [NSString stringWithFormat:@"%@\n %@", text, @"inside of fences: "];
    [inside enumerateObjectsUsingBlock:^(NSString *name, NSUInteger idx,
                                         BOOL *_Nonnull stop) {
      if (idx > 0) {
        text = [NSString stringWithFormat:@"%@, \n \"%@\"", text, name];
      } else {
        text = [NSString stringWithFormat:@"%@ \"%@\"", text, name];
      }
    }];
  }
  if (outside.count > 0) {
    text = [NSString stringWithFormat:@"%@\n %@", text, @"outside of fences: "];
    [outside enumerateObjectsUsingBlock:^(NSString *name, NSUInteger idx,
                                          BOOL *_Nonnull stop) {
      if (idx > 0) {
        text = [NSString stringWithFormat:@"%@, \n \"%@\"", text, name];
      } else {
        text = [NSString stringWithFormat:@"%@ \"%@\"", text, name];
      }
    }];
  }
  return text;
}

- (UILabel *)labelForText:(NSString *)text {
  UILabel *label = [UILabel new];
  label.font = [UIFont systemFontOfSize:15.0];
  label.text = text;
  label.numberOfLines = 0;
  [label sizeToFit];
  return label;
}

@end
