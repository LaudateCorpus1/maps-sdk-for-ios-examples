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

import Foundation
import TomTomOnlineSDKSearch

public extension TTOpeningHours {
    @objc func humanReadableHours() -> String {
        let result = timeRanges.map { (timeRange) -> String in
            "OPEN: \(timeRange.startTime.readableFormat()) CLOSE \(timeRange.endTime.readableFormat())"
        }.joined(separator: "\n")
        return result
    }
}

public extension TTTimeRangeDateTime {
    static var parseFormater: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd H:m"
        formatter.locale = Locale(identifier: "en_GB")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()

    static var displayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        formatter.locale = Locale(identifier: "en_GB")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()

    func timeDate() -> Date? {
        let dateStr = date
        let m = minute
        let h = hour
        let str = "\(dateStr) \(h):\(m)"
        let maybeDate = TTTimeRangeDateTime.parseFormater.date(from: str)
        return maybeDate
    }

    @objc func readableFormat() -> String {
        guard let td = timeDate() else {
            return "-"
        }
        let result = TTTimeRangeDateTime.displayFormatter.string(from: td)
        return result
    }
}
