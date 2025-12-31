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
    var showingEmailComposer: Binding<Bool>? = nil  // Optional - only on macOS
    @Binding var showingDeleteAlert: Bool

    let filteredTeams: [Team]
    var allTeams: [Team]? = nil  // Optional - falls nicht gesetzt, wird filteredTeams verwendet

    var isMultiSelectMode: Binding<Bool>? = nil
    var selectedTeamIDs: Binding<Set<Team.ID>>? = nil
    var showingMultiDeleteAlert: Binding<Bool>? = nil

    let onCreateTestData: (() -> Void)?
    
    /// Teams für E-Mail-Zählung (nutzt allTeams falls vorhanden, sonst filteredTeams)
    private var teamsForEmail: [Team] {
        allTeams ?? filteredTeams
    }
    
    /// Anzahl der Teams mit E-Mail-Adresse
    private var teamsWithEmailCount: Int {
        teamsForEmail.filter { !$0.email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }.count
    }
    
    /// Multi-Select aktiv
    private var isMultiSelect: Bool {
        isMultiSelectMode?.wrappedValue ?? false
    }
    
    /// Ausgewählte Team-IDs
    private var selectedIDs: Set<Team.ID> {
        selectedTeamIDs?.wrappedValue ?? []
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: AppSpacing.xxxs) {
                Label("Team-Manager", systemImage: "person.3.fill")
                    .font(.headline)
                    .foregroundStyle(Color.appTextPrimary)

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
                .helpText("Neues Team erstellen")
                
                // E-Mail Button
                if teamsWithEmailCount > 0, let emailBinding = showingEmailComposer {
                    Button {
                        emailBinding.wrappedValue = true
                    } label: {
                        HStack(spacing: AppSpacing.xxs) {
                            Image(systemName: "envelope.fill")
                                .font(.body)
                            Text(NSLocalizedString("email.send", comment: "Send email"))
                                .font(.body)
                                .bold()
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .secondaryGradientButton()
                    #if os(macOS)
                    .keyboardShortcut("e", modifiers: .command)
                    #endif
                    .helpText(String(format: NSLocalizedString("email.send.teams.help", comment: ""), teamsWithEmailCount))
                }

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
                    .helpText("Erstellt Test-Teams und Quizzes (nur Debug)")
                }
                #endif
            }
            #if os(iOS)
            .padding(.horizontal, AppSpacing.sm)
            .padding(.vertical, 2)
            #else
            .padding(AppSpacing.md)
            #endif
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
                    .helpText("Suche zurücksetzen")
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
            .padding(.top, 0)
            .padding(.bottom, AppSpacing.xxxs)

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
                
                // Löschen Button und Multi-Select (nur wenn Bindings vorhanden)
                if let isMultiSelectBinding = isMultiSelectMode,
                   let selectedIDsBinding = selectedTeamIDs,
                   let showMultiDeleteBinding = showingMultiDeleteAlert {
                    if isMultiSelectBinding.wrappedValue && !selectedIDsBinding.wrappedValue.isEmpty {
                        Button {
                            showMultiDeleteBinding.wrappedValue = true
                        } label: {
                            HStack(spacing: AppSpacing.xxs) {
                                Image(systemName: "trash.fill")
                                    .font(.caption)
                                Text("\(selectedIDsBinding.wrappedValue.count)")
                                    .font(.caption)
                                    .bold()
                                    .monospacedDigit()
                            }
                        }
                        .accentGradientButton()
                        .helpText("\(selectedIDsBinding.wrappedValue.count) Teams löschen")
                        .transition(.scale.combined(with: .opacity))
                    } else {
                        // Multi-Select Toggle Button (nur Icon, kein Text)
                        Button {
                            isMultiSelectBinding.wrappedValue.toggle()
                            if !isMultiSelectBinding.wrappedValue {
                                selectedIDsBinding.wrappedValue.removeAll()
                            }
                        } label: {
                            Image(systemName: isMultiSelectBinding.wrappedValue ? "checkmark.circle.fill" : "checkmark.circle")
                                .font(.caption)
                        }
                        .secondaryGradientButton()
                        .helpText(isMultiSelectBinding.wrappedValue ? "Multi-Select beenden" : "Mehrere Teams auswählen")
                        .transition(.scale.combined(with: .opacity))
                    }
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
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isMultiSelect)
            
            Divider()
            
            // Teams List
            List(selection: isMultiSelect ? nil : $selectedTeam) {
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
                            if isMultiSelect, let selectedIDsBinding = selectedTeamIDs {
                                MultiSelectTeamRow(
                                    team: team,
                                    isSelected: selectedIDsBinding.wrappedValue.contains(team.id)
                                )
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    if selectedIDsBinding.wrappedValue.contains(team.id) {
                                        selectedIDsBinding.wrappedValue.remove(team.id)
                                    } else {
                                        selectedIDsBinding.wrappedValue.insert(team.id)
                                    }
                                }
                            } else {
                                GlobalTeamSidebarRow(team: team)
                                    .tag(team)
                            }
                        }
                        .onDelete { indexSet in
                            if !isMultiSelect {
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

                            if isMultiSelect, let selectedIDsBinding = selectedTeamIDs, !filteredTeams.isEmpty {
                                Spacer()
                                Button {
                                    if selectedIDsBinding.wrappedValue.count == filteredTeams.count {
                                        selectedIDsBinding.wrappedValue.removeAll()
                                    } else {
                                        selectedIDsBinding.wrappedValue = Set(filteredTeams.map { $0.id })
                                    }
                                } label: {
                                    Text(selectedIDsBinding.wrappedValue.count == filteredTeams.count ? "Alle abwählen" : "Alle wählen")
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

