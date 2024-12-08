//
//  GroupsViewController.swift
//  HackChallengeStudyMatch
//
//  Created by Michael Vu on 12/6/24.
//

import UIKit

class GroupsViewController: UIViewController {
    
    // MARK: - Properties (Data)
    private var groups: [Group] = []
    
    // MARK: - Init
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Groups"
        
        setupCreateGroupSection()
        fetchGroups()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchGroups()
    }
    
    // MARK: - Setup Views
    private func setupScrollView() {
        view.subviews.filter { $0.tag == 1001 }.forEach { $0.removeFromSuperview() }
        
        let scrollView = UIScrollView()
        scrollView.tag = 1001
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        let contentView = UIView()
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        let stackView = UIStackView()
        contentView.addSubview(stackView)
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
        
        for group in groups {
            let groupView = GroupView(
                group: group,
                onDelete: { [weak self] in
                    self?.deleteGroup(group)
                },
                onTap: { [weak self] in
                    self?.navigateToGroupDetail(group)
                }
            )
            groupView.tag = group.id
            stackView.addArrangedSubview(groupView)
        }
    }
    
    private func navigateToGroupDetail(_ group: Group) {
        let groupDetailVC = GroupDetailViewController(group: group)
        navigationController?.pushViewController(groupDetailVC, animated: true)
    }
    
    private func deleteGroup(_ group: Group) {
        let endpoint = "/groups/\(group.id)/"
        
        APIService.shared.delete(endpoint) { result in
            DispatchQueue.main.async {
                if case .success = result {
                    self.groups.removeAll { $0.id == group.id }
                    self.setupScrollView()
                }
            }
        }
    }
    
    private func setupCreateGroupSection() {
        let createGroupStackView = UIStackView()
        createGroupStackView.axis = .horizontal
        createGroupStackView.spacing = 8
        createGroupStackView.alignment = .center
        createGroupStackView.distribution = .fillProportionally
        
        let textField = UITextField()
        textField.placeholder = "Enter Group Name"
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .none
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        let createGroupButton = UIButton(type: .system)
        createGroupButton.setTitle("Create Group", for: .normal)
        createGroupButton.backgroundColor = .systemBlue
        createGroupButton.setTitleColor(.white, for: .normal)
        createGroupButton.layer.cornerRadius = 8
        createGroupButton.addTarget(self, action: #selector(createGroup(_:)), for: .touchUpInside)
        
        createGroupStackView.addArrangedSubview(textField)
        createGroupStackView.addArrangedSubview(createGroupButton)
        
        view.addSubview(createGroupStackView)
        createGroupStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            createGroupStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            createGroupStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            createGroupStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textField.heightAnchor.constraint(equalToConstant: 40),
            createGroupButton.heightAnchor.constraint(equalToConstant: 40),
            createGroupButton.widthAnchor.constraint(equalToConstant: 120)
        ])
    }
    
    // MARK: - Actions
    @objc private func createGroup(_ sender: UIButton) {
        guard let stackView = sender.superview as? UIStackView,
              let textField = stackView.arrangedSubviews.first(where: { $0 is UITextField }) as? UITextField,
              let groupName = textField.text, !groupName.isEmpty else {
            return
        }
        
        let newGroup = Group(id: 0, name: groupName, users: [], tasks: [])
        APIService.shared.create("/groups/", payload: newGroup as Encodable, responseType: Group.self) { result in
            DispatchQueue.main.async {
                if case let .success(createdGroup) = result {
                    self.groups.append(createdGroup)
                    textField.text = ""
                    self.setupScrollView()
                }
            }
        }
    }
    
    @objc private func handleGroupTap(_ sender: UITapGestureRecognizer) {
        guard let groupView = sender.view as? GroupView,
              let selectedGroup = groups.first(where: { $0.id == groupView.tag }) else {
            return
        }
        
        let groupDetailVC = GroupDetailViewController(group: selectedGroup)
        navigationController?.pushViewController(groupDetailVC, animated: true)
    }
    
    // MARK: - API Integration
    private func fetchGroups() {
        APIService.shared.fetch("/groups/", responseType: GroupResponse.self) { result in
            DispatchQueue.main.async {
                if case let .success(response) = result {
                    self.groups = response.groups
                    self.setupScrollView()
                }
            }
        }
    }
}
