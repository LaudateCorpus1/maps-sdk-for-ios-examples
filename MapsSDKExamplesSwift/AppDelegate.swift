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

import UIKit
import MapsSDKExamplesCommon
import MapsSDKExamplesVC

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, ExampleDisplayRequest {

    var window: UIWindow?
    var mainVC: OptionsViewController!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        
        let layout = UICollectionViewFlowLayout()
        let mainVC = OptionsViewController(collectionViewLayout: layout)
        self.mainVC = mainVC
        mainVC.exampleDelegate = self
        window?.rootViewController = UINavigationController(rootViewController: mainVC)
        return true
    }
    
    func requestExample(index: Int, category: Options.Category) {
        var newViewController: BaseViewController!
        if category == .Map {
            switch index {
            case 0:
                newViewController = MapTilesViewController()
            case 1:
                newViewController = MapVectorTrafficViewController()
            case 2:
                newViewController = MapRasterTrafficViewController()
            case 3:
                newViewController = MapLanguageViewController()
            case 4:
                newViewController = MapGeopoliticalViewController()
            case 5:
                newViewController = MapCustomStyleViewController()
            case 6:
                newViewController = MapStaticImageViewController()
            case 7:
                newViewController = MapCenteringViewController()
            case 8:
                newViewController = MapPerspectiveViewController()
            case 9:
                newViewController = MapEventsViewController()
            case 10:
                newViewController = MapUIExtensionsViewController()
            case 11:
                newViewController = MapMarkersViewController()
            case 12:
                newViewController = MapAdvancedMarkersViewController()
            case 13:
                newViewController = MapBallonsViewController()
            case 14:
                newViewController = MapShapesViewController()
            case 15:
                newViewController = MapMarkersClusteringViewController()
            case 16:
                newViewController = MapFollowTheChevronController()
            case 17:
                newViewController = MapMultipleViewController()
            default:
                fatalError("This VC is not handled")
            }
        } else if category == .Traffic {
            switch index {
            case 0:
                newViewController = TrafficIncidentsViewController()
            default:
                fatalError("This VC is not handled")
            }
        } else if category == .Routing {
            switch index {
            case 0:
                newViewController = RoutingTravelModesViewController()
            case 1:
                newViewController = RoutingRouteTypesViewController()
            case 2:
                newViewController = RoutingRouteAvoidsViewController()
            case 3:
                newViewController = RoutingRouteWithWaypointsViewController()
            case 4:
                newViewController = RoutingDepartureArrivalTimeViewController()
            case 5:
                newViewController = RoutingAlternativesRouteViewController()
            case 6:
                newViewController = RoutingManeuverListViewController()
            case 7:
                newViewController = RoutingConsumptionModelViewController()
            case 8:
                newViewController = RoutingSupportingPointsViewController()
            case 9:
                newViewController = RoutingReachableRangeViewController()
            case 10:
                newViewController = RoutingBatchRouteViewController()
            case 11:
                newViewController = RoutingMatrixViewController()
            default:
                fatalError("This VC is not handled")
            }
        } else if category == .Search {
            switch index {
            case 0:
                newViewController = SearchAddressViewController()
            case 1:
                newViewController = SearchCategoryViewController()
            case 2:
                newViewController = SearchLanguageSelectorViewController()
            case 3:
                newViewController = SearchTypeaheadParameterViewController()
            case 4:
                newViewController = SearchMaxFuzzinessLevelViewController()
            case 5:
                newViewController = SearchReverseGeocodingViewController()
            case 6:
                newViewController = SearchAlongTheRouteViewController()
            case 7:
                newViewController = SearchGeometryViewController()
            case 8:
                newViewController = SearchEntryPointsViewController()
            case 9:
                newViewController = SearchAdditionalDataViewController()
            case 10:
                newViewController = SearchBatchViewController()
            default:
                fatalError("This VC is not handled")
            }
        }
        newViewController.name = MenuLabels.titleFor(index: category.rawValue, subindex: index)
        mainVC.displayExample(newViewController)
    }

}
