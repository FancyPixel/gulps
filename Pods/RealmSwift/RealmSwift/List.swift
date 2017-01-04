////////////////////////////////////////////////////////////////////////////
//
// Copyright 2014 Realm Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
////////////////////////////////////////////////////////////////////////////

import Foundation
import Realm
import Realm.Private

#if swift(>=3.0)

/// :nodoc:
/// Internal class. Do not use directly.
public class ListBase: RLMListBase {
    // Printable requires a description property defined in Swift (and not obj-c),
    // and it has to be defined as @objc override, which can't be done in a
    // generic class.
    /// Returns a human-readable description of the objects contained in the List.
    @objc public override var description: String {
        return descriptionWithMaxDepth(RLMDescriptionMaxDepth)
    }

    @objc private func descriptionWithMaxDepth(_ depth: UInt) -> String {
        let type = "List<\(_rlmArray.objectClassName)>"
        return gsub(pattern: "RLMArray <0x[a-z0-9]+>", template: type, string: _rlmArray.description(withMaxDepth: depth)) ?? type
    }

    /// Returns the number of objects in this List.
    public var count: Int { return Int(_rlmArray.count) }
}

/**
 `List` is the container type in Realm used to define to-many relationships.

 Like Swift's `Array`, `List` is a generic type that is parameterized on the type of `Object` it stores.

 Unlike Swift's native collections, `List`s are reference types, and are only immutable if the Realm that manages them
 is opened as read-only.

 Lists can be filtered and sorted with the same predicates as `Results<T>`.

 Properties of `List` type defined on `Object` subclasses must be declared as `let` and cannot be `dynamic`.
 */
public final class List<T: Object>: ListBase {

    /// The type of the elements contained within the collection.
    public typealias Element = T

    // MARK: Properties

    /// The Realm which manages the list, or `nil` if the list is unmanaged.
    public var realm: Realm? {
        return _rlmArray.realm.map { Realm($0) }
    }

    /// Indicates if the list can no longer be accessed.
    public var isInvalidated: Bool { return _rlmArray.isInvalidated }

    // MARK: Initializers

    /// Creates a `List` that holds Realm model objects of type `T`.
    public override init() {
        super.init(array: RLMArray(objectClassName: (T.self as Object.Type).className()))
    }

    internal init(rlmArray: RLMArray<RLMObject>) {
        super.init(array: rlmArray)
    }

    // MARK: Index Retrieval

    /**
     Returns the index of an object in the list, or `nil` if the object is not present.

     - parameter object: An object to find.
     */
    public func index(of object: T) -> Int? {
        return notFoundToNil(index: _rlmArray.index(of: object.unsafeCastToRLMObject()))
    }

    /**
     Returns the index of the first object in the list matching the predicate, or `nil` if no objects match.

     - parameter predicate: The predicate with which to filter the objects.
    */
    public func index(matching predicate: NSPredicate) -> Int? {
        return notFoundToNil(index: _rlmArray.indexOfObject(with: predicate))
    }

    /**
     Returns the index of the first object in the list matching the predicate, or `nil` if no objects match.

     - parameter predicateFormat: A predicate format string, optionally followed by a variable number of arguments.
    */
    public func index(matching predicateFormat: String, _ args: Any...) -> Int? {
        return index(matching: NSPredicate(format: predicateFormat, argumentArray: args))
    }

    // MARK: Object Retrieval

    /**
     Returns the object at the given index (get), or replaces the object at the given index (set).

     - warning: You can only set an object during a write transaction.

     - parameter index: The index of the object to retrieve or replace.
     */
    public subscript(position: Int) -> T {
        get {
            throwForNegativeIndex(position)
            return unsafeBitCast(_rlmArray.object(at: UInt(position)), to: T.self)
        }
        set {
            throwForNegativeIndex(position)
            _rlmArray.replaceObject(at: UInt(position), with: newValue.unsafeCastToRLMObject())
        }
    }

    /// Returns the first object in the list, or `nil` if the list is empty.
    public var first: T? { return _rlmArray.firstObject() as! T? }

    /// Returns the last object in the list, or `nil` if the list is empty.
    public var last: T? { return _rlmArray.lastObject() as! T? }

    // MARK: KVC

