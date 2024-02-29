import GDSCommon
import UIKit

public class UnlockScreenButton: UIButton {

    public var fontWeight: UIFont.Weight = .bold
    public var color: UIColor = .white
    public var fontSize: Double = 26.0
    public var symbolPosition: SymbolPosition = .afterTitle

    public init() {
        super.init(frame: .zero)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        titleLabel?.numberOfLines = 0
        titleLabel?.lineBreakMode = .byWordWrapping
        titleLabel?.adjustsFontForContentSizeCategory = true
        titleLabel?.font = UIFont(style: .body)
        titleLabel?.font = .systemFont(ofSize: fontSize, weight: fontWeight)
        titleLabel?.textColor = .white
        titleLabel?.tintColor = color

        if #available(iOS 14.0, *) {
            buttonBackground()
        }

        if #available(iOS 14.0, *) {
            NotificationCenter.default.addObserver(forName: Notification.Name( "buttonShapesEnabled"),
                                                   object: nil,
                                                   queue: nil) { _ in
                self.buttonBackground()
            }
        }

        NSLayoutConstraint.activate([
            self.heightAnchor.constraint(greaterThanOrEqualToConstant: 24),
            self.widthAnchor.constraint(greaterThanOrEqualToConstant: 24)
        ])
    }

    deinit {
        NotificationCenter.default.removeObserver(UIContentSizeCategory.didChangeNotification)
        NotificationCenter.default.removeObserver(Notification.Name( "buttonShapesEnabled"))
    }
}

extension UnlockScreenButton {

    @available(iOS 14.0, *)
    @objc public func buttonBackground() {
        if UIAccessibility.buttonShapesEnabled {
            backgroundColor = .secondarySystemBackground
            contentEdgeInsets = .init(top: 13, left: 8, bottom: 13, right: 8)
            titleLabel?.font = UIFont(style: .body, weight: fontWeight)
            layer.cornerRadius = 10
            layer.cornerCurve = .continuous
        } else {
            backgroundColor = .none
        }
    }
}
