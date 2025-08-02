//
//  MainTabView.swift
//  PermitManager
//
//  Created by macbook on 01/08/25.
//
import SwiftUI
import Combine
import Foundation

struct MainTabView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    
    var body: some View {
        TabView {
            PermitListView()
                .tabItem {
                    Image(systemName: "list.clipboard")
                    Text("Permits")
                }
            
            CreatePermitView()
                .tabItem {
                    Image(systemName: "plus.circle")
                    Text("Create")
                }
            
            BluetoothView()
                .tabItem {
                    Image(systemName: "antenna.radiowaves.left.and.right")
                    Text("Device")
                }
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.circle")
                    Text("Profile")
                }
        }
    }
}

struct PermitListView: View {
    @EnvironmentObject var permitManager: PermitManager
    @State private var showingCreateView = false
    @State private var selectedPermit: Permit?
    @State private var showingEditView = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search and Filter Bar
                VStack(spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                            .font(.system(size: 16)) // Smaller icon
                        TextField("Search permits...", text: $permitManager.searchText)
                            .font(.system(size: 14)) // Smaller text
                            .textFieldStyle(PlainTextFieldStyle())
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            FilterChip(
                                title: "All",
                                isSelected: permitManager.selectedStatus == nil
                            ) {
                                permitManager.selectedStatus = nil
                            }
                            
                            ForEach(Permit.PermitStatus.allCases, id: \.self) { status in
                                FilterChip(
                                    title: status.rawValue,
                                    isSelected: permitManager.selectedStatus == status,
                                    color: status.color
                                ) {
                                    permitManager.selectedStatus = status
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                
                // Permits List
                if permitManager.isLoading {
                    ProgressView("Loading...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if permitManager.filteredPermits.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        Text("No permits found")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text("Try adjusting your search or filters")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(permitManager.filteredPermits) { permit in
                            PermitRowView(permit: permit) {
                                selectedPermit = permit
                                showingEditView = true
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button("Delete", role: .destructive) {
                                    permitManager.deletePermit(permit)
                                }
                                
                                Button("Edit") {
                                    selectedPermit = permit
                                    showingEditView = true
                                }
                                .tint(.blue)
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Site Inspectors")
            .navigationBarTitleDisplayMode(.automatic)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingCreateView = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingCreateView) {
                CreatePermitView()
            }
            .sheet(isPresented: $showingEditView) {
                if let permit = selectedPermit {
                    EditPermitView(permit: permit)
                }
            }
        }
    }
}

// MARK: - Filter Chip
struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    init(title: String, isSelected: Bool, color: Color = .blue, action: @escaping () -> Void) {
        self.title = title
        self.isSelected = isSelected
        self.color = color
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? color : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(16)
        }
    }
}

// MARK: - Permit Row View
struct PermitRowView: View {
    let permit: Permit
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(permit.permitNumber)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Text(permit.status.rawValue)
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(permit.status.color.opacity(0.2))
                        .foregroundColor(permit.status.color)
                        .cornerRadius(8)
                }
                
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(permit.visitorName)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text(permit.company)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(permit.entryDate, style: .date)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(permit.entryDate, style: .time)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                Text(permit.purpose)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Create Permit View
struct CreatePermitView: View {
    @EnvironmentObject var permitManager: PermitManager
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var permitNumber = ""
    @State private var visitorName = ""
    @State private var company = ""
    @State private var purpose = ""
    @State private var entryDate = Date()
    @State private var exitDate = Date().addingTimeInterval(3600 * 8)
    @State private var authorizedBy = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Permit Information")) {
                    TextField("Permit Number", text: $permitNumber)
                        .textInputAutocapitalization(.characters)
                    
                    TextField("Visitor Name", text: $visitorName)
                        .textInputAutocapitalization(.words)
                    
                    TextField("Company", text: $company)
                        .textInputAutocapitalization(.words)
                }
                
                Section(header: Text("Visit Details")) {
                    TextField("Purpose of Visit", text: $purpose, axis: .vertical)
                        .lineLimit(3...6)
                    
                    DatePicker("Entry Date", selection: $entryDate, displayedComponents: [.date, .hourAndMinute])
                    
                    DatePicker("Exit Date", selection: $exitDate, displayedComponents: [.date, .hourAndMinute])
                }
                
                Section(header: Text("Authorization")) {
                    TextField("Authorized By", text: $authorizedBy)
                        .textInputAutocapitalization(.words)
                }
            }
            .navigationTitle("Create Permit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        createPermit()
                    }
                    .disabled(!isFormValid)
                }
            }
            .alert("Create Permit", isPresented: $showingAlert) {
                Button("OK") {
                    if alertMessage.contains("successfully") {
                        dismiss()
                    }
                }
            } message: {
                Text(alertMessage)
            }
        }
        .onAppear {
            permitNumber = generatePermitNumber()
            authorizedBy = authManager.currentUser?.username ?? ""
        }
    }
    
    private var isFormValid: Bool {
        !permitNumber.isEmpty &&
        !visitorName.isEmpty &&
        !company.isEmpty &&
        !purpose.isEmpty &&
        !authorizedBy.isEmpty &&
        exitDate > entryDate
    }
    
    private func generatePermitNumber() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        let dateString = formatter.string(from: Date())
        let randomNumber = Int.random(in: 100...999)
        return "PRM-\(dateString)-\(randomNumber)"
    }
    
    private func createPermit() {
        guard isFormValid else {
            alertMessage = "Please fill in all required fields and ensure exit date is after entry date."
            showingAlert = true
            return
        }
        
        let newPermit = Permit(
            permitNumber: permitNumber,
            visitorName: visitorName,
            company: company,
            purpose: purpose,
            entryDate: entryDate,
            exitDate: exitDate,
            status: .pending,
            createdBy: authManager.currentUser?.username ?? "",
            createdAt: Date(),
            authorizedBy: authorizedBy
        )
        
        permitManager.createPermit(newPermit)
        
        alertMessage = "Permit created successfully!"
        showingAlert = true
    }
}

