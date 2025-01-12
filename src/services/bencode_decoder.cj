package bencode4cj.services


import encoding.json.*
import std.collection.*

public const ASCII_MINUS: Byte = 45
public const ASCII_0: Byte = 48
public const ASCII_1: Byte = 49
public const ASCII_9: Byte = 57
public const ASCII_COLON: Byte = 58
public const ASCII_d: Byte = 100
public const ASCII_e: Byte = 101
public const ASCII_i: Byte = 105
public const ASCII_l: Byte = 108



public class BencodeDecoder <: IBencodeDecoder {
    private let encodedValue: Array<Byte>
    public var probe: Int64 = 0

    public BencodeDecoder(encodedValue: Array<Byte>) {
        this.encodedValue = encodedValue.toArray()
    }

    private func currentChar(): Option<Byte> {
        try {
            return encodedValue[probe]
        } catch (e: Exception) {
            return None
        }
    }

    private func nextChar(): Option<Byte> {
        try {
            return encodedValue[probe + 1]
        } catch (e: Exception) {
            return None
        }
    }

    public func parseOver(): Bool {
        // probe越界时，代表解析结束
        if (this.probe == this.encodedValue.size) {
            return true
        }
        return false
    }

    private func parseType(): Option<String> {
        if (let Some(currentChar) <- this.currentChar()) {
            match (currentChar) {
                case 100 => return "dictionary" // ASCII code for 'd'
                case 108 => return "list" // ASCII code for 'l'
                case 105 => return "integer" // ASCII code for 'i'
                case 48|49|50|51|52|53|54|55|56|57|45 => return "string" // ASCII code from '0' to '9' and '-'
                case _ => return None
            }
        }
        else {
            return None
        }

    }

    public func decodeInteger():JsonInt {
        // 检查编码是否以'i'开头
        if (let Some(currentChar) <- currentChar()) {
            if (currentChar != ASCII_i) { // ASCII code for 'i'
                throw Exception("Invalid bencoded value: missing 'i' at the start")
            }
        }
        else {
            throw Exception("Invalid bencoded value: Out-of-Bounds Access")
        }

        probe++
        var sign:Int64 = 1
        var integer:Int64 = 0

        // 检查是否以'0'开头
        if (let Some(currentChar) <- currentChar()) {
            if (currentChar == ASCII_0) { // ASCII code for '0'
                throw Exception("Invalid bencoded value: invalid character in integer") 
            }
        }
        else {
            throw Exception("Invalid bencoded value: Out-of-Bounds Access")
        }

        // 检查是否以非法'-'开头
        if (let Some(currentChar) <- currentChar()) {
            if (currentChar == ASCII_MINUS) { // ASCII code for '-'
                if (let Some(nextChar) <- nextChar()) {
                    if (nextChar < ASCII_1 || 
                        nextChar > ASCII_9
                    ) { // 不合法负数
                        throw Exception("Invalid bencoded value: invalid character in integer")
                    }
                    sign = -1
                    probe++
                }
                else {
                    throw Exception("Invalid bencoded value: Out-of-Bounds Access")
                }
            }
        }
        else {
            throw Exception("Invalid bencoded value: Out-of-Bounds Access")
        }


        // 开始解析整数
        
        while (let Some(currentChar) <- currentChar()) {

            if (currentChar == ASCII_e) {  // ASCII code for 'e'
                probe++
                let result = JsonInt(integer * sign)
                return result
            }

            if (currentChar < ASCII_0 || currentChar > ASCII_9) { // ASCII code from '0' to '9'
                throw Exception("Invalid bencoded value: invalid character in integer")
            }

            integer = integer * 10 + Int64(currentChar - ASCII_0)
            probe++
        }

        throw Exception("Invalid bencoded value: Out-of-Bounds Access")

    }

    public func decodeString():JsonString {
        var strLength: Int64 = 0

        if (let Some(currentChar) <- currentChar()) {
            if (currentChar < ASCII_0 || currentChar > ASCII_9) { // ASCII code from '0' to '9'
                throw Exception("Invalid bencoded value: missing positive number at the start")
            }
            strLength = Int64(currentChar - ASCII_0)
            probe++
        }
        else {
            throw Exception("Invalid bencoded value: Out-of-Bounds Access")
        }
        

        // 解析字符串长度
        while (true) {
            if (let Some(currentChar) <- currentChar()){
                if (currentChar == ASCII_COLON) { // ASCII code for ':'
                    probe++
                    break
                }

                if (currentChar < ASCII_0 || currentChar > ASCII_9) { // ASCII code from '0' to '9'
                    throw Exception("Invalid bencoded value: invalid character in string length")
                }

                strLength = strLength * 10 + Int64(currentChar - ASCII_0)
                probe++
            }
            else {
                throw Exception("Invalid bencoded value: Out-of-Bounds Access")
            }
        }

        // 解析字符串
        var charList: ArrayList<Byte> = ArrayList<Byte>()

        for (_ in 0..strLength) {
            if (let Some(currentChar) <- currentChar()) {
                charList.append(currentChar)
                probe++
            }
            else {
                throw Exception("Invalid bencoded value: Out-of-Bounds Access")
            }
        }

        return JsonString(String.fromUtf8(charList.toArray()))
    }

    public func decodeList():JsonArray {
        // 检查列表是否以'l'开头
        if (let Some(currentChar) <- currentChar()) {
            if (currentChar != ASCII_l) { // ASCII code for 'l'
                throw Exception("Invalid bencoded value: missing 'l' at the start")
            }
        }
        else {
            throw Exception("Invalid bencoded value: Out-of-Bounds Access")
        }

        // 解析列表
        let list: JsonArray = JsonArray()
        var safeBreak: Bool = false
        probe++
        while (let Some(currentChar) <- currentChar()) {
            if (currentChar == ASCII_e) { // ASCII code for 'e'
                safeBreak = true
                probe++
                break
            }
            
            let decodedValue = decode()
            list.add(decodedValue)

        }

        if (!safeBreak) {
            throw Exception("Invalid bencoded value: missing 'e' at the end")
        }

        return list
    }

    public func decodeDict():JsonObject {
        // 检查字典是否以'd'开头
        if (let Some(currentChar) <- currentChar()) {
            if (currentChar != ASCII_d) { // ASCII code for 'd'
                throw Exception("Invalid bencoded value: missing 'd' at the start")
            }
        }
        else {
            throw Exception("Invalid bencoded value: Out-of-Bounds Access")
        }

        // 解析字典
        let dict: HashMap<String, JsonValue> = HashMap<String, JsonValue>()
        var safeBreak: Bool = false
        probe++
        while (let Some(currentChar) <- currentChar()) {
            if (currentChar == ASCII_e) { // ASCII code for 'e'
                safeBreak = true 
                probe++
                break
            }
            let key = decode()

            let value = decode()

            if (key is JsonString) {
                dict[key.asString().getValue()] = value
            }
            else {
                throw Exception("Invalid bencoded value: key is not a string")
            }
            
        }

        if (!safeBreak) {
            throw Exception("Invalid bencoded value: missing 'e' at the end")
        }

        return JsonObject(dict)
    }

    public func decode():JsonValue {
        if (let Some(parseType) <- parseType()) {
            match (parseType) {
                case "integer" => 
                    return decodeInteger()
                case "string" => 
                    return decodeString()
                case "list" => 
                    return decodeList()
                case "dictionary" =>
                    return decodeDict()
                case _ => 
                    throw Exception("Invalid bencoded value: unknown type")
            }            
        }
        else {
            throw Exception("Invalid bencoded value: unknown type")
        }
    }

}
