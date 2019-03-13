/**
 * Copyright (c) 2019 TomTom N.V. All rights reserved.
 *
 * This software is the proprietary copyright of TomTom N.V. and its subsidiaries and may be used
 * for internal evaluation purposes or commercial use strictly subject to separate licensee
 * agreement between you and TomTom. If you are the licensee, you are only permitted to use
 * this Software in accordance with the terms of your license agreement. If you are not the
 * licensee then you are not authorised to use this software in any manner and should
 * immediately return it to TomTom N.V.
 */

import UIKit

class AboutViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    static let aboutDescription = """
    This Maps SDK Examples app is provided by TomTom and subject to TomToms privacy policy at https://tomtom.com/privacy.

    Developers using TomTom SDKs and APIs in their apps similarly bear responsibility to adhere to applicable privacy laws.

    These Maps SDK Examples are provided as-is and shall be used internally, and for evaluation purposes only. Any other use is strictly prohibited.
    """
    
    let elements = ["TomTomOnlineSDKMaps",
                    "TomTomOnlineSDKRouting",
                    "TomTomOnlineSDKSearch",
                    "TomTomOnlineSDKTraffic",
                    "TomTomOnlineSDKGeofencing",
                    "TomTomOnlineUtils"]
    
    private func version() -> String? {
        let number = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")
        let version = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String)
        if let number = number, let version = version {
            return "\(number) (\(version))"
        }
        return nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = TTColor.White()
        navigationItem.title = "TomTomOnlineSDK v\(version() ?? "")"
        
        view = UIView()
        view.backgroundColor = TTColor.White()
        
        let scrollView = UIScrollView()
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[sv]|", options: [], metrics: nil, views: ["sv": scrollView]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[sv]|", options: [], metrics: nil, views: ["sv": scrollView]))
        
        let container = UIView()
        scrollView.addSubview(container)
        container.translatesAutoresizingMaskIntoConstraints = false
        container.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        scrollView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[container]|", options: [], metrics: nil, views: ["container": container]))
        scrollView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[container]|", options: [], metrics: nil, views: ["container": container]))
        container.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 0)
        container.heightAnchor.constraint(equalToConstant: 660).isActive = true
        
        let textView = UITextView()
        textView.text = AboutViewController.aboutDescription
        textView.isEditable = false
        textView.dataDetectorTypes = .link
        textView.tintColor = TTColor.GrayLight()
        textView.font = textView.font?.withSize(14)
        container.addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        container.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[text]-10-|", options: [], metrics: nil, views: ["text": textView]))
        
        let tableView = UITableView()
        tableView.isScrollEnabled = false
        tableView.rowHeight = 50
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(tableView)
        container.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[table]-10-|", options: [], metrics: nil, views: ["table": tableView]))
        container.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[text(200)]-10-[table]-0-|", options: [], metrics: nil, views: ["text": textView, "table": tableView]))
    }
    
    //MARK: UITableViewDataSource, UITableViewDelegate
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Open Source"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return elements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = elements[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let resource = Bundle.main.resourcePath! + "/Frameworks/\(elements[indexPath.row]).framework/ATTRIBUTION.html"
        let licenseViewController = LicenseViewController()
        licenseViewController.resourceName = resource
        navigationController?.pushViewController(licenseViewController, animated: true)
    }
    
}
