//
//  main.swift
//  structs-and-refs
//
//  Created by Fritz Anderson on 8/9/16.
//  Copyright © 2016 Fritz Anderson. All rights reserved.
//

import Foundation

// Flag to record which branch in `addInts(x:, y:)`
// was taken. We’ll know `addInts` was called at all
// if unwrapping `reusedTheBackingStore` crashes.

var reusedTheBackingStore: Bool?

// MARK: - Joe Groff's suggestion

// This is Joe’s proposed solution verbatim, with two
// exceptions:
//
// - Uses `isUniquelyReferencedNonObjC(inout _:)`
//   sted `isKnownUniquelyReferenced(inout _:)`,
//   which hadn’t yet made it into Xcode 8.0b5.
//   I am assured the two are equivalent for this
//   purpose.
//
// - Sets `reusedTheBackingStore` to whether the
//   reuse branch was taken instead of creating a
//   new `S` and allocating a new buffer.

class C {
    var value: Int
    init(value: Int) { self.value = value }
}

struct S { var c: C }

func addInts(x: S, y: S) -> S {
    var tmp = x
    // Don't use x after this point so that it gets forwarded into tmp
    if isUniquelyReferencedNonObjC(&tmp.c) {
        reusedTheBackingStore = true
        tmp.c.value += y.c.value
        return tmp
    } else {
        reusedTheBackingStore = false
        return S(c: C(value: tmp.c.value + y.c.value))
    }
}

// MARK: - Exercise

// Call `addInts(x:, y:)` with no global references
// (unless the mere passing of a parameter retains a
// reference at the call site).
//
// Assign to `_`, to assure the call won't be
// optimized away (see next comment).

_ = addInts(x: S(c: C(value: 99)), y: S(c: C(value: -98)))

// If `addInts` were optimized away, `reusedTheBackingStore`
// would still be nil.
print(reusedTheBackingStore! ? "DID" : "Did NOT",
      "reuse the backing store.")

// Expected (fritza’s intuition):
// - unoptimized:   Did NOT
// - optimized:     Did NOT

// Joe’s claim (endorsed by other Swift-team engineers):
// - unoptimized:   Did NOT
// - optimized:     DID

// Actual:
// - unoptimized:   Did NOT
// - optimized:     Did NOT
