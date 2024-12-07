//
//  PeopleViewController.swift
//  HackChallengeStudyMatch
//
//  Created by Michael Vu on 12/6/24.
//
import UIKit

class PeopleViewController: UIViewController {
    
    // MARK: - Properties (Data)
    private var groups: [Group] = []  // Groups from backend
    private var users: [User] = []    // Users from backend
    
    // MARK: - Init
    init(groups: [Group]) {
        self.groups = groups
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "People"
        
        fetchGroups()   // Fetch groups from backend
        fetchUsers()    // Fetch users from backend
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchGroups()   // Refresh groups
        fetchUsers()    // Refresh users
    }
    
    // MARK: - Setup Views
    private func setupScrollView() {
        // Remove existing views first
        view.subviews.forEach { $0.removeFromSuperview() }
        
        let scrollView = UIScrollView()
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        let contentView = UIView()
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
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
        
        // Add a view for each user
        for user in users {
            let personView = PersonView(user: user, groups: groups)
            stackView.addArrangedSubview(personView)
        }
    }
    
    // MARK: - API Integration
    
    /// Fetches all groups from the backend
    private func fetchGroups() {
        APIService.shared.fetch("/groups/", responseType: [String: [Group]].self) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self.groups = response["groups"] ?? []
                    self.setupScrollView()  // Refresh the scroll view
                case .failure(let error):
                    print("Error fetching groups:", error.localizedDescription)
                }
            }
        }
    }
    
    // Fetches all users from the backend
    private func fetchUsers() {
        APIService.shared.fetch("/users/", responseType: [String: [User]].self) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self.users = response["users"] ?? []
                    self.setupScrollView()  // Refresh the scroll view
                case .failure(let error):
                    print("Error fetching users:", error.localizedDescription)
                }
            }
        }
    }
}