    /**
     Returns an `Array` containing the results of invoking `valueForKey(_:)` using `key` on each of the collection's
     objects.
    */
    public override func value(forKey key: String) -> Any? {
        return value(forKeyPath: key)
    }

    /**
     Returns an `Array` containing the results of invoking `valueForKeyPath(_:)` using `keyPath` on each of the
     collection's objects.

     - parameter keyPath: The key path to the property whose values are desired.
     */
    public override func value(forKeyPath keyPath: String) -> Any? {
        return _rlmArray.value(forKeyPath: keyPath)
    }

    /**
     Invokes `setValue(_:forKey:)` on each of the collection's objects using the specified `value` and `key`.

     - warning: This method can only be called during a write transaction.

     - parameter value: The object value.
     - parameter key:   The name of the property whose value should be set on each object.
    */
    public override func setValue(_ value: Any?, forKey key: String) {
        return _rlmArray.setValue(value, forKeyPath: key)
    }

    // MARK: Filtering

    /**
     Returns a `Results` containing all objects matching the given predicate in the list.

     - parameter predicateFormat: A predicate format string, optionally followed by a variable number of arguments.
    */
    public func filter(_ predicateFormat: String, _ args: Any...) -> Results<T> {
        return Results<T>(_rlmArray.objects(with: NSPredicate(format: predicateFormat, argumentArray: args)))
    }

    /**
     Returns a `Results` containing all objects matching the given predicate in the list.

     - parameter predicate: The predicate with which to filter the objects.
     */
    public func filter(_ predicate: NSPredicate) -> Results<T> {
        return Results<T>(_rlmArray.objects(with: predicate))
    }

    // MARK: Sorting

    /**
     Returns a `Results` containing the objects in the list, but sorted.

     Objects are sorted based on the values of the given property. For example, to sort a list of `Student`s from
     youngest to oldest based on their `age` property, you might call
     `students.sorted(byProperty: "age", ascending: true)`.

     - warning: Lists may only be sorted by properties of boolean, `Date`, `NSDate`, single and double-precision
                floating point, integer, and string types.

     - parameter property:  The name of the property to sort by.
     - parameter ascending: The direction to sort in.
     */
    public func sorted(byProperty property: String, ascending: Bool = true) -> Results<T> {
        return sorted(by: [SortDescriptor(property: property, ascending: ascending)])
    }

    /**
     Returns a `Results` containing the objects in the list, but sorted.

     - warning: Lists may only be sorted by properties of boolean, `Date`, `NSDate`, single and double-precision
                floating point, integer, and string types.

     - see: `sorted(byProperty:ascending:)`
    */
    public func sorted<S: Sequence>(by sortDescriptors: S) -> Results<T> where S.Iterator.Element == SortDescriptor {
        return Results<T>(_rlmArray.sortedResults(using: sortDescriptors.map { $0.rlmSortDescriptorValue }))
    }

    // MARK: Aggregate Operations

    /**
     Returns the minimum (lowest) value of the given property among all the objects in the list, or `nil` if the list is
     empty.

     - warning: Only a property whose type conforms to the `MinMaxType` protocol can be specified.

     - parameter property: The name of a property whose minimum value is desired.
     */
    public func min<U: MinMaxType>(ofProperty property: String) -> U? {
        return filter(NSPredicate(value: true)).min(ofProperty: property)
    }

    /**
     Returns the maximum (highest) value of the given property among all the objects in the list, or `nil` if the list
     is empty.

     - warning: Only a property whose type conforms to the `MinMaxType` protocol can be specified.

     - parameter property: The name of a property whose maximum value is desired.
     */
    public func max<U: MinMaxType>(ofProperty property: String) -> U? {
        return filter(NSPredicate(value: true)).max(ofProperty: property)
    }

    /**
     Returns the sum of the values of a given property over all the objects in the list.

     - warning: Only a property whose type conforms to the `AddableType` protocol can be specified.

     - parameter property: The name of a property whose values should be summed.
     */
    public func sum<U: AddableType>(ofProperty property: String) -> U {
        return filter(NSPredicate(value: true)).sum(ofProperty: property)
    }

