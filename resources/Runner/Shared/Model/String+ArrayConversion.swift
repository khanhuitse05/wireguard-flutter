// SPDX-License-Identifier: MIT
// Copyright © 2018-2023 WireGuard LLC. All Rights Reserved.

import Foundation

extension String {

    func splitToArray(separator: Character = ",", trimmingCharacters: CharacterSet? = nil) -> [String] {
        return split(separator: separator)
            .map {
                if let charSet = trimmingCharacters {
                    return $0.trimmingCharacters(in: charSet)
                } else {
                    return String($0)
                }
        }
    }

}
