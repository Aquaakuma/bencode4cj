package bencode4cj.services

import encoding.json.*
import std.collection.*

public interface IBencodeEncoder {
    func encodeInteger(): ArrayList<Byte>
    func encodeString(): ArrayList<Byte>
    func encodeList(): ArrayList<Byte>
    func encodeDict(): ArrayList<Byte>
    func encode(): ArrayList<Byte>
}
