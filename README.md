# GPEngine

[![CI Status](http://img.shields.io/travis/LuizZak/GPEngine.svg?style=flat)](https://travis-ci.org/LuizZak/GPEngine)
[![Version](https://img.shields.io/cocoapods/v/GPEngine.svg?style=flat)](http://cocoapods.org/pods/GPEngine)
[![License](https://img.shields.io/cocoapods/l/GPEngine.svg?style=flat)](http://cocoapods.org/pods/GPEngine)
[![Platform](https://img.shields.io/cocoapods/p/GPEngine.svg?style=flat)](http://cocoapods.org/pods/GPEngine)

iOS entity-base game framework written in Swift.

The framework uses traditional Entity-component-system as well as the concept of spaces, which is described [in this article](http://gamedevelopment.tutsplus.com/tutorials/spaces-useful-game-object-containers--gamedev-14091)


The pod also comes with a subpod `GPEngine/Serialization` which allows serialization of space/subspace/entity/components from and to JSON, using [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON) (see [Serialization](#serialization)).

## Requirements

Xcode 8.2 & Swift 3.0 or higher.

## Installation

GPEngine is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "GPEngine"
```

## Author

LuizZak, luizinho_mack@yahoo.com.br

## License

GPEngine is available under the MIT license. See the LICENSE file for more info.

### Serialization

(this optional feature is available under `pod 'GPEngine/Serialization'`)

You can use GameSerializer class to serialize an entity or entire spaces (along with subspaces/entities/components).

This allows you to save partial or complete game states, as well as perform data-driven initialization of game states from pre-made JSON structures.

(see [Serialization requirements](#serialization-requirements) bellow for info on how to serialize stuff).

```swift
let myProvider = MyTypeProvider() // Implements SerializationTypeProvider

let gameSerializer = GameSerializer(typeProvider: myProvider)
let mySerialized = try gameSerializer.serialize(myEntity)

// .serialize(_:) returns a Serialized object, call .serialize() on it to receive a JSON that you can store:
let json = mySerialized.serialized()

// Store json somewhere...
```

To deserialize the entity back, use the following process:

```swift
let json = // Retrieve entity JSON from somewhere...

// Retrive it back to a Serialized object
// If this fails, that means you got a bad JSON :(
let mySerialized = try Serialized.deserialized(from: json)

// Requires explicit ': Entity' type annotation
let myEntity: Entity = try gameSerializer.extract(from: mySerialized)

// If we reached here, entity was deserialized correctly! Success!
```

Process to serialization/deserialization of `Space`s is similar, and uses the same method names.

The serialized JSON returned from `Serialized.serialized()` follows the given structure:

```json
{
    "contentType": "<String - one of the raw values of Serialized.ContentType>",
    "typeName": "<String - type name returned by your SerializationTypeProvider to retrieve the class to instantiate back>",
    "data": "<Any - this is the JSON returned by the object's serialize() method>"
}
```

Serialized containers can be nested inside one another by adding them to the `data` field, and retrieved using `GameSerializer.extract<T: Serializable>(from: Serialized)` method. You must implement custom logic to perform such operations, though.

#### SerializationTypeProvider

This is a protocol that must be implemented to provide your custom component/subspace types to instantiate during deserialization.

The GameSerializer calls your type provider with the serialized type names, and you must return back a Swift metatype (e.g. `MyComponent.self`).

The protocol by default implements the method for fetching the serialized name of a type and returns `String(describing: Type.self)`.

A simple type provider can be implemented using an array to store every known serializable type in your game:

```swift
class Provider: SerializationTypeProvider {
    var serializableTypes: [Serializable.Type] = [
        MySerializableComponent.self,
        MySerializableSubspace.self
    ]

    func deserialized(from name: String) throws -> Serializable.Type {
        for type in serializableTypes {
            if(String(describing: type) == name) {
                return type
            }
        }
        
        throw DeserializationError.unrecognizedSerializedName
    }
}
```

#### Serialization requirements

To serialize entities and spaces, you need to follow these requirements:

- For entities, every `Component` added to the entity must implement the `Serializable` protocol.
- For spaces, every entity must follow the above rule, as well as every subspace also implementing the `Serializable` protocol.

To check your entities and spaces are fully serializable, use the `GameSerializer.canSerialize(_:)` & `GameSerializer.diagnoseSerialize(on:)` methods on your entities or spaces.

Systems are aimed to be stateless, so they are not supported to be serialized by default.
That won't stop you from adding it to your serialization type provider & implementing `Serializable` protocol on them, however, making them serializable then.
