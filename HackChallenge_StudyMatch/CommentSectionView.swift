//
//  CommentSectionView.swift
//  HackChallengeStudyMatch
//
//  Created by Michael Vu on 12/5/24.
//

import UIKit

protocol CommentSectionViewDelegate: AnyObject {
    func postComment(text: String)
}

class CommentSectionView: UIView {
    
    // MARK: - Properties
    private let stackView = UIStackView()
    private let textField = UITextField()
    private let postButton = UIButton(type: .system)
    
    private var comments: [Comment] = [] {
        didSet {
            updateCommentsDisplay()
        }
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
        
        textField.placeholder = "Write a comment..."
        textField.borderStyle = .roundedRect
        
        postButton.setTitle("Post", for: .normal)
        postButton.addTarget(self, action: #selector(postComment), for: .touchUpInside)
        
        let entryStackView = UIStackView(arrangedSubviews: [textField, postButton])
        entryStackView.axis = .horizontal
        entryStackView.spacing = 8
        
        addSubview(entryStackView)
        entryStackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            entryStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            entryStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            entryStackView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            entryStackView.heightAnchor.constraint(equalToConstant: 40),
            
            stackView.topAnchor.constraint(equalTo: entryStackView.bottomAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    private func updateCommentsDisplay() {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for comment in comments.reversed() {
            let commentView = createCommentView(for: comment)
            stackView.addArrangedSubview(commentView)
        }
    }

    private func createCommentView(for comment: Comment) -> UIView {
        let containerView = UIView()
        containerView.layer.cornerRadius = 8
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.gray.cgColor
        containerView.backgroundColor = .systemGray6

        let idLabel = UILabel()
        idLabel.text = "ID: \(comment.id)"
        idLabel.font = .boldSystemFont(ofSize: 14)

        let descriptionLabel = UILabel()
        descriptionLabel.text = comment.description
        descriptionLabel.font = .systemFont(ofSize: 14)
        descriptionLabel.numberOfLines = 0

        let timestampLabel = UILabel()
        timestampLabel.text = comment.timestamp
        timestampLabel.font = .italicSystemFont(ofSize: 12)
        timestampLabel.textColor = .gray

        let stack = UIStackView(arrangedSubviews: [idLabel, descriptionLabel, timestampLabel])
        stack.axis = .vertical
        stack.spacing = 4

        containerView.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            stack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            stack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            stack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8)
        ])

        return containerView
    }

    // MARK: - Actions
    @objc private func postComment() {
        guard let text = textField.text, !text.isEmpty else { return }
        
        let newComment = Comment(
            id: comments.count + 1,
            description: text,
            timestamp: DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .short),
            post_id: comments.count + 1
        )
        comments.append(newComment)
        textField.text = ""
    }

    // MARK: - Public Methods
    func setComments(_ comments: [Comment]) {
        self.comments = comments
    }
}








