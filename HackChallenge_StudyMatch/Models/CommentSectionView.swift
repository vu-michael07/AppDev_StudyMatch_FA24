//
//  CommentSectionView.swift
//  HackChallengeStudyMatch
//
//  Created by Michael Vu on 12/5/24.
//

import UIKit

protocol CommentSectionViewDelegate: AnyObject {
    func viewComments(for post: Post)
    func createPost(name: String, description: String)
    func deletePost(for post: Post)
}

class CommentSectionView: UIView {
    
    // MARK: - Properties
    private let stackView = UIStackView()
    private let nameTextField = UITextField()
    private let descriptionTextField = UITextField()
    private let postButton = UIButton(type: .system)
    
    private var posts: [Post] = [] {
        didSet { updatePostsDisplay() }
    }
    
    weak var delegate: CommentSectionViewDelegate?

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup UI
    private func setupView() {
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.alignment = .fill
        
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        setupPostCreationFields()
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }
    
    private func setupPostCreationFields() {
        nameTextField.placeholder = "Enter post title..."
        nameTextField.borderStyle = .roundedRect
        nameTextField.autocapitalizationType = .none
        
        descriptionTextField.placeholder = "Write a new post description..."
        descriptionTextField.borderStyle = .roundedRect
        descriptionTextField.autocapitalizationType = .none
        
        postButton.setTitle("Post", for: .normal)
        postButton.backgroundColor = .systemBlue
        postButton.setTitleColor(.white, for: .normal)
        postButton.layer.cornerRadius = 8
        postButton.addTarget(self, action: #selector(createPostTapped), for: .touchUpInside)
        
        let inputStack = UIStackView(arrangedSubviews: [nameTextField, descriptionTextField, postButton])
        inputStack.axis = .vertical
        inputStack.spacing = 8
        
        stackView.addArrangedSubview(inputStack)
    }
    
    // MARK: - Display Posts
    private func updatePostsDisplay() {
        stackView.arrangedSubviews.dropFirst().forEach { $0.removeFromSuperview() }
        
        for post in posts {
            let postView = createPostView(for: post)
            stackView.addArrangedSubview(postView)
        }
    }
    
    private func createPostView(for post: Post) -> UIView {
        let containerView = UIView()
        containerView.layer.cornerRadius = 8
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.lightGray.cgColor
        containerView.backgroundColor = .systemGray6
        
        let titleLabel = UILabel()
        titleLabel.text = post.post_name
        titleLabel.font = .boldSystemFont(ofSize: 16)
        
        let descriptionLabel = UILabel()
        descriptionLabel.text = post.post_description
        descriptionLabel.font = .systemFont(ofSize: 14)
        descriptionLabel.numberOfLines = 0
        
        let timestampLabel = UILabel()
        timestampLabel.text = post.timestamp
        timestampLabel.font = .italicSystemFont(ofSize: 12)
        timestampLabel.textColor = .gray
        
        let viewCommentsButton = UIButton(type: .system)
        viewCommentsButton.setTitle("View Comments (\(post.comments.count))", for: .normal)
        viewCommentsButton.backgroundColor = .systemGreen
        viewCommentsButton.setTitleColor(.white, for: .normal)
        viewCommentsButton.layer.cornerRadius = 8
        viewCommentsButton.tag = post.id
        viewCommentsButton.addTarget(self, action: #selector(viewCommentsButtonTapped(_:)), for: .touchUpInside)
        
        let deletePostButton = UIButton(type: .system)
        deletePostButton.setTitle("Delete Post", for: .normal)
        deletePostButton.backgroundColor = .systemRed
        deletePostButton.setTitleColor(.white, for: .normal)
        deletePostButton.layer.cornerRadius = 8
        deletePostButton.tag = post.id
        deletePostButton.addTarget(self, action: #selector(deletePostButtonTapped(_:)), for: .touchUpInside)
        
        let postStack = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel, timestampLabel, viewCommentsButton, deletePostButton])
        postStack.axis = .vertical
        postStack.spacing = 8
        
        containerView.addSubview(postStack)
        postStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            postStack.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            postStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            postStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            postStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8)
        ])
        
        return containerView
    }

    // MARK: - Actions
    @objc private func createPostTapped() {
        guard let name = nameTextField.text, !name.isEmpty,
              let description = descriptionTextField.text, !description.isEmpty else {
            showAlert(title: "Error", message: "Both title and description are required.")
            return
        }
        
        delegate?.createPost(name: name, description: description)
        nameTextField.text = ""
        descriptionTextField.text = ""
    }
    
    @objc private func viewCommentsButtonTapped(_ sender: UIButton) {
        guard let post = posts.first(where: { $0.id == sender.tag }) else { return }
        delegate?.viewComments(for: post)
    }
    
    @objc private func deletePostButtonTapped(_ sender: UIButton) {
        guard let post = posts.first(where: { $0.id == sender.tag }) else { return }
        
        let alert = UIAlertController(
            title: "Confirm Deletion",
            message: "Are you sure you want to delete this post and all its comments?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            self.delegate?.deletePost(for: post)
        })
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController {
            rootVC.present(alert, animated: true)
        }
    }

    // MARK: - Public Methods
    func setPosts(_ posts: [Post]) {
        self.posts = posts.sorted { $0.id > $1.id }
    }
    
    // MARK: - Utility
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController {
            rootVC.present(alert, animated: true)
        }
    }
}
