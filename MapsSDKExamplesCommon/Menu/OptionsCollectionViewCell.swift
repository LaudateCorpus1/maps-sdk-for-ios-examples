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

class OptionsCollectionViewCell: UICollectionViewCell {
    
    override init(frame: CGRect){
        super.init(frame: frame)
        setup()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.preservesSuperviewLayoutMargins = false
        self.layoutMargins = .zero
    }
    
    func setup(){
        self.backgroundColor = TTColor.White()
        self.addSubview(mainImage)
        self.setupLayoutForImg()
        self.addSubview(iconImage)
        self.setupLayoutIcon()
        self.addSubview(titleLabel)
        self.setupLabelLayout()
        self.addSubview(goIntoButton)
        self.setUpLayoutButton()
        self.addSubview(subtitleLabel)
        self.setupTextLabelLayout()

    }
    var mainImage: UIImageView = {
       let iv = UIImageView()
        iv.contentMode = .scaleToFill
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 10
        iv.layer.masksToBounds = true
        
        return iv
    }()
    
    var iconImage: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleToFill
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 10
        iv.layer.masksToBounds = true
        
        return iv
    }()
    
    let goIntoButton:UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "Combined-Shape-Hilight"), for: UIControlState.normal)
        button.setImage(UIImage(named: "Combined-Shape"), for: UIControlState.highlighted)
        button.addTarget(self, action: #selector(pressButton(_:)), for: .touchUpInside)
        
        return button
    }()
    
    @objc func pressButton(_ button: UIButton) {
        print("Button with tag: \(button.tag) clicked!")
    }
    
    
    func setupLabelLayout(){
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.text = titleLabel.text?.uppercased()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.leftAnchor.constraint(equalTo: self.iconImage.leftAnchor, constant: 50).isActive = true
        titleLabel.topAnchor.constraint(equalTo: self.iconImage.topAnchor, constant: 10).isActive = true
    }
    
    func setupLayoutIcon(){
        iconImage.translatesAutoresizingMaskIntoConstraints = false
        iconImage.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10).isActive = true
        iconImage.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        iconImage.heightAnchor.constraint(equalToConstant: 40).isActive = true
        iconImage.widthAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    func setupLayoutForImg(){
        mainImage.translatesAutoresizingMaskIntoConstraints = false
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[v0]-0-|", options: [], metrics: nil, views: ["v0": mainImage]))
        mainImage.bottomAnchor.constraint(equalTo:self.bottomAnchor, constant: 0).isActive = true
        mainImage.heightAnchor.constraint(equalToConstant: 150).isActive = true
    }
    
    func setUpLayoutButton(){
        goIntoButton.translatesAutoresizingMaskIntoConstraints = false
        goIntoButton.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -9).isActive = true
        goIntoButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 19).isActive = true
        goIntoButton.heightAnchor.constraint(equalToConstant: 15).isActive = true
        goIntoButton.widthAnchor.constraint(equalToConstant: 10).isActive = true
    }
    
    func setupTextLabelLayout(){
        
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[v0]-15-|", options: [], metrics: nil, views: ["v0": subtitleLabel]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-25-[v1]-0-[v0]|", options: [], metrics: nil, views: ["v0": mainImage,
                                                                                                                                "v1": subtitleLabel]))
    }
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Map"
        label.textColor = TTColor.Black()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textAlignment = .left
        label.numberOfLines = 3
        return label
    }()
    
    let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Show map visualization in your app using vector tiles, raster tiles, traffic incidents and/or traffic flow"
        label.textColor = TTColor.Black()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textAlignment = .left
        label.numberOfLines = 3
        return label
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has been implement")
    }
    
    
    
}
