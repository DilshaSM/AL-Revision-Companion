//
//  ALRevisionCompanionUITests.swift
//  A/L Revision CompanionUITests
//
import XCTest

final class ALRevisionCompanionUITests: XCTestCase {

    private func makeApp(mode: String) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += ["-ui-testing", "-ui-test-mode", mode]
        return app
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
    }

    @MainActor
    func testSignInScreenLaunchesWithPrimaryActions() throws {
        let app = makeApp(mode: "signIn")
        app.launch()

        XCTAssertTrue(app.staticTexts["Sign in to continue"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.textFields["EMAIL"].exists)
        XCTAssertTrue(app.secureTextFields["PASSWORD"].exists)
        XCTAssertTrue(app.buttons["Sign In"].exists)
        XCTAssertTrue(app.buttons["Forgot Password?"].exists)
        XCTAssertTrue(app.buttons["Get Started"].exists)
    }

    @MainActor
    func testSignInScreenNavigatesToSignUpAndBack() throws {
        let app = makeApp(mode: "signIn")
        app.launch()

        app.buttons["Get Started"].tap()

        XCTAssertTrue(app.staticTexts["Create your account"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.textFields["FULL NAME"].exists)
        XCTAssertTrue(app.textFields["EMAIL ADDRESS"].exists)
        XCTAssertTrue(app.secureTextFields["PASSWORD"].exists)
        XCTAssertTrue(app.secureTextFields["CONFIRM PASSWORD"].exists)

        app.buttons["Back to sign in"].tap()

        XCTAssertTrue(app.staticTexts["Sign in to continue"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testForgotPasswordFlowOpensRecoverySheet() throws {
        let app = makeApp(mode: "signIn")
        app.launch()

        app.buttons["Forgot Password?"].tap()

        XCTAssertTrue(app.staticTexts["Forgot password"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.textFields["Email"].exists)
        XCTAssertTrue(app.buttons["Continue"].exists)
        XCTAssertTrue(app.buttons["Back"].exists)
    }

    @MainActor
    func testStreamSelectionLaunchShowsAvailableStreams() throws {
        let app = makeApp(mode: "streamSelection")
        app.launch()

        XCTAssertTrue(app.staticTexts["Select Your\nStream"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Science"].exists)
        XCTAssertTrue(app.buttons["Commerce"].exists)
    }
}
