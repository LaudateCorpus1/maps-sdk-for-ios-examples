//
/**
 * Copyright (c) 2020 TomTom N.V. All rights reserved.
 *
 * This software is the proprietary copyright of TomTom N.V. and its subsidiaries and may be used
 * for internal evaluation purposes or commercial use strictly subject to separate licensee
 * agreement between you and TomTom. If you are the licensee, you are only permitted to use
 * this Software in accordance with the terms of your license agreement. If you are not the
 * licensee then you are not authorised to use this software in any manner and should
 * immediately return it to TomTom N.V.
 */

import UIKit

@objc public protocol AutoCompleteBarModel {
    @objc var title: String { get }
    @objc var subTitle: String { get }
}

@objc public protocol AutoCompleteBarDelegate: class {
    func autoCompleteBar(bar: AutoCompleteBar, textDidChange text: String)
    func autoCompleteBar(bar: AutoCompleteBar, didSelect item: AutoCompleteBarModel, withText text: String)
    func autoCompleteBarCancelButtonClicked(bar: AutoCompleteBar)
}

public class AutoCompleteBar: UIView {
    fileprivate static var REUSE_ID = "bar_cell_reuseId"

    @objc public weak var delegate: AutoCompleteBarDelegate?

    @objc public var data: [AutoCompleteBarModel] = [] {
        didSet {
            reload()
        }
    }

    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.barStyle = .default
        searchBar.tintColor = TTColor.GreenLight()
        searchBar.backgroundColor = TTColor.White()
        searchBar.barTintColor = TTColor.White()
        searchBar.delegate = self
        return searchBar
    }()

    private lazy var tblView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()

    private var heightConstraint: NSLayoutConstraint?

    public init() {
        super.init(frame: .zero)
        backgroundColor = .gray
        translatesAutoresizingMaskIntoConstraints = false
        isUserInteractionEnabled = true
        addSubview(searchBar)
        searchBar.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        searchBar.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        searchBar.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
        searchBar.heightAnchor.constraint(equalToConstant: 50).isActive = true
        heightConstraint = heightAnchor.constraint(equalToConstant: 50)
        heightConstraint?.isActive = true
        addSubview(tblView)
        tblView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 0).isActive = true
        tblView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        tblView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
        tblView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
    }

    private func calculateHeight() -> CGFloat {
        var height: CGFloat = 50
        height = height + CGFloat(data.count) * 45
        print("height: \(height) datacount: \(data.count)")
        return min(400, height)
    }

    private func reload() {
        let height = calculateHeight()
        self.tblView.reloadData()

        UIView.animate(withDuration: 0.3) {
            self.heightConstraint?.constant = height
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension AutoCompleteBar: UITableViewDataSource, UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = data[indexPath.row]
        delegate?.autoCompleteBar(bar: self, didSelect: item, withText: searchBar.text ?? "")
    }

    public func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 45
    }

    private func decorate(cell: UITableViewCell, indexPath: IndexPath) {
        let model = data[indexPath.row]

        let titleAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.black,
                                                              .font: UIFont.boldSystemFont(ofSize: 15)]

        let subTitleAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.lightGray,
                                                                 .font: UIFont.boldSystemFont(ofSize: 10)]

        let title = model.title
        let subTitle = model.subTitle

        let attribiutedText = NSMutableAttributedString(string: title,
                                                        attributes: titleAttributes)
        attribiutedText.append(.init(string: "  "))
        attribiutedText.append(.init(string: subTitle, attributes: subTitleAttributes))

        cell.textLabel?.attributedText = attribiutedText
    }

    public func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    public func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return data.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseId = AutoCompleteBar.REUSE_ID
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseId) ?? UITableViewCell(style: .default, reuseIdentifier: reuseId)
        decorate(cell: cell, indexPath: indexPath)
        return cell
    }
}

extension AutoCompleteBar: UISearchBarDelegate {
    public func searchBarCancelButtonClicked(_: UISearchBar) {
        delegate?.autoCompleteBarCancelButtonClicked(bar: self)
    }

    public func searchBarTextDidBeginEditing(_: UISearchBar) {}

    public func searchBar(_: UISearchBar, textDidChange searchText: String) {
        print("search text: \(searchText)")
        delegate?.autoCompleteBar(bar: self, textDidChange: searchText)
    }
}
