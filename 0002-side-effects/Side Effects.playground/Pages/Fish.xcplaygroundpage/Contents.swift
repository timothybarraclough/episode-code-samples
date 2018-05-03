struct TSet<A> {
    var contains : (A) -> Bool
    init(_ f: @escaping (A) -> Bool) {
        contains = f
    }
}

extension TSet {
    
    func invert() -> TSet<A> {
        return TSet { a in !self.contains(a) }
    }
    
    func intersection(with other: TSet<A>) -> TSet<A> {
        return TSet { a in
            self.contains(a) && other.contains(a)
        }
    }
    
    func union(with other: TSet<A>) -> TSet<A> {
        return TSet { a in
            self.contains(a) || other.contains(a)
        }
    }
    
    static func +(lhs: TSet<A>, rhs: TSet<A>) -> TSet<A> {
        return lhs.union(with: rhs)
    }
    
    static func *(lhs: TSet<A>, rhs: TSet<A>) -> TSet<A> {
        return lhs.intersection(with: rhs)
    }
}


let evenIntegers = TSet { $0 % 2 == 0 }

let fizzbang =
        TSet { $0 % 3 == 0 }
        * TSet { $0 % 5 == 0 }
        * TSet { $0 * $0 % 8 == 0 }

precedencegroup LeftAssociatingBinaryOperation {
    associativity: left
}
infix operator <> : LeftAssociatingBinaryOperation

struct FizzBuzzRule {
    let set : TSet<Int>
    let log : (Int) -> String
    
    static func <>( _ lhs: FizzBuzzRule, _ rhs: FizzBuzzRule) -> FizzBuzzRule {
        return FizzBuzzRule(set: lhs.set + rhs.set) { i in return lhs.set.contains(i)
              ? lhs.log(i)
              : rhs.log(i) }
    }
    
    func evaluate(_ i: Int) -> String {
        return set.contains(i) ? log(i) : ""
    }
}

// Rule set
let rules =
    FizzBuzzRule(set: TSet { $0 % 15 == 0 }) { _ in "Fizz Buzz" }
 <> FizzBuzzRule(set: TSet { $0 % 5  == 0 }) { _ in "Buzz" }
 <> FizzBuzzRule(set: TSet { $0 % 3  == 0 }) { _ in "Fizz" }
 <> FizzBuzzRule(set: TSet { _ in true }) { i in i.description }


extension String {
    static func <>(_ lhs: String, _ rhs: String) -> String {
        return "\(lhs)\(rhs)"
    }
}

// Reducer function
func ruleReducer(_ s: String, i: Int) -> String {
    return s
        <> "\n"
        <> rules.evaluate(i)
}

print(
    Array(1...30).reduce("", ruleReducer)
)




// https://www.pointfree.co/episodes/ep2-side-effects

