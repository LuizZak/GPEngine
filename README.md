# GPEngine

[![CI Status](http://img.shields.io/travis/LuizZak/GPEngine.svg?style=flat)](https://travis-ci.org/LuizZak/GPEngine)
[![Version](https://img.shields.io/cocoapods/v/GPEngine.svg?style=flat)](http://cocoapods.org/pods/GPEngine)
[![License](https://img.shields.io/cocoapods/l/GPEngine.svg?style=flat)](http://cocoapods.org/pods/GPEngine)
[![Platform](https://img.shields.io/cocoapods/p/GPEngine.svg?style=flat)](http://cocoapods.org/pods/GPEngine)

iOS entity-base game framework written in Swift.

The framework uses traditional Entity-component-system as well as the concept of spaces, which is described [in this article](http://gamedevelopment.tutsplus.com/tutorials/spaces-useful-game-object-containers--gamedev-14091)

The pod also comes with a subpod `GPEngine/Serialization` which allows serialization of space/subspace/entity/components from and to JSON, using [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON) (see [Serialization](#serialization)).

### Concepts

This engine works much like classic ECS engines, but with the added abstraction of `Spaces`.

Spaces are containers for entities that act separetedly such that it lifts a layer of abstraction between entities grouped together. To aid in such abstraction, the soncept of `Subspaces` is also propsed, which aims to group relevant data for systems to act upon spaces/entities separetedly (such as a separate instance of the physics engine, rendering camera position, etc.).

#### Classic ECS layout

```
╔══════════╗
║  Engine  ║
╚═════╤════╝ ╔════════╗╔════════╗╔════════╗
      ├──────╢ Entity ╟╢ Entity ╟╢ Entity ╟...
      │      ╚════════╝╚════════╝╚════════╝
      │      ╔════════╗╔════════╗╔════════╗
      └──────╢ System ╟╢ System ╟╢ System ╟...
             ╚════════╝╚════════╝╚════════╝
```

In this fashion, you cannot easily isolate groups of entities such that they are logically grouped (e.g. split enemies into foreground and background enemies, such that background enemies do not interact with the player). This is achievable through component/type flag specification, but Spaces aim to make that an explicit abstraction:

#### Spaces-based ECS layout

```
╔══════════╗
║  Engine  ║
╚═════╤════╝
  ╔═══╧═══╗   ╔════════╗╔════════╗╔════════╗
  ║ Space ╟─┬─╢ Entity ╟╢ Entity ╟╢ Entity ╟...
  ╚═══╤═══╝ │ ╚════════╝╚════════╝╚════════╝
      │     │ ╔══════════╗
      │     └─╢ Subspace ║
      │       ╚══════════╝
  ╔═══╧═══╗   ╔════════╗╔════════╗╔════════╗
  ║ Space ╟─┬─╢ Entity ╟╢ Entity ╟╢ Entity ╟...
  ╚═══╤═══╝ │ ╚════════╝╚════════╝╚════════╝
      │     │ ╔══════════╗╔══════════╗
      │     └─╢ Subspace ╟╢ Subspace ║
      │       ╚══════════╝╚══════════╝
      │
      │      ╔════════╗╔════════╗╔════════╗
      └──────╢ System ╟╢ System ╟╢ System ╟...
             ╚════════╝╚════════╝╚════════╝
```

Here, entities are grouped into Spaces, where each space is fully isolated from each other. Subspaces are also introduced, as these aid in storing state that will be used by Systems to process data. A cool thing about this is that spaces only need to add subspaces that are relevant to them; if a subspace is not meant to be rendered (such as a different game room that is still 'alive' but behind a door), no RenderingSubspace needs to be added to it!

Systems are still global, since they would ideally be stateless (with help of Subspaces). Systems would then query spaces for entities with relevant components, and subspaces needed within, and if available, act upon them using their stated logic. Systems always act on each Space _independently_, as if they where isolated classic ECS engines.

## Requirements

Xcode 8.2 & Swift 3.0 or higher.

## Installation

#### CocoaPods

GPEngine is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "GPEngine"
```

GPEngine is also available in a Swift package:

#### Swift Package Manager

GPEngine is also available as a [Swift Package](https://swift.org/package-manager)

```swift
import PackageDescription

let package = Package(
    name: "project_name",
    targets: [],
    dependencies: [
        .Package(url: "https://github.com/LuizZak/GPEngine.git", majorVersion: 2, minor: 2)
    ]
)
```

## Author

LuizZak, luizinho_mack@yahoo.com.br

## License

GPEngine is available under the MIT license. See the LICENSE file for more info.

### Serialization

(this optional feature is available under `pod 'GPEngine/Serialization'`)

You can use the GameSerializer class to serialize an entity or entire spaces (along with subspaces/entities/components).

This allows you to save partial or complete game states, as well as perform data-driven initialization of game states from pre-made JSON structures.

(see [Serialization requirements](#serialization-requirements) bellow for info on what's needed to make stuff serializable).

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

`Serializable` is a basic protocol for encoding/decoding objects using JSON:

```swift
/// Describes an object that can be serialized to and back from a JSON object.
/// Implementers of this protocol should take care of guaranteeing that the inner
/// state of the object remains the same when deserializing from a previously
/// serialized object.
public protocol Serializable {
    /// Initializes an instance of this type from a given serialized state.
    ///
    /// - Parameter json: A state that was previously serialized by an instance
    /// of this type using `serialized()`
    /// - Throws: Any type of error during deserialization.
    init(json: JSON) throws
    
    /// Serializes the state of this component into a JSON object.
    ///
    /// - Returns: The serialized state for this object.
    func serialized() -> JSON
}
```

To check your entities and spaces are fully serializable, use the `GameSerializer.canSerialize(_:)` & `GameSerializer.diagnoseSerialize(on:)` methods on your entities or spaces.

Systems are aimed to be stateless, so they are not supported to be serialized by default.
That won't stop you from adding it to your serialization type provider & implementing `Serializable` protocol on them, however, making them serializable then.
