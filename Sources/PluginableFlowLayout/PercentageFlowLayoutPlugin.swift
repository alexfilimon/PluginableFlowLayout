import UIKit

extension PluginableFlowLayoutAttributes {

    var collectionVisibility: CGFloat? {
        get {
            dictWithProperties[#fileID + "_" + #function] as? CGFloat
        }
        set {
            dictWithProperties[#fileID + "_" + #function] = newValue
        }
    }

    var idealFrameVisibility: CGFloat? {
        get {
            dictWithProperties[#fileID + "_" + #function] as? CGFloat
        }
        set {
            dictWithProperties[#fileID + "_" + #function] = newValue
        }
    }

    var idealFrameAndCollectionVisibility: CGFloat? {
        get {
            dictWithProperties[#fileID + "_" + #function] as? CGFloat
        }
        set {
            dictWithProperties[#fileID + "_" + #function] = newValue
        }
    }

    public var percentageInfo: PercentageInfo {
        .init(
            collectionVisibility: collectionVisibility,
            idealFrameVisibility: idealFrameVisibility,
            idealFrameAndCollectionVisibility: idealFrameAndCollectionVisibility
        )
    }

}

public struct PercentageInfo {
    public let collectionVisibility: CGFloat?
    public let idealFrameVisibility: CGFloat?
    public let idealFrameAndCollectionVisibility: CGFloat?
}

open class PercentageFlowLayoutPlugin: FlowLayoutPlugin {

    // MARK: - Nested Types

    private struct Context {
        let alignment: PluginableFlowLayoutAlignment?
        let collectionSizeValue: CGFloat
        let halfCollectionSizeValue: CGFloat
        let itemSizeValue: CGFloat
        let halfItemSizeValue: CGFloat
        let contentOffsetValue: CGFloat
        let itemMidValue: CGFloat
        let sectionInsetBeforeValue: CGFloat
        let sectionInsetAfterValue: CGFloat
    }

    // MARK: - Initialization

    public init() {}

    // MARK: - CollectionViewFlowLayoutPlugin

    open func prepareAttributes(
        _ attributes: PluginableFlowLayoutAttributes,
        in collectionView: UICollectionView,
        scrollDirection: UICollectionView.ScrollDirection,
        alignment: PluginableFlowLayoutAlignment?,
        sectionInset: UIEdgeInsets
    ) -> PluginableFlowLayoutAttributes {
        let collectionSizeValue = collectionView.bounds.size.value(scrollDirection: scrollDirection)
        let halfCollectionSizeValue = collectionSizeValue / 2
        let itemSizeValue = attributes.size.value(scrollDirection: scrollDirection)
        let halfItemSizeValue = itemSizeValue / 2
        let contentOffsetValue = collectionView.contentOffset.value(scrollDirection: scrollDirection)
        let itemMidValue = attributes.frame.midValue(scrollDirection: scrollDirection)
        let sectionInsetBeforeValue = sectionInset.beforeValue(scrollDirection: scrollDirection)
        let sectionInsetAfterValue = sectionInset.beforeValue(scrollDirection: scrollDirection)

        let context = Context(
            alignment: alignment,
            collectionSizeValue: collectionSizeValue,
            halfCollectionSizeValue: halfCollectionSizeValue,
            itemSizeValue: itemSizeValue,
            halfItemSizeValue: halfItemSizeValue,
            contentOffsetValue: contentOffsetValue,
            itemMidValue: itemMidValue,
            sectionInsetBeforeValue: sectionInsetBeforeValue,
            sectionInsetAfterValue: sectionInsetAfterValue
        )

        attributes.collectionVisibility = getCollectionVisibilityWithSign(
            context: context
        )
        attributes.idealFrameVisibility = getIdealFrameVisibilityWithSign(
            context: context
        )
        attributes.idealFrameAndCollectionVisibility = getIdealFrameAndCollectionVisibilityWithSign(
            context: context
        )

        return attributes
    }

    // MARK: - Private Properties

    private func getCollectionVisibilityWithSign(
        context: Context
    ) -> CGFloat {
        return getVisibilityWithSignFromDistances(
            idealBeforeDistance: context.itemSizeValue,
            idealAfterDistance: context.itemSizeValue,
            currentBeforeDistance: context.itemMidValue - (context.contentOffsetValue - context.halfItemSizeValue),
            currentAfterDistance: context.itemMidValue - (context.contentOffsetValue + context.collectionSizeValue + context.halfItemSizeValue)
        )
    }

    private func getValueWithSignNormalized(
        value: CGFloat,
        isPositive: Bool
    ) -> CGFloat {
        let sign: CGFloat = isPositive ? 1 : -1
        return sign * max(1 - min(abs(value), 1), 0)
    }

    private func getIdealFrameVisibilityWithSign(
        context: Context
    ) -> CGFloat {
        switch context.alignment {
        case .lineCenter, .none:
            return getVisibilityWithSignFromDistances(
                idealBeforeDistance: context.itemSizeValue,
                idealAfterDistance: context.itemSizeValue,
                currentBeforeDistance: context.itemMidValue - (context.contentOffsetValue + context.halfCollectionSizeValue - context.itemSizeValue),
                currentAfterDistance: context.itemMidValue - (context.contentOffsetValue + context.halfCollectionSizeValue + context.itemSizeValue)
            )
        case .lineStart:
            return getVisibilityWithSignFromDistances(
                idealBeforeDistance: context.itemSizeValue,
                idealAfterDistance: context.itemSizeValue,
                currentBeforeDistance: context.itemMidValue - (context.contentOffsetValue + context.sectionInsetBeforeValue - context.halfItemSizeValue),
                currentAfterDistance: context.itemMidValue - (context.contentOffsetValue + context.sectionInsetBeforeValue + context.halfItemSizeValue + context.itemSizeValue)
            )
        case .lineEnd:
            return getVisibilityWithSignFromDistances(
                idealBeforeDistance: context.itemSizeValue,
                idealAfterDistance: context.itemSizeValue,
                currentBeforeDistance: context.itemMidValue - (context.contentOffsetValue + context.collectionSizeValue - context.sectionInsetAfterValue - context.halfItemSizeValue - context.itemSizeValue),
                currentAfterDistance: context.itemMidValue - (context.contentOffsetValue + context.collectionSizeValue - context.sectionInsetAfterValue + context.halfItemSizeValue)
            )
        }
    }

    private func getIdealFrameAndCollectionVisibilityWithSign(
        context: Context
    ) -> CGFloat {
        switch context.alignment {
        case .lineCenter, .none:
            return getVisibilityWithSignFromDistances(
                idealBeforeDistance: context.halfCollectionSizeValue + context.halfItemSizeValue,
                idealAfterDistance: context.halfCollectionSizeValue + context.halfItemSizeValue,
                currentBeforeDistance: context.itemMidValue - (context.contentOffsetValue - context.halfItemSizeValue),
                currentAfterDistance: context.itemMidValue - (context.contentOffsetValue + context.collectionSizeValue + context.halfItemSizeValue)
            )
        case .lineStart:
            return getVisibilityWithSignFromDistances(
                idealBeforeDistance: context.itemSizeValue + context.sectionInsetBeforeValue,
                idealAfterDistance: context.halfItemSizeValue + (context.collectionSizeValue - context.halfItemSizeValue - context.sectionInsetBeforeValue),
                currentBeforeDistance: context.itemMidValue - (context.contentOffsetValue - context.halfItemSizeValue),
                currentAfterDistance: context.itemMidValue - (context.contentOffsetValue + context.collectionSizeValue + context.halfItemSizeValue)
            )
        case .lineEnd:
            return getVisibilityWithSignFromDistances(
                idealBeforeDistance: context.halfItemSizeValue + (context.collectionSizeValue - context.halfItemSizeValue - context.sectionInsetAfterValue),
                idealAfterDistance: context.itemSizeValue + context.sectionInsetAfterValue,
                currentBeforeDistance: context.itemMidValue - (context.contentOffsetValue - context.halfItemSizeValue),
                currentAfterDistance: context.itemMidValue - (context.contentOffsetValue + context.collectionSizeValue + context.halfItemSizeValue)
            )
        }
    }

    private func getVisibilityWithSignFromDistances(
        idealBeforeDistance: CGFloat,
        idealAfterDistance: CGFloat,
        currentBeforeDistance: CGFloat,
        currentAfterDistance: CGFloat
    ) -> CGFloat {
        let beforeVisibility = currentBeforeDistance / idealBeforeDistance
        let afterVisibility = currentAfterDistance / idealAfterDistance

        if abs(beforeVisibility) < abs(afterVisibility) {
            return getValueWithSignNormalized(
                value: max(beforeVisibility, 0),
                isPositive: false
            )
        } else {
            return getValueWithSignNormalized(
                value: min(afterVisibility, 0),
                isPositive: true
            )
        }
    }

}

// TODO: move to another file

extension CGRect {

    func minValue(
        scrollDirection: UICollectionView.ScrollDirection
    ) -> CGFloat {
        switch scrollDirection {
        case .vertical:
            return minY
        case .horizontal:
            return minX
        @unknown default:
            return 0
        }
    }

    func midValue(
        scrollDirection: UICollectionView.ScrollDirection
    ) -> CGFloat {
        switch scrollDirection {
        case .vertical:
            return midY
        case .horizontal:
            return midX
        @unknown default:
            return 0
        }
    }

    func maxValue(
        scrollDirection: UICollectionView.ScrollDirection
    ) -> CGFloat {
        switch scrollDirection {
        case .vertical:
            return maxY
        case .horizontal:
            return maxX
        @unknown default:
            return 0
        }
    }

}

extension CGSize {

    func value(
        scrollDirection: UICollectionView.ScrollDirection
    ) -> CGFloat {
        switch scrollDirection {
        case .vertical:
            return height
        case .horizontal:
            return width
        @unknown default:
            return 0
        }
    }

}

extension CGPoint {

    func value(
        scrollDirection: UICollectionView.ScrollDirection
    ) -> CGFloat {
        switch scrollDirection {
        case .vertical:
            return y
        case .horizontal:
            return x
        @unknown default:
            return 0
        }
    }

}

extension UIEdgeInsets {

    func beforeValue(
        scrollDirection: UICollectionView.ScrollDirection
    ) -> CGFloat {
        switch scrollDirection {
        case .vertical:
            return top
        case .horizontal:
            return left
        @unknown default:
            return 0
        }
    }

    func afterValue(
        scrollDirection: UICollectionView.ScrollDirection
    ) -> CGFloat {
        switch scrollDirection {
        case .vertical:
            return bottom
        case .horizontal:
            return right
        @unknown default:
            return 0
        }
    }

}
