//
//  CommentSectionView.swift
//  HackChallengeStudyMatch
//
//  Created by Michael Vu on 12/5/24.
//

import UIKit

protocol CommentSectionViewDelegate: AnyObject {
    func createPost(name: String, description: String)
    func viewComments(for post: Post)
}

class CommentSectionView: UIView {
    
    // MARK: - Properties
    private let stackView = UIStackView()
    private let nameTextField = UITextField()
    private let descriptionTextField = UITextField()
    private let postButton = UIButton(type: .system)
    
    private var posts: [Post] = [] {
        didSet {
            updatePostsDisplay()
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
        titleLabel.text = post.post_name
        titleLabel.font = .boldSystemFont(ofSize: 16)
        titleLabel.textColor = .black
        
        let descriptionLabel = UILabel()
        descriptionLabel.text = post.description
        descriptionLabel.font = .systemFont(ofSize: 14)
        descriptionLabel.textColor = .darkGray
        descriptionLabel.numberOfLines = 0
        
        let timestampLabel = UILabel()
        timestampLabel.text = post.timestamp
        timestampLabel.font = .italicSystemFont(ofSize: 12)
        timestampLabel.textColor = .gray
        
        let commentButton = UIButton(type: .system)
        let commentCount = MockData.comments.filter { $0.post_id == post.id }.count
        commentButton.setTitle("View Comments (\(commentCount))", for: .normal)
        commentButton.backgroundColor = .systemGreen
        commentButton.setTitleColor(.white, for: .normal)
        commentButton.layer.cornerRadius = 8
        commentButton.addTarget(self, action: #selector(viewCommentsButtonTapped(_:)), for: .touchUpInside)
        commentButton.tag = post.id
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel, timestampLabel, commentButton])
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .fill
        
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

    @objc private func viewCommentsButtonTapped(_ sender: UIButton) {
        guard let post = MockData.posts.first(where: { $0.id == sender.tag }) else { return }
        delegate?.viewComments(for: post)
    }


    // MARK: - Actions
    @objc private func createPost() {
        guard let name = nameTextField.text, !name.isEmpty,
              let description = descriptionTextField.text, !description.isEmpty else { return }
        
        delegate?.createPost(name: name, description: description)
        nameTextField.text = ""
        descriptionTextField.text = ""
    }

    // MARK: - Public Methods
    func setPosts(_ posts: [Post]) {
        self.posts = posts
    }
}










