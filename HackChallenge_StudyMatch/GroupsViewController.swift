import UIKit

class GroupsViewController: UIViewController {
    private let groups: [Group]
    private let stackView = UIStackView()
    
    init(groups: [Group]) {
        self.groups = groups
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Groups"
        setupStackView()
    }
    
    private func setupStackView() {
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        
        for group in groups {
            let groupView = GroupView(group: group)
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleGroupTap(_:)))
            groupView.addGestureRecognizer(tapGesture)
            groupView.isUserInteractionEnabled = true
            groupView.tag = group.id
            stackView.addArrangedSubview(groupView)
        }
        
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    @objc private func handleGroupTap(_ sender: UITapGestureRecognizer) {
        guard let groupView = sender.view as? GroupView,
              let selectedGroup = groups.first(where: { $0.id == groupView.tag }) else {
            return
        }
        let groupDetailVC = GroupDetailViewController(group: selectedGroup)
        navigationController?.pushViewController(groupDetailVC, animated: true)
    }
}
