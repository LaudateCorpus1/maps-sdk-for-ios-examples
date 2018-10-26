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

class SubOptionsCollectionViewCell: UICollectionViewCell {

    override init(frame: CGRect){
        super.init(frame: frame)
        setup()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has been implement")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //self.separatorInset = .zero
        self.preservesSuperviewLayoutMargins = false
        self.layoutMargins = .zero
    }
    
    func setup(){
        self.backgroundColor = TTColor.White()
        addSubview(iconImage)
        setupLayoutForImg()
        self.addSubview(goIntoButton)
        self.setUpLayoutButton()
        self.addSubview(titleLabel)
        self.setupLabelLayout()
        self.addSubview(subtitleLabel)
        self.setupLayoutSubTitle()
        
    }
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Map tiles"
        label.textColor = TTColor.GrayLight()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textAlignment = .left
        label.numberOfLines = 2
        return label
    }()
    
    func setupLabelLayout(){
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0]-7-[v1]-2-[v2]-10-|", options: [], metrics: nil, views: ["v0": iconImage,
                                                                                                                                  "v1": titleLabel,
                                                                                                                                  "v2": goIntoButton]))
        titleLabel.topAnchor.constraint(equalTo: self.iconImage.topAnchor, constant: 10).isActive = true
    }
    
    
    let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Show map visualization in your app using vector tiles, raster tiles, traffic"
        label.textColor = TTColor.GrayLight()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textAlignment = .left
        label.numberOfLines = 3
        return label
    }()
    
    func setupLayoutSubTitle(){
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 10).isActive = true
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v1]-7-[v0]-15-|", options: [], metrics: nil, views: ["v0": subtitleLabel,
                                                                                                                                   "v1": iconImage]))
    }
    
    let iconImage:UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "map_image")
        iv.contentMode = .scaleToFill
        iv.contentMode = .scaleAspectFill
        iv.layer.masksToBounds = true
        
        return iv
    }()
    
    func setupLayoutForImg(){
        iconImage.translatesAutoresizingMaskIntoConstraints = false
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[v0]-0-|", options: [], metrics: nil, views: ["v0": iconImage]))
        iconImage.bottomAnchor.constraint(equalTo:self.bottomAnchor, constant: 0).isActive = true
        iconImage.widthAnchor.constraint(equalToConstant: 150).isActive = true
    }
    
    let goIntoButton:UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "Combined-Shape-Hilight"), for: UIControlState.normal)
        button.setImage(UIImage(named: "Combined-Shape"), for: UIControlState.highlighted)
        button.addTarget(self, action: #selector(pressButton(_:)), for: .touchUpInside)
        
        return button
    }()
    
    func setUpLayoutButton(){
        goIntoButton.translatesAutoresizingMaskIntoConstraints = false
        goIntoButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 15).isActive = true
        goIntoButton.heightAnchor.constraint(equalToConstant: 15).isActive = true
        goIntoButton.widthAnchor.constraint(equalToConstant: 10).isActive = true
    }
    
    @objc func pressButton(_ button: UIButton) {
        print("Button with tag: \(button.tag) clicked!")
    }
    
}
