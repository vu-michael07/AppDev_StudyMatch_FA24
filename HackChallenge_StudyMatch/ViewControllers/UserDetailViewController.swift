//
//  UserDetailViewController.swift
//  HackChallenge_StudyMatch
//
//  Created by Michael Vu on 12/5/24.
//

import UIKit

class UserDetailViewController: UIViewController {
    
    // MARK: - Properties (Views)
    private let nameLabel = UILabel()
    private let netidLabel = UILabel()
    private let groupLabel = UILabel()
    
    // MARK: - Properties (Data)
    private var user: User?
    private var group: Group?
    
    // MARK: - Init
    init(user: User?) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupLabels()
        fetchUserDetails()
    }
    
    // MARK: - Setup Views
    private func setupLabels() {
        nameLabel.font = .boldSystemFont(ofSize: 24)
        netidLabel.font = .systemFont(ofSize: 18)
        netidLabel.textColor = .darkGray
        groupLabel.font = .systemFont(ofSize: 18)
        groupLabel.textColor = .gray
        
        let stack = UIStackView(arrangedSubviews: [nameLabel, netidLabel, groupLabel])
        stack.axis = .vertical
        stack.spacing = 16
        
        view.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    // MARK: - Data Fetching
    
    private func fetchUserDetails() {
        guard let user = user else { return }
        
        APIService.shared.fetch("/users/\(user.id)/", responseType: User.self) { result in
            DispatchQueue.main.async {
                if case let .success(fetchedUser) = result {
                    self.user = fetchedUser
                    self.populateData()
                    self.fetchGroupDetails()
                }
            }
        }
    }
    
    private func fetchGroupDetails() {
        guard let groupId = user?.group_id else {
            groupLabel.text = "No Group Assigned"
            return
        }
        
        APIService.shared.fetch("/groups/\(groupId)/", responseType: Group.self) { result in
            DispatchQueue.main.async {
                if case let .success(fetchedGroup) = result {
                    self.group = fetchedGroup
                    self.groupLabel.text = "Group: \(fetchedGroup.name)"
                } else {
                    self.groupLabel.text = "Group ID: \(groupId)"
                }
            }
        }
    }
    
    // MARK: - Populate Data
    
    private func populateData() {
        guard let user = user else {
            nameLabel.text = "User Not Found"
            netidLabel.text = "N/A"
            groupLabel.text = "N/A"
            return
        }
        
        nameLabel.text = user.name
        netidLabel.text = "NetID: \(user.netid)"
    }
}