    /**
     Returns the average value of a given property over all the objects in the list, or `nil` if the list is empty.

     - warning: Only a property whose type conforms to the `AddableType` protocol can be specified.

     - parameter property: The name of a property whose average value should be calculated.
     */
    public func average<U: AddableType>(ofProperty property: String) -> U? {
        return filter(NSPredicate(value: true)).average(ofProperty: property)
    }

    // MARK: Mutation

    /**
     Appends the given object to the end of the list.

     If the object is managed by a different Realm than the receiver, a copy is made and added to the Realm managing
     the receiver.

     - warning: This method may only be called during a write transaction.

     - parameter object: An object.
     */
    public func append(_ object: T) {
        _rlmArray.add(object.unsafeCastToRLMObject())
    }

    /**
     Appends the objects in the given sequence to the end of the list.

     - warning: This method may only be called during a write transaction.
    */
    public func append<S: Sequence>(objectsIn objects: S) where S.Iterator.Element == T {
        for obj in objects {
            _rlmArray.add(obj.unsafeCastToRLMObject())
        }
    }

    /**
     Inserts an object at the given index.

     - warning: This method may only be called during a write transaction.

     - warning: This method will throw an exception if called with an invalid index.

     - parameter object: An object.
     - parameter index:  The index at which to insert the object.
     */
    public func insert(_ object: T, at index: Int) {
        throwForNegativeIndex(index)
        _rlmArray.insert(object.unsafeCastToRLMObject(), at: UInt(index))
    }

    /**
     Removes an object at the given index. The object is not removed from the Realm that manages it.

     - warning: This method may only be called during a write transaction.

     - warning: This method will throw an exception if called with an invalid index.

     - parameter index: The index at which to remove the object.
     */
    public func remove(objectAtIndex index: Int) {
        throwForNegativeIndex(index)
        _rlmArray.removeObject(at: UInt(index))
    }

    /**
     Removes the last object in the list. The object is not removed from the Realm that manages it.

     - warning: This method may only be called during a write transaction.
     */
    public func removeLast() {
        _rlmArray.removeLastObject()
    }

    /**
     Removes all objects from the list. The objects are not removed from the Realm that manages them.

     - warning: This method may only be called during a write transaction.
     */
    public func removeAll() {
        _rlmArray.removeAllObjects()
    }

    /**
     Replaces an object at the given index with a new object.

     - warning: This method may only be called during a write transaction.

     - warning: This method will throw an exception if called with an invalid index.

     - parameter index:  The index of the object to be replaced.
     - parameter object: An object.
     */
    public func replace(index: Int, object: T) {
        throwForNegativeIndex(index)
        _rlmArray.replaceObject(at: UInt(index), with: object.unsafeCastToRLMObject())
    }

    /**
     Moves the object at the given source index to the given destination index.

     - warning: This method may only be called during a write transaction.

     - warning: This method will throw an exception if called with invalid indices.

     - parameter from:  The index of the object to be moved.
     - parameter to:    index to which the object at `from` should be moved.
     */
    public func move(from: Int, to: Int) { // swiftlint:disable:this variable_name
        throwForNegativeIndex(from)
        throwForNegativeIndex(to)
        _rlmArray.moveObject(at: UInt(from), to: UInt(to))
    }

    /**
     Exchanges the objects in the list at given indices.

     - warning: This method may only be called during a write transaction.

     - warning: This method will throw an exception if called with invalid indices.

     - parameter index1: The index of the object which should replace the object at index `index2`.
     - parameter index2: The index of the object which should replace the object at index `index1`.
     */
    public func swap(index1: Int, _ index2: Int) {
        throwForNegativeIndex(index1, parameterName: "index1")
        throwForNegativeIndex(index2, parameterName: "index2")
        _rlmArray.exchangeObject(at: UInt(index1), withObjectAt: UInt(index2))
    }

    // MARK: Notifications

