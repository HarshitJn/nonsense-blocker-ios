import Foundation

/// Manages the state machine and logic for blocking, click challenges, and unblocked durations.
public class BlockSessionManager {
    private let store: KeyValueStore
    public let totalRequiredClicks: Int
    public let unblockDuration: TimeInterval // in seconds

    /// Initializes the session manager with a persistent key-value store.
    /// - Parameters:
    ///   - store: The KeyValueStore implementation.
    ///   - totalRequiredClicks: Total clicks required to pass the challenge (default 25).
    ///   - unblockDuration: Time in seconds that the app remains unblocked after completion (default 15 minutes).
    public init(store: KeyValueStore, totalRequiredClicks: Int = 25, unblockDuration: TimeInterval = 900) {
        self.store = store
        self.totalRequiredClicks = totalRequiredClicks
        self.unblockDuration = unblockDuration
    }

    /// Check if a specific app is currently within its unblocked window.
    /// - Parameter appIdentifier: The identifier/token of the app.
    public func isUnblocked(appIdentifier: String) -> Bool {
        let unblockedUntil = store.double(forKey: "NonsenseBlocker_UnblockedUntil_\(appIdentifier)")
        let now = Date().timeIntervalSince1970
        return now < unblockedUntil
    }

    /// Explicitly unblock an app by setting its unblock expiration timestamp.
    /// - Parameter appIdentifier: The identifier/token of the app.
    public func markUnblocked(appIdentifier: String) {
        let expiry = Date().timeIntervalSince1970 + unblockDuration
        store.set(expiry, forKey: "NonsenseBlocker_UnblockedUntil_\(appIdentifier)")
        resetChallengeState()
    }

    /// Lock the app again by removing its unblock session.
    /// - Parameter appIdentifier: The identifier/token of the app.
    public func markBlocked(appIdentifier: String) {
        store.removeObject(forKey: "NonsenseBlocker_UnblockedUntil_\(appIdentifier)")
    }

    /// The current number of completed clicks in the challenge.
    public var currentClicks: Int {
        return store.integer(forKey: "NonsenseBlocker_CurrentClicks")
    }

    /// Retrieve the current active challenge quote, or fetch a new one if empty.
    public var currentQuote: String {
        if let quote = store.string(forKey: "NonsenseBlocker_CurrentQuote"), !quote.isEmpty {
            return quote
        }
        let initialQuote = QuotesDatabase.getRandomQuote()
        store.set(initialQuote, forKey: "NonsenseBlocker_CurrentQuote")
        return initialQuote
    }

    /// Increments the click count and updates the quote. If the click limit is reached,
    /// it marks the app as unblocked.
    /// - Parameter appIdentifier: The identifier of the app triggering the shield.
    /// - Returns: `true` if the challenge is completed and the app is unblocked; `false` otherwise.
    @discardableResult
    public func handlePrimaryButtonPress(appIdentifier: String) -> Bool {
        let nextClicks = currentClicks + 1
        if nextClicks >= totalRequiredClicks {
            markUnblocked(appIdentifier: appIdentifier)
            return true
        } else {
            store.set(nextClicks, forKey: "NonsenseBlocker_CurrentClicks")
            let nextQuote = QuotesDatabase.getRandomQuote()
            store.set(nextQuote, forKey: "NonsenseBlocker_CurrentQuote")
            return false
        }
    }

    /// Resets the current challenge click count and quote back to starting values.
    public func resetChallengeState() {
        store.set(0, forKey: "NonsenseBlocker_CurrentClicks")
        store.removeObject(forKey: "NonsenseBlocker_CurrentQuote")
    }
}
