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

@objc public protocol ExampleDisplayRequest: class {
    @objc func requestExample(index: Int, category: Options.Category)
}

class SubOptionsViewController: OptionsBaseViewController, UICollectionViewDelegateFlowLayout {
    let reuseIdentifier = "cell"
    var subOptionsArray: [SubOptions] = []
    var category: Options.Category!
    weak var exampleDelegate: ExampleDisplayRequest?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView?.backgroundColor = TTColor.Black()
        navigationItem.title = "TomTom Maps SDK"

        collectionView?.register(SubOptionsCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
    }

    override func viewWillTransition(to _: CGSize, with _: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }

    override func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return subOptionsArray.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! SubOptionsCollectionViewCell
        let subOption = self.subOptionsArray[indexPath.row]
        cell.iconImage.image = UIImage(named: subOption.iconImage, in: Bundle(for: OptionsViewController.self), compatibleWith: nil)
        cell.titleLabel.text = subOption.titleLabel
        cell.subtitleLabel.text = subOption.subtitleLabel
        return cell
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        let orientation = UIApplication.shared.statusBarOrientation
        let spaceLeftAndRight = TTCollectionViewCell.UIEdgeInsetRight + TTCollectionViewCell.UIEdgeInsetLeft

        if UIInterfaceOrientationIsPortrait(orientation) {
            return CGSize(width: (self.collectionView?.frame.width)! - spaceLeftAndRight, height: TTCollectionViewCell.HeightPortrait)
        } else {
            return CGSize(width: (self.collectionView?.frame.width)! - spaceLeftAndRight, height: TTCollectionViewCell.HeightLandscape)
        }
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, insetForSectionAt _: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: TTCollectionViewCell.UIEdgeInsetTop,
                            left: TTCollectionViewCell.UIEdgeInsetLeft,
                            bottom: TTCollectionViewCell.UIEdgeInsetBottom,
                            right: TTCollectionViewCell.UIEdgeInsetRight)
    }

    override func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        exampleDelegate?.requestExample(index: indexPath.row, category: category)
    }
}
