import XCTest
@testable import NonsenseBlockerCore

final class NonsenseBlockerCoreTests: XCTestCase {
    
    // Test that the QuotesDatabase has quotes and returns a non-empty string with an emoji
    func testQuotesDatabaseLoadsAndGeneratesQuotes() {
        XCTAssertEqual(QuotesDatabase.quotes.count, 226, "Database should contain exactly 226 quotes.")
        
        let randomQuote = QuotesDatabase.getRandomQuote()
        XCTAssertFalse(randomQuote.isEmpty, "Random quote should not be empty.")
        
        // Verify that the quote starts with one of the configured emojis
        let hasEmoji = QuotesDatabase.emojis.contains { randomQuote.hasPrefix($0) }
        XCTAssertTrue(hasEmoji, "Generated quote should start with one of the predefined emojis.")
    }
    
    // Test that the getRoast function returns correct custom message or falls back to a generic one
    func testAppRoastingMatching() {
        let instaRoast = QuotesDatabase.getRoast(for: "https://www.instagram.com/reels/")
        XCTAssertEqual(instaRoast.icon, "📸")
        XCTAssertTrue(instaRoast.title.contains("influencer"))
        
        let redditRoast = QuotesDatabase.getRoast(for: "reddit.com/r/swift")
        XCTAssertEqual(redditRoast.icon, "🤖")
        
        let linkedinRoast = QuotesDatabase.getRoast(for: "linkedin.com/feed")
        XCTAssertEqual(linkedinRoast.icon, "💼")
        
        let unknownRoast = QuotesDatabase.getRoast(for: "google.com")
        XCTAssertEqual(unknownRoast.icon, "⏳")
        XCTAssertEqual(unknownRoast.title, "Moments of Pause Required")
    }
    
    // Test initial state of BlockSessionManager
    func testBlockSessionManagerInitialState() {
        let store = MockKeyValueStore()
        let manager = BlockSessionManager(store: store, totalRequiredClicks: 25)
        
        XCTAssertEqual(manager.currentClicks, 0)
        XCTAssertFalse(manager.isUnblocked(appIdentifier: "instagram"), "App should be blocked initially.")
        
        let quote = manager.currentQuote
        XCTAssertFalse(quote.isEmpty)
        XCTAssertEqual(manager.currentQuote, quote, "Repeated reads of currentQuote should return the same cached quote.")
    }
    
    // Test incrementing clicks up to the limit
    func testClickChallengeWorkflow() {
        let store = MockKeyValueStore()
        let requiredClicks = 5
        let manager = BlockSessionManager(store: store, totalRequiredClicks: requiredClicks)
        let appId = "reddit"
        
        var quotesSeen = Set<String>()
        quotesSeen.insert(manager.currentQuote)
        
        // Perform 4 clicks (limit is 5)
        for i in 1...4 {
            let completed = manager.handlePrimaryButtonPress(appIdentifier: appId)
            XCTAssertFalse(completed, "Challenge should not be complete at \(i) clicks.")
            XCTAssertEqual(manager.currentClicks, i)
            
            let nextQuote = manager.currentQuote
            XCTAssertFalse(nextQuote.isEmpty)
            quotesSeen.insert(nextQuote)
        }
        
        XCTAssertGreaterThan(quotesSeen.count, 1, "We should have rotated through multiple quotes.")
        XCTAssertFalse(manager.isUnblocked(appIdentifier: appId), "App should still be blocked before reaching the click limit.")
        
        // 5th click (Completing the challenge)
        let completed = manager.handlePrimaryButtonPress(appIdentifier: appId)
        XCTAssertTrue(completed, "Challenge should complete on the 5th click.")
        
        // After completion:
        // 1. App should be unblocked
        XCTAssertTrue(manager.isUnblocked(appIdentifier: appId), "App should be unblocked after completing the challenge.")
        // 2. Challenge state should be reset
        XCTAssertEqual(manager.currentClicks, 0, "Completed challenge should reset clicks to 0.")
        XCTAssertNotEqual(manager.currentQuote, store.string(forKey: "NonsenseBlocker_CurrentQuote"), "Stored active quote should be cleared/reset.")
    }
    
    // Test unblock session duration and expiration
    func testSessionUnblockDurationAndExpiry() {
        let store = MockKeyValueStore()
        // Set short unblock duration of 2 seconds
        let manager = BlockSessionManager(store: store, totalRequiredClicks: 3, unblockDuration: 2)
        let appId = "linkedin"
        
        XCTAssertFalse(manager.isUnblocked(appIdentifier: appId))
        
        // Complete challenge to unblock
        manager.handlePrimaryButtonPress(appIdentifier: appId) // 1
        manager.handlePrimaryButtonPress(appIdentifier: appId) // 2
        manager.handlePrimaryButtonPress(appIdentifier: appId) // 3 (Unlocks)
        
        XCTAssertTrue(manager.isUnblocked(appIdentifier: appId), "App should be unblocked.")
        
        // Simulate expiration by manually setting the stored timestamp to 5 seconds ago
        let expiredTimestamp = Date().timeIntervalSince1970 - 5.0
        store.set(expiredTimestamp, forKey: "NonsenseBlocker_UnblockedUntil_\(appId)")
        
        XCTAssertFalse(manager.isUnblocked(appIdentifier: appId), "App should block again once the session timestamp expires.")
    }
    
    // Test manually locking the app again
    func testManualBlockAndReset() {
        let store = MockKeyValueStore()
        let manager = BlockSessionManager(store: store, totalRequiredClicks: 25)
        let appId = "tradingview"
        
        manager.markUnblocked(appIdentifier: appId)
        XCTAssertTrue(manager.isUnblocked(appIdentifier: appId))
        
        manager.markBlocked(appIdentifier: appId)
        XCTAssertFalse(manager.isUnblocked(appIdentifier: appId), "App should be immediately blocked again after manual block command.")
    }
}
