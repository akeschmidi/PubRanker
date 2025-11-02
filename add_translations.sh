#!/bin/bash

# Translations to add to all remaining languages
TRANSLATIONS='
// MARK: - Planning View (v2.0)
"planning.title" = "Plan Quiz";
"planning.subtitle" = "Prepare your quiz";
"planning.noQuizzes" = "No planned quizzes";
"planning.noQuizzes.description" = "Create your first quiz";
"planning.plannedQuizzes" = "Planned Quizzes (%d)";
"planning.delete" = "Delete";
"planning.edit" = "Edit";
"planning.start" = "Start Quiz";
"planning.delete.confirm" = "Do you really want to delete '\''%@'\''? This action cannot be undone.";
"planning.ready" = "Ready for your first quiz?";
"planning.ready.description" = "Plan and organize your pub quiz easily";
"planning.create" = "Create New Quiz";
"planning.create.subtitle" = "Start planning";

// MARK: - Edit Quiz Sheet (v2.0)
"edit.title" = "Edit Quiz";
"edit.details" = "Quiz Details";
"edit.statistics" = "Statistics";
"edit.status" = "Status";
"edit.active" = "Active";
"edit.planned" = "Planned";
"edit.completed" = "Completed";
"edit.preparation" = "Preparation";
"edit.teams" = "Teams";
"edit.rounds" = "Rounds";
"edit.maxPoints" = "Max Points";
"edit.overview" = "Overview";

// MARK: - Team Management (v2.0)
"teams.manage" = "Manage Teams";
"teams.none" = "No Teams";
"teams.none.description" = "Add teams to start the quiz";
"teams.add.first" = "Add First Team";
"teams.colorPicker" = "Choose Color";
"teams.rank" = "Rank %d";
"teams.points" = "Points";

// MARK: - Round Management (v2.0)
"rounds.manage" = "Manage Rounds";
"rounds.none" = "No Rounds";
"rounds.none.description" = "Add rounds to award points";
"rounds.add.first" = "Add First Round";
"rounds.preparation" = "Preparation";
"rounds.active" = "Active";
"rounds.completed" = "Completed";
"rounds.delete.confirm" = "Do you really want to delete '\''%@'\''?";
"rounds.maxPoints" = "Max %d Points";
"rounds.points" = "Points";
"rounds.editName" = "Edit Name";
"rounds.editPoints" = "Edit Points";
"rounds.savePoints" = "Save Points";

// MARK: - Analysis View (v2.0)
"analysis.leaderboard" = "Leaderboard";
"analysis.overview" = "Overview";
'

# List of language folders to update
LANGS=("it.lproj" "it-CH.lproj" "fr-CH.lproj" "da.lproj" "nl.lproj" "pl.lproj" "pt-BR.lproj" "rm.lproj" "ru.lproj" "sv.lproj" "ja.lproj" "ko.lproj" "zh-Hans.lproj")

for lang in "${LANGS[@]}"; do
    echo "Updating $lang..."
    echo "$TRANSLATIONS" >> "PubRanker/$lang/Localizable.strings"
done

echo "✅ All translations added!"
