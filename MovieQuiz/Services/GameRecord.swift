//
//  GameRecord.swift
//  MovieQuiz
//
//  Created by Vladimir Savorovsky on 04.07.2023.
//

import Foundation

struct GameRecord: Codable {
    let correct: Int
    let total: Int
    let date: Date
}

extension GameRecord: Comparable {
    private var accuracy: Double {
        guard total != 0 else {
            return 0
        }

        return Double(correct) / Double(total)
    }
    static func < (lhs: GameRecord, rhs: GameRecord) -> Bool {
        lhs.accuracy < rhs.accuracy
    }
}
