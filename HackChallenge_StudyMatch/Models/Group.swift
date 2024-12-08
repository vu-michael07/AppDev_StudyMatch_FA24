//
//  Group.swift
//  HackChallenge_StudyMatch
//
//  Created by Michael Vu on 12/5/24.
//


import Foundation

struct UserResponse: Codable {
    let users: [User]
}

struct User: Identifiable, Codable {
    let id: Int
    let name: String
    let netid: String
    var group_id: Int?
}




struct Task: Identifiable, Codable {
    let id: Int
    let task_name: String
    let task_description: String
    let due_date: String
    let group_id: Int
}

struct TaskCreationPayload: Encodable {
    let task_name: String
    let task_description: String
    let due_date: String
    let group_id: Int
}


struct GroupUpdatePayload: Codable {
    let group_id: Int?
}

struct PostCreationPayload: Codable {
    let post_name: String
    let description: String
    let timestamp: String
}



struct GroupResponse: Codable {
    let groups: [Group]
}

struct Group: Identifiable, Codable {
    let id: Int
    let name: String
    var users: [User]
    var tasks: [Task]
}

struct PostResponse: Codable {
    let posts: [Post]
}

struct Post: Codable, Identifiable {
    let id: Int
    let post_name: String
    let post_description: String
    let timestamp: String
    let comments: [Comment]
}

struct CommentResponse: Decodable {
    let comments: [Comment]
}

struct CommentPayload: Encodable {
    let description: String
    let timestamp: String
}


struct Comment: Codable, Identifiable {
    let id: Int
    let comment_description: String
    let timestamp: String
    let post_id: Int?
}










