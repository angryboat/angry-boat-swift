//
//  Bundle.swift
//  angry-boat-swift
//
//  Created by Maddie Schipper on 1/29/25.
//

import Foundation

extension Bundle {
    public var bundleVersion: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
    
    public var bundleShortVersion: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
    public var bundleDisplayName: String? {
        return infoDictionary?["CFBundleDisplayName"] as? String
    }
    
    public var bundleHumanReadableCopyright: String? {
        return infoDictionary?["NSHumanReadableCopyright"] as? String
    }
    
    public var appIconName: String? {
        guard let icons = infoDictionary?["CFBundleIcons"] as? [String: Any] else {
            return infoDictionary?["CFBundleIconFile"] as? String
        }
        guard let primary = icons["CFBundlePrimaryIcon"] as? [String: Any] else {
            return infoDictionary?["CFBundleIconFile"] as? String
        }
        guard let files = primary["CFBundleIconFiles"] as? [String] else {
            return infoDictionary?["CFBundleIconFile"] as? String
        }
        
        return files.first
    }
}