    /**
     Registers a block to be called each time the collection changes.

     The block will be asynchronously called with the initial results, and then called again after each write
     transaction which changes either any of the objects in the collection, or which objects are in the collection.

     The `change` parameter that is passed to the block reports, in the form of indices within the collection, which of
     the objects were added, removed, or modified during each write transaction. See the `RealmCollectionChange`
     documentation for more information on the change information supplied and an example of how to use it to update a
     `UITableView`.

     At the time when the block is called, the collection will be fully evaluated and up-to-date, and as long as you do
     not perform a write transaction on the same thread or explicitly call `realm.refresh()`, accessing it will never
     perform blocking work.

     Notifications are delivered via the standard run loop, and so can't be delivered while the run loop is blocked by
     other activity. When notifications can't be delivered instantly, multiple notifications may be coalesced into a
     single notification. This can include the notification with the initial collection.

     For example, the following code performs a write transaction immediately after adding the notification block, so
     there is no opportunity for the initial notification to be delivered first. As a result, the initial notification
     will reflect the state of the Realm after the write transaction.

     ```swift
     let results = realm.objects(Dog.self)
     print("dogs.count: \(dogs?.count)") // => 0
     let token = dogs.addNotificationBlock { changes in
         switch changes {
         case .initial(let dogs):
             // Will print "dogs.count: 1"
             print("dogs.count: \(dogs.count)")
             break
         case .update:
             // Will not be hit in this example
             break
         case .error:
             break
         }
     }
     try! realm.write {
         let dog = Dog()
         dog.name = "Rex"
         person.dogs.append(dog)
     }
     // end of run loop execution context
     ```

     You must retain the returned token for as long as you want updates to be sent to the block. To stop receiving
     updates, call `stop()` on the token.

     - warning: This method cannot be called during a write transaction, or when the containing Realm is read-only.

     - parameter block: The block to be called whenever a change occurs.
     - returns: A token which must be held for as long as you want updates to be delivered.
     */
    public func addNotificationBlock(_ block: @escaping (RealmCollectionChange<List>) -> ()) -> NotificationToken {
        return _rlmArray.addNotificationBlock { list, change, error in
            block(RealmCollectionChange.fromObjc(value: self, change: change, error: error))
        }
    }
}

extension List : RealmCollection, RangeReplaceableCollection {
    // MARK: Sequence Support

    /// Returns a `RLMIterator` that yields successive elements in the `List`.
    public func makeIterator() -> RLMIterator<T> {
        return RLMIterator(collection: _rlmArray)
    }

    // MARK: RangeReplaceableCollection Support

    /**
     Replace the given `subRange` of elements with `newElements`.

    - parameter subRange:    The range of elements to be replaced.
    - parameter newElements: The new elements to be inserted into the List.
    */
    public func replaceSubrange<C: Collection>(_ subrange: Range<Int>, with newElements: C)
        where C.Iterator.Element == T {
        for _ in subrange.lowerBound..<subrange.upperBound {
            remove(objectAtIndex: subrange.lowerBound)
        }
        for x in newElements.reversed() {
            insert(x, at: subrange.lowerBound)
        }
    }

    /// The position of the first element in a non-empty collection.
    /// Identical to endIndex in an empty collection.
    public var startIndex: Int { return 0 }

    /// The collection's "past the end" position.
    /// endIndex is not a valid argument to subscript, and is always reachable from startIndex by
    /// zero or more applications of successor().
    public var endIndex: Int { return count }

    public func index(after i: Int) -> Int { return i + 1 }
    public func index(before i: Int) -> Int { return i - 1 }

    /// :nodoc:
    public func _addNotificationBlock(_ block: @escaping (RealmCollectionChange<AnyRealmCollection<T>>) -> Void) ->
        NotificationToken {
        let anyCollection = AnyRealmCollection(self)
        return _rlmArray.addNotificationBlock { _, change, error in
            block(RealmCollectionChange.fromObjc(value: anyCollection, change: change, error: error))
        }
    }
}

// MARK: Unavailable

extension List {
    @available(*, unavailable, renamed: "append(objectsIn:)")
    public func appendContentsOf<S: Sequence>(_ objects: S) where S.Iterator.Element == T { fatalError() }

    @available(*, unavailable, renamed: "remove(objectAtIndex:)")
    public func remove(at index: Int) { fatalError() }

    @available(*, unavailable, renamed: "isInvalidated")
    public var invalidated: Bool { fatalError() }

    @available(*, unavailable, renamed: "index(matching:)")
    public func index(of predicate: NSPredicate) -> Int? { fatalError() }

    @available(*, unavailable, renamed: "index(matching:_:)")
    public func index(of predicateFormat: String, _ args: Any...) -> Int? { fatalError() }

