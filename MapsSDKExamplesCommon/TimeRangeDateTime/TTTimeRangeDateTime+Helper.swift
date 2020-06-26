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
extension DateFormatter {
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

    static var displayMinutesFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.locale = Locale(identifier: "en_GB")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
}

extension Date {
    func days(since: Date) -> Int? {
        let calendar = Calendar.current

        let maybeDate1 = calendar.date(bySettingHour: 12, minute: 00, second: 00, of: calendar.startOfDay(for: self))
        let maybeDate2 = calendar.date(bySettingHour: 12, minute: 00, second: 00, of: calendar.startOfDay(for: since))

        guard let date1 = maybeDate1, let date2 = maybeDate2 else {
            return nil
        }
        let components = calendar.dateComponents([.day], from: date2, to: date1)
        return components.day ?? 0
    }
}

public extension TTOpeningHours {
    func dates(in range: TTTimeRange) -> String {
        guard let openDate = range.startTime.timeDate(), let closeDate = range.endTime.timeDate() else {
            return "OPEN: \(range.startTime.readableFormat()) CLOSE \(range.endTime.readableFormat())"
        }

        guard let days = closeDate.days(since: openDate) else {
            return "OPEN: \(range.startTime.readableFormat()) CLOSE \(range.endTime.readableFormat())"
        }
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()

        var result: [String] = []

        for index in 0 ... days - 1 {
            let nOpenDate = calendar.date(byAdding: .day, value: index, to: openDate) ?? Date()
            let weekday = calendar.component(.weekday, from: nOpenDate) - 1
            let weakDaySymbol = dateFormatter.weekdaySymbols[weekday]
            let openMin = DateFormatter.displayMinutesFormatter.string(from: openDate)
            let closeMin = DateFormatter.displayMinutesFormatter.string(from: closeDate)
            let readableName: String
            if openMin == closeMin {
                readableName = "\(weakDaySymbol) Open 24h"
            } else {
                readableName = "\(weakDaySymbol) \(openMin) - \(closeMin)"
            }
            result.append(readableName)
        }
        let joined = result.joined(separator: "\n")
        return joined
    }

    @objc func humanReadableHours() -> String {
        let result = timeRanges.map { (timeRange) -> String in
            dates(in: timeRange)

        }.joined(separator: "\n")
        return result
    }
}

public extension TTTimeRangeDateTime {
    func timeDate() -> Date? {
        let dateStr = date
        let m = minute
        let h = hour
        let str = "\(dateStr) \(h):\(m)"
        let maybeDate = DateFormatter.parseFormater.date(from: str)
        return maybeDate
    }

    @objc func readableFormat() -> String {
        guard let td = timeDate() else {
            return "-"
        }
        let result = DateFormatter.displayFormatter.string(from: td)
        return result
    }
}
