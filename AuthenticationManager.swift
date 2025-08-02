//
//  AuthenticationManager.swift
//  PermitManager
//
//  Created by macbook on 01/08/25.
//
import SwiftUI
import Combine
import Foundation
class AuthenticationManager: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    
    private let demoUsers = [
        User(username: "inspector1", role: .inspector),
        User(username: "supervisor1", role: .supervisor),
        User(username: "admin1", role: .admin)
    ]
    
    func login(username: String, password: String) -> Bool {
        // Simple demo authentication
        if let user = demoUsers.first(where: { $0.username == username }), password == "demo123" {
            currentUser = user
            isAuthenticated = true
            return true
        }
        return false
    }
    
    func logout() {
        currentUser = nil
        isAuthenticated = false
    }
}
