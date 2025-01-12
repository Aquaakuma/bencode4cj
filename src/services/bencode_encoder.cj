package bencode4cj.services

import encoding.json.*
import std.collection.*
import std.core.*


public class BencodeEncoder <: IBencodeEncoder {
    private let uncodedValue: JsonValue

    public BencodeEncoder(uncodedValue: JsonValue) {
        this.uncodedValue = uncodedValue
    }

    public func encodeInteger(): String {
        // 利用ArrayList的特性，拼接字符串编码
        let encodedInteger = StringBuilder()
        encodedInteger.append('i')

        // 解析JsonInt
        if (uncodedValue is JsonInt) {
            let integer: Int64 = uncodedValue.asInt().getValue()
            encodedInteger.append(integer.toString())
        } else {
            throw Exception("Invalid json object: json is not an JsonInt")
        }

        encodedInteger.append('e')

        return encodedInteger.toString()
    }

    public func encodeString(): String {
        // 计算长度，然后拼接

        let encodedString = StringBuilder()

        // 解析JsonString
        if (uncodedValue is JsonString) {
            let string: String = uncodedValue.asString().getValue()
            let strLength: Int64 = string.size
            encodedString.append(strLength.toString())
            encodedString.append(':')
            encodedString.append(string)
        } else {
            throw Exception("Invalid json object: json is not an JsonString")
        }

        return encodedString.toString()
    }
    public func encodeList(): String {
        // 第一个字符放l，然后遍历列表，解码元素，拼接，末尾添e
        let encodedList = StringBuilder()
        encodedList.append('l') // 起始字符'l'
        if (uncodedValue is JsonArray) {
            for (jsonValueItem in uncodedValue.asArray().getItems()) {
                let encodeder = BencodeEncoder(jsonValueItem)
                let encodedItem = encodeder.encode()
                encodedList.append(encodedItem)
            }
        }
        encodedList.append('e')
        return encodedList.toString()
    }
    public func encodeDict(): String {
        // 第一个字符放d，然后遍历字典，解码元素，拼接，末尾添e
        let encodedDict = StringBuilder()
        encodedDict.append('d') // 起始字符'd'

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

                encodedDict.append(encodedKey)
                encodedDict.append(encodedValue)
            }
        }

        encodedDict.append('e')
        return encodedDict.toString()
    }

    public func encode(): String {
        match (uncodedValue.kind()) {
            case JsInt => return encodeInteger()
            case JsString => return encodeString()
            case JsArray => return encodeList()
            case JsObject => return encodeDict()
            case _ => throw Exception("Invalid json object: json object can be one of JsonInt, JsonString, JsonArray, JsonObject")
        }
    }
}
