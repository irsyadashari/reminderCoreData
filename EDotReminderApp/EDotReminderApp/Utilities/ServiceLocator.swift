//
//  ServiceLocator.swift
//  EDotReminderApp
//
//  Created by Muh Irsyad Ashari on 9/22/25.
//

final class ServiceLocator {
    static let shared = ServiceLocator()
    private init() {}
    
    private var services: [String: Any] = [:]
    
    func register<T>(_ type: T.Type, service: T) {
        services[String(describing: type)] = service
    }
    
    func resolve<T>(_ type: T.Type) -> T {
        guard let s = services[String(describing: type)] as? T else {
            fatalError("Service \(T.self) not registered")
        }
        return s
    }
}

