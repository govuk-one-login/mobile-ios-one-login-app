import UIKit

extension UIView {
    private func findChildView(byAccessibilityIdentifier accessibilityIdentifier: String) -> UIView? {
        guard let match = subviews.first(where: { $0.accessibilityIdentifier == accessibilityIdentifier }) else {
            return subviews.lazy.compactMap {
                $0.findChildView(byAccessibilityIdentifier: accessibilityIdentifier)
            }.first
        }
        return match
    }
    
    subscript<T: UIView>(child identifier: String) -> T? {
        guard let child = findChildView(byAccessibilityIdentifier: identifier) as? T else {
            return nil
        }
        return child
    }
}
