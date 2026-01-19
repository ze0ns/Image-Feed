import UIKit

class CustomTabBar: UIView {
    
    // Замыкание для уведомления о выборе вкладки
    var onItemSelected: ((Int) -> Void)?
    
    // Текущий выбранный индекс
    var selectedIndex: Int = 0 {
        didSet { updateSelection() }
    }
    
    // Высота панели
    var height: CGFloat = 83 {
        didSet { setNeedsLayout() }
    }
    
    // Элементы вкладок
    private var items: [UITabBarItem] = []
    
    // Кнопки вкладок
    private var buttons: [UIButton] = []

    init(items: [UITabBarItem]) {
        self.items = items
        super.init(frame: .zero)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) не поддерживается")
    }

    private func setupViews() {
        for (index, item) in items.enumerated() {
            let button = UIButton(type: .custom)
            button.tag = index
            button.setTitle(item.title, for: .normal)
            
            if let image = item.image {
                button.setImage(
                    image.withRenderingMode(.alwaysTemplate),
                    for: .normal
                )
            }
            
            // Стили
            button.setTitleColor(.secondaryLabel, for: .normal)
            button.setTitleColor(.label, for: .selected)
            button.tintColor = .secondaryLabel
            
            button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
            buttons.append(button)
            addSubview(button)
        }
        
        updateSelection()
    }

    @objc private func buttonTapped(_ sender: UIButton) {
        selectedIndex = sender.tag
        onItemSelected?(selectedIndex)  // Вызываем замыкание
    }

    private func updateSelection() {
        for (index, button) in buttons.enumerated() {
            button.isSelected = (index == selectedIndex)
            button.tintColor = index == selectedIndex ? .label : .secondaryLabel
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        let count = buttons.count
        let width = bounds.width / CGFloat(count)
        
        for (index, button) in buttons.enumerated() {
            button.frame = CGRect(
                x: width * CGFloat(index),
                y: 0,
                width: width,
                height: height
            )
            
            button.imageEdgeInsets = UIEdgeInsets(top: 6, left: 0, bottom: 2, right: 0)
            button.titleEdgeInsets = UIEdgeInsets(
                top: 0,
                left: -button.imageView!.frame.width,
                bottom: -6,
                right: 0
            )
        }
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: height)
    }
}

