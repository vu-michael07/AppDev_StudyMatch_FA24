//
//  Group.swift
//  HackChallenge_StudyMatch
//
//  Created by Michael Vu on 12/5/24.
//


import Foundation

struct Group: Identifiable, Codable {
    let id: Int
    let name: String
    var users: [User]
    var tasks: [Task]
}

struct User: Identifiable, Codable {
    let id: Int
    var name: String
    let netid: String
    var group_id: Int?
}


struct Task: Identifiable, Codable {
    let id: Int
    var task_name: String
    var description: String
    var due_date: String
    let group_id: Int
}

struct Post: Identifiable, Codable {
    let id: Int
    let post_name: String
    let description: String
    let timestamp: String
    var comments: [Comment]
}

struct Comment: Identifiable, Codable {
    let id: Int
    let description: String
    let timestamp: String
    let post_id: Int
}



