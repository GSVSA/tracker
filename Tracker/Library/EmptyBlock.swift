import UIKit

final class EmptyBlock: UIView {
    private lazy var imageView: UIImageView = {
        let emptyImage = UIImageView(image: UIImage(named: "ListEmpty"))
        emptyImage.contentMode = .scaleAspectFit
        return emptyImage
    }()
    
    private lazy var labelView: UILabel = {
        let emptyLabel = UILabel()
        emptyLabel.textAlignment = .center
        emptyLabel.numberOfLines = 2
        emptyLabel.font = .systemFont(ofSize: 12, weight: .medium)
        emptyLabel.textColor = .Theme.contrast
        return emptyLabel
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [imageView, labelView])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .center
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setImage(_ image: UIImage?) {
        imageView.image = image
    }
    
    func setLabel(_ text: String) {
        labelView.text = text
    }
    
    override func didMoveToSuperview() {
        setupConstraints()
    }
    
    private func setupConstraints() {
        guard let superview else { return }
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)

        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.topAnchor),
            leadingAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.leadingAnchor),
            trailingAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.trailingAnchor),
            
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),

            imageView.widthAnchor.constraint(equalToConstant: 80),
            imageView.heightAnchor.constraint(equalToConstant: 80),
        ])
    }
}
