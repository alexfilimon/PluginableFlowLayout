import UIKit

public protocol FlowLayoutPlugin {
    func prepareAttributes(
        _ attributes: PluginableFlowLayoutAttributes,
        in collectionView: UICollectionView,
        scrollDirection: UICollectionView.ScrollDirection,
        alignment: PluginableFlowLayoutAlignment?,
        sectionInset: UIEdgeInsets
    ) -> PluginableFlowLayoutAttributes
}

public extension FlowLayoutPlugin {

    func prepareAttributes(
        _ attributes: PluginableFlowLayoutAttributes,
        in collectionView: UICollectionView,
        scrollDirection: UICollectionView.ScrollDirection,
        alignment: PluginableFlowLayoutAlignment?,
        sectionInset: UIEdgeInsets
    ) -> PluginableFlowLayoutAttributes {
        return attributes
    }

}
