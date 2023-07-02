//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Vladimir Savorovsky on 02.07.2023.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)    
}
