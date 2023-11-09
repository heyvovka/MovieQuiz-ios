//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Vladimir Savorovsky on 09.11.2023.
//

import XCTest

    class MovieQuizUITests: XCTestCase {
        
        var app: XCUIApplication!
        
        override func setUpWithError() throws {
            try super.setUpWithError()
            
            app = XCUIApplication()
            app.launch()
            
            continueAfterFailure = false
        }
        override func tearDownWithError() throws {
            try super.tearDownWithError()
            
            app.terminate()
            app = nil
        }
        func testYesButton() {
            sleep(3)
            
            let firstPoster = app.images["Poster"]
            let firstPosterData = firstPoster.screenshot().pngRepresentation
            let textLabel = app.staticTexts["Index"]
            
            app.buttons["Yes"].tap()
            sleep(3)
            
            let secondPoster = app.images["Poster"]
            let secondPosterData = secondPoster.screenshot().pngRepresentation
            
            XCTAssertNotEqual(firstPosterData, secondPosterData)
            XCTAssertEqual(textLabel.label, "2/10")
        }
        func testNoButton() {
            sleep(3)
            
            let firstPoster = app.images["Poster"]
            let firstPosterData = firstPoster.screenshot().pngRepresentation
            let textLabel = app.staticTexts["Index"]
            
            app.buttons["No"].tap()
            sleep(3)
            
            let secondPoster = app.images["Poster"]
            let secondPosterData = secondPoster.screenshot().pngRepresentation
            
            XCTAssertNotEqual(firstPosterData, secondPosterData)
            XCTAssertEqual(textLabel.label, "2/10")
        }
        func testFinalRound() {
            sleep(2)
            for _ in 1...10 {
                app.buttons["No"].tap()
                sleep(2)
            }
            
            let alert = app.alerts["Alert"]
            XCTAssertTrue(alert.exists)
            XCTAssertTrue(alert.label == "Этот раунд окончен!")
            XCTAssertTrue(alert.buttons.firstMatch.label == "Сыграть ещё раз")
            
        }
        func testRestartGame(){
            sleep(2)
            for _ in 1...10 {
                app.buttons["No"].tap()
                sleep(2)
            }
            
            let alert = app.alerts["Alert"]
            alert.buttons.firstMatch.tap()
            sleep(2)
            
            let indexLabel = app.staticTexts["Index"]
            XCTAssertTrue(alert.exists == false)
            XCTAssertEqual(indexLabel.label, "1/10")
            
        }
        
    }
