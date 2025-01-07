# Bencode

Bencode 是一种简单的编码格式，用于表示数据结构，如列表、字典等。它常用于 BitTorrent 协议中。本库用仓颉encoding库的 `JsonArray` 和 `JsonObject` 表示列表和字典。

## 语法

Bencode 的语法如下：

* 整数：`i` 开头，后跟整数值，结尾为 `e`。例如：`i123e`
* 字符串：`:` 开头，后跟长度，后跟字符串值。例如：`5:hello`
* 列表：`l` 开头，后跟列表元素，结尾为 `e`。例如：`li1ei2ei3ee`
* 字典：`d` 开头，后跟键值对，结尾为 `e`。例如：`d3:fooi1e3:bari2ee`

## 编码器

本库提供了一个 Bencode 编码器，将 `JsonInt, JsonString, JsonArray 或 JsonObject` 数据编码为 Bencode 格式。

### 使用方法

1. 将数据类型转换成 `JsonValue` 类型
2. 调用 `Bencode` 的 `encode()` 方法获取编码后的 Bencode 字符串

### 示例

```cangjie
let json = JsonValue.fromStr({\"bar\": \"spam\", \"foo\": {\"bar\": 42}})
let encoder = Bencode()
let encodedValue = encoder.encode(json)
println(encoded) // 输出：d3:bar4:spam3:food3:bari42eee
```

## 解码器

本库提供了一个 Bencode 解码器，用于将 Bencode 格式解码为 `JsonVaule` 数据。

### 使用方法

1. 调用 `Bencode` 的 `decode()` 方法获得 `JsonValue` 类型数据
2. 将`JsonValue` 类型数据转换成需要的类型

### 示例

```cangjie
let bencode = "d3:bazd3:quxli1ei2eee3:food3:bari1eee"
let decoder = BencodeDecoder(bencode)
let decodedJson = decoder.decode()
println(decodedJson) // 输出：{\"foo\": {\"bar\": 1}, \"baz\": {\"qux\": [1, 2]}}
```

## 许可

本库使用 MIT 许可证。