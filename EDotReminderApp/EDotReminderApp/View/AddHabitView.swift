//
//  AddHabitView.swift
//  EDotReminderApp
//
//  Created by Muh Irsyad Ashari on 9/22/25.
//

import SwiftUI

struct AddHabitView: View {
    @State var name = ""
    @State var time = Date()
    @State var enabled = true
    var onSave: (String, Date, Bool) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Habit name", text: $name)
                DatePicker("Date & Time", selection: $time, displayedComponents: .date)
                Toggle("Enabled", isOn: $enabled)
            }
            .navigationTitle("Add Habit")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(name, time, enabled)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}


