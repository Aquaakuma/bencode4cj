package bencode4cj.tests

import bencode4cj.services.*
import std.collection.*
import std.unittest.*
import std.unittest.testmacro.*
import encoding.json.*


@Test
class BencodeEncodeTest {
    @TestCase
    public func testEncodeInteger(): Unit {
        let encoder = BencodeEncoder(JsonInt(123))
        let encoded = encoder.encode()
        @Expect(encoded, "i123e")
    }

    @TestCase
    public func testEncodeString(): Unit {
        let encoder = BencodeEncoder(JsonString("hello"))
        let encoded = encoder.encode()
        @Expect(encoded, "5:hello")
    }

    @TestCase
    public func testEncodeList(): Unit {
        let encoder = BencodeEncoder(JsonArray([JsonInt(1), JsonInt(2), JsonInt(3)]))
        let encoded = encoder.encode()
        @Expect(encoded, "li1ei2ei3ee")
    }

    @TestCase
    public func testEncodeDict(): Unit {
        let encoder = BencodeEncoder(JsonValue.fromStr("{\"foo\": 1, \"bar\": 2}"))
        let encoded = encoder.encode()
        @Expect(encoded, "d3:bari2e3:fooi1ee")
    }

    @TestCase
    public func testEncodeNestedList(): Unit {
        let encoder = BencodeEncoder(JsonArray([JsonArray([JsonInt(1), JsonInt(2)]), JsonArray([JsonInt(3), JsonInt(4)])]))
        let encoded = encoder.encode()
        @Expect(encoded, "lli1ei2eeli3ei4eee")
    }

    @TestCase
    public func testEncodeNestedDict(): Unit {
        let encoder = BencodeEncoder(JsonValue.fromStr("{\"foo\": {\"bar\": 1}, \"baz\": {\"qux\": [1, 2]}}"))
        let encoded = encoder.encode()
        @Expect(encoded, "d3:bazd3:quxli1ei2eee3:food3:bari1eee")
    }
}