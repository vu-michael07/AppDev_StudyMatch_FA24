import UIKit

class PostDetailViewController: UIViewController {
    
    // MARK: - Properties
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private let commentTextField = UITextField()
    private let addCommentButton = UIButton(type: .system)
    
    private var post: Post
    
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
        setupScrollView()
        setupPostDetails()
        setupCommentInput()
    }
    
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        scrollView.addSubview(stackView)
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])
    }
    
    private func setupPostDetails() {
        let titleLabel = UILabel()
        titleLabel.text = post.post_name
        titleLabel.font = .boldSystemFont(ofSize: 20)
        
        let descriptionLabel = UILabel()
        descriptionLabel.text = post.description
        descriptionLabel.numberOfLines = 0
        
        let timestampLabel = UILabel()
        timestampLabel.text = post.timestamp
        timestampLabel.font = .italicSystemFont(ofSize: 14)
        timestampLabel.textColor = .gray
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(descriptionLabel)
        stackView.addArrangedSubview(timestampLabel)
        
        for comment in post.comments {
            let commentView = createCommentView(for: comment)
            stackView.addArrangedSubview(commentView)
        }
    }
    
    private func setupCommentInput() {
        commentTextField.placeholder = "Write a comment..."
        commentTextField.borderStyle = .roundedRect
        
        addCommentButton.setTitle("Add Comment", for: .normal)
        addCommentButton.addTarget(self, action: #selector(addComment), for: .touchUpInside)
        
        let inputStackView = UIStackView(arrangedSubviews: [commentTextField, addCommentButton])
        inputStackView.axis = .horizontal
        inputStackView.spacing = 8
        
        stackView.addArrangedSubview(inputStackView)
    }
    
    private func createCommentView(for comment: Comment) -> UIView {
        let label = UILabel()
        label.text = "\(comment.description) (\(comment.timestamp))"
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14)
        return label
    }
    
    @objc private func addComment() {
        guard let text = commentTextField.text, !text.isEmpty else { return }
        let newComment = Comment(
            id: post.comments.count + 1,
            description: text,
            timestamp: DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .short),
            post_id: post.id
        )
        post.comments.append(newComment)
        commentTextField.text = ""
        setupPostDetails()
    }
}
