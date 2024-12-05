//
//  PersonView.swift
//  HackChallengeStudyMatch
//
//  Created by Michael Vu on 12/5/24.
//

import UIKit

class PersonView: UIView {
    
    // MARK: - Init
    
    init(user: User, groups: [Group]) {
        super.init(frame: .zero)
        setupView(user: user, groups: groups)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupView(user: User, groups: [Group]) {
        layer.cornerRadius = 12
        layer.borderWidth = 1
        layer.borderColor = UIColor.gray.cgColor
        backgroundColor = .systemGray6

        let nameLabel = UILabel()
        nameLabel.text = user.name
        nameLabel.font = .boldSystemFont(ofSize: 18)
        nameLabel.textAlignment = .center

        let ratingLabel = UILabel()
        ratingLabel.font = .systemFont(ofSize: 14)
        ratingLabel.textAlignment = .left
        updateAverageRatingLabel(for: user, label: ratingLabel)

        let groupsLabel = UILabel()
        groupsLabel.text = "Groups:"
        groupsLabel.font = .boldSystemFont(ofSize: 16)
        groupsLabel.textAlignment = .left

        let groupsListLabel = UILabel()
        let userGroups = groups.filter { $0.users.contains(where: { $0.id == user.id }) }
        groupsListLabel.text = userGroups.isEmpty
            ? "No groups found"
            : userGroups.map { $0.name }.joined(separator: ", ")
        groupsListLabel.font = .systemFont(ofSize: 14)
        groupsListLabel.textAlignment = .left
        groupsListLabel.numberOfLines = 0

        let ratingTextField = UITextField()
        ratingTextField.placeholder = "Rate (0-10)"
        ratingTextField.borderStyle = .roundedRect
        ratingTextField.keyboardType = .numberPad

        let rateButton = UIButton(type: .system)
        rateButton.setTitle("Rate", for: .normal)
        rateButton.backgroundColor = .red
        rateButton.setTitleColor(.white, for: .normal)
        rateButton.layer.cornerRadius = 5
        rateButton.tag = user.id
        rateButton.addTarget(self, action: #selector(rateUser(_:)), for: .touchUpInside)

        let ratingStackView = UIStackView(arrangedSubviews: [ratingTextField, rateButton])
        ratingStackView.axis = .horizontal
        ratingStackView.spacing = 8

        let stackView = UIStackView(arrangedSubviews: [nameLabel, ratingLabel, groupsLabel, groupsListLabel, ratingStackView])
        stackView.axis = .vertical
        stackView.spacing = 8

        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            rateButton.widthAnchor.constraint(equalToConstant: 80),
            rateButton.heightAnchor.constraint(equalToConstant: 40),
            ratingTextField.widthAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    private func updateAverageRatingLabel(for user: User, label: UILabel) {
        let averageRating = user.rates.isEmpty
        ? "N/A"
        : String(format: "%.2f", Double(user.rates.map { $0.stars }.reduce(0, +)) / Double(user.rates.count))
        label.text = "Average Rating: \(averageRating)"
    }
    
    // MARK: - Actions
    
    @objc private func rateUser(_ sender: UIButton) {
        guard let ratingTextField = (sender.superview as? UIStackView)?.arrangedSubviews.compactMap({ $0 as? UITextField }).first,
              let text = ratingTextField.text,
              let rating = Int(text), rating >= 0, rating <= 10 else {
            sender.setTitle("Failed", for: .normal)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                sender.setTitle("Rate", for: .normal)
            }
            return
        }
        
        guard let userID = MockData.users.firstIndex(where: { $0.id == sender.tag }) else { return }
        MockData.users[userID].rates.append(Rate(id: MockData.rates.count + 1, stars: rating, users: [MockData.users[userID]], groups: []))
        MockData.rates.append(Rate(id: MockData.rates.count + 1, stars: rating, users: [MockData.users[userID]], groups: []))
        
        ratingTextField.text = ""
        sender.setTitle("Success", for: .normal)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            sender.setTitle("Rate", for: .normal)
        }
        
        if let ratingLabel = (sender.superview?.superview as? UIStackView)?.arrangedSubviews.first(where: { $0.tag == 100 }) as? UILabel {
            updateAverageRatingLabel(for: MockData.users[userID], label: ratingLabel)
        }
    }
    
    
    
}