    @available(*, unavailable, renamed: "sorted(byProperty:ascending:)")
    public func sorted(_ property: String, ascending: Bool = true) -> Results<T> { fatalError() }

    @available(*, unavailable, renamed: "sorted(by:)")
    public func sorted<S: Sequence>(_ sortDescriptors: S) -> Results<T> where S.Iterator.Element == SortDescriptor {
        fatalError()
    }

    @available(*, unavailable, renamed: "min(ofProperty:)")
    public func min<U: MinMaxType>(_ property: String) -> U? { fatalError() }

    @available(*, unavailable, renamed: "max(ofProperty:)")
    public func max<U: MinMaxType>(_ property: String) -> U? { fatalError() }

    @available(*, unavailable, renamed: "sum(ofProperty:)")
    public func sum<U: AddableType>(_ property: String) -> U { fatalError() }

    @available(*, unavailable, renamed: "average(ofProperty:)")
    public func average<U: AddableType>(_ property: String) -> U? { fatalError() }
}

#else

/// :nodoc:
/// Internal class. Do not use directly.
public class ListBase: RLMListBase {
    // Printable requires a description property defined in Swift (and not obj-c),
    // and it has to be defined as @objc override, which can't be done in a
    // generic class.
    /// Returns a human-readable description of the objects contained in the List.
    @objc public override var description: String {
        return descriptionWithMaxDepth(RLMDescriptionMaxDepth)
    }

    @objc private func descriptionWithMaxDepth(depth: UInt) -> String {
        let type = "List<\(_rlmArray.objectClassName)>"
        return gsub("RLMArray <0x[a-z0-9]+>", template: type, string: _rlmArray.descriptionWithMaxDepth(depth)) ?? type
    }

    /// Returns the number of objects in this List.
    public var count: Int { return Int(_rlmArray.count) }
}

/**
 `List` is the container type in Realm used to define to-many relationships.

 Like Swift's `Array`, `List` is a generic type that is parameterized on the type of `Object` it stores.

 Unlike Swift's native collections, `List`s are reference types, and are only immutable if the Realm that manages them
 is opened as read-only.

 Lists can be filtered and sorted with the same predicates as `Results<T>`.

 Properties of `List` type defined on `Object` subclasses must be declared as `let` and cannot be `dynamic`.
*/
public final class List<T: Object>: ListBase {

    /// The type of the elements contained within the collection.
    public typealias Element = T

    // MARK: Properties

    /// The Realm which manages the list. Returns `nil` for unmanaged lists.
    public var realm: Realm? {
        return _rlmArray.realm.map { Realm($0) }
    }

    /// Indicates if the list can no longer be accessed.
    public var invalidated: Bool { return _rlmArray.invalidated }

    // MARK: Initializers

    /// Creates a `List` that holds Realm model objects of type `T`.
    public override init() {
        super.init(array: RLMArray(objectClassName: (T.self as Object.Type).className()))
    }

    internal init(rlmArray: RLMArray) {
        super.init(array: rlmArray)
    }

    // MARK: Index Retrieval

    /**
     Returns the index of an object in the list, or `nil` if the object is not present.

     - parameter object: An object to find.
     */
    public func indexOf(object: T) -> Int? {
        return notFoundToNil(_rlmArray.indexOfObject(object.unsafeCastToRLMObject()))
    }

    /**
     Returns the index of the first object in the list matching the predicate, or `nil` if no objects match.

     - parameter predicate: The predicate with which to filter the objects.
     */
    public func indexOf(predicate: NSPredicate) -> Int? {
        return notFoundToNil(_rlmArray.indexOfObjectWithPredicate(predicate))
    }

    /**
     Returns the index of the first object in the list matching the predicate, or `nil` if no objects match.

     - parameter predicateFormat: A predicate format string, optionally followed by a variable number of arguments.
     */
    public func indexOf(predicateFormat: String, _ args: AnyObject...) -> Int? {
        return indexOf(NSPredicate(format: predicateFormat, argumentArray: args))
    }

    // MARK: Object Retrieval

