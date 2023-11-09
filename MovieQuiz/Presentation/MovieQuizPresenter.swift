//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Vladimir Savorovsky on 10.11.2023.
//

import Foundation
import UIKit

final class MovieQuizPresenter {
    var currentQuestionIndex = 0
    let questionsAmount: Int = 10
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }
}
