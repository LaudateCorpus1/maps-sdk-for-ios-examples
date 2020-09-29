//
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

class ImageScroller: UIView {
    var images: [UIImage] = [] {
        didSet {
            self.loadImages(images: images)
        }
    }

    func loadImages(images: [UIImage]) {
        images.enumerated().forEach { it in
            let imageViewFrame = CGRect(x: frame.width * CGFloat(it.offset),
                                        y: 0,
                                        width: frame.width,
                                        height: frame.height)

            let imageView = UIImageView(frame: imageViewFrame)
            imageView.image = it.element
            scrollView.addSubview(imageView)
        }
    }

    lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isPagingEnabled = true
        return view
    }()

    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.subviews.compactMap { $0 as? UIImageView }.forEach { $0.removeFromSuperview() }
        loadImages(images: images)
        scrollView.contentSize = CGSize(width: frame.size.width * CGFloat(images.count), height: frame.height)
    }

    init() {
        super.init(frame: .zero)
        isUserInteractionEnabled = true
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(scrollView)
        scrollView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        scrollView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        scrollView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
