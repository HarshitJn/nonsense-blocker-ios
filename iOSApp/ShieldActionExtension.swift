import ManagedSettings
import Foundation
import NonsenseBlockerCore

class ShieldActionExtension: ShieldActionDelegate {
    
    private let totalClicks = 25
    
    override func handle(action: ShieldAction, for application: ApplicationToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        handleAction(action: action, appIdentifier: getAppTokenKey(application), applicationToken: application, completionHandler: completionHandler)
    }
    
    override func handle(action: ShieldAction, for webDomain: WebDomainToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        handleAction(action: action, appIdentifier: webDomain.description, completionHandler: completionHandler)
    }
    
    private func handleAction(
        action: ShieldAction,
        appIdentifier: String,
        applicationToken: ApplicationToken? = nil,
        completionHandler: @escaping (ShieldActionResponse) -> Void
    ) {
        let store = UserDefaults(suiteName: "group.com.harshitjn.nonsenseblocker") ?? UserDefaults.standard
        let keyValueStoreBridge = UserDefaultsKeyValueStore(defaults: store)
        let sessionManager = BlockSessionManager(store: keyValueStoreBridge, totalRequiredClicks: totalClicks)
        
        switch action {
        case .primaryButtonPressed:
            // Tapped "Next Quote"
            let isCompleted = sessionManager.handlePrimaryButtonPress(appIdentifier: appIdentifier)
            
            if isCompleted {
                // Challenge completed!
                if let token = applicationToken {
                    // Remove the specific app token from the ManagedSettingsStore shields
                    let settingsStore = ManagedSettingsStore()
                    var apps = settingsStore.shield.applications ?? []
                    apps.remove(token)
                    settingsStore.shield.applications = apps.isEmpty ? nil : apps
                }
                
                // Allow the user to proceed into the app
                completionHandler(.none)
            } else {
                // Not completed yet, tell iOS to defer and redraw the shield with the next quote
                completionHandler(.defer)
            }
            
        case .secondaryButtonPressed:
            // Tapped "Cancel" - close the shield (returns user to Home screen)
            completionHandler(.close)
            
        @unknown default:
            completionHandler(.close)
        }
    }
    
    // MARK: - Helpers
    
    private func getAppTokenKey(_ token: ApplicationToken) -> String {
        let encoder = JSONEncoder()
        if let tokenData = try? encoder.encode(token) {
            return tokenData.base64EncodedString()
        }
        return token.hashValue.description
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
