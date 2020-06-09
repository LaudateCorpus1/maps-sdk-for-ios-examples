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

@objc public protocol OptionsViewDelegate: class {
    func displayExample(ID: Int, on: Bool)
}

public class OptionsView: UIStackView {
    @objc public weak var delegate: OptionsViewDelegate?

    @objc public init(labels: [String], selectedID: Int) {
        super.init(frame: CGRect.zero)
        setup(labels: labels, selectedID: selectedID)
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup(labels: ["default"], selectedID: -1)
    }

    public required init(coder: NSCoder) {
        super.init(coder: coder)
        setup(labels: ["default"], selectedID: -1)
    }

    private func setup(labels: [String], selectedID: Int) {
        distribution = .fillEqually
        spacing = 10
        for i in 0 ..< labels.count {
            let label = labels[i]
            addButton(ID: i, title: label, isSelected: i == selectedID)
        }
    }

    private func addButton(ID: Int, title: String, isSelected: Bool) {
        let button = OptionButton()
        button.layer.cornerRadius = 20
        button.setTitleColor(TTColor.Black(), for: .normal)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = button.titleLabel?.font.withSize(13)
        addArrangedSubview(button)
        button.isSelected = isSelected
        button.tag = ID
        button.addTarget(self, action: #selector(buttonTouchUpInside(button:)), for: .touchUpInside)
    }

    @objc public func deselectAll() {
        for button in buttons {
            button.isSelected = false
        }
    }

    var buttons: [OptionButton] {
        var buttons: [OptionButton] = []
        for view in subviews {
            if let button = view as? OptionButton {
                buttons.append(button)
            }
        }
        return buttons
    }

    func selectAndTriggerDelegateFor(_ button: UIButton, selected: Bool) {
        button.isSelected = selected
        if let delegate = self.delegate {
            delegate.displayExample(ID: button.tag, on: selected)
        }
    }

    @objc func buttonTouchUpInside(button _: UIButton) {}
}
