import UIKit
import PluginableFlowLayout

class GradientView: UIView {
    let gradientLayer = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)

        layer.addSublayer(gradientLayer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        gradientLayer.frame = layer.bounds
    }
}

class BannerCell: UICollectionViewCell {

    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let debugLabel = UILabel()
    private let dimmView = UIView()

    private let topGradientView = GradientView()
    private let bottomGradientView = GradientView()

    private var debugTopConstraint: NSLayoutConstraint!
    private var titleBottomConstraint: NSLayoutConstraint!

    override init(frame: CGRect) {
        super.init(frame: frame)

        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    func commonInit() {
        contentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        imageView.contentMode = .scaleAspectFill

        contentView.addSubview(dimmView)
        dimmView.translatesAutoresizingMaskIntoConstraints = false
        dimmView.backgroundColor = .black
        NSLayoutConstraint.activate([
            dimmView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            dimmView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            dimmView.topAnchor.constraint(equalTo: contentView.topAnchor),
            dimmView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])

        contentView.addSubview(bottomGradientView)
        bottomGradientView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bottomGradientView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bottomGradientView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bottomGradientView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        bottomGradientView.gradientLayer.colors = [UIColor.black.cgColor, UIColor.clear.cgColor]
        bottomGradientView.gradientLayer.opacity = 0.6
        bottomGradientView.gradientLayer.startPoint = .init(x: 0, y: 1)
        bottomGradientView.gradientLayer.endPoint = .init(x: 0, y: 0)
        bottomGradientView.gradientLayer.locations = [0.5, 1]

        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleBottomConstraint = titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            titleBottomConstraint,
            titleLabel.topAnchor.constraint(equalTo: bottomGradientView.topAnchor, constant: 40)
        ])
        titleLabel.font = .systemFont(ofSize: 24, weight: .semibold)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 0

        contentView.addSubview(topGradientView)
        topGradientView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topGradientView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            topGradientView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            topGradientView.topAnchor.constraint(equalTo: contentView.topAnchor)
        ])
        topGradientView.gradientLayer.colors = [UIColor.black.cgColor, UIColor.clear.cgColor]
        topGradientView.gradientLayer.opacity = 0.4
        topGradientView.gradientLayer.startPoint = .init(x: 0, y: 0)
        topGradientView.gradientLayer.endPoint = .init(x: 0, y: 1)
        topGradientView.gradientLayer.locations = [0.6, 1]

        contentView.addSubview(debugLabel)
        debugLabel.translatesAutoresizingMaskIntoConstraints = false
        debugTopConstraint = debugLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10)
        NSLayoutConstraint.activate([
            debugLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            debugTopConstraint,
            debugLabel.bottomAnchor.constraint(equalTo: topGradientView.bottomAnchor, constant: -80)
        ])
        debugLabel.font = .systemFont(ofSize: 14)
        debugLabel.textAlignment = .left
        debugLabel.textColor = .white
        debugLabel.numberOfLines = 0

        contentView.backgroundColor = .systemGray3
        contentView.clipsToBounds = true
    }

    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)

        guard
            let pluginableLayoutAttributes = layoutAttributes as? PluginableFlowLayoutAttributes
        else { return }

        let collectionVisibility = pluginableLayoutAttributes.percentageInfo.collectionVisibility
        let idealFrameVisibility = pluginableLayoutAttributes.percentageInfo.idealFrameVisibility
        let idealFrameAndCollectionVisibility = pluginableLayoutAttributes.percentageInfo.idealFrameAndCollectionVisibility

        debugLabel.text = """
        \(collectionVisibility?.roundedString() ?? "<none>")
        \(idealFrameVisibility?.roundedString() ?? "<none>")
        \(idealFrameAndCollectionVisibility?.roundedString() ?? "<none>")
        """
        imageView.transform = .init(translationX: -(idealFrameAndCollectionVisibility ?? 0) * contentView.bounds.width, y: 0)
        dimmView.alpha = abs(idealFrameVisibility ?? 0) / 2

        let titlePercentage = min(abs(idealFrameVisibility ?? 0) * 10, 1)
        titleLabel.alpha = 1 - titlePercentage

        bottomGradientView.alpha = 1 - abs(idealFrameAndCollectionVisibility ?? 0)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }

    func configure(
        banner: BannerViewModel,
        safeArea: UIEdgeInsets
    ) {
        let image = UIImage(data: try! Data(contentsOf: Bundle.main.url(forResource: banner.imageName, withExtension: banner.imageExtension)!))
        imageView.image = image
        titleLabel.text = banner.title
        debugTopConstraint.constant = safeArea.top + 10
        titleBottomConstraint.constant = -safeArea.bottom - 10
    }

}

struct BannerViewModel {
    let imageName: String
    let imageExtension: String
    let title: String
}

class ViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    private let banners: [BannerViewModel] = [
        .init(
            imageName: "1",
            imageExtension: "jpg",
            title: "Toronto"
        ),
        .init(
            imageName: "2",
            imageExtension: "jpg",
            title: "Italy"
        ),
        .init(
            imageName: "3",
            imageExtension: "jpg",
            title: "New-York"
        ),
        .init(
            imageName: "4",
            imageExtension: "jpg",
            title: "New-York"
        ),
        .init(
            imageName: "5",
            imageExtension: "jpg",
            title: "Toronto"
        ),
        .init(
            imageName: "6",
            imageExtension: "jpg",
            title: "Golden Gate"
        )
    ]

    init() {
        super.init(
            collectionViewLayout: PluginableFlowLayout(
                alignment: .lineCenter,
                plugins: [
                    PercentageFlowLayoutPlugin()
                ]
            )
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()


        let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout
        flowLayout?.scrollDirection = .horizontal

        collectionView.register(BannerCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.decelerationRate = .fast
    }

    override func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return banners.count
    }

    override func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! BannerCell

        cell.configure(
            banner: banners[indexPath.row],
            safeArea: UIApplication.shared.windows.first?.safeAreaInsets ?? .zero
        )

        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return .init(
            width: 200,
            height: collectionView.bounds.height
        )
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return .init(
            top: 0,
            left: (collectionView.bounds.width - 200) / 2,
            bottom: 0,
            right: (collectionView.bounds.width - 200) / 2
        )
    }

}

extension CGFloat {
    func roundedString() -> String {
        let rounded = CGFloat(Int(self * 100)) / CGFloat(100)
        return "\(rounded)"
    }
}

