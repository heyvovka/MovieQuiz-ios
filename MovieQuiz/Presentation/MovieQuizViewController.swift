//
//  MovieQuizViewController.swift
//  MovieQuiz
//
//  Created by Vladimir Savorovsky on 03.07.2023.
//

import UIKit

final class MovieQuizViewController: UIViewController {
    private let presenter = MovieQuizPresenter()
    
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak private var activityIndicator: UIActivityIndicatorView!
    
    private var isButtonsEnabled: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.viewController = self
        
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
        guard isButtonsEnabled else { return }
        presenter.yesButtonClicked()
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard isButtonsEnabled else { return }
        presenter.noButtonClicked()
    }
    
    private var questionFactory: QuestionFactoryProtocol?
    private var alertPresenter: AlertPresenterProtocol?
    private var statisticService: StatisticServiceProtocol?
    
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
            
            presenter.restartGame()
            presenter.correctAnswers = 0
            self.showLoadingIndicator()
            self.questionFactory?.loadData()
            self.questionFactory?.requestNextQuestion()
        }
        
        alertPresenter?.show(model: viewModel)
    }
    
    func show(quiz step: QuizStepViewModel) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.cornerRadius = 20
        imageView.layer.borderWidth = 0
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func showNextQuestionOrResults() {
        if presenter.isLastQuestion() {
            presenter.showQuizResult(statisticService: self.statisticService, questionFactory: self.questionFactory, alertPresenter: self.alertPresenter)
        } else {
            presenter.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
    func showAnswerResult(isCorrect: Bool) {
        presenter.didAnswer(isCorrectAnswer: isCorrect)
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        isButtonsEnabled = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.showNextQuestionOrResults()
            self?.isButtonsEnabled = true
        }
    }
}

extension MovieQuizViewController: QuestionFactoryDelegate {
    func didReceiveNextQuestion(question: QuizQuestion?) {
            presenter.didReceiveNextQuestion(question: question)
        }
}

extension MovieQuizViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
