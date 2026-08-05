import Foundation
import NonsenseBlockerCore

print("🚀 Running Nonsense Blocker Core Tests...\n")

// Test helper to capture and run tests with clean printing
func runTest(_ name: String, block: () -> Void) {
    print("⏳ Running: \(name)...", terminator: "")
    fflush(stdout)
    block()
    print(" ✓ Passed")
}

runTest("testQuotesDatabaseLoadsAndGeneratesQuotes") {
    print(" (Actual count in database: \(QuotesDatabase.quotes.count)) ")
    fflush(stdout)
    assert(QuotesDatabase.quotes.count == 210, "Database should contain exactly 210 quotes.")
    let randomQuote = QuotesDatabase.getRandomQuote()
    assert(!randomQuote.isEmpty, "Random quote should not be empty.")
    let hasEmoji = QuotesDatabase.emojis.contains { randomQuote.hasPrefix($0) }
    assert(hasEmoji, "Generated quote should start with one of the predefined emojis.")
}

runTest("testAppRoastingMatching") {
    let instaRoast = QuotesDatabase.getRoast(for: "https://www.instagram.com/reels/")
    assert(instaRoast.icon == "📸")
    assert(instaRoast.title.contains("influencer"))
    
    let redditRoast = QuotesDatabase.getRoast(for: "reddit.com/r/swift")
    assert(redditRoast.icon == "🤖")
    
    let linkedinRoast = QuotesDatabase.getRoast(for: "linkedin.com/feed")
    assert(linkedinRoast.icon == "💼")
    
    let unknownRoast = QuotesDatabase.getRoast(for: "google.com")
    assert(unknownRoast.icon == "⏳")
    assert(unknownRoast.title == "Moments of Pause Required")
}

runTest("testBlockSessionManagerInitialState") {
    let store = MockKeyValueStore()
    let manager = BlockSessionManager(store: store, totalRequiredClicks: 25)
    
    assert(manager.currentClicks == 0)
    assert(!manager.isUnblocked(appIdentifier: "instagram"), "App should be blocked initially.")
    
    let quote = manager.currentQuote
    assert(!quote.isEmpty)
    assert(manager.currentQuote == quote, "Repeated reads of currentQuote should return the same cached quote.")
}

runTest("testClickChallengeWorkflow") {
    let store = MockKeyValueStore()
    let requiredClicks = 5
    let manager = BlockSessionManager(store: store, totalRequiredClicks: requiredClicks)
    let appId = "reddit"
    
    var quotesSeen = Set<String>()
    quotesSeen.insert(manager.currentQuote)
    
    // Perform 4 clicks (limit is 5)
    for i in 1...4 {
        let completed = manager.handlePrimaryButtonPress(appIdentifier: appId)
        assert(!completed, "Challenge should not be complete at \(i) clicks.")
        assert(manager.currentClicks == i)
        
        let nextQuote = manager.currentQuote
        assert(!nextQuote.isEmpty)
        quotesSeen.insert(nextQuote)
    }
    
    assert(quotesSeen.count > 1, "We should have rotated through multiple quotes.")
    assert(!manager.isUnblocked(appIdentifier: appId), "App should still be blocked before reaching the click limit.")
    
    // 5th click (Completing the challenge)
    let completed = manager.handlePrimaryButtonPress(appIdentifier: appId)
    assert(completed, "Challenge should complete on the 5th click.")
    
    // After completion
    assert(manager.isUnblocked(appIdentifier: appId), "App should be unblocked after completing the challenge.")
    assert(manager.currentClicks == 0, "Completed challenge should reset clicks to 0.")
}

runTest("testSessionUnblockDurationAndExpiry") {
    let store = MockKeyValueStore()
    // Set short unblock duration of 2 seconds
    let manager = BlockSessionManager(store: store, totalRequiredClicks: 3, unblockDuration: 2)
    let appId = "linkedin"
    
    assert(!manager.isUnblocked(appIdentifier: appId))
    
    // Complete challenge to unblock
    manager.handlePrimaryButtonPress(appIdentifier: appId) // 1
    manager.handlePrimaryButtonPress(appIdentifier: appId) // 2
    manager.handlePrimaryButtonPress(appIdentifier: appId) // 3 (Unlocks)
    
    assert(manager.isUnblocked(appIdentifier: appId), "App should be unblocked.")
    
    // Simulate expiration by manually setting the stored timestamp to 5 seconds ago
    let expiredTimestamp = Date().timeIntervalSince1970 - 5.0
    store.set(expiredTimestamp, forKey: "NonsenseBlocker_UnblockedUntil_\(appId)")
    
    assert(!manager.isUnblocked(appIdentifier: appId), "App should block again once the session timestamp expires.")
}

runTest("testManualBlockAndReset") {
    let store = MockKeyValueStore()
    let manager = BlockSessionManager(store: store, totalRequiredClicks: 25)
    let appId = "tradingview"
    
    manager.markUnblocked(appIdentifier: appId)
    assert(manager.isUnblocked(appIdentifier: appId))
    
    manager.markBlocked(appIdentifier: appId)
    assert(!manager.isUnblocked(appIdentifier: appId), "App should be immediately blocked again after manual block command.")
}

print("\n🎉 All 6 core test suites passed successfully!")
