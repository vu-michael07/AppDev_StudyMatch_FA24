//
//  PostDetailViewController.swift
//  HackChallengeStudyMatch
//
//  Created by Michael Vu on 12/6/24.
//

import UIKit

class PostDetailViewController: UIViewController {

    // MARK: - Properties
    private var post: Post
    private var comments: [Comment] = []

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let contentStackView = UIStackView()
    private let commentStackView = UIStackView()
    private let textField = UITextField()
    private let postButton = UIButton(type: .system)

    // MARK: - Init
    init(post: Post) {
        self.post = post
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Post Details"
        
        setupScrollView()
        setupContent()
        displayPostContent()
        fetchComments()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchComments()
    }

    // MARK: - Setup UI
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
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

    private func setupContent() {
        contentStackView.axis = .vertical
        contentStackView.spacing = 16
        contentStackView.alignment = .fill
        contentStackView.layer.cornerRadius = 12
        contentStackView.layer.borderWidth = 1
        contentStackView.layer.borderColor = UIColor.lightGray.cgColor
        contentStackView.backgroundColor = .systemGray6
        contentStackView.isLayoutMarginsRelativeArrangement = true
        contentStackView.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

        commentStackView.axis = .vertical
        commentStackView.spacing = 16

        textField.placeholder = "Write a comment..."
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .none

        postButton.setTitle("Post", for: .normal)
        postButton.backgroundColor = .systemBlue
        postButton.setTitleColor(.white, for: .normal)
        postButton.layer.cornerRadius = 8
        postButton.addTarget(self, action: #selector(addComment), for: .touchUpInside)

        contentView.addSubview(contentStackView)
        contentView.addSubview(commentStackView)
        contentView.addSubview(textField)
        contentView.addSubview(postButton)

        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        commentStackView.translatesAutoresizingMaskIntoConstraints = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        postButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            contentStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            contentStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            commentStackView.topAnchor.constraint(equalTo: contentStackView.bottomAnchor, constant: 16),
            commentStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            commentStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            textField.topAnchor.constraint(equalTo: commentStackView.bottomAnchor, constant: 16),
            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: postButton.leadingAnchor, constant: -8),
            textField.heightAnchor.constraint(equalToConstant: 40),

            postButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            postButton.centerYAnchor.constraint(equalTo: textField.centerYAnchor),
            postButton.widthAnchor.constraint(equalToConstant: 80),
            postButton.heightAnchor.constraint(equalToConstant: 40),

            textField.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -16)
        ])
    }

    // MARK: - Display Post Content
    private func displayPostContent() {
        contentStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let titleLabel = UILabel()
        titleLabel.text = post.post_name
        titleLabel.font = .boldSystemFont(ofSize: 20)
        titleLabel.textAlignment = .center

        let descriptionLabel = UILabel()
        descriptionLabel.text = post.post_description
        descriptionLabel.font = .systemFont(ofSize: 16)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .justified

        let timestampLabel = UILabel()
        timestampLabel.text = post.timestamp
        timestampLabel.font = .italicSystemFont(ofSize: 12)
        timestampLabel.textColor = .gray
        timestampLabel.textAlignment = .right

        contentStackView.addArrangedSubview(titleLabel)
        contentStackView.addArrangedSubview(descriptionLabel)
        contentStackView.addArrangedSubview(timestampLabel)
    }
    
    private func refreshPost() {
        let endpoint = "/posts/\(post.id)/"
        
        APIService.shared.fetch(endpoint, responseType: Post.self) { result in
            DispatchQueue.main.async {
                if case let .success(updatedPost) = result {
                    self.post = updatedPost
                    self.comments = updatedPost.comments
                    self.displayComments()
                }
            }
        }
    }



    // MARK: - Display Comments
    private func displayComments() {
        commentStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for comment in comments {
            let commentView = createCommentView(for: comment)
            commentStackView.addArrangedSubview(commentView)
        }
    }

    private func createCommentView(for comment: Comment) -> UIView {
        let containerView = UIView()
        containerView.layer.cornerRadius = 8
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.lightGray.cgColor
        containerView.backgroundColor = .systemGray6

        // Description Label
        let descriptionLabel = UILabel()
        descriptionLabel.text = comment.comment_description
        descriptionLabel.font = .systemFont(ofSize: 14)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textColor = .black

        // Timestamp Label
        let timestampLabel = UILabel()
        timestampLabel.text = comment.timestamp
        timestampLabel.font = .italicSystemFont(ofSize: 12)
        timestampLabel.textColor = .gray

        // Delete Button
        let deleteButton = UIButton(type: .system)
        deleteButton.setTitle("Delete", for: .normal)
        deleteButton.setTitleColor(.white, for: .normal)
        deleteButton.backgroundColor = .systemRed
        deleteButton.layer.cornerRadius = 8
        deleteButton.tag = comment.id
        deleteButton.addTarget(self, action: #selector(deleteCommentTapped(_:)), for: .touchUpInside)

        // Stack View for Layout
        let stack = UIStackView(arrangedSubviews: [descriptionLabel, timestampLabel, deleteButton])
        stack.axis = .vertical
        stack.spacing = 8
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)

        containerView.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: containerView.topAnchor),
            stack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])

        return containerView
    }


    // MARK: - API Calls
    private func fetchComments() {
        let endpoint = "/posts/\(post.id)/"

        APIService.shared.fetch(endpoint, responseType: CommentResponse.self) { result in
            DispatchQueue.main.async {
                if case let .success(response) = result {
                    self.comments = response.comments
                    self.displayComments()
                } else {
                    self.showAlert(title: "Error", message: "Failed to fetch comments.")
                }
            }
        }
    }

    @objc private func addComment() {
        guard let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty else {
            showAlert(title: "Error", message: "Comment cannot be empty.")
            return
        }
        
        let payload = CommentPayload(
            description: text,
            timestamp: DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .short)
        )
        
        APIService.shared.create("/posts/\(post.id)/comments/", payload: payload, responseType: Post.self) { result in
            DispatchQueue.main.async {
                if case let .success(updatedPost) = result {
                    self.post = updatedPost
                    self.comments = updatedPost.comments
                    self.textField.text = ""
                    self.displayComments()
                } else {
                    self.showAlert(title: "Error", message: "Failed to post comment.")
                }
            }
        }
    }
    
    @objc private func deleteCommentTapped(_ sender: UIButton) {
        let commentID = sender.tag
        let deleteEndpoint = "/comments/\(commentID)/"

        APIService.shared.delete(deleteEndpoint) { result in
            DispatchQueue.main.async {
                if case .success = result {
                    self.comments.removeAll { $0.id == commentID }
                    self.displayComments()
                } else {
                    self.showAlert(title: "Error", message: "Failed to delete the comment.")
                }
            }
        }
    }


    // MARK: - Utility
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}






