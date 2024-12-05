//
//  MockData.swift
//  HackChallenge_StudyMatch
//
//  Created by Michael Vu on 12/5/24.
//


import Foundation

struct MockData {
    static var rates: [Rate] = [
        Rate(id: 1, stars: 5, users: [], groups: []),
        Rate(id: 2, stars: 8, users: [], groups: []),
        Rate(id: 3, stars: 9, users: [], groups: []),
        Rate(id: 4, stars: 7, users: [], groups: []),
        Rate(id: 5, stars: 6, users: [], groups: [])
    ]

    static var users: [User] = [
        User(id: 1, name: "Alice", netid: "aliceInWonderland", group_id: 1, rates: [rates[0]]),
        User(id: 2, name: "Bob", netid: "builderBob", group_id: 1, rates: [rates[1]]),
        User(id: 3, name: "Charlie", netid: "chocoLover", group_id: 2, rates: [rates[2]]),
        User(id: 4, name: "Diana", netid: "princessD", group_id: 2, rates: [rates[3]]),
        User(id: 5, name: "Eve", netid: "codeBreaker", group_id: 3, rates: [rates[4]]),
    ]

    static var tasks: [Task] = [
        Task(id: 1, task_name: "Plan Movie Night", description: "Decide between Marvel or rom-coms", due_date: "2024-12-10", group_id: 1),
        Task(id: 2, task_name: "Something Educational", description: "???", due_date: "2024-12-12", group_id: 2),
        Task(id: 3, task_name: "Do math or something", description: "Math", due_date: "2024-12-15", group_id: 3)
    ]

    static var groups: [Group] = [
        Group(
            id: 1,
            name: "Netflix",
            users: [users[0], users[1]],
            rates: [rates[0], rates[1]],
            tasks: tasks.filter { $0.group_id == 1 }
        ),
        Group(
            id: 2,
            name: "School",
            users: [users[2], users[3]],
            rates: [rates[2], rates[3]],
            tasks: tasks.filter { $0.group_id == 2 }
        ),
        Group(
            id: 3,
            name: "Some Math Project",
            users: [users[4]],
            rates: [rates[4]],
            tasks: tasks.filter { $0.group_id == 3 }
        )
    ]

    static var comments: [Comment] = [
        Comment(id: 1, description: "This is a comment", timestamp: "2024-12-05", post_id: 1),
        Comment(id: 2, description: "Pineapple belongs on pizza", timestamp: "2024-12-07", post_id: 1)
    ]
    
    static var currentUser: User = User(id: 999, name: "Test Person", netid: "testingtesting", group_id: nil, rates: [])
}



