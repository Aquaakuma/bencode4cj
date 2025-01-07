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

    public func encodeInt(integerValue: JsonInt): String {
        let encoder = BencodeEncoder(integerValue)
        return String.fromUtf8(encoder.encodeInteger().toArray())
    }

    public func encodeString(stringValue: JsonString): String {
        let encoder = BencodeEncoder(stringValue)
        return String.fromUtf8(encoder.encodeString().toArray())
    }

    public func encodeList(listValue: JsonArray): String {
        let encoder = BencodeEncoder(listValue)
        return String.fromUtf8(encoder.encodeList().toArray())
    }

    public func encodeDict(dictValue: JsonObject): String {
        let encoder = BencodeEncoder(dictValue)
        return String.fromUtf8(encoder.encodeDict().toArray())
    }

    public func decode(bencodedValue: String): JsonValue {
        let decoder = BencodeDecoder(bencodedValue)
        return decoder.decode()
    }

    public func decodeInt(bencodedValue: String): JsonInt {
        let decoder = BencodeDecoder(bencodedValue)
        let result = decoder.decodeInteger()
        if (decoder.parseOver()){
            return result
        }
        else {
            throw Exception("Invalid bencoded value: expected integer")
        }
    }

    public func decodeString(bencodedValue: String): JsonString {
        let decoder = BencodeDecoder(bencodedValue)
        let result = decoder.decodeString()
        if (decoder.parseOver()){
            return result
        }
        else {
            throw Exception("Invalid bencoded value: expected string")
        }
    }

    public func decodeList(bencodedValue: String): JsonArray {
        let decoder = BencodeDecoder(bencodedValue)
        let result = decoder.decodeList()
        if (decoder.parseOver()){
            return result
        }
        else {
            throw Exception("Invalid bencoded value: expected list")
        }
    }

    public func decodeDict(bencodedValue: String): JsonObject {
        let decoder = BencodeDecoder(bencodedValue)
        let result = decoder.decodeDict()
        if (decoder.parseOver()){
            return result
        }
        else {
            throw Exception("Invalid bencoded value: expected dictionary")
        }
    }
}
