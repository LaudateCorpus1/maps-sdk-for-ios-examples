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

public class OptionsViewController: OptionsBaseViewController, UICollectionViewDelegateFlowLayout {
    @objc public weak var exampleDelegate: ExampleDisplayRequest?
    private let reuseIdentifier = "cellID"

    public override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView?.backgroundColor = TTColor.BlackLight()
        navigationItem.title = "TomTom Maps SDK Examples"

        collectionView?.register(OptionsCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    }

    public override func viewWillTransition(to _: CGSize, with _: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }

    public override func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return MenuLabels.valueArray.count
    }

    public override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! OptionsCollectionViewCell

        let option = MenuLabels.valueArray[indexPath.row]
        cell.iconImage.image = UIImage(named: option.iconImage, in: Bundle(for: OptionsViewController.self), compatibleWith: nil)
        cell.mainImage.image = UIImage(named: option.mainImage, in: Bundle(for: OptionsViewController.self), compatibleWith: nil)
        cell.titleLabel.text = option.titleLabel
        cell.subtitleLabel.text = option.subtitleLabel

        return cell
    }

    public func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        let orientation = UIApplication.shared.statusBarOrientation
        let spaceLeftAndRight = TTCollectionViewCell.UIEdgeInsetRight + TTCollectionViewCell.UIEdgeInsetLeft

        if UIInterfaceOrientationIsPortrait(orientation) {
            return CGSize(width: (self.collectionView?.frame.width)! - spaceLeftAndRight, height: TTCollectionViewCell.OptionHeightPortrait)
        } else {
            return CGSize(width: (self.collectionView?.frame.width)! - spaceLeftAndRight, height: TTCollectionViewCell.OptionHeightLandscape)
        }
    }

    public func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, insetForSectionAt _: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: TTCollectionViewCell.UIEdgeInsetTop,
                            left: TTCollectionViewCell.UIEdgeInsetLeft,
                            bottom: TTCollectionViewCell.UIEdgeInsetBottom,
                            right: TTCollectionViewCell.UIEdgeInsetRight)
    }

    public override func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let layout = UICollectionViewFlowLayout()
        let nextVC = SubOptionsViewController(collectionViewLayout: layout)
        nextVC.exampleDelegate = exampleDelegate
        nextVC.subOptionsArray = MenuLabels.valueArray[indexPath.row].subOptions
        nextVC.category = MenuLabels.valueArray[indexPath.row].category
        navigationController?.pushViewController(nextVC, animated: true)
    }

    @objc public func displayExample(_ example: UIViewController) {
        navigationController?.pushViewController(example, animated: true)
    }
}
