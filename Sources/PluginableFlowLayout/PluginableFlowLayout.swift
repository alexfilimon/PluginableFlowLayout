import UIKit

open class PluginableFlowLayoutAttributes: UICollectionViewLayoutAttributes {

    open var dictWithProperties: [String: AnyHashable] = [:]

    override open func copy(with zone: NSZone? = nil) -> Any {
        let copy = super.copy(with: zone) as? Self
        copy?.dictWithProperties = dictWithProperties
        return copy as Any
    }

    override open func isEqual(_ object: Any?) -> Bool {
        let attrs = object as? Self
        if attrs?.dictWithProperties != dictWithProperties {
            return false
        }
        return super.isEqual(object)
    }

}

public enum PluginableFlowLayoutAlignment {
    case lineStart, lineCenter, lineEnd
}

open class PluginableFlowLayout: UICollectionViewFlowLayout {

    // MARK: - Nested Types

    public typealias LayoutAttributes = PluginableFlowLayoutAttributes
    public typealias Alignment = PluginableFlowLayoutAlignment

    // MARK: - Private Properties

    private let alignment: Alignment?
    private let plugins: [FlowLayoutPlugin]

    // MARK: - Initialization

    public init(
        alignment: Alignment?, // TODO: support vertical
        plugins: [FlowLayoutPlugin]
    ) {
        self.alignment = alignment
        self.plugins = plugins
        super.init()
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented in \(#file)")
    }

    // MARK: - UICollectionViewFlowLayout Methods

    override open func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }

    override open class var layoutAttributesClass: AnyClass {
        return LayoutAttributes.self
    }

