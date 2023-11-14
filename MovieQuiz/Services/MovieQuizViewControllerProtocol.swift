//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//  Created by Vladimir Savorovsky on 12.11.2023.
//

import Foundation

protocol MovieQuizViewControllerProtocol: AnyObject {
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func showNetworkError(message: String)
    func show(quiz step: QuizStepViewModel)
    func highlightImageBorder(isCorrectAnswer: Bool)
}
