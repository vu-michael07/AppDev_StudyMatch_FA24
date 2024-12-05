//
//  UserDetailViewController.swift
//  HackChallenge_StudyMatch
//
//  Created by Michael Vu on 12/5/24.
//


import UIKit

class UserDetailViewController: UIViewController {
    
    // MARK: - Properties
    private let nameLabel = UILabel()
    private let netidLabel = UILabel()
    private let groupLabel = UILabel()
    var user: User?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupLabels()
        populateData()
    }
    
    // MARK: - Setup Views
    private func setupLabels() {
        nameLabel.font = .boldSystemFont(ofSize: 24)
        netidLabel.font = .systemFont(ofSize: 18)
        netidLabel.textColor = .darkGray
        groupLabel.font = .systemFont(ofSize: 18)
        groupLabel.textColor = .gray
        
        let stack = UIStackView(arrangedSubviews: [nameLabel, netidLabel, groupLabel])
        stack.axis = .vertical
        stack.spacing = 16
        
        view.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func populateData() {
        guard let user = user else { return }
        nameLabel.text = user.name
        netidLabel.text = "NetID: \(user.netid)"
        groupLabel.text = "Group ID: \(user.group_id ?? -1)" 
    }
}

