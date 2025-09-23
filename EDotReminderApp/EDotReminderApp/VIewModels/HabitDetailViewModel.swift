//
//  HabitDetailViewModel.swift
//  EDotReminderApp
//
//  Created by Muh Irsyad Ashari on 9/22/25.
//

import Combine
import Foundation

@MainActor
final class HabitDetailViewModel: ObservableObject {
    @Published var name: String
    @Published var time: Date
    @Published var enabled: Bool
    
    private let habit: HabitEntity
    private let notif: NotificationService
    private let repo: HabitRepository
    
    init(habit: HabitEntity,
         repo: HabitRepository = ServiceLocator.shared.resolve(HabitRepository.self),
         notif: NotificationService = ServiceLocator.shared.resolve(NotificationService.self)) {
        self.habit = habit
        self.repo = repo
        self.notif = notif
        
        self.name = habit.name ?? ""
        self.time = habit.time ?? Date()
        self.enabled = habit.enabled
    }
    
    func save() async throws {
        habit.name = name
        habit.time = time
        habit.enabled = enabled
        try PersistenceController.shared.viewContext.save()
        
        guard let habitId = habit.id else {
            print("Warning: Habit ID is nil. Cannot schedule or cancel notification.")
            return
        }
        
        if enabled {
            try await notif.scheduleDailyReminder(id: habitId.uuidString, title: name, date: time)
        } else {
            await notif.cancelReminder(id: habitId.uuidString)
        }
    }
    
    func delete() async throws {
        guard let habitId = habit.id else {
            print("Warning: Habit ID is nil. Cannot cancel notification.")
            return
        }
        
        await notif.cancelReminder(id: habitId.uuidString)
        try await repo.deleteHabit(habit)
    }
}

