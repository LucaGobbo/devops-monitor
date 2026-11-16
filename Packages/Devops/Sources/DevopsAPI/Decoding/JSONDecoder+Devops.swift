import Foundation

extension JSONDecoder {
    static func devops() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let string = try decoder.singleValueContainer().decode(String.self)
            guard let date = AzureDate.parse(string) else {
                throw DecodingError.dataCorrupted(
                    .init(codingPath: decoder.codingPath, debugDescription: "Unsupported date format: \(string)")
                )
            }
            return date
        }
        return decoder
    }
}
