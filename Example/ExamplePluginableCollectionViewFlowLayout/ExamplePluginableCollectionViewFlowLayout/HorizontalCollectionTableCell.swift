import UIKit
import PluginableFlowLayout

class HorizontalCollectionCell: UICollectionViewCell {

    private let contentWrapperView = UIView()
    private let imageView = UIImageView()
    private let bottomGradientView = GradientView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let button = UIButton(type: .custom)
    private var bottomConstraint: NSLayoutConstraint!

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func commonInit() {
        contentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])

        contentView.addSubview(bottomGradientView)
        bottomGradientView.translatesAutoresizingMaskIntoConstraints = false
        bottomGradientView.gradientLayer.locations = [0.7, 1]
        bottomGradientView.gradientLayer.startPoint = .init(x: 0, y: 1)
        bottomGradientView.gradientLayer.endPoint = .init(x: 0, y: 0)
        bottomGradientView.gradientLayer.colors = [UIColor.black.cgColor, UIColor.clear.cgColor]
        bottomGradientView.gradientLayer.opacity = 0.5
        NSLayoutConstraint.activate([
            bottomGradientView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bottomGradientView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bottomGradientView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])

        contentView.addSubview(contentWrapperView)
        contentWrapperView.translatesAutoresizingMaskIntoConstraints = false
        bottomConstraint = contentWrapperView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        NSLayoutConstraint.activate([
            contentWrapperView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            contentWrapperView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            contentWrapperView.topAnchor.constraint(equalTo: contentView.topAnchor),
            bottomConstraint
        ])

        contentWrapperView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: bottomGradientView.topAnchor, constant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: contentWrapperView.leadingAnchor, constant: 30),
            titleLabel.trailingAnchor.constraint(equalTo: contentWrapperView.trailingAnchor, constant: -30)
        ])
        titleLabel.font = .systemFont(ofSize: 34, weight: .semibold).rounded()
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 2
        titleLabel.textAlignment = .center

        contentWrapperView.addSubview(descriptionLabel)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentWrapperView.leadingAnchor, constant: 30),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentWrapperView.trailingAnchor, constant: -30),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentWrapperView.bottomAnchor),
        ])
        descriptionLabel.font = .systemFont(ofSize: 18)
        descriptionLabel.textColor = .white.withAlphaComponent(0.7)
        descriptionLabel.numberOfLines = 3
        descriptionLabel.textAlignment = .center

        contentView.clipsToBounds = true
    }

    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        guard let pluginableAttributes = layoutAttributes as? PluginableFlowLayoutAttributes else {
            return super.apply(layoutAttributes)
        }

        let percentage = pluginableAttributes.percentageInfo.collectionVisibility ?? 0

        let translationX = -percentage / 2 * imageView.bounds.width
        print("$ percentage: \(translationX)")
        imageView.transform = .init(
            translationX: translationX,
            y: 0
        )

        contentWrapperView.alpha = 1 - abs(percentage * 2)
    }

    func configure(banner: BannerViewModel, safeArea: UIEdgeInsets) {
        let image = UIImage(data: try! Data(contentsOf: Bundle.main.url(forResource: banner.imageName, withExtension: banner.imageExtension)!))
        imageView.image = image

        titleLabel.text = banner.title
        descriptionLabel.text = banner.description

        bottomConstraint.constant = -safeArea.bottom
    }

}

class HorizontalCollectionTableCell: UITableViewCell {

    private let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: PluginableFlowLayout(
            alignment: .lineStart,
            plugins: [PercentageFlowLayoutPlugin()]
        )
    )
    private var banners: [BannerViewModel] = []
    private var safeArea: UIEdgeInsets = .zero
    private let pageControl = UIPageControl()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    func commonInit() {
        contentView.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        let bottomConstraint = collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        bottomConstraint.priority = .init(999)
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            bottomConstraint,
            collectionView.heightAnchor.constraint(equalToConstant: 500)
        ])
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(HorizontalCollectionCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.isPagingEnabled = false
        collectionView.decelerationRate = .fast
        collectionView.showsHorizontalScrollIndicator = false
        let flowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.scrollDirection = .horizontal

        contentView.addSubview(pageControl)
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6)
        ])
    }

    func configure(banners: [BannerViewModel], safeArea: UIEdgeInsets) {
        self.banners = banners
        self.safeArea = safeArea
        pageControl.numberOfPages = banners.count
        collectionView.reloadData()
        DispatchQueue.main.async {
            self.collectionView.scrollToItem(
                at: IndexPath(item: 5000, section: 0),
                at: .centeredHorizontally,
                animated: false
            )
        }
    }

}

extension HorizontalCollectionTableCell: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return .init(
            width: collectionView.bounds.width,
            height: 500
        )
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 0
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 0
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offSet = scrollView.contentOffset.x
        let width = scrollView.frame.width
        let horizontalCenter = width / 2

        pageControl.currentPage = (Int(offSet + horizontalCenter) / Int(width)) % banners.count
    }

}

extension HorizontalCollectionTableCell: UICollectionViewDataSource {

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return 10000
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! HorizontalCollectionCell

        cell.configure(banner: banners[indexPath.row % banners.count], safeArea: .init(
            top: safeArea.top,
            left: 0,
            bottom: 45,
            right: 0
        ))

        return cell
    }

}

class HorizontalCollectionController: UITableViewController {

    private let banners: [BannerViewModel] = [
        .init(
            imageName: "1",
            imageExtension: "jpg",
            title: "Toronto",
            description: "The largest city in Canada"
        ),
        .init(
            imageName: "2",
            imageExtension: "jpg",
            title: "Italy",
            description: "Walk around streets"
        ),
        .init(
            imageName: "3",
            imageExtension: "jpg",
            title: "New-York",
            description: "Beautiful place to visit"
        ),
        .init(
            imageName: "4",
            imageExtension: "jpg",
            title: "New-York",
            description: "Beautiful place to visit"
        ),
        .init(
            imageName: "5",
            imageExtension: "jpg",
            title: "Toronto",
            description: "The largest city in Canada"
        ),
        .init(
            imageName: "6",
            imageExtension: "jpg",
            title: "Golden Gate",
            description: "Bridge in San-Francisco"
        )
    ]
    private let horizontalCell = HorizontalCollectionTableCell(style: .default, reuseIdentifier: nil)

    override func viewDidLoad() {
        super.viewDidLoad()

        horizontalCell.configure(
            banners: banners,
            safeArea: UIApplication.shared.windows.first?.safeAreaInsets ?? .zero
        )
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.separatorStyle = .none
    }

}

extension HorizontalCollectionController {

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return horizontalCell
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

}

extension UIFont {
    func rounded() -> UIFont {
        guard let descriptor = fontDescriptor.withDesign(.rounded) else {
            return self
        }

        return UIFont(descriptor: descriptor, size: pointSize)
    }
}
