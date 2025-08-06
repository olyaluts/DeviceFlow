import Foundation

extension String {
    func localized(comment: String? = nil) -> String {
        let _comment = comment != nil ? comment! : self
        return NSLocalizedString(self, comment: _comment)
    }
}
