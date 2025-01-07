package bencode4cj.services

import encoding.json.*
import std.collection.*
import bencode4cj.services.common_constant.*

public class BencodeEncoder <: IBencodeEncoder {
    private let uncodedValue: JsonValue

    public BencodeEncoder(uncodedValue: JsonValue) {
        this.uncodedValue = uncodedValue
    }

    public func encodeInteger(): ArrayList<Byte> {
        // 利用ArrayList的特性，拼接字符串编码
        let encodedInteger: ArrayList<Byte> = ArrayList()
        encodedInteger.append(ASCII_i)

        // 解析JsonInt
        if (uncodedValue is JsonInt) {
            let integer: Int64 = uncodedValue.asInt().getValue()
            encodedInteger.appendAll(integer.toString().toArray())
        } else {
            throw Exception("Invalid json object: json is not an JsonInt")
        }

        encodedInteger.append(ASCII_e)

        return encodedInteger
    }

    public func encodeString(): ArrayList<Byte> {
        // 计算长度，然后拼接

        let encodedString: ArrayList<Byte> = ArrayList()

        // 解析JsonString
        if (uncodedValue is JsonString) {
            let string: String = uncodedValue.asString().getValue()
            let strLength: Int64 = string.size
            encodedString.appendAll(strLength.toString().toArray())
            encodedString.append(ASCII_COLON)
            encodedString.appendAll(string.toArray())
        } else {
            throw Exception("Invalid json object: json is not an JsonString")
        }

        return encodedString
    }
    public func encodeList(): ArrayList<Byte> {
        // 第一个字符放l，然后遍历列表，解码元素，拼接，末尾添e
        let encodedList: ArrayList<Byte> = ArrayList()
        encodedList.append(ASCII_l) // 起始字符'l'
        if (uncodedValue is JsonArray) {
            for (jsonValueItem in uncodedValue.asArray().getItems()) {
                let encodeder = BencodeEncoder(jsonValueItem)
                let encodedItem = encodeder.encode()
                encodedList.appendAll(encodedItem)
            }
        }
        encodedList.append(ASCII_e)
        return encodedList
    }
    public func encodeDict(): ArrayList<Byte> {
        // 第一个字符放d，然后遍历字典，解码元素，拼接，末尾添e
        let encodedDict: ArrayList<Byte> = ArrayList()
        encodedDict.append(ASCII_d)

        // 编码字典
        if (uncodedValue is JsonObject) {
            let hashMap = uncodedValue.asObject().getFields()
            let treeMap: TreeMap<String, JsonValue> = TreeMap()
            treeMap.putAll(hashMap) // 将HashMap转换为TreeMap，利用TreeMap的特性，使其元素有序

            for ((key, value) in treeMap) {
                let encodederOfKey = BencodeEncoder(JsonString(key))
                let encodedKey = encodederOfKey.encode()

                let encodederOfValue = BencodeEncoder(value)
                let encodedValue = encodederOfValue.encode()

                encodedDict.appendAll(encodedKey)
                encodedDict.appendAll(encodedValue)
            }
        }

        encodedDict.append(ASCII_e)
        return encodedDict
    }

    public func encode(): ArrayList<Byte> {
        match (uncodedValue.kind()) {
            case JsInt => return encodeInteger()
            case JsString => return encodeString()
            case JsArray => return encodeList()
            case JsObject => return encodeDict()
            case _ => throw Exception("Invalid json object: json object can be one of JsonInt, JsonString, JsonArray, JsonObject")
        }
    }
}
