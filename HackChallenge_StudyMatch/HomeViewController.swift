//
//  HomeViewController.swift
//  HackChallenge_StudyMatch
//
//  Created by Michael Vu on 12/5/24.
//

import UIKit

class HomeViewController: UIViewController {
    
    // MARK: - Properties (views)
    private let scrollView = UIScrollView()
    private let groupsStackView = UIStackView()
    private let peopleStackView = UIStackView()
    private let commentSectionView = CommentSectionView()
    
    // MARK: - Properties (local storage)
    private var groups = MockData.groups
    private var users = MockData.users
    private var comments = MockData.comments
    private var currentUser = MockData.currentUser
    
    // MARK: - Properties (UI Elements)
    private let settingsButton = UIButton(type: .system)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Study Match"
        
        setupSettingsButton()
        setupScrollView()
        setupGroupsSection()
        setupPeopleSection()
        setupCommentSection()
    }
    
    // MARK: - Setup Views
    
    private func setupSettingsButton() {
        settingsButton.setTitle("Change Name / Create Group", for: .normal)
        settingsButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
        settingsButton.setTitleColor(.white, for: .normal)
        settingsButton.backgroundColor = .systemBlue
        settingsButton.layer.cornerRadius = 8
        settingsButton.addTarget(self, action: #selector(navigateToSettings), for: .touchUpInside)
        
        view.addSubview(settingsButton)
        settingsButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            settingsButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            settingsButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            settingsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            settingsButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: settingsButton.bottomAnchor, constant: 16),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        let contentView = UIView()
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        contentView.addSubview(groupsStackView)
        contentView.addSubview(peopleStackView)
        contentView.addSubview(commentSectionView)
        
        groupsStackView.axis = .vertical
        groupsStackView.spacing = 16
        
        peopleStackView.axis = .vertical
        peopleStackView.spacing = 16
        
        groupsStackView.translatesAutoresizingMaskIntoConstraints = false
        peopleStackView.translatesAutoresizingMaskIntoConstraints = false
        commentSectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            groupsStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            groupsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            groupsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            peopleStackView.topAnchor.constraint(equalTo: groupsStackView.bottomAnchor, constant: 32),
            peopleStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            peopleStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            commentSectionView.topAnchor.constraint(equalTo: peopleStackView.bottomAnchor, constant: 32),
            commentSectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            commentSectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            commentSectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupGroupsSection() {
        groupsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let groupsLabel = UILabel()
        groupsLabel.text = "Groups"
        groupsLabel.font = .boldSystemFont(ofSize: 20)
        groupsLabel.textAlignment = .center
        groupsStackView.addArrangedSubview(groupsLabel)
        
        for group in groups {
            let groupView = GroupView(group: group)
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleGroupTap(_:)))
            groupView.addGestureRecognizer(tapGesture)
            groupView.isUserInteractionEnabled = true
            groupView.tag = group.id
            
            groupsStackView.addArrangedSubview(groupView)
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

    private func setupPeopleSection() {
        peopleStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let peopleLabel = UILabel()
        peopleLabel.text = "People"
        peopleLabel.font = .boldSystemFont(ofSize: 20)
        peopleLabel.textAlignment = .center
        peopleStackView.addArrangedSubview(peopleLabel)
        
        for user in users {
            let personView = PersonView(user: user, groups: MockData.groups)
            peopleStackView.addArrangedSubview(personView)
        }
    }
    
    private func setupCommentSection() {
        commentSectionView.setComments(MockData.comments)
        commentSectionView.delegate = self
        scrollView.addSubview(commentSectionView)
        commentSectionView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            commentSectionView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            commentSectionView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            commentSectionView.topAnchor.constraint(equalTo: peopleStackView.bottomAnchor, constant: 32),
            commentSectionView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        ])
    }

    
    // MARK: - Navigation
    @objc private func navigateToSettings() {
        let settingsView = SettingsView(currentUser: currentUser, groups: groups) { [weak self] updatedUser, updatedGroups in
            guard let self = self else { return }
            self.currentUser = updatedUser
            self.groups = updatedGroups
            self.updateUI()
        }
        navigationController?.pushViewController(settingsView, animated: true)
    }

    private func updateUI() {
        setupGroupsSection()
        setupPeopleSection()
    }
}

// MARK: - CommentSectionViewDelegate
extension HomeViewController: CommentSectionViewDelegate {
    func postComment(text: String) {
        let newComment = Comment(
            id: MockData.comments.count + 1,
            description: text,
            timestamp: DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .short),
            post_id: 1 // Adjust post_id as needed
        )
        MockData.comments.insert(newComment, at: 0)
        commentSectionView.setComments(MockData.comments)
    }
}