// MARK: - Edit Permit View
struct EditPermitView: View {
    @EnvironmentObject var permitManager: PermitManager
    @Environment(\.dismiss) private var dismiss
    
    let permit: Permit
    
    @State private var permitNumber = ""
    @State private var visitorName = ""
    @State private var company = ""
    @State private var purpose = ""
    @State private var entryDate = Date()
    @State private var exitDate = Date()
    @State private var status: Permit.PermitStatus = .pending
    @State private var authorizedBy = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Permit Information")) {
                    TextField("Permit Number", text: $permitNumber)
                        .textInputAutocapitalization(.characters)
                    
                    TextField("Visitor Name", text: $visitorName)
                        .textInputAutocapitalization(.words)
                    
                    TextField("Company", text: $company)
                        .textInputAutocapitalization(.words)
                }
                
                Section(header: Text("Visit Details")) {
                    TextField("Purpose of Visit", text: $purpose, axis: .vertical)
                        .lineLimit(3...6)
                    
                    DatePicker("Entry Date", selection: $entryDate, displayedComponents: [.date, .hourAndMinute])
                    
                    DatePicker("Exit Date", selection: $exitDate, displayedComponents: [.date, .hourAndMinute])
                }
                
                Section(header: Text("Status & Authorization")) {
                    Picker("Status", selection: $status) {
                        ForEach(Permit.PermitStatus.allCases, id: \.self) { status in
                            Text(status.rawValue).tag(status)
                        }
                    }
                    
                    TextField("Authorized By", text: $authorizedBy)
                        .textInputAutocapitalization(.words)
                }
            }
            .navigationTitle("Edit Permit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Update") {
                        updatePermit()
                    }
                    .disabled(!isFormValid)
                }
            }
            .alert("Update Permit", isPresented: $showingAlert) {
                Button("OK") {
                    if alertMessage.contains("successfully") {
                        dismiss()
                    }
                }
            } message: {
                Text(alertMessage)
            }
        }
        .onAppear {
            loadPermitData()
        }
    }
    
    private var isFormValid: Bool {
        !permitNumber.isEmpty &&
        !visitorName.isEmpty &&
        !company.isEmpty &&
        !purpose.isEmpty &&
        !authorizedBy.isEmpty &&
        exitDate > entryDate
    }
    
    private func loadPermitData() {
        permitNumber = permit.permitNumber
        visitorName = permit.visitorName
        company = permit.company
        purpose = permit.purpose
        entryDate = permit.entryDate
        exitDate = permit.exitDate
        status = permit.status
        authorizedBy = permit.authorizedBy
    }
    
    private func updatePermit() {
        guard isFormValid else {
            alertMessage = "Please fill in all required fields and ensure exit date is after entry date."
            showingAlert = true
            return
        }
        
        let updatedPermit = Permit(
            permitNumber: permitNumber,
            visitorName: visitorName,
            company: company,
            purpose: purpose,
            entryDate: entryDate,
            exitDate: exitDate,
            status: status,
            createdBy: permit.createdBy,
            createdAt: permit.createdAt,
            authorizedBy: authorizedBy
        )
        
        permitManager.updatePermit(updatedPermit)
        
        alertMessage = "Permit updated successfully!"
        showingAlert = true
    }
}

// MARK: - Bluetooth View
struct BluetoothView: View {
    @EnvironmentObject var bluetoothManager: BluetoothManager
    @EnvironmentObject var permitManager: PermitManager
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                VStack(spacing: 20) {
                    Image(systemName: bluetoothManager.isConnected ? "antenna.radiowaves.left.and.right" : "antenna.radiowaves.left.and.right.slash")
                        .font(.system(size: 80))
                        .foregroundColor(bluetoothManager.isConnected ? .blue : .gray)
                    
                    Text(bluetoothManager.deviceName)
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text(bluetoothManager.connectionStatus)
                        .font(.subheadline)
                        .foregroundColor(bluetoothManager.isConnected ? .green : .secondary)
                }
                
                VStack(spacing: 15) {
                    if bluetoothManager.isConnected {
                        Button("Disconnect Device") {
                            bluetoothManager.disconnectDevice()
                        }
                        .buttonStyle(.bordered)
                        .tint(.red)
                    } else {
                        Button("Connect to Gate Device") {
                            bluetoothManager.connectToDevice()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    
                    if bluetoothManager.isConnected {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Active Permits")
                                .font(.headline)
                            
                            if permitManager.permits.filter({ $0.status == .active }).isEmpty {
                                Text("No active permits")
                                    .foregroundColor(.secondary)
                            } else {
                                ForEach(permitManager.permits.filter { $0.status == .active }) { permit in
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(permit.permitNumber)
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                            Text(permit.visitorName)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        Spacer()
                                        
                                        Button("Send to Gate") {
                                            _ = bluetoothManager.sendPermitToGate(permit)
                                        }
                                        .buttonStyle(.bordered)
                                        .font(.caption)
                                    }
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Gate Device")
        }
    }
}

// MARK: - Profile View
struct ProfileView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                VStack(spacing: 20) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 100))
                        .foregroundColor(.blue)
                    
                    if let user = authManager.currentUser {
                        Text(user.username)
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text(user.role.rawValue)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
                
                VStack(spacing: 15) {
                    Button("Logout") {
                        authManager.logout()
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Profile")
        }
    }
}
