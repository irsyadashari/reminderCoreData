//
//  HabitRowView.swift
//  EDotReminderApp
//
//  Created by Muh Irsyad Ashari on 9/22/25.
//

import SwiftUI

struct HabitRowView: View {
    let habit: HabitEntity
    let onToggle: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(habit.name ?? "")
                    .font(.headline)
                Text(Formatters.fullDateTime.string(from: habit.time ?? Date()))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Toggle("", isOn: Binding(
                get: { habit.enabled },
                set: { _ in onToggle() }
            ))
            .labelsHidden()
        }
        .swipeActions {
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}
