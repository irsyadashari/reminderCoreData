//
//  Repository.swift
//  EDotReminderApp
//
//  Created by Muh Irsyad Ashari on 9/22/25.
//

import Foundation
import CoreData

protocol HabitRepository {
    func fetchAll() async throws -> [HabitEntity]
    func addHabit(name: String, time: Date, enabled: Bool) async throws -> HabitEntity
    func deleteHabit(_ habit: HabitEntity) async throws
    func markCompleted(habit: HabitEntity, at: Date) async throws
}

final class CoreDataHabitRepository: HabitRepository {
    private let ctx: NSManagedObjectContext
    init(context: NSManagedObjectContext = PersistenceController.shared.viewContext) {
        self.ctx = context
    }
    
    func fetchAll() async throws -> [HabitEntity] {
        try await ctx.perform {
            let request: NSFetchRequest<HabitEntity> = HabitEntity.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(keyPath: \HabitEntity.createdAt, ascending: false)]
            return try self.ctx.fetch(request)
        }
    }
    
    func addHabit(name: String, time: Date, enabled: Bool) async throws -> HabitEntity {
        try await ctx.perform {
            let habit = HabitEntity(context: self.ctx)
            habit.id = UUID()
            habit.name = name
            habit.time = time
            habit.enabled = enabled
            habit.createdAt = Date()
            try self.ctx.save()
            return habit
        }
    }
    
    func deleteHabit(_ habit: HabitEntity) async throws {
        try await ctx.perform {
            self.ctx.delete(habit)
            try self.ctx.save()
        }
    }
    
    func markCompleted(habit: HabitEntity, at: Date) async throws {
        try await ctx.perform {
            let history = HabitHistoryEntity(context: self.ctx)
            history.id = UUID()
            history.habitID = habit.id
            history.date = at
            habit.lastCompletedAt = at
            try self.ctx.save()
        }
    }
}

