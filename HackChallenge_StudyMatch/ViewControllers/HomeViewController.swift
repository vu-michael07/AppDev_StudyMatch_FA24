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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchPosts()
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
        APIService.shared.fetch("/users/", responseType: [User].self) { result in
            DispatchQueue.main.async {
                if case let .success(users) = result {
                    self.users = users
                    if let currentUser = users.first(where: { $0.netid == UserSessionManager.shared.currentUser?.netid }) {
                        UserSessionManager.shared.setCurrentUser(currentUser)
                        self.currentUser = currentUser
                    }
                }
            }
        }
        
        APIService.shared.fetch("/groups/", responseType: [Group].self) { result in
            DispatchQueue.main.async {
                if case let .success(groups) = result {
                    self.groups = groups
                }
            }
        }
        
        fetchPosts()
    }

    private func fetchPosts() {
        APIService.shared.fetch("/posts/", responseType: PostResponse.self) { result in
            DispatchQueue.main.async {
                if case let .success(response) = result {
                    self.posts = response.posts
                    self.commentSectionView.setPosts(self.posts)
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
    func deletePost(for post: Post) {
        APIService.shared.delete("/posts/\(post.id)/") { result in
            DispatchQueue.main.async {
                if case .success = result {
                    self.posts.removeAll(where: { $0.id == post.id })
                    self.commentSectionView.setPosts(self.posts)
                }
            }
        }
    }
    
    func createPost(name: String, description: String) {
        let currentTimestamp = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .short)
        
        let newPostPayload = PostCreationPayload(
            post_name: name,
            description: description,
            timestamp: currentTimestamp
        )
        
        APIService.shared.create("/posts/", payload: newPostPayload, responseType: Post.self) { result in
            DispatchQueue.main.async {
                if case let .success(createdPost) = result {
                    self.posts.insert(createdPost, at: 0)
                    self.commentSectionView.setPosts(self.posts)
                }
            }
        }
    }
    
    func viewComments(for post: Post) {
        let postDetailVC = PostDetailViewController(post: post)
        navigationController?.pushViewController(postDetailVC, animated: true)
    }
}
    
    
    

