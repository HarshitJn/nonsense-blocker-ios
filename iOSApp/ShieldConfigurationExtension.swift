import ManagedSettings
import ManagedSettingsUI
import UIKit
import NonsenseBlockerCore

class ShieldConfigurationExtension: ShieldConfigurationDataSource {
    
    private let totalClicks = 25
    
    override func configuration(shielding application: ApplicationToken, in category: ActivityCategoryToken) -> ShieldConfiguration {
        return generateShieldConfiguration(for: application)
    }
    
    override func configuration(shielding webDomain: WebDomainToken) -> ShieldConfiguration {
        // Fallback for web domains
        return generateShieldConfiguration(for: nil, hostname: webDomain.description)
    }
    
    private func generateShieldConfiguration(for application: ApplicationToken?, hostname: String? = nil) -> ShieldConfiguration {
        let store = UserDefaults(suiteName: "group.com.harshitjn.nonsenseblocker") ?? UserDefaults.standard
        let keyValueStoreBridge = UserDefaultsKeyValueStore(defaults: store)
        let sessionManager = BlockSessionManager(store: keyValueStoreBridge, totalRequiredClicks: totalClicks)
        
        // Resolve app hostname/display name for roasting
        let appName = application.flatMap { getDisplayName(for: $0, from: store) } ?? hostname ?? "this app"
        let roast = QuotesDatabase.getRoast(for: appName)
        
        let clicks = sessionManager.currentClicks
        let currentQuote = sessionManager.currentQuote
        
        // Customize text
        let titleText = roast.title
        let subtitleText = """
        \(roast.subtitle)
        
        --------------------------------------------
        \(currentQuote)
        --------------------------------------------
        
        🎯 Challenge Progress: \(clicks) / \(totalClicks) quotes read.
        """
        
        let buttonLabel = clicks == 0 ? "Begin Pause (0/\(totalClicks))" : "Next Quote (\(clicks)/\(totalClicks))"
        
        return ShieldConfiguration(
            backgroundMaterial: .ultraThinMaterial,
            backgroundColor: .black,
            icon: UIImage(systemName: "hand.raised.fill")?.withTintColor(.systemGreen),
            title: ShieldConfiguration.Label(text: titleText, color: .white),
            subtitle: ShieldConfiguration.Label(text: subtitleText, color: .lightGray),
            primaryButtonLabel: ShieldConfiguration.Label(text: buttonLabel, color: .black),
            primaryButtonBackgroundColor: .systemGreen,
            secondaryButtonLabel: ShieldConfiguration.Label(text: "Cancel", color: .systemRed)
        )
    }
    
    // MARK: - App Name Resolution Helper
    
    private func getDisplayName(for application: ApplicationToken, from store: UserDefaults) -> String? {
        let encoder = JSONEncoder()
        guard let tokenData = try? encoder.encode(application) else { return nil }
        let key = tokenData.base64EncodedString()
        let mappings = store.dictionary(forKey: "NonsenseBlocker_TokenDisplayNameMappings") as? [String: String]
        return mappings?[key]
    }
}

/// A wrapper helper to bridge UserDefaults to our KeyValueStore protocol.
private class UserDefaultsKeyValueStore: KeyValueStore {
    private let defaults: UserDefaults
    
    init(defaults: UserDefaults) {
        self.defaults = defaults
    }
    
    func set(_ value: Any?, forKey defaultName: String) {
        defaults.set(value, forKey: defaultName)
    }
    
    func string(forKey defaultName: String) -> String? {
        defaults.string(forKey: defaultName)
    }
    
    func integer(forKey defaultName: String) -> Int {
        defaults.integer(forKey: defaultName)
    }
    
    func double(forKey defaultName: String) -> Double {
        defaults.double(forKey: defaultName)
    }
    
    func bool(forKey defaultName: String) -> Bool {
        defaults.bool(forKey: defaultName)
    }
    
    func removeObject(forKey defaultName: String) {
        defaults.removeObject(forKey: defaultName)
    }
}
