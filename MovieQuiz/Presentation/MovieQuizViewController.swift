//
//  MovieQuizViewController.swift
//  MovieQuiz
//
//  Created by Vladimir Savorovsky on 03.07.2023.
//

import UIKit

final class MovieQuizViewController: UIViewController {
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var isButtonsEnabled: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        showLoadingIndicator()
        questionFactory?.loadData()
        questionFactory?.requestNextQuestion()

        alertPresenter = AlertPresenter(delegate: self)
        statisticService = StatisticServiceImplementation(
            userDefaults: Foundation.UserDefaults.standard,
            decoder: JSONDecoder(),
            encoder: JSONEncoder(),
            dateProvider: { return Date() }
        )
        
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = true
        
        guard isButtonsEnabled else { return }
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = false
        
        guard isButtonsEnabled else { return }
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private let questionsAmount: Int = 10
    private var currentQuestion: QuizQuestion?
    private var questionFactory: QuestionFactoryProtocol?
    private var alertPresenter: AlertPresenterProtocol?
    private var statisticService: StatisticServiceProtocol?
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    func didLoadDataFromServer() {
        hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let viewModel = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
            
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            self.showLoadingIndicator()
            self.questionFactory?.loadData()
            self.questionFactory?.requestNextQuestion()
        }
        
        alertPresenter?.show(model: viewModel)
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.cornerRadius = 20
        imageView.layer.borderWidth = 0
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            showQuizResult()
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        isButtonsEnabled = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.showNextQuestionOrResults()
            self?.isButtonsEnabled = true
        }
    }
    
    private func showQuizResult() {
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
                self.currentQuestionIndex = 0
                self.questionFactory?.requestNextQuestion()
            }
        )

        alertPresenter?.show(model: viewModel)
    }
}

extension MovieQuizViewController: QuestionFactoryDelegate {
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)

        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
}

extension MovieQuizViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
