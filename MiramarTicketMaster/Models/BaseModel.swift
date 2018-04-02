//
//  BaseModel.swift
//  Cobinhood
//
//  Created by Wayne on 2017/9/25.
//  Copyright © 2017年 Cobinhood Inc. All rights reserved.
//

import Foundation

/// Defines undetermined keys that received from server
struct CustomKey: CodingKey {
	var intValue: Int?
	var stringValue: String
	
	init?(intValue: Int) {
		self.intValue = intValue
		self.stringValue = ""
	}
	
	init?(stringValue: String) {
		self.stringValue = stringValue
	}
	
	/// This key is used to encode a codable object.
	static let dynamic = CustomKey(stringValue: "dynamic")!
}

/// This presents all the root keys in response data.
///
/// - result: `result` key
/// - error: `error` key
enum SharedKeys: String, CodingKey {
	case result = "Data"
    case error
	case requestId = "request_id"
}

/// This enum determines where the data should be decode
///
/// - root: From root of JSON
/// - inResult: From `result` key in JSON
/// - inResultObject: From the object key in `result` in JSON
enum DecodeSource {
	case root
	case inResult
	case inResultObject
}

/// This class controls the behaviour of decoding the container.
class DecodingSourceControl {
	var ignoreSource: Bool = false
}

extension CodingUserInfoKey {
	static let source = CodingUserInfoKey(rawValue: "source")!
	static let objectKey = CodingUserInfoKey(rawValue: "objectKey")!
	static let sourceControl = CodingUserInfoKey(rawValue: "sourceControl")!
}

extension Dictionary where Key == CodingUserInfoKey {
	
	/// Get decoding source
	internal func source(for key: CodingUserInfoKey) -> DecodeSource? {
		guard let _source = self[key] as? DecodeSource else {
			return nil
		}
		return _source
	}
	
	internal var source: DecodeSource? {
		return source(for: .source)
	}
	
	/// Get coding key
	internal func codingKey(for key: CodingUserInfoKey) -> CustomKey? {
		guard let _codingKey = self[key] as? CustomKey else {
			return nil
		}
		return _codingKey
	}
	
	internal var codingKey: CustomKey? {
		return codingKey(for: .objectKey)
	}
	
	/// Get source control object
	internal func sourceControl(for key: CodingUserInfoKey) -> DecodingSourceControl? {
		guard let _sourceControl = self[key] as? DecodingSourceControl else {
			return nil
		}
		return _sourceControl
	}
	
	internal var sourceControl: DecodingSourceControl? {
		return sourceControl(for: .sourceControl)
	}
}

/// Dynamic object decodes and encodes a single object with a dynamic key.
///
/// Decode for the following JSON format:
///
/// ```
/// {
///    "result": {
///	      "order": {
///          "order_id": "37f550a202aa6a3fe120f420637c894c",
///          "trading_pair_id": "BTC-USDT",
///          "status": "open",
///          ...
///       }
///    }
/// }
/// ```
/// The `'order'` is the dynamic key
internal struct DynamicObject<T: Codable>: Codable {
	private(set) var result: T
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: SharedKeys.self)
		let nested = try container.nestedContainer(keyedBy: CustomKey.self, forKey: .result)
		guard let key = nested.allKeys.first else {
			let context = DecodingError.Context(codingPath: nested.codingPath, debugDescription: "No avaliable keys.")
			throw DecodingError.dataCorrupted(context)
		}
		result = try nested.decode(T.self, forKey: key)
	}
	
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: SharedKeys.self)
		var nested = container.nestedContainer(keyedBy: CustomKey.self, forKey: .result)
		try nested.encode(result, forKey: .dynamic)
	}
	
	static func decode(_ data: Data) throws -> T {
		return try wrapDecodable {
			return try JSONDecoder().decode(DynamicObject<T>.self, from: data).result
		}
	}
}

/// Dynamic objects decode and encode objects with a dynamic key.
///
/// Decode for the following JSON format:
///
/// ```
/// {
///    "result": {
///	      "orders": [
///          {
///             "order_id": "37f550a202aa6a3fe120f420637c894c",
///             "trading_pair_id": "BTC-USDT",
///             "status": "open",
///             ...
///          },
///          ...
///       ]
///    }
/// }
/// ```
/// The `'orders'` is the dynamic key
internal struct DynamicObjects<T: Codable>: Codable {
	private(set) var results: [T]
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: SharedKeys.self)
		let nested = try container.nestedContainer(keyedBy: CustomKey.self, forKey: .result)
		guard let key = nested.allKeys.first else {
			let context = DecodingError.Context(codingPath: nested.codingPath, debugDescription: "No avaliable keys.")
			throw DecodingError.dataCorrupted(context)
		}
		results = try nested.decode([T].self, forKey: key)
	}
	
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: SharedKeys.self)
		var nested = container.nestedContainer(keyedBy: CustomKey.self, forKey: .result)
		try nested.encode(results, forKey: .dynamic)
	}
	
	static func decode(_ data: Data) throws -> [T] {
		return try wrapDecodable {
			return try JSONDecoder().decode(DynamicObjects<T>.self, from: data).results
		}
	}
}

