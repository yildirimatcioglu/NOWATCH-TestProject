// Created on 30/05/2024

import SwiftUI

@propertyWrapper
struct RandomNumberEmitter: DynamicProperty {
    @StateObject private var store: RandomNumberEmitterStore

    init(interval: TimeInterval = 1.0) {
        _store = .init(wrappedValue: RandomNumberEmitterStore(interval: interval))
    }

    var wrappedValue: Int {
        store.value
    }
}

private extension RandomNumberEmitter {
    final class RandomNumberEmitterStore: ObservableObject {
        @Published private(set) var value: Int = Int.random(in: range)

        private static let range = 60 ... 160
        private let interval: TimeInterval
        private var timer: DispatchSourceTimer

        init(interval: TimeInterval) {
            self.interval = interval

            self.timer = DispatchSource.makeTimerSource(queue: DispatchQueue.main)
            self.timer.schedule(deadline: .now(), repeating: interval)
            self.timer.setEventHandler {
                self.value = max(Self.range.lowerBound, 
                                 min(Self.range.upperBound,
                                     self.value + Int.random(in: -10 ... 10)))
            }
            self.timer.activate()
        }
    }
}
