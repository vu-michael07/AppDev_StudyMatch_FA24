//
//  HomeViewController.swift
//  HackChallenge_StudyMatch
//
//  Created by Michael Vu on 12/5/24.
//

import UIKit

class HomeViewController: UIViewController {
    
    // MARK: - Properties (views)
    private let scrollView = UIScrollView() // Scrollable area for all content
    private let contentView = UIView() // Container for all subviews within the scroll view
    private let profileButton = UIButton(type: .system) // Button to view the user's profile
    private let groupsButton = UIButton(type: .system) // Button to view all groups
    private let peopleButton = UIButton(type: .system) // Button to view people in groups
    private let commentSectionView = CommentSectionView() // Embedded comment section

    // MARK: - Properties (data)
    private var groups = MockData.groups // Reference to the current list of groups
    private var users = MockData.users // Reference to the current list of users
    private var comments = MockData.comments // Reference to the current list of comments
    private var currentUser = MockData.currentUser // The current logged-in user

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Study Match" // Title for the navigation bar
        setupScrollView()
        setupButtons()
        setupCommentSection()
    }

    // MARK: - Setup Views

    // Sets up the scrolling
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

    // Arranges the buttons for navigation
    private func setupButtons() {
        configureButton(profileButton, title: "User Profile", action: #selector(viewProfile))
        configureButton(groupsButton, title: "Groups", action: #selector(viewGroups))
        configureButton(peopleButton, title: "People", action: #selector(viewPeople))
        
        let buttonStack = UIStackView(arrangedSubviews: [profileButton, groupsButton, peopleButton])
        buttonStack.axis = .vertical // Button stack
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

    // Decorating a button
    private func configureButton(_ button: UIButton, title: String, action: Selector) {
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .blue
        button.layer.cornerRadius = 8
        button.addTarget(self, action: action, for: .touchUpInside)
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }

    // Comment section
    private func setupCommentSection() {
        contentView.addSubview(commentSectionView)
        commentSectionView.setPosts(MockData.posts) // Load posts into the comment section
        commentSectionView.delegate = self // Delegate
        commentSectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            commentSectionView.topAnchor.constraint(equalTo: peopleButton.bottomAnchor, constant: 32),
            commentSectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            commentSectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            commentSectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }

    // MARK: - Navigation

    // Navigate to Profile
    @objc private func viewProfile() {
        let profile = SettingsView(currentUser: currentUser, groups: groups) { [weak self] updatedUser, updatedGroups in
            // I think this updates the user?
            guard let self = self else { return }
            self.currentUser = updatedUser
            self.groups = updatedGroups
        }
        navigationController?.pushViewController(profile, animated: true)
    }

    // Navigate to Groups
    @objc private func viewGroups() {
        let groupsVC = GroupsViewController()
        navigationController?.pushViewController(groupsVC, animated: true)
    }

    // Navigate to People
    @objc private func viewPeople() {
        let peopleVC = PeopleViewController(groups: groups)
        navigationController?.pushViewController(peopleVC, animated: true)
    }
}

// MARK: - CommentSectionViewDelegate
extension HomeViewController: CommentSectionViewDelegate {
    // Create Post
    func createPost(name: String, description: String) {
        let newPost = Post(
            id: MockData.posts.count + 1,
            post_name: name,
            description: description,
            timestamp: DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .short),
            comments: []
        )
        MockData.posts.insert(newPost, at: 0) // Add the new post to the top of the list
        commentSectionView.setPosts(MockData.posts) // Refresh
    }

    func viewComments(for post: Post) {
        let postDetailVC = PostDetailViewController(post: post)
        navigationController?.pushViewController(postDetailVC, animated: true)
    }
}
