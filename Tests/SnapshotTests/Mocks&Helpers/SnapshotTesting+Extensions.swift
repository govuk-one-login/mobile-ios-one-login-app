@testable import OneLogin
import SnapshotTesting
import UIKit

extension UIViewController {
    public func assertSnapshot(
        devices: [ViewImageConfig] = .standard,
        precision: Float = 0.995,
        perceptualPrecision: Float = 0.98,
        record recording: Bool? = nil,
        timeout: TimeInterval = 5,
        fileID: StaticString = #fileID,
        file filePath: StaticString = #filePath,
        testName: String = #function,
        line: UInt = #line,
        column: UInt = #column,
        traitCollections: [[UITraitCollection]] = allCombinationsOf(
            arrays: [
                UITraitCollection.testingDynamicTypeTraits,
                UITraitCollection.testingUserInterfaceStyle
            ]
        )
    ) {
        traitCollections.forEach {
            let traits = UITraitCollection(traitsFrom: $0)

            devices.forEach {
                SnapshotTesting.assertSnapshot(
                    of: self,
                    as: .image(
                        on: $0,
                        precision: precision,
                        perceptualPrecision: perceptualPrecision,
                        traits: traits
                    ),
                    record: recording,
                    timeout: timeout,
                    fileID: fileID,
                    file: filePath,
                    testName: testName,
                    line: line,
                    column: column
                )
            }
        }
    }
}

extension [ViewImageConfig] {
    public static let standard: [ViewImageConfig] = [
        .iPhone13(.portrait),
        .iPhone13(.landscape)
    ]
}

extension UITraitCollection {
    public static var testingDynamicTypeTraits: [UITraitCollection] {
        [
            UITraitCollection(preferredContentSizeCategory: .large),
            UITraitCollection(preferredContentSizeCategory: .accessibilityLarge),
            UITraitCollection(preferredContentSizeCategory: .accessibilityExtraExtraExtraLarge)
        ]
    }

    public static var testingUserInterfaceStyle: [UITraitCollection] {
        [
            UITraitCollection(userInterfaceStyle: .light),
            UITraitCollection(userInterfaceStyle: .dark)
        ]
    }
}

public func allCombinationsOf<T>(arrays: [[T]], partial: [T] = []) -> [[T]] {
    if arrays.isEmpty {
        return [partial]
    } else {
        var arrays = arrays
        let first = arrays.removeFirst()
        var result = [[T]]()

        for item in first {
            result += allCombinationsOf(arrays: arrays, partial: partial + [item])
        }

        return result
    }
}
