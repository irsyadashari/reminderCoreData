//
//  HabitDetailViewModelTests.swift
//  EDotReminderApp
//
//  Created by Muh Irsyad Ashari on 9/23/25.
//

import XCTest
import Combine
@testable import EDotReminderApp

final class HabitDetailViewModelTests: XCTestCase {
    
    // MARK: - Mocks
    
    final class MockNotificationService: NotificationService {
        var scheduledReminders: [(id: String, title: String, date: Date)] = []
        var canceledReminders: [String] = []
        
        func requestAuthorization() async throws -> Bool { true }
        
        func scheduleDailyReminder(id: String, title: String, date: Date) async throws {
            scheduledReminders.append((id, title, date))
        }
        
        func cancelReminder(id: String) async {
            canceledReminders.append(id)
        }
    }
    
    final class MockHabitRepository: HabitRepository {
        var deletedHabits: [HabitEntity] = []
        
        func fetchAll() async throws -> [HabitEntity] { [] }
        func addHabit(name: String, time: Date, enabled: Bool) async throws -> HabitEntity {
            let habit = HabitEntity(context: PersistenceController.shared.viewContext)
            habit.id = UUID()
            habit.name = name
            habit.time = time
            habit.enabled = enabled
            return habit
        }
        func deleteHabit(_ habit: HabitEntity) async throws {
            deletedHabits.append(habit)
        }
        func markCompleted(habit: HabitEntity, at: Date) async throws {}
    }
    
    // MARK: - Tests
    
    func testSaveSchedulesNotificationWhenEnabled() async throws {
        // Given
        let habit = HabitEntity(context: PersistenceController.shared.viewContext)
        habit.id = UUID()
        habit.name = "Test Habit"
        habit.time = Date()
        habit.enabled = true
        habit.createdAt = Date()
        
        let mockRepo = MockHabitRepository()
        let mockNotif = MockNotificationService()
        let viewModel = await HabitDetailViewModel(habit: habit, repo: mockRepo, notif: mockNotif)
        
        // When
        await MainActor.run {
            viewModel.name = "Updated Habit"
            viewModel.enabled = true
            viewModel.time = Date().addingTimeInterval(3600)
        }
        
        try await viewModel.save()
        
        // Then
        XCTAssertEqual(habit.name, "Updated Habit")
        XCTAssertTrue(habit.enabled)
        XCTAssertEqual(mockNotif.scheduledReminders.count, 1)
        XCTAssertEqual(mockNotif.scheduledReminders.first?.title, "Updated Habit")
    }
    
    func testSaveCancelsNotificationWhenDisabled() async throws {
        // Given
        let habit = HabitEntity(context: PersistenceController.shared.viewContext)
        habit.id = UUID()
        habit.name = "Test Habit"
        habit.time = Date()
        habit.enabled = true
        habit.createdAt = Date()
        
        let mockRepo = MockHabitRepository()
        let mockNotif = MockNotificationService()
        let viewModel = await HabitDetailViewModel(habit: habit, repo: mockRepo, notif: mockNotif)
        
        // When
        await MainActor.run {
            viewModel.enabled = false
        }
       
        try await viewModel.save()
        
        // Then
        XCTAssertEqual(mockNotif.canceledReminders.count, 1)
        XCTAssertEqual(mockNotif.canceledReminders.first, habit.id!.uuidString)
    }
    
    func testDeleteCancelsNotificationAndDeletesHabit() async throws {
        // Given
        let habit = HabitEntity(context: PersistenceController.shared.viewContext)
        habit.id = UUID()
        habit.name = "Test Habit"
        habit.time = Date()
        habit.enabled = true
        habit.createdAt = Date()
        
        let mockRepo = MockHabitRepository()
        let mockNotif = MockNotificationService()
        let viewModel = await HabitDetailViewModel(habit: habit, repo: mockRepo, notif: mockNotif)
        
        // When
        try await viewModel.delete()
        
        // Then
        XCTAssertEqual(mockNotif.canceledReminders.count, 1)
        XCTAssertEqual(mockNotif.canceledReminders.first, habit.id!.uuidString)
        XCTAssertEqual(mockRepo.deletedHabits.count, 1)
        XCTAssertTrue(mockRepo.deletedHabits.first === habit)
    }
}

