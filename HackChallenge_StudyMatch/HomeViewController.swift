//
//  HomeViewController.swift
//  HackChallenge_StudyMatch
//
//  Created by Michael Vu on 12/5/24.
//

//
//  HomeViewController.swift
//  HackChallenge_StudyMatch
//
//  Created by Michael Vu on 12/5/24.
//

import UIKit

class HomeViewController: UIViewController {
    
    // MARK: - Views
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let profileButton = UIButton(type: .system)
    private let groupsButton = UIButton(type: .system)
    private let peopleButton = UIButton(type: .system)
    private let commentSectionView = CommentSectionView()
    
    // MARK: - Data
    private var groups: [Group] = []
    private var users: [User] = []
    private var comments: [Comment] = []
    private var currentUser: User?
    private var posts: [Post] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Study Match"
        setupScrollView()
        setupButtons()
        setupCommentSection()
        fetchData()
    }
    
    // MARK: - Setup Views
    
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
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
    }
    
    private func setupButtons() {
        configureButton(profileButton, title: "User Profile", action: #selector(viewProfile))
        configureButton(groupsButton, title: "Groups", action: #selector(viewGroups))
        configureButton(peopleButton, title: "People", action: #selector(viewPeople))
        
        let buttonStack = UIStackView(arrangedSubviews: [profileButton, groupsButton, peopleButton])
        buttonStack.axis = .vertical
        buttonStack.spacing = 16
        buttonStack.alignment = .fill
        
        contentView.addSubview(buttonStack)
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            buttonStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            buttonStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            buttonStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
    
    private func configureButton(_ button: UIButton, title: String, action: Selector) {
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .blue
        button.layer.cornerRadius = 8
        button.addTarget(self, action: action, for: .touchUpInside)
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    private func setupCommentSection() {
        contentView.addSubview(commentSectionView)
        commentSectionView.delegate = self
        commentSectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            commentSectionView.topAnchor.constraint(equalTo: peopleButton.bottomAnchor, constant: 32),
            commentSectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            commentSectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            commentSectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    // MARK: - API Integration
    
    private func fetchData() {
        // Fetch current user
        APIService.shared.fetch("/users/", responseType: [User].self) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let users):
                    self.users = users
                    if let currentUser = users.first(where: { $0.netid == UserSessionManager.shared.currentUser?.netid }) {
                        UserSessionManager.shared.setCurrentUser(currentUser)
                        self.currentUser = currentUser
                    }
                case .failure(let error):
                    print("Error fetching users:", error.localizedDescription)
                }
            }
        }
        
        // Fetch groups
        APIService.shared.fetch("/groups/", responseType: [Group].self) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let groups):
                    self.groups = groups
                case .failure(let error):
                    print("Error fetching groups:", error.localizedDescription)
                }
            }
        }
        
        // Fetch posts
        APIService.shared.fetch("/posts/", responseType: [Post].self) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let posts):
                    self.posts = posts
                    self.commentSectionView.setPosts(posts)
                case .failure(let error):
                    print("Error fetching posts:", error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - Navigation
    
    @objc private func viewProfile() {
        guard let currentUser = UserSessionManager.shared.currentUser else {
            return
        }
        let profileVC = SettingsView(currentUser: currentUser, groups: groups) { [weak self] updatedUser, updatedGroups in
            self?.currentUser = updatedUser
            self?.groups = updatedGroups
        }
        navigationController?.pushViewController(profileVC, animated: true)
    }
    
    @objc private func viewGroups() {
        let groupsVC = GroupsViewController()
        navigationController?.pushViewController(groupsVC, animated: true)
    }
    
    @objc private func viewPeople() {
        let peopleVC = PeopleViewController(groups: groups)
        navigationController?.pushViewController(peopleVC, animated: true)
    }
}

// MARK: - CommentSectionViewDelegate
extension HomeViewController: CommentSectionViewDelegate {
    func createPost(name: String, description: String) {
        let newPost = Post(id: 0, postName: name, postDescription: description, timestamp: "Now", comments: [])
        
        APIService.shared.create("/posts/", payload: newPost, responseType: Post.self) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let createdPost):
                    self.posts.insert(createdPost, at: 0)
                    self.commentSectionView.setPosts(self.posts)
                case .failure(let error):
                    print("Error creating post:", error.localizedDescription)
                }
            }
        }
    }
}


