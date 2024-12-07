//
//  CommentSectionView.swift
//  HackChallengeStudyMatch
//
//  Created by Michael Vu on 12/5/24.
//

import UIKit

protocol CommentSectionViewDelegate: AnyObject {
    func createPost(name: String, description: String)
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

    // MARK: - Setup
    private func setupView() {
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .fill
        
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Configure text fields and button
        nameTextField.placeholder = "Enter post title..."
        nameTextField.borderStyle = .roundedRect
        
        descriptionTextField.placeholder = "Write a new post description..."
        descriptionTextField.borderStyle = .roundedRect
        
        postButton.setTitle("Post", for: .normal)
        postButton.backgroundColor = .systemBlue
        postButton.setTitleColor(.white, for: .normal)
        postButton.layer.cornerRadius = 8
        postButton.addTarget(self, action: #selector(createPost), for: .touchUpInside)
        
        let entryStackView = UIStackView(arrangedSubviews: [nameTextField, descriptionTextField, postButton])
        entryStackView.axis = .vertical
        entryStackView.spacing = 8
        
        addSubview(entryStackView)
        entryStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            entryStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            entryStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            entryStackView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            
            stackView.topAnchor.constraint(equalTo: entryStackView.bottomAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    // MARK: - Update UI
    private func updatePostsDisplay() {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for post in posts {
            let postView = createPostView(for: post)
            stackView.addArrangedSubview(postView)
        }
    }
    
    private func createPostView(for post: Post) -> UIView {
        let containerView = UIView()
        containerView.layer.cornerRadius = 8
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.gray.cgColor
        containerView.backgroundColor = .systemGray6
        
        let titleLabel = UILabel()
        titleLabel.text = post.postName
        titleLabel.font = .boldSystemFont(ofSize: 16)
        
        let descriptionLabel = UILabel()
        descriptionLabel.text = post.postDescription
        descriptionLabel.font = .systemFont(ofSize: 14)
        descriptionLabel.numberOfLines = 0
        
        let timestampLabel = UILabel()
        timestampLabel.text = post.timestamp
        timestampLabel.font = .italicSystemFont(ofSize: 12)
        timestampLabel.textColor = .gray
    
        
        let postStack = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel, timestampLabel])
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

    
    func setPosts(_ posts: [Post]) {
        self.posts = posts
    }
    
    @objc public func createPost() {
        guard let name = nameTextField.text, !name.isEmpty,
              let description = descriptionTextField.text, !description.isEmpty else {
            showAlert(title: "Error", message: "Both title and description are required.")
            return
        }
        
        let newPost = Post(
            id: 0,  // Backend will generate ID
            postName: name,
            postDescription: description,
            timestamp: DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .short),
            comments: []
        )

        APIService.shared.create("/posts/", payload: newPost, responseType: Post.self) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let createdPost):
                    self.posts.insert(createdPost, at: 0)
                    self.nameTextField.text = ""
                    self.descriptionTextField.text = ""
                    print("Post created successfully:", createdPost)
                case .failure(let error):
                    print("Error creating post:", error.localizedDescription)
                    self.showAlert(title: "Error", message: "Failed to create post.")
                }
            }
        }
    }
    
    
    
    // MARK: - API Integration
    @objc public func fetchPosts() {
        APIService.shared.fetch("/posts/", responseType: [String: [Post]].self) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if let fetchedPosts = response["posts"] {
                        self.posts = fetchedPosts
                        print("Fetched Posts:", fetchedPosts)
                    } else {
                        print("Unexpected Response Format")
                    }
                case .failure(let error):
                    print("Error fetching posts:", error.localizedDescription)
                    self.showAlert(title: "Error", message: "Failed to fetch posts.")
                }
            }
        }
    }

    // MARK: - Utility
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true)
    }
}













