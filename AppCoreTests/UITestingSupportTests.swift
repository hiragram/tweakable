//
//  UITestingSupportTests.swift
//  AppCoreTests
//
//  UITestingSupport のユニットテスト

import Foundation
import Testing
@testable import AppCore

@Suite
struct UITestingSupportTests {
    // MARK: - shouldResetAuth Tests

    @Test
    func shouldResetAuth_whenArgumentPresent_returnsTrue() {
        // Arrange
        let arguments = ["AppName", "--uitesting-reset-auth"]

        // Act
        let result = UITestingSupport.shouldResetAuth(arguments: arguments)

        // Assert
        #expect(result == true, "引数に--uitesting-reset-authが含まれている場合はtrueを返すべき")
    }

    @Test
    func shouldResetAuth_whenArgumentAbsent_returnsFalse() {
        // Arrange
        let arguments = ["AppName", "--other-argument"]

        // Act
        let result = UITestingSupport.shouldResetAuth(arguments: arguments)

        // Assert
        #expect(result == false, "引数に--uitesting-reset-authが含まれていない場合はfalseを返すべき")
    }

    @Test
    func shouldResetAuth_whenEmptyArguments_returnsFalse() {
        // Arrange
        let arguments: [String] = []

        // Act
        let result = UITestingSupport.shouldResetAuth(arguments: arguments)

        // Assert
        #expect(result == false, "空の引数の場合はfalseを返すべき")
    }

    // MARK: - isUITesting Tests

    @Test
    func isUITesting_whenResetAuthArgumentPresent_returnsTrue() {
        // Arrange
        let arguments = ["AppName", "--uitesting-reset-auth"]

        // Act
        let result = UITestingSupport.isUITesting(arguments: arguments)

        // Assert
        #expect(result == true, "UIテスト用引数が含まれている場合はtrueを返すべき")
    }

    @Test
    func isUITesting_whenNoUITestingArguments_returnsFalse() {
        // Arrange
        let arguments = ["AppName", "--some-other-flag", "-v"]

        // Act
        let result = UITestingSupport.isUITesting(arguments: arguments)

        // Assert
        #expect(result == false, "UIテスト用引数が含まれていない場合はfalseを返すべき")
    }

    @Test
    func isUITesting_whenEmptyArguments_returnsFalse() {
        // Arrange
        let arguments: [String] = []

        // Act
        let result = UITestingSupport.isUITesting(arguments: arguments)

        // Assert
        #expect(result == false, "空の引数の場合はfalseを返すべき")
    }

    // MARK: - UITestingLaunchArgument Tests

    @Test
    func launchArgument_resetAuth_hasCorrectRawValue() {
        #expect(UITestingLaunchArgument.resetAuth.rawValue == "--uitesting-reset-auth")
    }
}
