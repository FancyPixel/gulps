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

#import "RLMObject_Private.hpp"

#import "RLMAccessor.h"
#import "RLMObjectSchema_Private.hpp"
#import "RLMObjectStore.h"
#import "RLMQueryUtil.hpp"
#import "RLMRealm_Private.hpp"
#import "RLMSchema_Private.h"

// We declare things in RLMObject which are actually implemented in RLMObjectBase
// for documentation's sake, which leads to -Wunimplemented-method warnings.
// Other alternatives to this would be to disable -Wunimplemented-method for this
// file (but then we could miss legitimately missing things), or declaring the
// inherited things in a category (but they currently aren't nicely grouped for
// that).
@implementation RLMObject

// synthesized in RLMObjectBase
@dynamic invalidated, realm, objectSchema;

#pragma mark - Designated Initializers

- (instancetype)init {
    return [super init];
}

- (instancetype)initWithValue:(id)value schema:(RLMSchema *)schema {
    return [super initWithValue:value schema:schema];
}

- (instancetype)initWithRealm:(__unsafe_unretained RLMRealm *const)realm schema:(RLMObjectSchema *)schema {
    return [super initWithRealm:realm schema:schema];
}

#pragma mark - Convenience Initializers

- (instancetype)initWithValue:(id)value {
    [self.class sharedSchema]; // ensure this class' objectSchema is loaded in the partialSharedSchema
    RLMSchema *schema = RLMSchema.partialSharedSchema;
    return [super initWithValue:value schema:schema];
}

#pragma mark - Class-based Object Creation

+ (instancetype)createInDefaultRealmWithValue:(id)value {
    return (RLMObject *)RLMCreateObjectInRealmWithValue([RLMRealm defaultRealm], [self className], value, false);
}

+ (instancetype)createInRealm:(RLMRealm *)realm withValue:(id)value {
    return (RLMObject *)RLMCreateObjectInRealmWithValue(realm, [self className], value, false);
}

+ (instancetype)createOrUpdateInDefaultRealmWithValue:(id)value {
    return [self createOrUpdateInRealm:[RLMRealm defaultRealm] withValue:value];
}

+ (instancetype)createOrUpdateInRealm:(RLMRealm *)realm withValue:(id)value {
    // verify primary key
    RLMObjectSchema *schema = [self sharedSchema];
    if (!schema.primaryKeyProperty) {
        NSString *reason = [NSString stringWithFormat:@"'%@' does not have a primary key and can not be updated", schema.className];
        @throw [NSException exceptionWithName:@"RLMExecption" reason:reason userInfo:nil];
    }
    return (RLMObject *)RLMCreateObjectInRealmWithValue(realm, [self className], value, true);
}

#pragma mark - Subscripting

- (id)objectForKeyedSubscript:(NSString *)key {
    return RLMObjectBaseObjectForKeyedSubscript(self, key);
}

- (void)setObject:(id)obj forKeyedSubscript:(NSString *)key {
    RLMObjectBaseSetObjectForKeyedSubscript(self, key, obj);
}

#pragma mark - Getting & Querying

+ (RLMResults *)allObjects {
    return RLMGetObjects(RLMRealm.defaultRealm, self.className, nil);
}

+ (RLMResults *)allObjectsInRealm:(RLMRealm *)realm {
    return RLMGetObjects(realm, self.className, nil);
}

+ (RLMResults *)objectsWhere:(NSString *)predicateFormat, ... {
    va_list args;
    va_start(args, predicateFormat);
    RLMResults *results = [self objectsWhere:predicateFormat args:args];
    va_end(args);
    return results;
}

+ (RLMResults *)objectsWhere:(NSString *)predicateFormat args:(va_list)args {
    return [self objectsWithPredicate:[NSPredicate predicateWithFormat:predicateFormat arguments:args]];
}

+ (RLMResults *)objectsInRealm:(RLMRealm *)realm where:(NSString *)predicateFormat, ... {
    va_list args;
    va_start(args, predicateFormat);
    RLMResults *results = [self objectsInRealm:realm where:predicateFormat args:args];
    va_end(args);
    return results;
}

+ (RLMResults *)objectsInRealm:(RLMRealm *)realm where:(NSString *)predicateFormat args:(va_list)args {
    return [self objectsInRealm:realm withPredicate:[NSPredicate predicateWithFormat:predicateFormat arguments:args]];
}

+ (RLMResults *)objectsWithPredicate:(NSPredicate *)predicate {
    return RLMGetObjects(RLMRealm.defaultRealm, self.className, predicate);
}

+ (RLMResults *)objectsInRealm:(RLMRealm *)realm withPredicate:(NSPredicate *)predicate {
    return RLMGetObjects(realm, self.className, predicate);
}

+ (instancetype)objectForPrimaryKey:(id)primaryKey {
    return RLMGetObject(RLMRealm.defaultRealm, self.className, primaryKey);
}

+ (instancetype)objectInRealm:(RLMRealm *)realm forPrimaryKey:(id)primaryKey {
    return RLMGetObject(realm, self.className, primaryKey);
}

#pragma mark - Other Instance Methods

- (BOOL)isEqualToObject:(RLMObject *)object {
    return [object isKindOfClass:RLMObject.class] && RLMObjectBaseAreEqual(self, object);
}

+ (NSString *)className {
    return [super className];
}

#pragma mark - Default values for schema definition

+ (NSArray *)indexedProperties {
    return @[];
}

+ (NSDictionary *)linkingObjectsProperties {
    return @{};
}

+ (NSDictionary *)defaultPropertyValues {
    return nil;
}

+ (NSString *)primaryKey {
    return nil;
}

+ (NSArray *)ignoredProperties {
    return nil;
}

+ (NSArray *)requiredProperties {
    return @[];
}

@end

@implementation RLMDynamicObject

+ (BOOL)shouldIncludeInDefaultSchema {
    return NO;
}

- (id)valueForUndefinedKey:(NSString *)key {
    return RLMDynamicGetByName(self, key, false);
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    RLMDynamicValidatedSet(self, key, value);
}

@end

@implementation RLMWeakObjectHandle {
    realm::Row _row;
    RLMClassInfo *_info;
    Class _objectClass;
}

- (instancetype)initWithObject:(RLMObjectBase *)object {
    if (!(self = [super init])) {
        return nil;
    }

    _row = object->_row;
    _info = object->_info;
    _objectClass = object.class;

    return self;
}

- (RLMObjectBase *)object {
    RLMObjectBase *object = RLMCreateManagedAccessor(_objectClass, _info->realm, _info);
    object->_row = std::move(_row);
    return object;
}

@end
