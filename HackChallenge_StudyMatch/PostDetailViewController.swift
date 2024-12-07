//
//  PostDetailViewController.swift
//  HackChallengeStudyMatch
//
//  Created by Michael Vu on 12/6/24.
//


import UIKit

class PostDetailViewController: UIViewController {

    private var post: Post
    private var comments: [Comment] = []

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let contentStackView = UIStackView()
    private let commentStackView = UIStackView()
    private let textField = UITextField()
    private let postButton = UIButton(type: .system)

    init(post: Post) {
        self.post = post
        super.init(nibName: nil, bundle: nil)
        self.comments = MockData.comments.filter { $0.post_id == post.id }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Post Details"
        setupScrollView()
        setupContent()
        displayPostContent()
        displayComments()
    }

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
        textField.translatesAutoresizingMaskIntoConstraints = false

        postButton.setTitle("Post", for: .normal)
        postButton.backgroundColor = .systemBlue
        postButton.setTitleColor(.white, for: .normal)
        postButton.layer.cornerRadius = 8
        postButton.addTarget(self, action: #selector(addComment), for: .touchUpInside)
        postButton.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(contentStackView)
        contentView.addSubview(commentStackView)
        contentView.addSubview(textField)
        contentView.addSubview(postButton)

        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        commentStackView.translatesAutoresizingMaskIntoConstraints = false

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

    private func displayPostContent() {
        contentStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let titleLabel = UILabel()
        titleLabel.text = post.post_name
        titleLabel.font = .boldSystemFont(ofSize: 20)
        titleLabel.textAlignment = .center

        let descriptionLabel = UILabel()
        descriptionLabel.text = post.description
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

    @objc private func addComment() {
        guard let text = textField.text, !text.isEmpty else { return }

        let newComment = Comment(
            id: MockData.comments.count + 1,
            description: text,
            timestamp: DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .short),
            post_id: post.id
        )
        MockData.comments.append(newComment)
        comments.append(newComment)
        textField.text = ""
        displayComments()
    }
}




