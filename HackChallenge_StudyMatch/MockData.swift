//
//  MockData.swift
//  HackChallenge_StudyMatch
//
//  Created by Michael Vu on 12/5/24.
//
import Foundation
struct MockData {
    // Sample users
    static var users: [User] = [
        User(id: 1, name: "Alice", netid: "aliceInWonderland", group_id: 1),
        User(id: 2, name: "Bob", netid: "builderBob", group_id: 1),
        User(id: 3, name: "Charlie", netid: "chocoLover", group_id: 2),
        User(id: 4, name: "Diana", netid: "princessD", group_id: 2),
        User(id: 5, name: "Eve", netid: "codeBreaker", group_id: 3)
    ]

    // Sample tasks
    static var tasks: [Task] = [
        Task(id: 1, task_name: "Plan Movie Night", description: "Decide between Marvel or rom-coms", due_date: "2024-12-10", group_id: 1),
        Task(id: 2, task_name: "Group Study", description: "Review topics for finals", due_date: "2024-12-12", group_id: 1),
        Task(id: 3, task_name: "Math Problem Set", description: "Solve all odd-numbered problems", due_date: "2024-12-15", group_id: 2),
        Task(id: 4, task_name: "Physics Lab Report", description: "Submit before midnight", due_date: "2024-12-16", group_id: 2),
        Task(id: 5, task_name: "Code Review", description: "Review PRs for team project", due_date: "2024-12-20", group_id: 3)
    ]

    // Groups
    static var groups: [Group] = [
        Group(
            id: 1,
            name: "Netflix",
            users: [users[0], users[1]], // Alice and Bob
            tasks: tasks.filter { $0.group_id == 1 }
        ),
        Group(
            id: 2,
            name: "School",
            users: [users[2], users[3]], // Charlie and Diana
            tasks: tasks.filter { $0.group_id == 2 }
        ),
        Group(
            id: 3,
            name: "Some Math Project",
            users: [users[4]], // Eve
            tasks: tasks.filter { $0.group_id == 3 }
        )
    ]

    // Comments
    
    static var posts: [Post] = [
        Post(id: 1, post_name: "Welcome to Netflix Group", description: "Let's plan our next movie night!", timestamp: "2024-12-05", comments: []),
        Post(id: 2, post_name: "Study Tips", description: "How do you stay focused?", timestamp: "2024-12-06", comments: [])
    ]

    static var comments: [Comment] = [
        Comment(id: 1, description: "This is a comment on the post", timestamp: "2024-12-05", post_id: 1),
        Comment(id: 2, description: "Another comment here", timestamp: "2024-12-06", post_id: 2)
    ]


    // Current User
    static var currentUser: User = User(id: 999, name: "Test Person", netid: "testingtesting", group_id: nil)
}




