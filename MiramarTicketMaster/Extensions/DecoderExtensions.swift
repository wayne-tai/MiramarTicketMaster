//
//  DecoderExtensions.swift
//  Cobinhood
//
//  Created by 𝕎𝔸𝕐ℕ𝔼 on 2018/2/6.
//  Copyright © 2018年 Cobinhood Inc. All rights reserved.
//

import Foundation

extension Decoder {
	
	// MARK: KeyedDecodingContainer
	
	internal func cobinhoodContainer<Key>(withContainerKeyType containerKeyType: Key.Type? = nil) throws -> KeyedDecodingContainer<Key> {
		if let sourceControl = userInfo.sourceControl, sourceControl.ignoreSource {
			return try self.container(keyedBy: containerKeyType ?? Key.self)
		}
		
		/// Get the source from userInfo
		let source = userInfo.source(for: .source)
		
		if let _source = source, _source == .inResult {
			let container = try self.container(keyedBy: SharedKeys.self)
			return try container.nestedContainer(keyedBy: containerKeyType ?? Key.self, forKey: .result)
		}
		else if let _source = source, let key = userInfo.codingKey(for: .objectKey), _source == .inResultObject {
			let container = try self.container(keyedBy: SharedKeys.self)
			let resultContainer = try container.nestedContainer(keyedBy: type(of: key), forKey: .result)
			return try resultContainer.nestedContainer(keyedBy: containerKeyType ?? Key.self, forKey: key)
		}
		else {
			return try self.container(keyedBy: containerKeyType ?? Key.self)
		}
	}
	
	internal func cobinhoodContainer<ObjKey, Key>(for objKey: ObjKey, containerKeyType: Key.Type? = nil) throws
		-> KeyedDecodingContainer<Key> where ObjKey: CodingKey
	{
		if let sourceControl = userInfo.sourceControl, sourceControl.ignoreSource {
			return try self.container(keyedBy: containerKeyType ?? Key.self)
		}
		
		/// Get the source from userInfo
		let source = userInfo.source(for: .source)
		
		if let _source = source, _source == .inResult {
			let container = try self.container(keyedBy: SharedKeys.self)
			return try container.nestedContainer(keyedBy: containerKeyType ?? Key.self, forKey: .result)
		}
		else if let _source = source, _source == .inResultObject {
			let container = try self.container(keyedBy: SharedKeys.self)
			let resultContainer = try container.nestedContainer(keyedBy: type(of: objKey), forKey: .result)
			return try resultContainer.nestedContainer(keyedBy: containerKeyType ?? Key.self, forKey: objKey)
		}
		else {
			return try self.container(keyedBy: containerKeyType ?? Key.self)
		}
	}
	
	// MARK: UnkeyedDecodingContainer
	
	internal func cobinhoodUnkeyedContainer() throws -> UnkeyedDecodingContainer {
		if let sourceControl = userInfo.sourceControl, sourceControl.ignoreSource {
			return try self.unkeyedContainer()
		}
		
		/// Get the source from userInfo
		let source = userInfo.source(for: .source)
		
		if let _source = source, _source == .inResult {
			let container = try self.container(keyedBy: SharedKeys.self)
			return try container.nestedUnkeyedContainer(forKey: .result)
		}
		else if let _source = source, let key = userInfo.codingKey(for: .objectKey), _source == .inResultObject {
			let container = try self.container(keyedBy: SharedKeys.self)
			let resultContainer = try container.nestedContainer(keyedBy: type(of: key), forKey: .result)
			return try resultContainer.nestedUnkeyedContainer(forKey: key)
		}
		else {
			return try self.unkeyedContainer()
		}
	}
	
	internal func cobinhoodUnkeyedContainer<ObjKey>(for objKey: ObjKey) throws
		-> UnkeyedDecodingContainer where ObjKey: CodingKey
	{
		if let sourceControl = userInfo.sourceControl, sourceControl.ignoreSource {
			return try self.unkeyedContainer()
		}
		
		/// Get the source from userInfo
		let source = userInfo.source(for: .source)
		
		if let _source = source, _source == .inResult {
			let container = try self.container(keyedBy: SharedKeys.self)
			return try container.nestedUnkeyedContainer(forKey: .result)
		}
		else if let _source = source, _source == .inResultObject {
			let container = try self.container(keyedBy: SharedKeys.self)
			let resultContainer = try container.nestedContainer(keyedBy: type(of: objKey), forKey: .result)
			return try resultContainer.nestedUnkeyedContainer(forKey: objKey)
		}
		else {
			return try self.unkeyedContainer()
		}
	}
}
