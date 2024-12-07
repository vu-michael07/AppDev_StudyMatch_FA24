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
        fetchComments()  // Ensure comments are updated when returning to this view
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
        titleLabel.text = post.postName
        titleLabel.font = .boldSystemFont(ofSize: 20)
        titleLabel.textAlignment = .center

        let descriptionLabel = UILabel()
        descriptionLabel.text = post.postDescription
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

        let descriptionLabel = UILabel()
        descriptionLabel.text = comment.description
        descriptionLabel.font = .systemFont(ofSize: 14)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textColor = .darkGray

        let timestampLabel = UILabel()
        timestampLabel.text = comment.timestamp
        timestampLabel.font = .italicSystemFont(ofSize: 12)
        timestampLabel.textColor = .gray

        let stack = UIStackView(arrangedSubviews: [descriptionLabel, timestampLabel])
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
        APIService.shared.fetch("/posts/\(post.id)/comments/", responseType: [Comment].self) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetchedComments):
                    self.comments = fetchedComments
                    self.displayComments()
                case .failure(let error):
                    print("Error fetching comments:", error.localizedDescription)
                    self.showAlert(title: "Error", message: "Failed to fetch comments.")
                }
            }
        }
    }

    @objc private func addComment() {
        guard let text = textField.text, !text.isEmpty else {
            showAlert(title: "Error", message: "Comment cannot be empty.")
            return
        }

        let newComment = Comment(
            id: 0,
            description: text,
            timestamp: DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .short),
            postID: post.id
        )

        APIService.shared.create("/posts/\(post.id)/comments/", payload: newComment, responseType: Comment.self) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let createdComment):
                    self.comments.append(createdComment)
                    self.textField.text = ""
                    self.displayComments()
                case .failure(let error):
                    print("Error posting comment:", error.localizedDescription)
                    self.showAlert(title: "Error", message: "Failed to post comment.")
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






