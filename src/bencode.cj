package bencode4cj

import std.convert.*
import bencode4cj.services.*
import std.collection.*
import encoding.json.*


public class Bencode {
    public func encode(jsonValue: JsonValue): String {
        let encoder = BencodeEncoder(jsonValue)
        return String.fromUtf8(encoder.encode().toArray())  
    }

    public func decode(bencodedValue: Array<Byte>): JsonValue {
        let decoder = BencodeDecoder(bencodedValue)
        return decoder.decode()
    }

}
