//
//  PermitManager.swift
//  PermitManager
//
//  Created by macbook on 01/08/25.
//
import SwiftUI
import Combine
import Foundation

class PermitManager: ObservableObject {
    @Published var permits: [Permit] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText = ""
    @Published var selectedStatus: Permit.PermitStatus?
    
    private var cancellables = Set<AnyCancellable>()
    
    var filteredPermits: [Permit] {
        permits.filter { permit in
            let matchesSearch = searchText.isEmpty ||
                permit.visitorName.localizedCaseInsensitiveContains(searchText) ||
                permit.company.localizedCaseInsensitiveContains(searchText) ||
                permit.permitNumber.localizedCaseInsensitiveContains(searchText)
            
            let matchesStatus = selectedStatus == nil || permit.status == selectedStatus
            
            return matchesSearch && matchesStatus
        }
    }
    
    init() {
        loadSampleData()
    }
    
    func loadSampleData() {
        permits = [
            Permit(
                permitNumber: "PRM-001",
                visitorName: "John Smith",
                company: "Tech Corp",
                purpose: "Equipment Installation",
                entryDate: Date(),
                exitDate: Date().addingTimeInterval(3600 * 8),
                status: .active,
                createdBy: "inspector1",
                createdAt: Date().addingTimeInterval(-3600),
                authorizedBy: "supervisor1"
            ),
            Permit(
                permitNumber: "PRM-002",
                visitorName: "Sarah Johnson",
                company: "Maintenance Ltd",
                purpose: "Routine Maintenance",
                entryDate: Date().addingTimeInterval(3600),
                exitDate: Date().addingTimeInterval(3600 * 4),
                status: .approved,
                createdBy: "inspector1",
                createdAt: Date().addingTimeInterval(-1800),
                authorizedBy: "admin1"
            ),
            Permit(
                permitNumber: "PRM-003",
                visitorName: "Mike Wilson",
                company: "Security Solutions",
                purpose: "Security Audit",
                entryDate: Date().addingTimeInterval(-3600 * 2),
                exitDate: Date().addingTimeInterval(-3600),
                status: .expired,
                createdBy: "inspector1",
                createdAt: Date().addingTimeInterval(-3600 * 3),
                authorizedBy: "supervisor1"
            )
        ]
    }
    
    func createPermit(_ permit: Permit) {
        isLoading = true
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.permits.append(permit)
            self.isLoading = false
        }
    }
    
    func updatePermit(_ permit: Permit) {
        isLoading = true
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if let index = self.permits.firstIndex(where: { $0.id == permit.id }) {
                self.permits[index] = permit
            }
            self.isLoading = false
        }
    }
    
    func deletePermit(_ permit: Permit) {
        isLoading = true
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.permits.removeAll { $0.id == permit.id }
            self.isLoading = false
        }
    }
}
