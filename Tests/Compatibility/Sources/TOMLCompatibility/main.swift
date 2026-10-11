import Foundation
import TOML

struct Config: Codable, Equatable {
    var port: UInt16
    var dns: DNS
    var proxies: [Proxy]
    struct DNS: Codable, Equatable { var nameserver: [String] }
    struct Proxy: Codable, Equatable { var name: String; var port: UInt16 }
}

struct Value<T: Codable>: Codable { var value: T }
enum CheckFailure: Error { case mismatch; case expectedError }

func expectFailure(_ action: () throws -> Void) throws {
    do { try action() } catch is TOMLDecodingError { return } catch is TOMLEncodingError { return }
    throw CheckFailure.expectedError
}

let input = """
    port = 65535
    [dns]
    nameserver = ["1.1.1.1", "tls://example.invalid"]
    [[proxies]]
    name = "测试\\u0000节点"
    port = 443
    """
let config = try TOMLDecoder().decode(Config.self, from: input)
let output = try TOMLEncoder().encode(config)
guard try TOMLDecoder().decode(Config.self, from: output) == config else { throw CheckFailure.mismatch }
for input in ["value = -1", "value = 65536"] {
    try expectFailure { _ = try TOMLDecoder().decode(Value<UInt16>.self, from: input) }
}
try expectFailure { _ = try TOMLEncoder().encode(Value(value: UInt64.max)) }
try expectFailure { _ = try TOMLDecoder().decode(Config.self, from: "port = = 443") }
print("TOML compatibility checks passed")
