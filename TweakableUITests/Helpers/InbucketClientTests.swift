//
//  InbucketClientTests.swift
//  TweakableUITests
//
//  InbucketClient のユニットテスト

import XCTest

final class InbucketClientTests: XCTestCase {
    // MARK: - extractOTP Tests

    func test_extractOTP_validSixDigitNumber_returnsOTP() {
        let text = "Your OTP code is 123456. Please enter it."

        let result = InbucketClient.testableExtractOTP(from: text)

        XCTAssertEqual(result, "123456", "6桁の数字が抽出されるべき")
    }

    func test_extractOTP_multipleSixDigitNumbers_returnsFirst() {
        let text = "Code: 123456. Backup: 789012"

        let result = InbucketClient.testableExtractOTP(from: text)

        XCTAssertEqual(result, "123456", "最初の6桁の数字が返されるべき")
    }

    func test_extractOTP_noSixDigitNumber_returnsNil() {
        let text = "Your code is 12345 (only 5 digits)"

        let result = InbucketClient.testableExtractOTP(from: text)

        XCTAssertNil(result, "5桁の数字ではnilを返すべき")
    }

    func test_extractOTP_sevenDigitNumber_returnsNil() {
        let text = "Code: 1234567"

        let result = InbucketClient.testableExtractOTP(from: text)

        XCTAssertNil(result, "7桁の数字ではnilを返すべき")
    }

    func test_extractOTP_emptyText_returnsNil() {
        let text = ""

        let result = InbucketClient.testableExtractOTP(from: text)

        XCTAssertNil(result, "空のテキストではnilを返すべき")
    }

    func test_extractOTP_sixDigitsInHTML_returnsOTP() {
        let text = "<p>Your verification code is: <strong>987654</strong></p>"

        let result = InbucketClient.testableExtractOTP(from: text)

        XCTAssertEqual(result, "987654", "HTML内の6桁の数字も抽出されるべき")
    }

    func test_extractOTP_sixDigitsWithLeadingZeros_returnsOTP() {
        let text = "Your code: 000123"

        let result = InbucketClient.testableExtractOTP(from: text)

        XCTAssertEqual(result, "000123", "先頭がゼロの6桁も正しく抽出されるべき")
    }

    // MARK: - extractMailboxName Tests

    func test_extractMailboxName_standardEmail_returnsLocalPart() {
        let email = "test@example.com"

        let result = InbucketClient.testableExtractMailboxName(from: email)

        XCTAssertEqual(result, "test", "メールアドレスの@より前の部分が返されるべき")
    }

    func test_extractMailboxName_emailWithPlus_returnsEncodedLocalPart() {
        let email = "test+alias@example.com"

        let result = InbucketClient.testableExtractMailboxName(from: email)

        // +はURLで特殊文字なのでエンコードされる
        XCTAssertEqual(result, "test+alias", "プラス記号を含むローカルパートが返されるべき")
    }

    func test_extractMailboxName_emailWithSpecialChars_returnsEncodedLocalPart() {
        let email = "user name@example.com"

        let result = InbucketClient.testableExtractMailboxName(from: email)

        // スペースは%20にエンコードされる
        XCTAssertEqual(result, "user%20name", "スペースを含むローカルパートがエンコードされるべき")
    }

    func test_extractMailboxName_noAtSymbol_returnsWholeString() {
        let email = "localonly"

        let result = InbucketClient.testableExtractMailboxName(from: email)

        XCTAssertEqual(result, "localonly", "@がない場合は全体が返されるべき")
    }

    func test_extractMailboxName_emptyString_returnsEmpty() {
        let email = ""

        let result = InbucketClient.testableExtractMailboxName(from: email)

        XCTAssertEqual(result, "", "空文字列では空文字列が返されるべき")
    }
}
