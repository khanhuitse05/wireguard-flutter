// SPDX-License-Identifier: MIT
// Copyright © 2018-2023 WireGuard LLC. All Rights Reserved.

import Foundation
import Security

class Keychain {
    static func openReference(called ref: Data) -> String? {
        var result: CFTypeRef?
        let ret = SecItemCopyMatching([kSecValuePersistentRef: ref,
                                        kSecReturnData: true] as CFDictionary,
                                       &result)
        if ret != errSecSuccess || result == nil {
            print("Unable to open config from keychain: \(ret)")
            return nil
        }
        guard let data = result as? Data else { return nil }
        return String(data: data, encoding: String.Encoding.utf8)
    }

    static func makeReference(containing value: String, called name: String, previouslyReferencedBy oldRef: Data? = nil) -> Data? {
        var ret: OSStatus
        guard let bundleIdentifier = Bundle.main.bundleIdentifier else {
            print("Unable to determine bundle identifier")
            return nil
        }
        
        let appGroupIdInfoDictionaryKey = "group.com.turisvpn.app"
        let itemLabel = "WireGuard Tunnel: \(name)"
        var items: [CFString: Any] = [kSecClass: kSecClassGenericPassword,
                                    kSecAttrLabel: itemLabel,
                                    kSecAttrAccount: name + ": " + UUID().uuidString,
                                    kSecAttrDescription: "wg-quick(8) config",
                                    kSecAttrService: bundleIdentifier,
                                    kSecValueData: value.data(using: .utf8) as Any,
                                    kSecReturnPersistentRef: true]

        #if os(iOS)
        items[kSecAttrAccessGroup] = appGroupIdInfoDictionaryKey
        items[kSecAttrAccessible] = kSecAttrAccessibleAfterFirstUnlock
        #else
        #error("Unimplemented")
        #endif

        var ref: CFTypeRef?
        ret = SecItemAdd(items as CFDictionary, &ref)
        if ret != errSecSuccess || ref == nil {
            print("Unable to add config to keychain: \(ret)")
            print("Items: \(items)")
            return nil
        }
        if let oldRef = oldRef {
            deleteReference(called: oldRef)
        }
        return ref as? Data
    }

    static func deleteReference(called ref: Data) {
        let ret = SecItemDelete([kSecValuePersistentRef: ref] as CFDictionary)
        if ret != errSecSuccess {
            print("Unable to delete config from keychain: \(ret)")
        }
    }

    static func deleteReferences(except whitelist: Set<Data>) {
        var result: CFTypeRef?
        let ret = SecItemCopyMatching([kSecClass: kSecClassGenericPassword,
                                       kSecAttrService: Bundle.main.bundleIdentifier as Any,
                                       kSecMatchLimit: kSecMatchLimitAll,
                                       kSecReturnPersistentRef: true] as CFDictionary,
                                      &result)
        if ret != errSecSuccess || result == nil {
            return
        }
        guard let items = result as? [Data] else { return }
        for item in items {
            if !whitelist.contains(item) {
                deleteReference(called: item)
            }
        }
    }

    static func verifyReference(called ref: Data) -> Bool {
        return SecItemCopyMatching([kSecValuePersistentRef: ref] as CFDictionary,
                                   nil) != errSecItemNotFound
    }
}
