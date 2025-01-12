package bencode4cj.tests

import bencode4cj.services.*
import std.collection.*
import std.unittest.*
import std.unittest.testmacro.*
import encoding.json.*

@Test
public class TestBencodeDecoderInteger {

    @TestCase
    // 测试解码有效的正整数
    public func testDecodeValidInteger():Unit {
        let decoder = BencodeDecoder("i123e".toArray())
        let result = decoder.decodeInteger()
        @Expect(result.toJsonString(), "123")
    }

    @TestCase
    // 测试解码有效的负整数
    public func testDecodeValidNegative():Unit {
        let decoder = BencodeDecoder("i-123e".toArray())
        let result = decoder.decodeInteger()
        @Expect(result.toJsonString(), "-123")
    }

    @TestCase
    // 测试解码无效的八进制整数（以'0'开头）
    public func testDecodeInvalidOctal():Unit {
        let decoder = BencodeDecoder("i0123e".toArray())
        try {
            decoder.decodeInteger()
            fail("Expected exception not thrown")
        } catch (e:Exception) {
            @Assert(e.message, "Invalid bencoded value: invalid character in integer")
        }
    }

    @TestCase
    // 测试解码无效的负零整数
    public func testDecodeInvalidNegativeZero():Unit {
        let decoder = BencodeDecoder("i-0123e".toArray())
        try {
            decoder.decodeInteger()
            fail("Expected exception not thrown")
        } catch (e:Exception) {
            @Assert(e.message, "Invalid bencoded value: invalid character in integer")
        }
    }

    @TestCase
    // 测试解码无效的整数（缺少'e'字符）
    public func testDecodeMissingEnd():Unit {
        let decoder = BencodeDecoder("i123".toArray())
        try {
            decoder.decodeInteger()
            fail("Expected exception not thrown")
        } catch (e:Exception) {
            @Assert(e.message, "Invalid bencoded value: Out-of-Bounds Access")
        }
    }

    @TestCase
    // 测试解码无效的整数（缺少'i'字符）
    public func testDecodeMissingIAtStart():Unit {
        let decoder = BencodeDecoder("123e".toArray())
        try {
            decoder.decodeInteger()
            fail("Expected exception not thrown")
        } catch (e:Exception) {
            @Assert(e.message, "Invalid bencoded value: missing 'i' at the start")
        }
    }
}


@Test
class BencodeDecoderStringTests {

    @TestCase
    // 测试解码有效的字符串
    public func testDecodeValidString():Unit {
        let decoder = BencodeDecoder("4:spam".toArray())
        let result = decoder.decodeString()
        let expected = JsonString("spam")
        @Expect(result.toJsonString(), expected.toJsonString())
    }

    @TestCase
    // 测试解码空字符串
    public func testDecodeEmptyString():Unit {
        let decoder = BencodeDecoder("0:".toArray())
        let result = decoder.decodeString()
        let expected = JsonString("")
        @Expect(result.toJsonString(), expected.toJsonString())
    }

    @TestCase
    // 测试解码无效的字符串（缺少冒号）
    public func testDecodeInvalidStringMissingColon():Unit {
        let decoder = BencodeDecoder("4spam".toArray())
        try {
            decoder.decodeString()
            fail("Expected exception not thrown")
        } catch (e:Exception) {
            @Assert(e.message, "Invalid bencoded value: invalid character in string length")
        }
    }

    @TestCase
    // 测试解码无效的字符串（长度超过数据）
    public func testDecodeInvalidStringLengthExceedsData():Unit {
        let decoder = BencodeDecoder("5:spam".toArray())
        try {
            decoder.decodeString()
            fail("Expected exception not thrown")
        } catch (e:Exception) {
            @Assert(e.message, "Invalid bencoded value: Out-of-Bounds Access")
        }
    }

    @TestCase
    // 测试解码无效的字符串（长度为负数）
    public func testDecodeInvalidStringLengthLessThanZero():Unit {
        let decoder = BencodeDecoder("-5:spam".toArray())
        try {
            decoder.decodeString()
            fail("Expected exception not thrown")
        } catch (e:Exception) {
            @Assert(e.message, "Invalid bencoded value: missing positive number at the start")
        }
    }

    @TestCase
    // 测试解码无效的字符串（无效的长度）
    public func testDecodeInvalidStringInvalidLength():Unit {
        let decoder = BencodeDecoder("a:spam".toArray())
        try {
            decoder.decodeString()
            fail("Expected exception not thrown")
        } catch (e:Exception) {
            @Assert(e.message, "Invalid bencoded value: missing positive number at the start")
        }
    }

