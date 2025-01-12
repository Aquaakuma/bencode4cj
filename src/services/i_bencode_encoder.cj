package bencode4cj.services

import encoding.json.*
import std.collection.*

public interface IBencodeEncoder {
    func encodeInteger(): String
    func encodeString(): String
    func encodeList(): String
    func encodeDict(): String
    func encode(): String
}
