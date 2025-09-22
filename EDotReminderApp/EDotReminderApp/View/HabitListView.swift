//
//  HabitListView.swift
//  EDotReminderApp
//
//  Created by Muh Irsyad Ashari on 9/22/25.
//

import SwiftUI

struct HabitListView: View {
    @StateObject private var vm = HabitListViewModel()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(vm.habits, id: \.id) { habit in
                    NavigationLink(destination: HabitDetailView(habit: habit)) {
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
                                set: { _ in Task { await vm.toggleEnabled(habit) } }
                            ))
                            .labelsHidden()
                        }
                    }
                    .swipeActions {
                        Button(role: .destructive) {
                            Task { await vm.delete(habit) }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            .navigationTitle("Daily Habits")
            .toolbar {
                Button("+") { vm.showAddSheet = true }
            }
            .task { await vm.load() }
            .sheet(isPresented: $vm.showAddSheet) {
                AddHabitView { name, date, enabled in
                    Task {
                        await vm.addHabit(name: name, time: date, enabled: enabled)
                        vm.showAddSheet = false
                    }
                }
            }
        }
    }
}