    override open func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return super.layoutAttributesForElements(in: rect)?
            .compactMap { $0 as? LayoutAttributes }
            .compactMap({ attributes in
                guard let collectionView = collectionView else { return nil }
                var mutableAttributes = attributes
                for plugin in plugins {
                    mutableAttributes = plugin.prepareAttributes(
                        mutableAttributes,
                        in: collectionView,
                        scrollDirection: scrollDirection,
                        alignment: alignment,
                        sectionInset: sectionInset
                    )
                }
                return mutableAttributes
            })
    }

    open override func targetContentOffset(
        forProposedContentOffset proposedContentOffset: CGPoint,
        withScrollingVelocity velocity: CGPoint
    ) -> CGPoint {
        guard
            let collectionView = collectionView,
            let alignment
        else {
            return super.targetContentOffset(
                forProposedContentOffset: proposedContentOffset,
                withScrollingVelocity: velocity
            )
        }
        let (prev, next) = getNearestCells(
            in: collectionView,
            proposedContentOffset: collectionView.contentOffset,
            alignment: alignment
        )
        guard
            let prev = prev,
            let next = next
        else {
            if let prev = prev {
                let prevContentOffset = getContentOffset(
                    in: collectionView,
                    layoutAttributes: prev,
                    alignment: alignment
                )
                return .init(
                    value: prevContentOffset,
                    oldPoint: proposedContentOffset,
                    scrollDirection: scrollDirection
                )
            }
            if let next = next {
                let nextContentOffset = getContentOffset(
                    in: collectionView,
                    layoutAttributes: next,
                    alignment: alignment
                )
                return .init(
                    value: nextContentOffset,
                    oldPoint: proposedContentOffset,
                    scrollDirection: scrollDirection
                )
            }
            return super.targetContentOffset(
                forProposedContentOffset: proposedContentOffset,
                withScrollingVelocity: velocity
            )
        }

        let nextDiff = abs(
            getDiff(
                in: collectionView,
                layoutAttributes: next,
                alignment: alignment
            )
        )
        let prevDiff = abs(
            getDiff(
                in: collectionView,
                layoutAttributes: prev,
                alignment: alignment
            )
        )
        let shouldShowNext = nextDiff < prevDiff
        let nextContentOffset = getContentOffset(
            in: collectionView,
            layoutAttributes: next,
            alignment: alignment
        )
        let prevContentOffset = getContentOffset(
            in: collectionView,
            layoutAttributes: prev,
            alignment: alignment
        )

        let velocityValue = velocity.value(scrollDirection: scrollDirection)
        let isFast = abs(velocityValue) > 0.3
        if isFast && velocityValue > 0 || !isFast && shouldShowNext {
            // next
            return .init(
                value: nextContentOffset,
                oldPoint: proposedContentOffset,
                scrollDirection: scrollDirection
            )
        } else {
            // prev
            return .init(
                value: prevContentOffset,
                oldPoint: proposedContentOffset,
                scrollDirection: scrollDirection
            )
        }
    }

    // MARK: - Private Properties

    private func getNearestCells(
        in collectionView: UICollectionView,
        proposedContentOffset: CGPoint,
        alignment: Alignment
    ) -> (prev: UICollectionViewLayoutAttributes?, next: UICollectionViewLayoutAttributes?) {
        var prev: UICollectionViewLayoutAttributes?
        var next: UICollectionViewLayoutAttributes?
        var prevMinDiff = CGFloat.greatestFiniteMagnitude
        var nextMinDiff = CGFloat.greatestFiniteMagnitude

        let targetRect = CGRect(origin: proposedContentOffset, size: collectionView.bounds.size)
        for layoutAttribute in layoutAttributesForElements(in: targetRect)! {
            let currentDiff = getDiff(
                in: collectionView,
                layoutAttributes: layoutAttribute,
                alignment: alignment
            )
            if currentDiff > 0 {
                if abs(currentDiff) < nextMinDiff {
                    nextMinDiff = abs(currentDiff)
                    next = layoutAttribute
                }
            } else {
                if abs(currentDiff) < prevMinDiff {
                    prevMinDiff = abs(currentDiff)
                    prev = layoutAttribute
                }
            }
        }

        return (prev: prev, next: next)
    }

    private func getDiff(
        in collectionView: UICollectionView,
        layoutAttributes: UICollectionViewLayoutAttributes,
        alignment: Alignment
    ) -> CGFloat {
        switch alignment {
        case .lineStart:
            let leftContentOffset = collectionView.contentOffset.value(scrollDirection: scrollDirection) + sectionInset.beforeValue(scrollDirection: scrollDirection)
            return layoutAttributes.frame.minValue(scrollDirection: scrollDirection) - leftContentOffset
        case .lineCenter:
            let middleContentOffset = collectionView.contentOffset.value(scrollDirection: scrollDirection) + collectionView.bounds.size.value(scrollDirection: scrollDirection) / 2
            return layoutAttributes.center.value(scrollDirection: scrollDirection) - middleContentOffset
        case .lineEnd:
            let rightContentOffset = collectionView.contentOffset.value(scrollDirection: scrollDirection) + collectionView.bounds.size.value(scrollDirection: scrollDirection) + sectionInset.afterValue(scrollDirection: scrollDirection)
            return layoutAttributes.frame.maxValue(scrollDirection: scrollDirection) - rightContentOffset
        }
    }

    private func getContentOffset(
        in collectionView: UICollectionView,
        layoutAttributes: UICollectionViewLayoutAttributes,
        alignment: Alignment
    ) -> CGFloat {
        switch alignment {
        case .lineStart:
            return layoutAttributes.frame.minValue(scrollDirection: scrollDirection) - sectionInset.beforeValue(scrollDirection: scrollDirection)
        case .lineCenter:
            return layoutAttributes.center.value(scrollDirection: scrollDirection) - collectionView.bounds.size.value(scrollDirection: scrollDirection) / 2
        case .lineEnd:
            return layoutAttributes.frame.maxValue(scrollDirection: scrollDirection) - collectionView.bounds.size.value(scrollDirection: scrollDirection) + sectionInset.afterValue(scrollDirection: scrollDirection)
        }
    }

}

extension CGPoint {

    init(
        value: CGFloat,
        oldPoint: CGPoint,
        scrollDirection: UICollectionView.ScrollDirection
    ) {
        switch scrollDirection {
        case .vertical:
            self.init(x: oldPoint.x, y: value)
        case .horizontal:
            self.init(x: value, y: oldPoint.y)
        @unknown default:
            self.init(x: oldPoint.x, y: oldPoint.y)
        }
    }

}
