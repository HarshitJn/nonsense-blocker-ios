import Foundation
import Combine
import ManagedSettings
import FamilyControls

/// Manages applying and removing shields on iOS using the Screen Time ManagedSettings API.
public class BlockManager: ObservableObject {
    public static let shared = BlockManager()
    
    private let store = ManagedSettingsStore()
    private let userDefaults: UserDefaults?
    
    private let selectionKey = "NonsenseBlocker_ActivitySelection"
    private let isEnabledKey = "NonsenseBlocker_IsEnabled"
    
    @Published public var isBlockingEnabled = false {
        didSet {
            userDefaults?.set(isBlockingEnabled, forKey: isEnabledKey)
            if isBlockingEnabled {
                applyShields()
            } else {
                removeShields()
            }
        }
    }
    
    @Published public var activitySelection = FamilyActivitySelection() {
        didSet {
            saveSelection(activitySelection)
            if isBlockingEnabled {
                applyShields()
            }
        }
    }
    
    private init() {
        // Use App Group suite to share settings with Shield Extensions
        self.userDefaults = UserDefaults(suiteName: "group.com.harshitjn.nonsenseblocker")
        
        // Load stored state
        self.isBlockingEnabled = userDefaults?.bool(forKey: isEnabledKey) ?? false
        self.activitySelection = loadSelection()
        
        // Ensure shields are in sync on app launch
        if isBlockingEnabled {
            applyShields()
        } else {
            removeShields()
        }
    }
    
    /// Applies shields to the selected applications and categories.
    public func applyShields() {
        let apps = activitySelection.applicationTokens
        let categories = activitySelection.categoryTokens
        let webDomains = activitySelection.webDomainTokens
        
        // Shield specific applications
        if !apps.isEmpty {
            store.shield.applications = apps
        } else {
            store.shield.applications = nil
        }
        
        // Shield app categories
        if !categories.isEmpty {
            store.shield.applicationCategories = .specific(categories)
        } else {
            store.shield.applicationCategories = nil
        }
        
        // Shield web domains
        if !webDomains.isEmpty {
            store.shield.webDomains = webDomains
        } else {
            store.shield.webDomains = nil
        }
    }
    
    /// Removes all shields.
    public func removeShields() {
        store.shield.applications = nil
        store.shield.applicationCategories = nil
        store.shield.webDomains = nil
    }
    
    /// Helper to remove a single application from the blocked list (used when challenge completes).
    public func unblockSingleApplication(_ token: ApplicationToken) {
        var currentApps = store.shield.applications ?? []
        currentApps.remove(token)
        store.shield.applications = currentApps.isEmpty ? nil : currentApps
    }
    
    // MARK: - Serialization Helpers
    
    private func saveSelection(_ selection: FamilyActivitySelection) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(selection) {
            userDefaults?.set(encoded, forKey: selectionKey)
        }
    }
    
    private func loadSelection() -> FamilyActivitySelection {
        guard let data = userDefaults?.data(forKey: selectionKey) else {
            return FamilyActivitySelection()
        }
        let decoder = JSONDecoder()
        return (try? decoder.decode(FamilyActivitySelection.self, from: data)) ?? FamilyActivitySelection()
    }
}