    /**
     Returns the object at the given index (get), or replaces the object at the given index (set).

     - warning: You can only set an object during a write transaction.

     - parameter index: The index of the object to retrieve or replace.
     */
    public subscript(index: Int) -> T {
        get {
            throwForNegativeIndex(index)
            return _rlmArray[UInt(index)] as! T
        }
        set {
            throwForNegativeIndex(index)
            return _rlmArray[UInt(index)] = newValue.unsafeCastToRLMObject()
        }
    }

    /// Returns the first object in the list, or `nil` if the list is empty.
    public var first: T? { return _rlmArray.firstObject() as! T? }

    /// Returns the last object in the list, or `nil` if the list is empty.
    public var last: T? { return _rlmArray.lastObject() as! T? }

    // MARK: KVC

    /**
     Returns an `Array` containing the results of invoking `valueForKey(_:)` using `key` on each of the collection's
     objects.

     - parameter key: The name of the property whose values are desired.
     */
    public override func valueForKey(key: String) -> AnyObject? {
        return _rlmArray.valueForKey(key)
    }

    /**
     Returns an `Array` containing the results of invoking `valueForKeyPath(_:)` using `keyPath` on each of the
     collection's objects.

     - parameter keyPath: The key path to the property whose values are desired.
     */
    public override func valueForKeyPath(keyPath: String) -> AnyObject? {
        return _rlmArray.valueForKeyPath(keyPath)
    }

    /**
     Invokes `setValue(_:forKey:)` on each of the collection's objects using the specified `value` and `key`.

     - warning: This method can only be called during a write transaction.

     - parameter value: The object value.
     - parameter key:   The name of the property whose value should be set on each object.
     */
    public override func setValue(value: AnyObject?, forKey key: String) {
        return _rlmArray.setValue(value, forKey: key)
    }

    // MARK: Filtering

    /**
     Returns a `Results` containing all objects matching the given predicate in the list.

     - parameter predicateFormat: A predicate format string, optionally followed by a variable number of arguments.
    */
    public func filter(predicateFormat: String, _ args: AnyObject...) -> Results<T> {
        return Results<T>(_rlmArray.objectsWithPredicate(NSPredicate(format: predicateFormat, argumentArray: args)))
    }

    /**
     Returns a `Results` containing all objects matching the given predicate in the list.

     - parameter predicate: The predicate with which to filter the objects.
     */
    public func filter(predicate: NSPredicate) -> Results<T> {
        return Results<T>(_rlmArray.objectsWithPredicate(predicate))
    }

    // MARK: Sorting

    /**
     Returns a `Results` containing the objects in the list, but sorted.

     Objects are sorted based on the values of the given property. For example, to sort a list of `Student`s from
     youngest to oldest based on their `age` property, you might call `students.sorted("age", ascending: true)`.

     - warning: Lists may only be sorted by properties of boolean, `NSDate`, single and double-precision floating point,
                integer, and string types.

     - parameter property:  The name of the property to sort by.
     - parameter ascending: The direction to sort in.
     */
    public func sorted(property: String, ascending: Bool = true) -> Results<T> {
        return sorted([SortDescriptor(property: property, ascending: ascending)])
    }

    /**
     Returns a `Results` containing the objects in the list, but sorted.

     - warning: Lists may only be sorted by properties of boolean, `NSDate`, single and double-precision floating point,
                integer, and string types.

     - see: `sorted(_:ascending:)`

     - parameter sortDescriptors: A sequence of `SortDescriptor`s to sort by.
     */
    public func sorted<S: SequenceType where S.Generator.Element == SortDescriptor>(sortDescriptors: S) -> Results<T> {
        return Results<T>(_rlmArray.sortedResultsUsingDescriptors(sortDescriptors.map { $0.rlmSortDescriptorValue }))
    }

    // MARK: Aggregate Operations

    /**
     Returns the minimum (lowest) value of the given property among all the objects in the list, or `nil` if the list is
     empty.

     - warning: Only a property whose type conforms to the `MinMaxType` protocol can be specified.

     - parameter property: The name of a property whose minimum value is desired.
     */
    public func min<U: MinMaxType>(property: String) -> U? {
        return filter(NSPredicate(value: true)).min(property)
    }

