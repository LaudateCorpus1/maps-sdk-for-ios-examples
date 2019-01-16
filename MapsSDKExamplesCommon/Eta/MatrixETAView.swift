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
import TomTomOnlineSDKRouting

public class MatrixETAView: UITableView, UITableViewDataSource, UITableViewDelegate {
    
    private static let ROW_HEIGHT: CGFloat = 24
    private static let REUSABLE_ID = "REUSABLE_ID"
    private static let ONE_TO_MANY_COLUMN_NAMES = ["Route", "Origin", "Destination", "Distance", "ETA"]
    private static let MANY_TO_MANY_COLUMN_NAMES = ["Route", "Passenger", "Taxi", "Distance", "Pick up"]
    private static let ONE_ORIGIN = "Amsterdam"
    private static let ONE_DESTINATIONS = ["LaRive", "Wagamama", "Greetje", "Envy", "Bridges"]
    private static let MANY_PASSENGER = ["One", "Two", "Two", "One"]
    private static let TAXI = ["A", "B", "A", "B"]
    private var currentSecondColumn = Array<String>()
    private var currentThirdColumn = Array<String>()
    private var results: Dictionary<TTMatrixRoutingResultKey, TTMatrixRouteResult>?
    
    public override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        backgroundColor = UIColor.clear
        isScrollEnabled = false
        rowHeight = MatrixETAView.ROW_HEIGHT
        dataSource = self
        delegate = self
    }

    @objc public func displayETAOneToMany(matrix: TTMatrixRouteResponse) {
        results = matrix.results
        currentSecondColumn = Array<String>.init(repeating: MatrixETAView.ONE_ORIGIN, count: 5)
        currentThirdColumn = MatrixETAView.ONE_DESTINATIONS
        insertHeaderView(columns: MatrixETAView.ONE_TO_MANY_COLUMN_NAMES)
        reloadData()
    }
    
    @objc public func displayETAManyToMany(matrix: TTMatrixRouteResponse) {
        results = matrix.results
        currentSecondColumn = MatrixETAView.MANY_PASSENGER
        currentThirdColumn = MatrixETAView.TAXI
        insertHeaderView(columns: MatrixETAView.MANY_TO_MANY_COLUMN_NAMES)
        reloadData()
    }
    
    private func insertHeaderView(columns:[String]) {
        let matrixHeaderView = MatrixRow(style: .default, reuseIdentifier: nil)
        matrixHeaderView.backgroundColor = TTColor.GreenDark()
        matrixHeaderView.update(columns: columns)
        tableHeaderView = matrixHeaderView
        tableHeaderView?.frame = CGRect(x: 0, y: 0, width: 0, height: MatrixETAView.ROW_HEIGHT)
        separatorStyle = .none
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let results = self.results else {
            return 0
        }
        return results.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let matrixRow = MatrixRow(style: .default, reuseIdentifier: MatrixETAView.REUSABLE_ID)
        guard let results = self.results else {
            return matrixRow
        }
        let matrixResults = Array(results.values)
        let length = matrixResults[indexPath.row].summary!.lengthInMetersValue
        let eta = matrixResults[indexPath.row].summary!.arrivalTime
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm"
        matrixRow.label_1.text = "\(indexPath.row+1)"
        matrixRow.label_2.text = currentSecondColumn[indexPath.row]
        matrixRow.label_3.text = currentThirdColumn[indexPath.row]
        matrixRow.label_4.text = FormatUtils.formatDistance(meters: UInt(length))
        matrixRow.label_5.text = dateFormatter.string(from: eta)
        return matrixRow
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        deselectRow(at: indexPath, animated: false)
    }
    
}
