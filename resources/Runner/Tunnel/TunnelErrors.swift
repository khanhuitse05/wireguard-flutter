// SPDX-License-Identifier: MIT
// Copyright © 2018-2023 WireGuard LLC. All Rights Reserved.

import NetworkExtension
import WireGuardKit

protocol WireGuardAppError: Error {
    var message: String { get }
}

enum TunnelsManagerError: WireGuardAppError {
    case tunnelNameEmpty
    case tunnelAlreadyExistsWithThatName
    case systemErrorOnListingTunnels(systemError: Error)
    case systemErrorOnAddTunnel(systemError: Error)
    case systemErrorOnModifyTunnel(systemError: Error)
    case systemErrorOnRemoveTunnel(systemError: Error)

    var message: String {
        switch self {
        case .tunnelNameEmpty:
            return "alertTunnelNameEmptyTitle"
        case .tunnelAlreadyExistsWithThatName:
            return "alertTunnelAlreadyExistsWithThatNameTitle"
        case .systemErrorOnListingTunnels(_):
            return "alertSystemErrorOnListingTunnelsTitle"
        case .systemErrorOnAddTunnel(_):
            return "alertSystemErrorOnAddTunnelTitle"
        case .systemErrorOnModifyTunnel(_):
            return "alertSystemErrorOnModifyTunnelTitle"
        case .systemErrorOnRemoveTunnel(_):
            return "alertSystemErrorOnRemoveTunnelTitle"
        }
    }
}

enum TunnelsManagerActivationAttemptError: WireGuardAppError {
    case tunnelIsNotInactive
    case failedWhileStarting(systemError: Error) // startTunnel() throwed
    case failedWhileSaving(systemError: Error) // save config after re-enabling throwed
    case failedWhileLoading(systemError: Error) // reloading config throwed
    case failedBecauseOfTooManyErrors(lastSystemError: Error) // recursion limit reached

    var message: String {
        switch self {
        case .tunnelIsNotInactive:
            return "alertTunnelActivationErrorTunnelIsNotInactiveTitle"
        case .failedWhileStarting(_),
             .failedWhileSaving(_),
             .failedWhileLoading(_),
             .failedBecauseOfTooManyErrors(_):
            return "alertTunnelActivationErrorTunnelIsNotInactiveTitle"
        }
    }
}

extension PacketTunnelProviderError: WireGuardAppError {
    var message: String {
        switch self {
        case .savedProtocolConfigurationIsInvalid:
            return "alertTunnelActivationFailureTitle"
        case .dnsResolutionFailure:
            return "alertTunnelDNSFailureTitle"
        case .couldNotStartBackend:
            return "alertTunnelActivationFailureTitle"
        case .couldNotDetermineFileDescriptor:
            return "alertTunnelActivationFailureTitle"
        case .couldNotSetNetworkSettings:
            return "alertTunnelActivationFailureTitle"
        }
    }
}
