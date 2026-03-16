//
//  HeartRateEmitter.swift
//  NOWATCH-TestProject
//
//  Created by Yıldırım Atçıoğlu on 04/06/2024.

import Foundation

enum HeartRateEmitter {
    private static let range = 60...160

    static func stream(interval: TimeInterval = 1.0) -> AsyncStream<Int> {
        AsyncStream { continuation in
            var current = Int.random(in: range)
            continuation.yield(current)

            let task = Task {
                while !Task.isCancelled {
                    try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
                    guard !Task.isCancelled else { break }
                    current = max(range.lowerBound,
                                  min(range.upperBound,
                                      current + Int.random(in: -10...10)))
                    continuation.yield(current)
                }
                continuation.finish()
            }

            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }
}
