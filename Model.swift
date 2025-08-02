//
//  Model.swift
//  PermitManager
//
//  Created by macbook on 01/08/25.
//
import SwiftUI
import Combine
import Foundation

// MARK: - Models
struct Permit: Identifiable, Codable {
    var id = UUID()
    var permitNumber: String
    var visitorName: String
    var company: String
    var purpose: String
    var entryDate: Date
    var exitDate: Date
    var status: PermitStatus
    var createdBy: String
    var createdAt: Date
    var authorizedBy: String
    
    enum PermitStatus: String, CaseIterable, Codable {
        case pending = "Pending"
        case approved = "Approved"
        case active = "Active"
        case expired = "Expired"
        case revoked = "Revoked"
        
        var color: Color {
            switch self {
            case .pending: return .orange
            case .approved: return .green
            case .active: return .blue
            case .expired: return .red
            case .revoked: return .gray
            }
        }
    }
}

struct User: Codable {
    let id = UUID()
    var username: String
    var role: UserRole
    var isAuthenticated: Bool = false
    
    enum UserRole: String, CaseIterable, Codable {
        case inspector = "Inspector"
        case supervisor = "Supervisor"
        case admin = "Admin"
    }
}
