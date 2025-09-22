//
//  HabitDetailView.swift
//  EDotReminderApp
//
//  Created by Muh Irsyad Ashari on 9/22/25.
//

import SwiftUI

struct HabitDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm: HabitDetailViewModel
    
    init(habit: HabitEntity) {
        _vm = StateObject(wrappedValue: HabitDetailViewModel(habit: habit))
    }
    
    var body: some View {
        Form {
            Section(header: Text("Habit Info")) {
                TextField("Habit name", text: $vm.name)
                DatePicker("Time", selection: $vm.time, displayedComponents: .)
                Toggle("Enabled", isOn: $vm.enabled)
            }
            
            Section {
                Button(role: .destructive) {
                    Task {
                        do {
                            try await vm.delete()
                            dismiss()
                        } catch {
                            print("Failed to delete:", error)
                        }
                    }
                } label: {
                    Label("Delete Habit", systemImage: "trash")
                }
            }
        }
        .navigationTitle("Edit Habit")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    Task {
                        do {
                            try await vm.save()
                            dismiss()
                        } catch {
                            print("Failed to save:", error)
                        }
                    }
                }
            }
        }
    }
}