    /**
     Returns the maximum (highest) value of the given property among all the objects in the list, or `nil` if the list
     is empty.

     - warning: Only a property whose type conforms to the `MinMaxType` protocol can be specified.

     - parameter property: The name of a property whose maximum value is desired.
     */
    public func max<U: MinMaxType>(property: String) -> U? {
        return filter(NSPredicate(value: true)).max(property)
    }

    /**
     Returns the sum of the values of a given property over all the objects in the list.

     - warning: Only a property whose type conforms to the `AddableType` protocol can be specified.

     - parameter property: The name of a property whose values should be summed.
     */
    public func sum<U: AddableType>(property: String) -> U {
        return filter(NSPredicate(value: true)).sum(property)
    }

    /**
     Returns the average value of a given property over all the objects in the list, or `nil` if the list is empty.

     - warning: Only a property whose type conforms to the `AddableType` protocol can be specified.

     - parameter property: The name of a property whose average value should be calculated.
     */
    public func average<U: AddableType>(property: String) -> U? {
        return filter(NSPredicate(value: true)).average(property)
    }

    // MARK: Mutation

    /**
     Appends the given object to the end of the list.

     If the object is managed by a different Realm than the receiver, a copy is made and added to the Realm managing
     the receiver.

     - warning: This method may only be called during a write transaction.

     - parameter object: An object.
     */
    public func append(object: T) {
        _rlmArray.addObject(object.unsafeCastToRLMObject())
    }

    /**
     Appends the objects in the given sequence to the end of the list.

     - warning: This method may only be called during a write transaction.

     - parameter objects: A sequence of objects.
    */
    public func appendContentsOf<S: SequenceType where S.Generator.Element == T>(objects: S) {
        for obj in objects {
            _rlmArray.addObject(obj.unsafeCastToRLMObject())
        }
    }

    /**
     Inserts an object at the given index.

     - warning: This method may only be called during a write transaction.

     - warning: This method will throw an exception if called with an invalid index.

     - parameter object: An object.
     - parameter index:  The index at which to insert the object.
     */
    public func insert(object: T, atIndex index: Int) {
        throwForNegativeIndex(index)
        _rlmArray.insertObject(object.unsafeCastToRLMObject(), atIndex: UInt(index))
    }

    /**
     Removes an object at the given index. The object is not removed from the Realm that manages it.

     - warning: This method may only be called during a write transaction.

     - warning: This method will throw an exception if called with an invalid index.

     - parameter index: The index at which to remove the object.
    */
    public func removeAtIndex(index: Int) {
        throwForNegativeIndex(index)
        _rlmArray.removeObjectAtIndex(UInt(index))
    }

    /**
     Removes the last object in the list. The object is not removed from the Realm that manages it.

     - warning: This method may only be called during a write transaction.
     */
    public func removeLast() {
        _rlmArray.removeLastObject()
    }

    /**
     Removes all objects from the list. The objects are not removed from the Realm that manages them.

     - warning: This method may only be called during a write transaction.
     */
    public func removeAll() {
        _rlmArray.removeAllObjects()
    }

    /**
     Replaces an object at the given index with a new object.

     - warning: This method may only be called during a write transaction.

     - warning: This method will throw an exception if called with an invalid index.

     - parameter index:  The index of the object to be replaced.
     - parameter object: An object.
     */
    public func replace(index: Int, object: T) {
        throwForNegativeIndex(index)
        _rlmArray.replaceObjectAtIndex(UInt(index), withObject: object.unsafeCastToRLMObject())
    }

    /**
     Moves the object at the given source index to the given destination index.

     - warning: This method may only be called during a write transaction.

     - warning: This method will throw an exception if called with invalid indices.

     - parameter from:  The index of the object to be moved.
     - parameter to:    index to which the object at `from` should be moved.
     */
    public func move(from from: Int, to: Int) { // swiftlint:disable:this variable_name
        throwForNegativeIndex(from)
        throwForNegativeIndex(to)
        _rlmArray.moveObjectAtIndex(UInt(from), toIndex: UInt(to))
    }

    /**
     Exchanges the objects in the list at given indices.

     - warning: This method may only be called during a write transaction.

     - warning: This method will throw an exception if called with invalid indices.

     - parameter index1: The index of the object which should replace the object at index `index2`.
     - parameter index2: The index of the object which should replace the object at index `index1`.
    */
    public func swap(index1: Int, _ index2: Int) {
        throwForNegativeIndex(index1, parameterName: "index1")
        throwForNegativeIndex(index2, parameterName: "index2")
        _rlmArray.exchangeObjectAtIndex(UInt(index1), withObjectAtIndex: UInt(index2))
    }

