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


public class OptionsViewController: OptionsBaseViewController, UICollectionViewDelegateFlowLayout {
    
    @objc public weak var exampleDelegate: ExampleDisplayRequest?

    override public func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView?.backgroundColor = TTColor.BlackLight()
        navigationItem.title = "TomTom Maps SDK Examples"

        collectionView?.register(OptionsCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
    }

    override public func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout();
    }

    override public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return MenuLabels.valueArray.count
    }

    private let reuseIdentifier = "cell"
    override public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! OptionsCollectionViewCell

        let option = MenuLabels.valueArray[indexPath.row]
        cell.iconImage.image = UIImage(named: option.iconImage, in: Bundle(for: OptionsViewController.self), compatibleWith: nil)
        cell.mainImage.image = UIImage(named: option.mainImage, in: Bundle(for: OptionsViewController.self), compatibleWith: nil)
        cell.titleLabel.text = option.titleLabel
        cell.subtitleLabel.text = option.subtitleLabel
        
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let orientation = UIApplication.shared.statusBarOrientation
        let spaceLeftAndRight = TTCollectionViewCell.UIEdgeInsetRight + TTCollectionViewCell.UIEdgeInsetLeft

        if (UIInterfaceOrientationIsPortrait(orientation)) {
            return CGSize(width:(self.collectionView?.frame.width)! - spaceLeftAndRight, height: TTCollectionViewCell.OptionHeightPortrait);
        } else {
            return CGSize(width:(self.collectionView?.frame.width)! - spaceLeftAndRight, height: TTCollectionViewCell.OptionHeightLandscape);
        }
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: TTCollectionViewCell.UIEdgeInsetTop,
                            left: TTCollectionViewCell.UIEdgeInsetLeft,
                            bottom: TTCollectionViewCell.UIEdgeInsetBottom,
                            right: TTCollectionViewCell.UIEdgeInsetRight)
    }
    
    override public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
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
