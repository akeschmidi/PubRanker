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

    @Binding var isMultiSelectMode: Bool
    @Binding var selectedTeamIDs: Set<Team.ID>
    @Binding var showingMultiDeleteAlert: Bool

    let onCreateTestData: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                    Label("Team-Manager", systemImage: "person.3.fill")
                        .font(.title2)
                        .bold()
                        .foregroundStyle(Color.appTextPrimary)
                    Text("Teams verwalten und organisieren")
                        .font(.subheadline)
                        .foregroundStyle(Color.appTextSecondary)
                }
                
                // Moderner + Button
                Button {
                    showingAddTeamSheet = true
                } label: {
                    HStack(spacing: AppSpacing.xxs) {
                        Image(systemName: "plus.circle.fill")
                            .font(.body)
                        Text("Neues Team")
                            .font(.body)
                            .bold()
                    }
                    .frame(maxWidth: .infinity)
                }
                .primaryGradientButton()
                .help("Neues Team erstellen")
                
                // E-Mail Button
                Button {
                    showingEmailComposer = true
                } label: {
                    HStack(spacing: AppSpacing.xxs) {
                        Image(systemName: "envelope.fill")
                            .font(.body)
                        Text(NSLocalizedString("email.send.all", comment: "Email to all teams"))
                            .font(.body)
                            .bold()
                    }
                    .frame(maxWidth: .infinity)
                }
                .accentGradientButton()
                .help(NSLocalizedString("email.send.all", comment: "Email to all teams"))

                #if DEBUG
                // Debug Button für Testdaten
                if let onCreateTestData = onCreateTestData {
                    Button {
                        onCreateTestData()
                    } label: {
                        HStack(spacing: AppSpacing.xxs) {
                            Image(systemName: "wand.and.stars")
                                .font(.body)
                            Text("🧪 Testdaten erstellen")
                                .font(.body)
                                .bold()
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .secondaryGradientButton()
                    .help("Erstellt Test-Teams und Quizzes (nur Debug)")
                }
                #endif
            }
            .padding(AppSpacing.md)
            .background(Color.appBackgroundSecondary)
            
            Divider()
            
            // Search Bar
            HStack(spacing: AppSpacing.xs) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(Color.appTextSecondary)
                    .font(.body)
                    .frame(width: 20)
                TextField("Teams durchsuchen...", text: $searchText)
                    .textFieldStyle(.plain)
                
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Color.appTextSecondary)
                            .font(.body)
                    }
                    .buttonStyle(.plain)
                    .help("Suche zurücksetzen")
                }
            }
            .padding(AppSpacing.xs)
            .background(
                RoundedRectangle(cornerRadius: AppCornerRadius.sm)
                    .fill(Color.appBackgroundSecondary)
                    .overlay {
                        RoundedRectangle(cornerRadius: AppCornerRadius.sm)
                            .stroke(Color.appTextTertiary.opacity(0.2), lineWidth: 1)
                    }
            )
            .padding(.horizontal, AppSpacing.screenPadding)
            .padding(.vertical, AppSpacing.xs)
            
            Divider()
            
            // Sort Menu und Auswählen Button
            HStack(spacing: AppSpacing.xs) {
                Image(systemName: "arrow.up.arrow.down")
                    .foregroundStyle(Color.appTextSecondary)
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
                    HStack(spacing: AppSpacing.xxxs) {
                        Text("Sortieren:")
                            .font(.caption)
                            .foregroundStyle(Color.appTextSecondary)
                        Text(sortOption.rawValue)
                            .font(.caption)
                            .foregroundStyle(Color.appTextPrimary)
                            .lineLimit(1)
                        Image(systemName: "chevron.down")
                            .font(.caption2)
                            .foregroundStyle(Color.appTextSecondary)
                    }
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                // Löschen Button (ersetzt Auswählen-Button wenn Teams ausgewählt)
                if isMultiSelectMode && !selectedTeamIDs.isEmpty {
                    Button {
                        showingMultiDeleteAlert = true
                    } label: {
                        HStack(spacing: AppSpacing.xxs) {
                            Image(systemName: "trash.fill")
                                .font(.caption)
                            Text("\(selectedTeamIDs.count)")
                                .font(.caption)
                                .bold()
                                .monospacedDigit()
                        }
                    }
                    .accentGradientButton()
                    .help("\(selectedTeamIDs.count) Teams löschen")
                    .transition(.scale.combined(with: .opacity))
                } else {
                    // Multi-Select Toggle Button (nur Icon, kein Text)
                    Button {
                        isMultiSelectMode.toggle()
                        if !isMultiSelectMode {
                            selectedTeamIDs.removeAll()
                        }
                    } label: {
                        Image(systemName: isMultiSelectMode ? "checkmark.circle.fill" : "checkmark.circle")
                            .font(.caption)
                    }
                    .secondaryGradientButton()
                    .help(isMultiSelectMode ? "Multi-Select beenden" : "Mehrere Teams auswählen")
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, AppSpacing.xs)
            .padding(.vertical, AppSpacing.xs)
            .background(
                RoundedRectangle(cornerRadius: AppCornerRadius.sm)
                    .fill(Color.appBackgroundSecondary.opacity(0.5))
            )
            .padding(.horizontal, AppSpacing.screenPadding)
            .padding(.vertical, AppSpacing.xxs)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isMultiSelectMode)
            
            Divider()
            
            // Teams List
            List(selection: isMultiSelectMode ? nil : $selectedTeam) {
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
                            if isMultiSelectMode {
                                MultiSelectTeamRow(
                                    team: team,
                                    isSelected: selectedTeamIDs.contains(team.id)
                                )
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    if selectedTeamIDs.contains(team.id) {
                                        selectedTeamIDs.remove(team.id)
                                    } else {
                                        selectedTeamIDs.insert(team.id)
                                    }
                                }
                            } else {
                                GlobalTeamSidebarRow(team: team)
                                    .tag(team)
                            }
                        }
                        .onDelete { indexSet in
                            if !isMultiSelectMode {
                                for index in indexSet {
                                    let team = filteredTeams[index]
                                    selectedTeam = team
                                    showingDeleteAlert = true
                                }
                            }
                        }
                    } header: {
                        HStack {
                            Text("Teams (\(filteredTeams.count))")
                                .font(.headline)
                                .foregroundStyle(Color.appTextSecondary)
                                .monospacedDigit()

                            if isMultiSelectMode && !filteredTeams.isEmpty {
                                Spacer()
                                Button {
                                    if selectedTeamIDs.count == filteredTeams.count {
                                        selectedTeamIDs.removeAll()
                                    } else {
                                        selectedTeamIDs = Set(filteredTeams.map { $0.id })
                                    }
                                } label: {
                                    Text(selectedTeamIDs.count == filteredTeams.count ? "Alle abwählen" : "Alle wählen")
                                        .font(.caption)
                                        .foregroundStyle(Color.appPrimary)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
            .listStyle(.sidebar)
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("")
        .frame(minWidth: 280, idealWidth: 320)
    }
}

// MARK: - Multi-Select Team Row

struct MultiSelectTeamRow: View {
    let team: Team
    let isSelected: Bool

    var body: some View {
        HStack(spacing: AppSpacing.xs) {
            // Checkbox
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .font(.title3)
                .foregroundStyle(isSelected ? Color.appPrimary : Color.appTextTertiary)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)

            // Team Icon
            TeamIconView(team: team, size: 32)

            // Team Info
            VStack(alignment: .leading, spacing: AppSpacing.xxxs) {
                Text(team.name)
                    .font(.body)
                    .bold()
                    .foregroundStyle(Color.appTextPrimary)

                if !team.contactPerson.isEmpty {
                    Text(team.contactPerson)
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary)
                }
            }

            Spacer()
        }
        .padding(.vertical, AppSpacing.xxs)
        .contentShape(Rectangle())
    }
}

