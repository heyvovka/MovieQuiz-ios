//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Vladimir Savorovsky on 10.11.2023.
//

import Foundation
import UIKit

final class MovieQuizPresenter {
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?
    private var currentQuestionIndex = 0
    var correctAnswers = 0
    let questionsAmount: Int = 10
    
       func isLastQuestion() -> Bool {
           currentQuestionIndex == questionsAmount - 1
       }
       
       func restartGame() {
           currentQuestionIndex = 0
       }
       
       func switchToNextQuestion() {
           currentQuestionIndex += 1
       }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    private func didAnswer(isYes: Bool) {
            guard let currentQuestion = currentQuestion else {
                return
            }
            
            let givenAnswer = isYes
            
            viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    func didAnswer(isCorrectAnswer: Bool) {
        if isCorrectAnswer {
            correctAnswers += 1
        }
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)

        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    func showQuizResult(
        statisticService: StatisticServiceProtocol?,
        questionFactory: QuestionFactoryProtocol?,
        alertPresenter: AlertPresenterProtocol?
    ) {
        statisticService?.store(correct: correctAnswers, total: questionsAmount)
        guard let statisticService = statisticService else {
            assertionFailure("Ошибка")
            return
        }

        let message =
                """
                \n Ваш результат: \(correctAnswers)/\(questionsAmount)
                \n Количество сыгранных квизов: \(statisticService.gamesCount)
                \n Рекорд: \(statisticService.bestGame?.correct ?? 0)/\(statisticService.bestGame?.total ?? 0) (\((statisticService.bestGame!.date.dateTimeString)))
                \n Средняя точность \(String(format: "%.2f",statisticService.totalAccuracy))%
                """
        let viewModel = AlertModel(
            title: "Этот раунд окончен!",
            message: message,
            buttonText: "Сыграть ещё раз",
            completion: { [weak self] in
                guard let self = self else { return }
                self.correctAnswers = 0
                restartGame()
                questionFactory?.requestNextQuestion()
            }
        )

        alertPresenter?.show(model: viewModel)
    }
    
}