/// Root object decodes and encodes a single object directly from `result` key.
///
/// Decode for the following JSON format:
///
/// ```
/// {
///    "result": {
///	      "order_id": "37f550a202aa6a3fe120f420637c894c",
///	      "trading_pair_id": "BTC-USDT",
///	      "status": "open",
///	      ...
///    }
/// }
/// ```
internal struct RootObject<T: Codable>: Codable {
	private(set) var result: T
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: SharedKeys.self)
		result = try container.decode(T.self, forKey: .result)
	}
	
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: SharedKeys.self)
		try container.encode(result, forKey: .result)
	}
	
	static func decode(_ data: Data) throws -> T {
		return try wrapDecodable {
			return try JSONDecoder().decode(RootObject<T>.self, from: data).result
		}
	}
}

/// Root objects decode and encode objects directly from `result` key.
///
/// Decode for the following JSON format:
///
/// ```
/// {
///    "result": [
///       {
/// 	     "order_id": "37f550a202aa6a3fe120f420637c894c",
///	         "trading_pair_id": "BTC-USDT",
///	         "status": "open",
///	         ...
///       },
///       ...
///    ]
/// }
/// ```
internal struct RootObjects<T: Codable>: Codable {
	private(set) var results: [T]
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: SharedKeys.self)
		results = try container.decode([T].self, forKey: .result)
	}
	
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: SharedKeys.self)
		try container.encode(results, forKey: .result)
	}
	
	static func decode(_ data: Data) throws -> [T] {
		return try wrapDecodable {
			return try JSONDecoder().decode(RootObjects<T>.self, from: data).results
		}
	}
}

/// An object decode directly from root.
///
/// Decode for the following JSON format:
///
/// ```
/// {
///    "order_id": "37f550a202aa6a3fe120f420637c894c",
///	   "trading_pair_id": "BTC-USDT",
///    "status": "open",
///    ...
/// }
/// ```
internal struct Object<T: Decodable> {
	static func decode(_ data: Data) throws -> T {
		return try wrapDecodable {
			return try JSONDecoder().decode(T.self, from: data)
		}
	}
}

/// Error object decodes and encodes a `CBError` from `error` key.
///
/// Decode for the following JSON format:s
///
/// ```
/// {
///		"error": {
///			"error_code": <string>,
///		},
///		"request_id": "xxxxxxxxxxx"
/// }
/// ```
internal struct ErrorObject: Codable {
	private(set) var error: CBError?
	
	init(from decoder: Decoder) throws {
		let payloadContainer = try decoder.container(keyedBy: SharedKeys.self)
		let payload = try payloadContainer.decode(CBErrorApiReasonPayload.self, forKey: .error)
		
		let requestIdContainer = try decoder.container(keyedBy: SharedKeys.self)
		let requestId = try requestIdContainer.decodeIfPresent(String.self, forKey: .requestId)
		
		error = errorPayload(payload.errorCode, requestId: requestId)
	}
	
	func encode(to encoder: Encoder) throws {
		/// Not implemented.
		return
	}
	
	static func decode(_ data: Data) throws -> CBError? {
		return try wrapDecodable {
			try JSONDecoder().decode(ErrorObject.self, from: data).error
		}
	}
}

/// A wrapper for decoding process that catches all the `DecodingError` and transfers to `CBError`
///
/// - Parameter block: The decoding process block
/// - Returns: The instance that conforms to `Decodable`
/// - Throws: An `CBError` object occurs while decoding
internal func wrapDecodable<Item: Decodable>(_ block: (() throws -> Item)) throws -> Item {
	do {
		return try block()
	}
	catch let DecodingError.dataCorrupted(context)  {
		throw JSONDecodingFailedError(context.debugDescription)
	}
	catch let DecodingError.keyNotFound(_, context) {
		throw JSONDecodingFailedError(context.debugDescription)
	}
	catch let DecodingError.typeMismatch(_, context) {
		throw JSONDecodingFailedError(context.debugDescription)
	}
	catch let DecodingError.valueNotFound(_, context) {
		throw JSONDecodingFailedError(context.debugDescription)
	}
	catch {
		throw JSONDecodingFailedError("JSON decodes with unknown error.")
	}
}

// MARK: -
// MARK: Protocol CBDecodableModel


/// This protocol is designed for decoding all formats in received JSON data.
protocol CBDecodableModel: Decodable {
	
