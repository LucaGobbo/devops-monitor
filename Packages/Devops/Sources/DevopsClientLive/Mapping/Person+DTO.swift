import DevopsAPI
import DevopsClient
import Foundation

extension Person {
    init(_ dto: IdentityDTO) { self.init(id: dto.id, displayName: dto.displayName) }
    init(_ dto: ConnectionDataDTO.AuthenticatedUserDTO) { self.init(id: dto.id, displayName: dto.providerDisplayName) }
}
