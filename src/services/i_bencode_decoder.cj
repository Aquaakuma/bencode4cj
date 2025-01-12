package bencode4cj.services

import encoding.json.*

public interface IBencodeDecoder {
    func decodeInteger(): JsonInt
    func decodeString(): JsonString
    func decodeList(): JsonArray
    func decodeDict(): JsonObject
    func decode(): JsonValue
}