    // MARK: Notifications

    /**
     Registers a block to be called each time the list changes.

     The block will be asynchronously called with the initial list, and then
     called again after each write transaction which changes the list or any of
     the items in the list.

     The `change` parameter that is passed to the block reports, in the form of indices within the
     list, which of the objects were added, removed, or modified during each write transaction. See the
     `RealmCollectionChange` documentation for more information on the change information supplied and an example of how
     to use it to update a `UITableView`.

     The block is called on the same thread as it was added on, and can only
     be added on threads which are currently within a run loop. Unless you are
     specifically creating and running a run loop on a background thread, this
     will normally only be the main thread.

     Notifications can't be delivered as long as the run loop is blocked by
     other activity. When notifications can't be delivered instantly, multiple
     notifications may be coalesced into a single notification. This can include
     the notification with the initial list.

     For example, the following code performs a write transaction immediately after adding the notification block, so
     there is no opportunity for the initial notification to be delivered first. As a result, the initial notification
     will reflect the state of the Realm after the write transaction, and will not include change information.

     ```swift
     let person = realm.objects(Person.self).first!
     print("dogs.count: \(person.dogs.count)") // => 0
     let token = person.dogs.addNotificationBlock { changes in
         switch changes {
             case .Initial(let dogs):
                 // Will print "dogs.count: 1"
                 print("dogs.count: \(dogs.count)")
                 break
             case .Update:
                 // Will not be hit in this example
                 break
             case .Error:
                 break
         }
     }
     try! realm.write {
         let dog = Dog()
         dog.name = "Rex"
         person.dogs.append(dog)
     }
     // end of run loop execution context
     ```

     You must retain the returned token for as long as you want updates to be sent to the block. To stop receiving
     updates, call `stop()` on the token.

     - warning: This method cannot be called during a write transaction, or when the containing Realm is read-only.
     - warning: This method may only be called on a managed list.

     - parameter block: The block to be called each time the list changes.
     - returns: A token which must be held for as long as you want updates to be delivered.
     */
    @warn_unused_result(message="You must hold on to the NotificationToken returned from addNotificationBlock")
    public func addNotificationBlock(block: (RealmCollectionChange<List>) -> ()) -> NotificationToken {
        return _rlmArray.addNotificationBlock { list, change, error in
            block(RealmCollectionChange.fromObjc(self, change: change, error: error))
        }
    }
}

extension List: RealmCollectionType, RangeReplaceableCollectionType {
    // MARK: Sequence Support

    /// Returns an `RLMGenerator` that yields successive elements in the list.
    public func generate() -> RLMGenerator<T> {
        return RLMGenerator(collection: _rlmArray)
    }

    // MARK: RangeReplaceableCollection Support

    /**
     Replace the given `subRange` of elements with `newElements`.

     - parameter subRange:    The range of elements to be replaced.
     - parameter newElements: The new elements to be inserted into the list.
    */
    public func replaceRange<C: CollectionType where C.Generator.Element == T>(subRange: Range<Int>,
                                                                               with newElements: C) {
        for _ in subRange {
            removeAtIndex(subRange.startIndex)
        }
        for x in newElements.reverse() {
            insert(x, atIndex: subRange.startIndex)
        }
    }

    /// The position of the first element in a non-empty collection.
    /// Identical to `endIndex` in an empty collection.
    public var startIndex: Int { return 0 }

    /// The collection's "past the end" position.
    /// `endIndex` is not a valid argument to subscript, and is always reachable from `startIndex` by
    /// zero or more applications of `successor()`.
    public var endIndex: Int { return count }

    /// :nodoc:
    public func _addNotificationBlock(block: (RealmCollectionChange<AnyRealmCollection<T>>) -> Void) ->
        NotificationToken {
        let anyCollection = AnyRealmCollection(self)
        return _rlmArray.addNotificationBlock { _, change, error in
            block(RealmCollectionChange.fromObjc(anyCollection, change: change, error: error))
        }
    }
}

#endif