    @TestCase
    // 测试解码无效的字符串（无法解析长度）
    public func testDecodeInvalidStringLengthCannotParse():Unit {
        let decoder = BencodeDecoder("1a:spam".toArray())
        try {
            decoder.decodeString()
            fail("Expected exception not thrown")
        } catch (e:Exception) {
            @Assert(e.message, "Invalid bencoded value: invalid character in string length")
        }
    }

}

@Test
class BencodeDecoderListTests {

    @TestCase
    // 测试解码有效的空列表
    public func testDecodeEmptyList():Unit {
        let decoder = BencodeDecoder("le".toArray())
        let result = decoder.decodeList()
        @Expect(result.toJsonString().trimAscii(), "[]")
    }

    @TestCase
    // 测试解码有效的整数列表
    public func testDecodeIntegerList():Unit {
        let decoder = BencodeDecoder("li1ei2ei3ee".toArray())
        let result = decoder.decodeList()
        let expected = JsonArray([JsonInt(1), JsonInt(2), JsonInt(3)])
        @Expect(result.toJsonString().trimAscii(), expected.toJsonString().trimAscii())
    }

    @TestCase
    // 测试解码有效的字符串列表
    public func testDecodeStringList():Unit {
        let decoder = BencodeDecoder("l4:spam4:eggse".toArray())
        let result = decoder.decodeList()
        let expected = JsonArray([JsonString("spam"), JsonString("eggs")])
        @Expect(result.toJsonString(), expected.toJsonString())
    }

    @TestCase
    // 测试解码有效的嵌套列表
    public func testDecodeNestedList():Unit {
        let decoder = BencodeDecoder("lli1ei2eel4:spam4:eggsee".toArray())
        let result = decoder.decodeList()
        @Expect(result.toString().trimAscii(), "[[1,2],[\"spam\",\"eggs\"]]")
    }

    @TestCase
    // 测试解码无效的列表（缺少'e'字符）
    public func testDecodeInvalidListMissingEnd():Unit {
        let decoder = BencodeDecoder("li1ei2ei3e".toArray())
        try {
            decoder.decodeList()
            fail("Expected exception not thrown")
        } catch (e:Exception) {
            @Assert(e.message, "Invalid bencoded value: missing 'e' at the end")
        }
    }

    @TestCase
    // 测试解码无效的列表（缺少'l'字符）
    public func testDecodeInvalidListMissingLAtStart():Unit {
        let decoder = BencodeDecoder("i1ei2ei3ee".toArray())
        try {
            decoder.decodeList()
            fail("Expected exception not thrown")
        } catch (e:Exception) {
            @Assert(e.message, "Invalid bencoded value: missing 'l' at the start")
        }
    }
}

@Test
class BencodeDecoderDictTests {

    @TestCase
    // 测试解码有效的空字典
    public func testDecodeEmptyDict():Unit {
        let decoder = BencodeDecoder("de".toArray())
        let result = decoder.decodeDict()
        @Expect(result.toJsonString(), "{}")
    }

    @TestCase
    // 测试解码有效的简单字典
    public func testDecodeSimpleDict():Unit {
        let decoder = BencodeDecoder("d3:bar4:spam3:fooi42ee".toArray())
        let result = decoder.decodeDict()
        let expected = JsonValue.fromStr("{\"bar\": \"spam\", \"foo\": 42}")
        @Expect(result.toJsonString(), expected.toJsonString())
    }

    @TestCase
    // 测试解码有效的嵌套字典
    public func testDecodeNestedDict():Unit {
        let decoder = BencodeDecoder("d3:bar4:spam3:food3:bari42eee".toArray())
        let result = decoder.decodeDict()
        let expected = JsonValue.fromStr("{\"bar\": \"spam\", \"foo\": {\"bar\": 42}}")
        @Expect(result.toJsonString(), expected.toJsonString())
    }

    @TestCase
    // 测试解码无效的字典（缺少'e'字符）
    public func testDecodeInvalidDictMissingEnd():Unit {
        let decoder = BencodeDecoder("d3:bar4:spam3:fooi42e".toArray())
        try {
            decoder.decodeDict()
            fail("Expected exception not thrown")
        } catch (e:Exception) {
            @Assert(e.message, "Invalid bencoded value: missing 'e' at the end")
        }
    }

    @TestCase
    // 测试解码无效的字典（缺少'd'字符）
    public func testDecodeInvalidDictMissingDAtStart():Unit {
        let decoder = BencodeDecoder("3:bar4:spam3:fooi42ee".toArray())
        try {
            decoder.decodeDict()
            fail("Expected exception not thrown")
        } catch (e:Exception) {
            @Assert(e.message, "Invalid bencoded value: missing 'd' at the start")
        }
    }
}