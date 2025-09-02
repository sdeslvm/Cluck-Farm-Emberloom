import Foundation
import AVFoundation
import CoreLocation
import AppTrackingTransparency

// MARK: - Manager Implementation Implementation Cluck Farm

@MainActor
class CluckFarmPermissionsManager: NSObject, ObservableObject {
    @Published var cameraPermissionStatus: AVAuthorizationStatus = .notDetermined
    @Published var locationPermissionStatus: CLAuthorizationStatus = .notDetermined
    @Published var trackingPermissionStatus: ATTrackingManager.AuthorizationStatus = .notDetermined
    
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.delegate = self
        checkAllPermissions()
    }
    
    func checkAllPermissions() {
        cameraPermissionStatus = AVCaptureDevice.authorizationStatus(for: .video)
        locationPermissionStatus = locationManager.authorizationStatus
        trackingPermissionStatus = ATTrackingManager.trackingAuthorizationStatus
    }
    
    func requestCameraPermission() async {
        _ = await AVCaptureDevice.requestAccess(for: .video)
        self.cameraPermissionStatus = AVCaptureDevice.authorizationStatus(for: .video)
    }
    
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func requestTrackingPermission() async {
        let status = await ATTrackingManager.requestTrackingAuthorization()
        self.trackingPermissionStatus = status
    }
    
    var allPermissionsGranted: Bool {
        return cameraPermissionStatus == .authorized &&
               locationPermissionStatus == .authorizedWhenInUse &&
               trackingPermissionStatus == .authorized
    }
    
    var hasRequiredPermissions: Bool {
        return cameraPermissionStatus != .denied &&
               locationPermissionStatus != .denied &&
               trackingPermissionStatus != .denied
    }
}

@MainActor
extension CluckFarmPermissionsManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.locationPermissionStatus = status
    }
}
