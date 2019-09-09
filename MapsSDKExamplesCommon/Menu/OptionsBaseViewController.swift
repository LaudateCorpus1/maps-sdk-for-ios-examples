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

public class OptionsBaseViewController: UICollectionViewController {
    public override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.barTintColor = TTColor.BlackLight()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = TTColor.White()

        setupRightButton()
    }

    func setupRightButton() {
        let customNavView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        let copyrightButton = UIButton(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        copyrightButton.setImage(UIImage(named: "info_icon"), for: UIControlState.normal)

        copyrightButton.addTarget(self, action: #selector(self.pressCopyrightButton), for: UIControlEvents.touchUpInside)
        customNavView.addSubview(copyrightButton)
        let rightBarButton = UIBarButtonItem(customView: customNavView)
        self.navigationItem.rightBarButtonItem = rightBarButton
    }

    @objc func pressCopyrightButton(_: UIButton) {
        let aboutViewController = AboutViewController()
        navigationController?.pushViewController(aboutViewController, animated: true)
    }
}
