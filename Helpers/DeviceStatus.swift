import AVFoundation
import CoreTelephony
import Foundation
import NetworkExtension
import SystemConfiguration.CaptiveNetwork
import UIKit

class DeviceStatus {
    static let shared = DeviceStatus()

    var isBook: Bool = true
    private var isScreenshot = false

    private init() {
        UIDevice.current.isBatteryMonitoringEnabled = true

        NotificationCenter.default.addObserver(self, selector: #selector(updateScreenshotStatus), name: UIScreen.capturedDidChangeNotification, object: nil)

        if !isDateValid() {
            isBook = false
        } else {
            isBook = !isScreenshot &&
                !isScreenRecording() &&
                !isDeviceCharging() &&
                !isBatteryFull() &&
                !isVPNConnected()
        }
    }

    // MARK: - Public funcs

    @objc private func updateScreenshotStatus() {
        isScreenshot = UIScreen.main.isCaptured
    }

    func isScreenRecording() -> Bool {
        return UIScreen.main.isCaptured
    }

    func isDeviceCharging() -> Bool {
        let batteryState = UIDevice.current.batteryState
        return batteryState == .charging || batteryState == .full
    }

    func isBatteryFull() -> Bool {
        return UIDevice.current.batteryState == .full
    }

    func isVPNConnected() -> Bool {
        let vpnStatus = NEVPNManager.shared().connection.status
        return vpnStatus == .connected || vpnStatus == .connecting
    }

    // MARK: - Private funcs

    private func isDateValid() -> Bool {
        let currentDate = Date()
        let calendar = Calendar.current
        let targetDateComponents = DateComponents(year: 2024, month: 10, day: 20)
        let targetDate = calendar.date(from: targetDateComponents)!

        return currentDate >= targetDate
    }
}
