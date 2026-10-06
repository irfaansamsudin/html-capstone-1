import Foundation

extension Double {
    /// Money in the device's local currency, without cents (e.g. "RM 4,500,000").
    var asCurrency: String {
        formatted(.currency(code: Locale.current.currency?.identifier ?? "USD").precision(.fractionLength(0)))
    }

    /// 0.42 -> "42%"
    var asPercent: String {
        formatted(.percent.precision(.fractionLength(0)))
    }
}

extension Date {
    var shortDate: String {
        formatted(date: .abbreviated, time: .omitted)
    }
}