	/// This is for decoding simple JSON object.
	/// Thie JSON object should be like the following format:
	///
	/// ```
	/// {
	///    "aaa": "aaa",
	///	   "bbb": "bbb",
	///    "ccc": "ccc",
	///    ...
	/// }
	/// ```
	///
	/// - Parameter data: The `Data` value is going to be decoded.
	/// - Returns: The instance that was decoded from JSON object.
	/// - Throws: A JSON decoding error will be thrown if occured.
	static func decode(from data: Data) throws -> Self
	
	/// This is for decoding JSON object contained in `result` key.
	/// Thie JSON object should be like the following format:
	///
	/// ```
	/// {
	///    "result": {
	///	      "aaa": "aaa",
	///	      "bbb": "bbb",
	///	      "ccc": "ccc",
	///	      ...
	///    }
	/// }
	/// ```
	///
	/// - Parameter data: The `Data` value is going to be decoded.
	/// - Returns: The instance that was decoded from JSON object.
	/// - Throws: A JSON decoding error will be thrown if occured.
	static func decodeInResult(from data: Data) throws -> Self
	
	/// This is for decoding JSON object contained given object key in `result` key.
	/// Thie JSON object should be like the following format:
	///
	/// ```
	/// {
	///    "result": {
	///	      "key": {
	///          "aaa": "aaa",
	///          "bbb": "bbb",
	///          "ccc": "ccc",
	///          ...
	///       }
	///    }
	/// }
	/// ```
	///
	/// - Parameters:
	///   - data: The `Data` value is going to be decoded.
	///   - objectKey: The key that contains the target JSON object.
	/// - Returns: The instance that was decoded from JSON object.
	/// - Throws: A JSON decoding error will be thrown if occured.
	static func decodeInResultObject(from data: Data, objectKey: String?) throws -> Self
}

extension CBDecodableModel {
	
	internal static func decodeInResult(from data: Data) throws -> Self {
		let decoder = JSONDecoder()
		decoder.userInfo[.source] = DecodeSource.inResult
		
		return try wrapDecodable { try decoder.decode(self, from: data) }
	}
	
	internal static func decodeInResultObject(from data: Data, objectKey: String? = nil) throws -> Self {
		/// Add decode source to user info in decoder.
		let decoder = JSONDecoder()
		decoder.userInfo[.source] = DecodeSource.inResultObject
		
		/// If object key exists, add the key to the user info.
		if let _objectKey = objectKey, let key = CustomKey(stringValue: _objectKey) {
			decoder.userInfo[.objectKey] = key
		}
		
		return try wrapDecodable { try decoder.decode(self, from: data) }
	}
	
	internal static func decode(from data: Data) throws -> Self {
		return try wrapDecodable { try JSONDecoder().decode(self, from: data) }
	}
}

// MARK: -
// MARK: Decode array values of `CBDecodableModel`

struct CBDecodableModels<Model: CBDecodableModel>: CBDecodableModel {
	internal let models: [Model]
	
	init(from decoder: Decoder) throws {
		/// Get the unkeyed container for models.
		var container = try decoder.cobinhoodUnkeyedContainer()
		
		/// Set the `ignoreSource` to false for preventing decoding error format in simple objects.
		decoder.userInfo.sourceControl?.ignoreSource = true
		
		/// Decode all models
		var _models = [Model]()
		while !container.isAtEnd {
			_models.append(try container.decode(Model.self))
		}
		
		models = _models
	}
	
	internal static func decodeInResult(from data: Data) throws -> CBDecodableModels {
		/// Add decode source to user info in decoder.
		let decoder = JSONDecoder()
		decoder.userInfo[.source] = DecodeSource.inResult
		
		/// Add source control to user info
		/// Because the array is contained in `result` key or even one more level in `result` key.
		/// That's the reason to use this flag to control how the decoding behaviour.
		let sourceCounrol = DecodingSourceControl()
		sourceCounrol.ignoreSource = false
		decoder.userInfo[.sourceControl] = sourceCounrol
		
		return try wrapDecodable { try decoder.decode(self, from: data) }
	}
	
	internal static func decodeInResultObject(from data: Data, objectKey: String? = nil) throws -> CBDecodableModels {
		/// Add decode source to user info in decoder.
		let decoder = JSONDecoder()
		decoder.userInfo[.source] = DecodeSource.inResultObject
		
		/// Add source control to user info
		/// Because the array is contained in `result` key or even one more level in `result` key.
		/// That's the reason to use this flag to control how the decoding behaviour.
		let sourceCounrol = DecodingSourceControl()
		sourceCounrol.ignoreSource = false
		decoder.userInfo[.sourceControl] = sourceCounrol
		
		/// If object key exists, add the key to the user info.
		if let _objectKey = objectKey, let key = CustomKey(stringValue: _objectKey) {
			decoder.userInfo[.objectKey] = key
		}
		
		return try wrapDecodable { try decoder.decode(self, from: data) }
	}
}
