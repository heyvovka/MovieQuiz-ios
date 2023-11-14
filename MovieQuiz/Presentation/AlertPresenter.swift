//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Vladimir Savorovsky on 03.07.2023.
//

import UIKit
import Foundation

final class AlertPresenter: AlertPresenterProtocol {
    private weak var delegate: UIViewController?
    
    init (delegate: UIViewController) {
        self.delegate = delegate
    }
    func show(model: AlertModel) {
        let alert = UIAlertController(title: model.title, message: model.message, preferredStyle: .alert)
        let action = UIAlertAction(title: model.buttonText,style: .default) { _ in model.completion()}
        alert.view.accessibilityIdentifier = "Alert"
        alert.addAction(action)
        delegate?.present(alert, animated: true, completion: nil)
    }
}


