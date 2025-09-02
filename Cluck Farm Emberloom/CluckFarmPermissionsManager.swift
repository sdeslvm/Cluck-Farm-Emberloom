import Foundation

// MARK: - Manager for managing Implementation Cluck Farm

class CluckFarmPermissionsManager: NSObject, ObservableObject {
    
    override init() {
        super.init()
    }
    
    var allPermissionsGranted: Bool {
        return true
    }
    
    var hasRequiredPermissions: Bool {
        return true
    }
}
