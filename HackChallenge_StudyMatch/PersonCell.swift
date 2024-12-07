//
//  PersonCell.swift
//  HackChallengeStudyMatch
//
//  Created by Michael Vu on 12/6/24.
//


import UIKit

class PersonCell: UICollectionViewCell {
    static let reuseIdentifier = "PersonCell"

    private let nameLabel = UILabel()
    private let ratingLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        contentView.layer.cornerRadius = 8
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.gray.cgColor
        contentView.backgroundColor = .systemGray6

        nameLabel.font = .boldSystemFont(ofSize: 16)
        nameLabel.textAlignment = .center

        ratingLabel.font = .systemFont(ofSize: 14)
        ratingLabel.textAlignment = .center

        let stackView = UIStackView(arrangedSubviews: [nameLabel, ratingLabel])
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.alignment = .center

        contentView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }

    func configure(with user: User) {
        nameLabel.text = user.name
        let averageRating = user.rates.isEmpty
            ? "N/A"
            : String(format: "%.2f", Double(user.rates.map { $0.stars }.reduce(0, +)) / Double(user.rates.count))
        ratingLabel.text = "Rating: \(averageRating)"
    }
}
