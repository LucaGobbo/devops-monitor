
/// Azure DevOps wraps lists as `{ "count": n, "value": [...] }`.
struct ListResponseDTO<Item: Decodable>: Decodable {
    var value: [Item]
}
