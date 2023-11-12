//
//  MoviesLoader.swift
//  MovieQuiz
//
//  Created by Vladimir Savorovsky on 09.07.2023.
//

import Foundation

protocol MoviesLoading {
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void)
}
