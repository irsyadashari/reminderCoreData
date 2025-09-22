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
        NavigationStack {
            List {
                ForEach(vm.habits, id: \.id) { habit in
                    HabitRowView(
                        habit: habit,
                        onToggle: { Task { await vm.toggleEnabled(habit) } },
                        onDelete: { Task { await vm.delete(habit) } }
                    )
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
