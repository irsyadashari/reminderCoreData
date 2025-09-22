//
//  HabitListViewModel.swift
//  EDotReminderApp
//
//  Created by Muh Irsyad Ashari on 9/22/25.
//

import Foundation
import Combine

@MainActor
final class HabitListViewModel: ObservableObject {
    @Published private(set) var habits: [HabitEntity] = []
    @Published var showAddSheet = false
    
    private let repo: HabitRepository
    private let notif: NotificationService
    
    init(repo: HabitRepository = ServiceLocator.shared.resolve(HabitRepository.self),
         notif: NotificationService = ServiceLocator.shared.resolve(NotificationService.self)) {
        self.repo = repo
        self.notif = notif
    }
    
    func load() async {
        do {
            self.habits = try await repo.fetchAll()
        } catch {
            print("Failed to load habits:", error)
        }
    }
    
    func addHabit(name: String, time: Date, enabled: Bool) async {
        do {
            let habit = try await repo.addHabit(name: name, time: time, enabled: enabled)
            // schedule notification
            if enabled {
                try await notif.scheduleDailyReminder(id: habit.id!.uuidString, title: name, date: time)
            }
            await load()
        } catch {
            print("Error adding habit:", error)
        }
    }
    
    func toggleEnabled(_ habit: HabitEntity) async {
        do {
            habit.enabled.toggle()
            try PersistenceController.shared.viewContext.save()
            if habit.enabled {
                try await notif.scheduleDailyReminder(id: habit.id!.uuidString, title: habit.name!, date: habit.time!)
            } else {
                await notif.cancelReminder(id: habit.id!.uuidString)
            }
            await load()
        } catch {
            print(error)
        }
    }
    
    func delete(_ habit: HabitEntity) async {
        do {
            await notif.cancelReminder(id: habit.id!.uuidString)
            try await repo.deleteHabit(habit)
            await load()
        } catch {
            print(error)
        }
    }
    
    func markCompleted(_ habit: HabitEntity) async {
        do {
            try await repo.markCompleted(habit: habit, at: Date())
            try PersistenceController.shared.viewContext.save()
            await load()
        } catch {
            print(error)
        }
    }
}
