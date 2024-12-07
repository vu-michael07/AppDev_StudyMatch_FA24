//
//  GroupsSectionView.swift
//  HackChallengeStudyMatch
//
//  Created by Michael Vu on 12/6/24.
//


import UIKit

class GroupsSectionView: UIView {
    private var groups: [Group] = []
    private let stackView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .fill

        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    func configure(with groups: [Group]) {
        self.groups = groups
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for group in groups {
            let groupView = GroupView(group: group)
            stackView.addArrangedSubview(groupView)
        }
    }
}