//func compute(_ x: Int) -> Int {
//  return x * x + 1
//}
//
//compute(2)
//compute(2)
//compute(2)
//
//assertEqual(5, compute(2))
//assertEqual(6, compute(2))
//assertEqual(5, compute(3))
//
//func computeWithEffect(_ x: Int) -> Int {
//  let computation = x * x + 1
//  print("Computed \(computation)")
//  return computation
//}
//
//computeWithEffect(2)
//
//assertEqual(5, computeWithEffect(2))
//
//[2, 10].map(compute).map(compute)
//[2, 10].map(compute >>> compute)
//
//[2, 10].map(computeWithEffect).map(computeWithEffect)
//__
//[2, 10].map(computeWithEffect >>> computeWithEffect)
//
//
//func computeAndPrint(_ x: Int) -> (Int, [String]) {
//  let computation = x * x + 1
//  return (computation, ["Computed \(computation)"])
//}
//
//__
//computeAndPrint(2)
//
//assertEqual(
//  (5, ["Computed 5"]),
//  computeAndPrint(2)
//)
//assertEqual(
//  (4, ["Computed 5"]),
//  computeAndPrint(2)
//)
//assertEqual(
//  (4, ["Computed 3"]),
//  computeAndPrint(2)
//)
//
//let (computation, logs) = computeAndPrint(2)
//__
//logs.forEach { print($0) }
//
//2 |> compute >>> compute
//__
//2 |> computeWithEffect >>> computeWithEffect
//
////computeAndPrint >>> computeAndPrint
//
//func compose<A, B, C>(
//  _ f: @escaping (A) -> (B, [String]),
//  _ g: @escaping (B) -> (C, [String])
//  ) -> ((A) -> (C, [String])) {
//
//  return { a in
//    let (b, logs) = f(a)
//    let (c, moreLogs) = g(b)
//    return (c, logs + moreLogs)
//  }
//}
//
//2 |> compose(computeAndPrint, computeAndPrint)
//
//2 |> compose(compose(computeAndPrint, computeAndPrint), computeAndPrint)
//
//2 |> compose(computeAndPrint, compose(computeAndPrint, computeAndPrint))
//
//precedencegroup EffectfulComposition {
//  associativity: left
//  higherThan: ForwardApplication
//  lowerThan: ForwardComposition
//}
//
//infix operator >=>: EffectfulComposition
//
//func >=> <A, B, C>(
//  _ f: @escaping (A) -> (B, [String]),
//  _ g: @escaping (B) -> (C, [String])
//  ) -> ((A) -> (C, [String])) {
//
//  return { a in
//    let (b, logs) = f(a)
//    let (c, moreLogs) = g(b)
//    return (c, logs + moreLogs)
//  }
//}
//
//2
//  |> computeAndPrint
//  >=> incr
//  >>> computeAndPrint
//  >=> square
//  >>> computeAndPrint
//
//
//func >=> <A, B, C>(
//  _ f: @escaping (A) -> B?,
//  _ g: @escaping (B) -> C?
//  ) -> ((A) -> C?) {
//
//  return { a in
//    guard let b = f(a) else { return nil }
//    return g(b)
//  }
//
//    return { a in
//        f(a).flatMap(g)
//    }
//}
//
//String.init(utf8String:) >=> URL.init(string:)
//
//func >=> <A, B, C>(
//  _ f: @escaping (A) -> [B],
//  _ g: @escaping (B) -> [C]
//  ) -> ((A) -> [C]) {
//
//
//    return { a in
//        f(a).flatMap(g)
//    }
//}
//
//
////func >=> <A, B, C>(
////  _ f: @escaping (A) -> Promise<B>,
////  _ g: @escaping (B) -> Promise<C>
////  ) -> ((A) -> Promise<C>) {
////
////  return { a in
////    fatalError()
////  }
////}
//
//func greetWithEffect(_ name: String) -> String {
//  let seconds = Int(Date().timeIntervalSince1970) % 60
//  return "Hello \(name)! It's \(seconds) seconds past the minute."
//}
//
//greetWithEffect("Blob")
//
//assertEqual("Hello Blob! It's 32 seconds past the minute.", greetWithEffect("Blob"))
//
//func greet(at date: Date = Date(), name: String) -> String {
//  let seconds = Int(date.timeIntervalSince1970) % 60
//  return "Hello \(name)! It's \(seconds) seconds past the minute."
//}
//
//greet(name: "Blob")
//
//assertEqual(
//  "Hello Blob! It's 39 seconds past the minute.",
//  greet(at: Date(timeIntervalSince1970: 39), name: "Blob")
//)
//
//assertEqual(
//  "Hello Blob! It's 39 seconds past the minute.",
//  greet(at: Date(timeIntervalSince1970: 39), name: "Blob")
//)
//
//assertEqual(
//  "Hello Blob! It's 39 seconds past the minute.",
//  greet(at: Date(timeIntervalSince1970: 39), name: "Blob")
//)
//
//greetWithEffect
//
//func uppercased(_ string: String) -> String {
//  return string.uppercased()
//}

//"Blob" |> uppercased >>> greetWithEffect
//"Blob" |> greetWithEffect >>> uppercased
//
////"Blob" |> uppercased >>> greet
////"Blob" |> greet >>> uppercased
//
//func greet(at date: Date, petName: String) -> (String) -> String {
//
//    func greetWithDate(name: String) -> String {
//            let seconds = Int(date.timeIntervalSince1970) % 60
//            return "Hello \(name)! It's \(seconds) seconds past the minute."
//    }
//
//    return greetWithDate
//}
//
//"Blob" |> uppercased >>> greet(at: Date())
//
//assertEqual(
//  "Hello BLOB! It's 37 seconds past the minute.",
//  "Blob" |> uppercased >>> greet(at: Date(timeIntervalSince1970: 37))
//)

