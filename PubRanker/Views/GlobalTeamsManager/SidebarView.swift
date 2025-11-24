//
//  SidebarView.swift
//  PubRanker
//
//  Created on 23.11.2025
//

import SwiftUI
import SwiftData

struct SidebarView: View {
    @Binding var searchText: String
    @Binding var sortOption: TeamSortOption
    @Binding var selectedTeam: Team?
    @Binding var showingAddTeamSheet: Bool
    @Binding var showingEmailComposer: Bool
    @Binding var showingDeleteAlert: Bool
    
    let filteredTeams: [Team]
    let onCreateTestData: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    Label("Team-Manager", systemImage: "person.3.fill")
                        .font(.title2)
                        .bold()
                    Text("Teams verwalten und organisieren")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                // Moderner + Button
                Button {
                    showingAddTeamSheet = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                            .font(.body)
                        Text("Neues Team")
                            .font(.body)
                            .bold()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        LinearGradient(
                            colors: [.blue, .cyan],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .shadow(color: .blue.opacity(0.3), radius: 6, y: 3)
                }
                .buttonStyle(.plain)
                .help("Neues Team erstellen")
                
                // E-Mail Button
                Button {
                    showingEmailComposer = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "envelope.fill")
                            .font(.body)
                        Text(NSLocalizedString("email.send.all", comment: "Email to all teams"))
                            .font(.body)
                            .bold()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        LinearGradient(
                            colors: [.orange, .red],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .shadow(color: .orange.opacity(0.3), radius: 6, y: 3)
                }
                .buttonStyle(.plain)
                .help(NSLocalizedString("email.send.all", comment: "Email to all teams"))
                
                #if DEBUG
                // Debug Button für Testdaten
                if let onCreateTestData = onCreateTestData {
                    Button {
                        onCreateTestData()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "wand.and.stars")
                                .font(.body)
                            Text("🧪 Testdaten erstellen")
                                .font(.body)
                                .bold()
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            LinearGradient(
                                colors: [.purple.opacity(0.7), .pink.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .shadow(color: .purple.opacity(0.3), radius: 6, y: 3)
                    }
                    .buttonStyle(.plain)
                    .help("Erstellt Test-Teams und Quizzes (nur Debug)")
                }
                #endif
            }
            .padding()
            .background(Color(nsColor: .controlBackgroundColor))
            
            Divider()
            
            // Search Bar
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                    .font(.body)
                    .frame(width: 20)
                TextField("Teams durchsuchen...", text: $searchText)
                    .textFieldStyle(.plain)
                
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                            .font(.body)
                    }
                    .buttonStyle(.plain)
                    .help("Suche zurücksetzen")
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(nsColor: .controlBackgroundColor))
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                    }
            )
            .padding(.horizontal)
            .padding(.vertical, 12)
            
            Divider()
            
            // Sort Menu
            HStack(spacing: 10) {
                Image(systemName: "arrow.up.arrow.down")
                    .foregroundStyle(.secondary)
                    .font(.caption)
                    .frame(width: 16)
                
                Menu {
                    ForEach(TeamSortOption.allCases, id: \.self) { option in
                        Button {
                            sortOption = option
                        } label: {
                            HStack {
                                Image(systemName: option.icon)
                                    .font(.caption)
                                    .frame(width: 16)
                                Text(option.rawValue)
                                Spacer()
                                if sortOption == option {
                                    Image(systemName: "checkmark")
                                        .font(.caption)
                                }
                            }
                        }
                    }
                } label: {
                    HStack(spacing: 6) {
                        Text("Sortieren:")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(sortOption.rawValue)
                            .font(.caption)
                            .foregroundStyle(.primary)
                            .lineLimit(1)
                        Image(systemName: "chevron.down")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                .buttonStyle(.plain)
                
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(nsColor: .controlBackgroundColor).opacity(0.5))
            )
            .padding(.horizontal)
            .padding(.vertical, 8)
            
            Divider()
            
            // Teams List
            List(selection: $selectedTeam) {
                if filteredTeams.isEmpty {
                    ContentUnavailableView(
                        "Keine Teams gefunden",
                        systemImage: "magnifyingglass",
                        description: Text(searchText.isEmpty ? "Erstelle dein erstes Team" : "Keine Teams gefunden für '\(searchText)'")
                    )
                    .frame(maxHeight: .infinity)
                } else {
                    Section {
                        ForEach(filteredTeams) { team in
                            GlobalTeamSidebarRow(team: team)
                                .tag(team)
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                let team = filteredTeams[index]
                                selectedTeam = team
                                showingDeleteAlert = true
                            }
                        }
                    } header: {
                        Text("Teams (\(filteredTeams.count))")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .listStyle(.sidebar)
            .scrollContentBackground(.hidden)
        }
        .frame(minWidth: 280, idealWidth: 320)
    }
}

