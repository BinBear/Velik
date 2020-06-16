//
//  Coordinator.swift
//  Fietscomputer
//
//  Created by Grigory Avdyushin on 11/06/2020.
//  Copyright © 2020 Grigory Avdyushin. All rights reserved.
//

import UIKit
import SwiftUI

protocol ViewRunner {
    associatedtype Content: View
    func start() -> Content
}

class Coordinator {

    private var childCoordinators = [Coordinator]()
    private(set) weak var parent: Coordinator?

    deinit {
        stop()
        debugPrint("\(self) released")
    }

    func stop() {
        debugPrint("\(self) stopped")
        parent?.onChildFinished(self)
        childCoordinators.forEach { $0.stop() }
    }

    private func add(_ coordinator: Coordinator) {
        assert(childCoordinators.contains { $0 === coordinator } == false)
        childCoordinators.append(coordinator)
        coordinator.parent = self
    }

    private func remove(_ coordinator: Coordinator) {
        childCoordinators.removeAll { $0 === coordinator }
        coordinator.parent = nil
    }

    func onChildFinished(_ coordinator: Coordinator) {
        assert(coordinator !== self)
        remove(coordinator)
    }

    func route<C: Coordinator & ViewRunner>(to coordinator: C) -> some View {
        add(coordinator)
        return coordinator.start()
    }
}

class AppCoordinator: Coordinator, ViewRunner {

    private weak var window: UIWindow?
    init(window: UIWindow?) {
        self.window = window
    }

    @discardableResult
    func start() -> some View {
        debugPrint("\(self) started")
        return route(to: RootCoordinator(window: window))
    }
}
