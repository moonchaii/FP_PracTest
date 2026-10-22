# Haskell Build Guide & Syntax Dictionary

*Built only from your FP lecture slides (FP 1-10). Nothing here comes from outside those files.*
*Items marked ⚠ are small illustrations that follow a slide's described signature but do not appear verbatim in the slides.*

---

## Contents
1. [Setup and running code](#1-setup-and-running-code)
2. [Step-by-step: building a Haskell program](#2-step-by-step-building-a-haskell-program)
3. [Syntax reference](#3-syntax-reference)
4. [Defining your own types](#4-defining-your-own-types)
5. [Generics, typeclasses, instances](#5-generics-typeclasses-instances)
6. [Lists, lambdas, comprehensions, folds](#6-lists-lambdas-comprehensions-folds)
7. [Recursion and laziness](#7-recursion-and-laziness)
8. [Worked reference: the dungeon base game](#8-worked-reference-the-dungeon-base-game)
9. [Function glossary](#9-function-glossary)
10. [Common errors and gotchas](#10-common-errors-and-gotchas)
11. [Quick checklist](#11-quick-checklist)

---

## 1. Setup and running code

| Thing | What the slides say |
|---|---|
| `ghc` | Glasgow Haskell Compiler |
| `ghci` | GHC interpreter |
| `cabal` | Package manager for GHC |
| Install | GHCup: https://www.haskell.org/ghcup/ (select ghc and ghci; cabal may be useful) |
| Script extension | `.hs` |
| Run a script | `runghc myscript.hs` (needs a `main` function) |
| Load into interpreter | `ghci myscript.hs` |

**ghci session**
```
$ ghci
ghci> 1 + 1
2
ghci> :{
ghci| f :: Int -> Int
ghci| f x = x - 1
ghci| :}
ghci> f 2
1
ghci> :quit
```
Multi-line input in ghci is wrapped in `:{` and `:}`.

**Useful ghci commands**

| Command | Purpose |
|---|---|
| `:?` | show all commands |
| `:quit` | quit ghci |
| `:load name` | load the given script |
| `:reload` | reload the current script |
| `:kind` | show the kind of a type (like `:type` for values) |

Example load: `ghci> :load myscript.hs` then `ghci> quadruple 4` gives `16`.

---

## 2. Step-by-step: building a Haskell program

The slides' own approach (prime search, FP 5) is **declarative and top-down**: say *what* you want, write the main function first, then fill in helpers.

### Step 1: State the goal in plain words
Example from the slides: "return all primes from 2 to upperBound. A number x is prime if it has no divisors other than 1 and x."

### Step 2: Decide the types (write the signature first)
Every function starts with a **type signature**, then a **body**.
```haskell
primes :: Int -> [Int]
```

### Step 3: Write the main function in terms of helpers you haven't written yet
```haskell
primes upperBound = filter isPrime [2..upperBound]
```

### Step 4: Implement each helper the same way (signature, then body)
```haskell
isPrime :: Int -> Bool
isPrime x = not $ any (isDivisor x) [2..(x - 1)]

isDivisor :: Int -> Int -> Bool
isDivisor num divisor = (num `mod` divisor) == 0
```

### Step 5: Think "pipeline of functions", not "sequence of actions"
The slides encourage writing functions as compositions of other functions; the body is often a single expression, using `where` for interim steps:
```haskell
intercepts :: Float -> Float -> Float -> (Float, Float)
intercepts a b c = (sol1, sol2)
  where sol1 = (-b + sqrt(discrim)) / denom
        sol2 = (-b - sqrt(discrim)) / denom
        discrim = b ^ 2 - (4 * a * c)
        denom = 2 * a
```

### Step 6: Add `main` if the script should run
```haskell
double :: Int -> Int
double x = x + x

quadruple :: Int -> Int
quadruple x = double (double x)

-- show = convert value to string to print
main :: IO ()
main = putStrLn (show (quadruple 4))
```

### Step 7: Load in ghci, test small pieces, fix compile errors
```
ghci> :load primeSearch.hs
ghci> isPrime 10
False
ghci> isPrime 13
True
```
Haskell finds all type errors at **compile time**, so if it compiles, whole classes of bugs are gone.

### Step 8: Pick the right tool for repetition
Haskell has no loops (they need a mutating counter).

| You'd write this in Python | In Haskell |
|---|---|
| `for` loop transforming each element | `map`, a list comprehension, or recursion |
| `for` loop keeping some elements | `filter`, or a comprehension with a guard |
| `for` loop with accumulator | `foldl'` / `foldr`, or recursion |
| `while` loop | recursion (state passed forward in arguments) |

The slides say the choice between recursion and a combinator is "a matter of taste", but code is read more than written, so keep it clear.

### Step 9: Build a data-type solution (for trees and problem models)
1. Describe the problem's things as types (`data ...`).
2. Write the one-step function for a single item (the "conquer" part).
3. Write the function that combines sub-results (the "divide" part).
4. Write the top-level recursive function that ties them together.
5. If you need to compare results, implement `Eq` and `Ord` for your type.

(Section 8 shows this pattern in the lecture's dungeon base game.)

---

## 3. Syntax reference

### 3.1 Comments
```haskell
-- this is a comment
```

### 3.2 Naming conventions
- Functions begin lowercase, `camelCase`: `sayHello`
- Types begin uppercase, `PascalCase`: `MyPet`
- List arguments end in `s`: `xs`, `pets`
- Generic type variables are lowercase letters: `a`

### 3.3 Layout (whitespace matters, like Python)
In a sequence of definitions each must start in the **same column**. `{}` and `;` can be used for explicit grouping.
```haskell
a = 10          -- OK: all in line
b = 20
c = 30

{a = 10;        -- OK: explicit grouping
b = 20;
c = 30}
```
Misaligned definitions are an error.

### 3.4 Basic arithmetic
```haskell
1 + 1        -- 2
5 - 2        -- 3
8 / 2        -- 4.0
2 * 5        -- 10
sqrt(144)    -- 12.0
5 ^ 2        -- 25
```

### 3.5 Basic types

| Type | Meaning |
|---|---|
| `()` | unit, "no value" (e.g. IO that returns nothing) |
| `Bool` | `True` or `False` |
| `Char` | single character |
| `String` | string of characters (a list of `Char`) |
| `Int` | fixed-size integer |
| `Integer` | arbitrary-size integer |
| `Float` / `Double` | floating point |
| `[a]` | list of values all of type `a` |
| `(a, b, ...)` | tuple |
| `Maybe a` | optional value |

The type of an expression is written `e :: T`.
```haskell
x :: Int = 1
y = x            -- type inferred
```
Type signatures are optional for functions when they can be inferred (the slides do still recommend writing them).

### 3.6 Function type signatures
```haskell
not  :: Bool -> Bool
even :: Int -> Bool
addVals :: Int -> Int -> Int
```
`T1 -> T2` means "takes T1, returns T2".

### 3.7 Defining and calling functions
```haskell
f :: Float -> Float
f x = 2 * x
```
- **Call with a space**, not brackets: `head [1, 2, 3, 4]`
- Function application binds tighter than operators: `f a + b` means `f(a) + b`, not `f(a + b)`.
- Brackets group: `quadruple (double 2)`

### 3.8 Conditionals: three ways
**if / else**
```haskell
abs :: Int -> Int
abs n = if n >= 0 then n else -n

signum :: Int -> Int
signum n = if n < 0 then -1
           else if n == 0 then 0
           else 1
```
**Guarded equations** (like piecewise maths)
```haskell
f :: Float -> Float
f x | x < 0 = -1
    | x > 1 = 1
    | otherwise = x
```
**Pattern matching** (matched in definition order)
```haskell
isPet :: String -> Bool
isPet "dog" = True
isPet "cat" = True
isPet var = False      -- use _ if the value isn't needed
```

### 3.9 Pattern matching on lists
```haskell
head :: [Int] -> Int
head (x:_) = x

tail :: [Int] -> [Int]
tail (_:xs) = xs
```
- Wrap cons patterns in `()`.
- No pattern for `[]` here, so these are **partial functions** (GHC warns).

### 3.10 `where` clauses
Define helper values/functions local to a function:
```haskell
nextPrime :: Int -> Int
nextPrime start = searchPrime $ start + 1
  where
    searchPrime start
      | isPrime start = start
      | otherwise = searchPrime (start + 1)
```

### 3.11 `case ... of`
```haskell
crawlBoth dog first second = sequenced
  where
    sequenced = case (crawl dog first) of
      Continue dog' -> crawl dog' second
      Victory -> Victory
      Death -> Death
```

### 3.12 `let ... in`
```haskell
foldl f z (x:xs) = let acc' = f acc x
                   in foldl f acc' xs
```

### 3.13 Pattern guards (`<-` inside a guard)
```haskell
| (Continue dog) <- a, (Continue dog') <- b = (dhp dog) <= (dhp dog')
| Death <- a = True
```
A guard can match a value against a constructor pattern and bind its fields.

### 3.14 The `$` operator
`foo $ bar baz quux` is sugar for `foo (bar baz quux)`. It removes brackets.
```haskell
isPrime x = not $ any (isDivisor x) [2..(x - 1)]
```

### 3.15 Backticks (infix a function)
```haskell
a `mod` b      -- same as mod a b
```

### 3.16 Function composition (`.`)
```haskell
f . g = \x -> f (g x)
(f . g) x = f (g x)

magnitude xs = sqrt $ sum $ map (^2) xs      -- with $
magnitude = sqrt . sum . map (^2)            -- composed, no data mentioned
```
Composing functions with multiple arguments "is not as trivial" (slides), so stay with single-argument pipelines.

### 3.17 Currying and partial application
`addVals :: Int -> Int -> Int` is really `Int -> (Int -> Int)`: a function that takes an `Int` and returns a function.
- `->` is right-associative; function application is left-associative.
- `addVals 1 2` is `((addVals 1) 2)`.
- Partial application:
```haskell
map (2 *) list        -- (2 *) :: Int -> Int
map (* 2) [1,2,3,4]   -- [2,4,6,8]
```

### 3.18 IO basics
```haskell
main :: IO ()
main = do
  let our_names :: [String] = []
  let new_names1 = add_name "Alice" our_names
  putStrLn ("New names " ++ show new_names1)
```
- `show` converts a value to a `String`.
- `print :: Show a => a -> IO ()` (equivalent to `putStrLn . show`).
- `mapM_` is "like map for IO functions, but we throw away the result since it's just ()". The slides promise to cover it later.

---

## 4. Defining your own types

Algebraic data types are made of **sum types** and **product types**.

### 4.1 Sum type: "one of these" (like an enum)
```haskell
data Suit = Hearts | Clubs | Spades | Diamonds
x :: Suit = Hearts

data IntOrStr = AnInteger Int | AString String
y :: IntOrStr = AnInteger 1
z :: IntOrStr = AString "Hello there"
```

### 4.2 Product type: "all of these" (like a struct)
```haskell
data IntAndStr = IntAndStr Int String
x :: IntAndStr = IntAndStr 1 "hello there"
```
Unnamed members are extracted via pattern matching.

### 4.3 Record syntax (named members)
```haskell
data Address = Address
  { number :: Int
  , street :: String
  }

addr = Address { number = 1, street = "a" }   -- named construction
addr = Address 1 "a"                          -- positional construction

number addr                                   -- get a field
addr { number = 2 }                           -- NEW copy with number changed (immutable)
```

### 4.4 Using constructors in functions (pattern matching on your type)
```haskell
data MyPet = Cat | Dog

sayHello :: MyPet -> String
sayHello Cat = "Hello, cat!"
sayHello Dog = "Hello, dog!"

sayHelloAll :: [MyPet] -> [String]
sayHelloAll pets = map sayHello pets
```
The constructor name need not equal the type name.

### 4.5 Deriving instances automatically
```haskell
data StreetAddress = Addr
  { number :: Int
  , street :: String
  , postcode :: Int
  } deriving Show
```
`deriving Show` saves writing the `Show` instance by hand. Also used with sum types:
```haskell
data RoomContents = Fight Monster
                  | Heal Int
                  | Empty
                  | Escape
                  deriving Show
```

### 4.6 Recursive types (trees)
```haskell
data Room = Room RoomContents (Maybe Room) (Maybe Room)
  deriving Show
```
A type can contain itself (here via `Maybe`, for 0, 1 or 2 children).

### 4.7 How lists are really defined
```haskell
data List a = [] | a : List a

[1, 2, 3, 4]
1:2:3:4:[]
1:(2:(3:(4:[])))     -- all three are equivalent
```
`:` is called **cons**.

### 4.8 Tuples
```haskell
(False, 1, "Hello") :: (Bool, Int, String)
fst (3, False)       -- 3
snd (3, False)       -- False
```
Tuples are fixed length and may hold different types. `fst`/`snd` work on pairs.

---

## 5. Generics, typeclasses, instances

### 5.1 Generic (polymorphic) functions
A lowercase type variable means "any type":
```haskell
add' :: a -> a -> a            -- unconstrained: but x + y won't compile!
```
Error you'll see: `No instance for 'Num a' arising from a use of '+'`.

Fix with a **constraint** (`Num a =>`):
```haskell
add' :: Num a => a -> a -> a
add' x y = x + y

add' 1 2        -- 3
add' 1.0 2.4    -- 3.4
```
A function with constraints is called an **overloaded** function.

### 5.2 Typeclasses
A typeclass is like an **interface** (not like an OOP class). It specifies behaviours.
```haskell
class Num a where
  (+), (-), (*) :: a -> a -> a
  negate :: a -> a
  abs :: a -> a
  signum :: a -> a
  fromInteger :: Integer -> a
  x - y = x + negate y        -- provided (default) member
  negate x = 0 - x            -- provided (default) member
```

### 5.3 Implementing a typeclass by hand (`instance`)
```haskell
instance Show StreetAddress where
  show addr =
    "Addr { number = " ++ (show $ number addr)
    ++ ", street = " ++ (show $ street addr)
    ++ "}"
```
`Show` only requires `show :: a -> String`.

### 5.4 Eq and Ord
`Ord` requires `Eq` (`class Eq a => Ord a`), so you implement `Eq` first:
```haskell
instance Eq VisitResult where
  Victory == Victory = True
  Death == Death = True
  (Continue a) == (Continue b) = (dhp a) == (dhp b)
  _ == _ = False
```
Then `Ord`, defining `<=`:
```haskell
instance Ord VisitResult where
  a <= b
    | a == b = True
    | (Continue dog) <- a, (Continue dog') <- b = (dhp dog) <= (dhp dog')
    | Death <- a = True
    | Death <- b = False
    | Victory <- b = True
    | Victory <- a = False
```
(Slides' convention: `x <= y` means *x is a worse result than y*. Once `Ord` is defined, functions like `maximum` work on the type.)

### 5.5 Generic types
```haskell
data Maybe a = Nothing | Just a
```
The type parameter goes **before the `=`** (different from function signatures).

**Why Maybe?** Haskell has no `null`. Instead of using `0` or `""` as "missing", use `Maybe`:
```haskell
data User = User
  { name :: String
  , age :: Maybe Int
  , parentEmail :: Maybe String
  }
```
The compiler then forces you to handle the missing case. Use `mapMaybe` / `catMaybes` to discard `Nothing`s:
```haskell
import Data.Maybe
spamAll :: String -> [User] -> IO ()
spamAll spam users = mapM_
  (\usrEmail -> sendEmail spam usrEmail)
  $ mapMaybe email users
```

### 5.6 Type constructors and kinds
`Maybe` is a function on types: `Maybe Int` is a type built from `Int`. In ghci, `:kind` shows it: `*` is a concrete type, `* -> *` maps a type to a type.

---

## 6. Lists, lambdas, comprehensions, folds

### 6.1 Lambdas (anonymous functions)
```haskell
\x -> 2 * x

factorise n = filter (\f -> n `mod` f == 0) [1..n]
```
Lambdas are useful for one-off functions and for returning functions:
```haskell
makeCallback :: String -> (Int -> String)
makeCallback name = \n -> "Hello" ++ name ++ "! Button has been pressed" ++ show n ++ "times."
```
Currying written as lambdas: `add x y = x + y` is equivalent to `add = \x -> (\y -> x + y)`.

### 6.2 List combinators in action
```haskell
map (* 2) [1, 2, 3, 4]        -- [2, 4, 6, 8]
filter (<= 2) [1, 2, 3, 4]    -- [1, 2]

-- batch processing pipeline
primeFactoriseNums :: [Int] -> [[Int]]
primeFactoriseNums ns = map primeFactorise ns

primeFactorise :: Int -> [Int]
primeFactorise n = filter isPrime (factorise n)

factorise :: Int -> [Int]
factorise n = filter (\f -> n `mod` f == 0) [1..n]
```

### 6.3 `zip` to process parallel lists
```haskell
names = ["John", "Eliza", "Muhammad", "Velesazi"]
ages  = [ 18, 102, 34, 68 ]

zip names ages
-- [("John",18),("Eliza",102),("Muhammad",34),("Velezazi",68)]

map fst $ filter (\(name, age) -> age < 65) $ zip names ages
-- ["John","Muhammad"]
```

### 6.4 Fold: the universal list combinator
`foldl f acc list`: for each element runs `f acc elt` and uses the result as the next `acc`.
```haskell
names = ["Tshepo", "Tafadzwa", "Tom"]
(foldl (\acc elt -> acc ++ elt ++ ", ") "Hello, " names) ++ "and everyone else!"

ns = [5, 10, 2, 3]
foldl (*) 1 ns        -- 300
```
- `foldl` is left-associative: `(((1 * 5) * 10) * 2) * 3`
- `foldr` is right-associative: `5 * (10 * (2 * (3 * 1)))`
- Matters for non-commutative operators: `foldl (-) 1 ns` is `-19`, `foldr (-) 1 ns` is `-5`.
- Python equivalent: a `for` loop with state, except the accumulator is copied forward, not mutated.
- Slide hint: every list combinator can be written as a fold.

### 6.5 List comprehensions
Mirrors set notation `E = { 2x | x ∈ N }`.
```haskell
e = [2 * x | x <- [1..]]
take 3 e                        -- [2, 4, 6]
```
- `x <- [1..]` is a **generator**.
- A condition after a comma is a **guard**:
```haskell
factorise' n = [f | f <- [1..n], n `mod` f == 0]
```
- **Multiple generators** = nested loops (order matters):
```haskell
suits = ["Clubs", "Hearts", "Spades", "Diamonds"]
regularCards = [(n, suit) | suit <- suits, n <- [2..10]]
```
- **Dependent generators** (later ones can use earlier ones):
```haskell
[(x, y) | x <- [1..3], y <- [1..x]]
-- [(1,1),(2,1),(2,2),(3,1),(3,2),(3,3)]
```
- **String comprehensions** (a `String` is a list of `Char`):
```haskell
import Data.Char
[toUpper c | c <- "hello"]      -- "HELLO"
```

### 6.6 Ranges
```haskell
[5, 4 .. 1]      -- [5,4,3,2,1]
[2..upperBound]
[1..]            -- infinite (lazy)
```

---

## 7. Recursion and laziness

### 7.1 Structure of a recursive function
- **Base case**: the simplest input; stops the recursion.
- **Recursive step / recurrence relation**: the part that calls itself.
```haskell
buildList :: Int -> [Int]
buildList 0 = []                      -- base case: exit at 0
buildList n = n : buildList (n - 1)   -- recursive step
```
Base case = loop exit, recursive step = loop body.

### 7.2 Recursion as a `for` loop over a list
```haskell
sum' :: Num a => [a] -> a
sum' [] = 0
sum' (x:xs) = x + sum' xs
```

### 7.3 Recursion as a `while` loop (state passed in arguments)
```haskell
nextPrime :: Int -> Int
nextPrime start = searchPrime $ start + 1
  where
    searchPrime start
      | isPrime start = start
      | otherwise = searchPrime (start + 1)
```
With more state (a counter `k`):
```haskell
kthNextPrime :: Int -> Int -> Int
kthNextPrime start k = searchPrime (start + 1) (k - 1)
  where
    searchPrime start k
      | isPrime start && k == 0 = start
      | isPrime start = searchPrime (start + 1) (k - 1)
      | otherwise = searchPrime (start + 1) k
```
A helper (`searchPrime`, often called `go`) carries the loop state.

### 7.4 Naturally recursive: Fibonacci and quicksort
```haskell
fib :: Int -> Int
fib 0 = 0
fib 1 = 1
fib n = fib (n - 1) + fib (n - 2)

qsort :: Ord a => [a] -> [a]
qsort [] = []
qsort (x:xs) = qsort tail ++ [pivot] ++ qsort head
  where
    pivot = x
    tail = [i | i <- xs, i <= pivot]
    head = [i | i <- xs, i > pivot]
```

### 7.5 Tail recursion (accumulator style)
```haskell
facAux 0 r = r
facAux n r = facAux (n-1) (r * n)
fac n = facAux n 1
```
Everything is calculated first and the recursive call is **last**, giving O(1) stack. Plain `fac n = n * fac (n-1)` uses O(n) stack.

Tail-recursive Fibonacci:
```haskell
fib :: Int -> Integer
fib n = go 0 1 0
  where
    go n_2 n_1 cur_n
      | n == cur_n = n_1
      | otherwise = go n_1 (n_2 + n_1) (cur_n + 1)
```
Fibonacci as a fold:
```haskell
fib :: Int -> Integer
fib n = fst (foldl' go (0, 1) [1..n])
  where
    go (n_1, n_2) _ = (n_1 + n_2, n_1)
```

### 7.6 Guarded recursion
Put the recursive call inside a data constructor where possible:
```haskell
map f (x:xs) = (f x) : (map f xs)
```
The rest of the list is only evaluated if needed.

### 7.7 Lazy evaluation essentials
- Expressions are evaluated **only when needed, only enough, at most once**.
- Lazy = outermost reduction + sharing (thunks).
- Unevaluated expressions are called **thunks**. The danger is a huge pile of thunks, not a deep "call stack".
- Infinite lists are fine: `ones = 1 : ones`.

### 7.8 `foldl` vs `foldl'` (strictness)
`foldl (+) 0 [1..300_000_000]` builds ~300 million thunks and may stack-overflow. `foldl'` forces evaluation as it goes via `seq`:
```haskell
foldl' f acc [] = acc
foldl' f acc (x:xs) = let acc' = f acc x
                      in seq acc' $ foldl' f acc' xs

seq :: a -> b -> b      -- strictly evaluates the 1st arg, then returns the 2nd
```
Using `foldr` instead doesn't help for `+` (it still piles up `1 + (2 + ...)`).

### 7.9 Memoising with a lazy array
```haskell
import Data.Array
fib' n = go n
  where go 0 = 0
        go 1 = 1
        go n = fibs ! (n - 1) + fibs ! (n - 2)
        fibs = listArray (0, n) [go x | x <- [0..n]]
```
`!` indexes the array. It is O(1) access but O(n) space.

### 7.10 Divide-and-conquer pattern
Break the problem into subproblems (e.g. subtrees), solve each, combine them. See Section 8.

---

## 8. Worked reference: the dungeon base game

This is the base-game code shown in FP 10 (also on Amathuba as `BaseGame.hs`). Use it as a syntax reference for how the pieces fit together. It is **not** the sample-prac solution; study how data types, instances and helper functions are laid out.

### Data types
```haskell
data Room = Room RoomContents (Maybe Room) (Maybe Room)
  deriving Show

data RoomContents = Fight Monster
                  | Heal Int
                  | Empty
                  | Escape
                  deriving Show

data Dog = Dog
  { dhp :: Int
  , ddmg :: Int
  } deriving Show

data Monster = Monster
  { mhp :: Int
  , mdmg :: Int
  } deriving Show

data VisitResult = Victory
                 | Death
                 | Continue Dog
                 deriving Show

crawl :: Dog -> Room -> VisitResult
```

### Eq and Ord instances
(See Section 5.4.)

### Fighting a monster (recursive guards)
```haskell
fight :: Dog -> Monster -> VisitResult
fight dog mon
  | dhp dog <= 0 = Death
  | mhp mon <= 0 = Continue dog
  | otherwise = fight dog' mon'
  where
    dog' = (dog { dhp = (dhp dog) - (mdmg mon) })
    mon' = (mon { mhp = (mhp mon) - (ddmg dog) })
```

### Solving one room (the "conquer" part)
```haskell
visitRoom :: Dog -> RoomContents -> VisitResult
visitRoom dog room = go room
  where
    go (Fight monster) = fight dog monster
    go (Heal hp) = Continue dog { dhp = (dhp dog) + hp }
    go Escape = Victory
    go Empty = Continue dog
```

### Combining children (the "divide" part)
```haskell
fork :: Dog -> Maybe Room -> Maybe Room -> VisitResult
fork dog leftRoom rightRoom = bestPath
  where
    bestPath = maximum validPaths
    validPaths = catMaybes
      [leftFirst, rightFirst, leftOnly, rightOnly, Just $ Continue dog]
    leftFirst  = fmap (uncurry $ crawlBoth dog) (both leftRoom rightRoom)
    rightFirst = fmap (uncurry $ crawlBoth dog) (both rightRoom leftRoom)
    leftOnly   = fmap (crawl dog) leftRoom
    rightOnly  = fmap (crawl dog) rightRoom

both :: Maybe a -> Maybe b -> Maybe (a, b)
both (Just a) (Just b) = Just (a, b)
both _ _ = Nothing

crawlBoth :: Dog -> Room -> Room -> VisitResult
crawlBoth dog first second = sequenced
  where
    sequenced = case (crawl dog first) of
      Continue dog' -> crawl dog' second
      Victory -> Victory
      Death -> Death
```

### Tying it together
```haskell
crawl :: Dog -> Room -> VisitResult
crawl dog (Room this left right) = soln
  where
    soln = case (visitRoom dog this) of
      Continue dog' -> fork dog' left right
      Victory -> Victory
      Death -> Death
```

### Prac tips from the slides
- **Question 1** is scaffolded and incremental; partial marks are available **as long as your code compiles**. Create a BLANK `Q1Ans.hs` and slowly copy and modify code from the base game.
- **Question 2** is not scaffolded and builds on Q1. Partial marks again need compiling code. Submit it in a **different file** from Q1 (copy Q1 over to start, never the other way).
- Typical changes the slides show: adding a member to a record, adding a variant to a sum type, and updating the `Eq` / `Ord` instances to match.

---

## 9. Function glossary

Format: **name** `:: signature` → what it does, then an example.

### Arithmetic & basics
| Function | Description | Example |
|---|---|---|
| `+ - * /` | arithmetic | `8 / 2` → `4.0` |
| `^` | power | `5 ^ 2` → `25` |
| `sqrt` | square root | `sqrt(144)` → `12.0` |
| `mod` | remainder (use with backticks) | ``num `mod` divisor`` |
| `negate`, `abs`, `signum` | `Num` class members | `negate x = 0 - x` |
| `even` | `Int -> Bool`, in the Prelude | `filter even [1,2,3]` → `[2]` |
| `not` | `Bool -> Bool` | `isPrime x = not $ any (isDivisor x) [2..(x - 1)]` |
| `otherwise` | catch-all guard | `\| otherwise = x` |
| `show` | `Show a => a -> String` | `show (quadruple 4)` |
| `print` | `Show a => a -> IO ()` | ⚠ `print 5` (slide: equivalent to `putStrLn . show`) |
| `putStrLn` | print a String | `putStrLn ("New names " ++ show new_names3)` |
| `div` | integer division (used in a slide exercise) | ``a `div` length xs`` |

### List functions (Prelude)
| Function | Description | Example |
|---|---|---|
| `head` | first element | `head list` → `1` |
| `tail` | all but first | `tail list` → `[2,3,4]` |
| `!!` | nth element (0-based) | `list !! 2` → `3` |
| `take n` | first n elements | `take 3 list` → `[1,2,3]` |
| `drop n` | remove first n | `drop 3 list` → `[4]` |
| `length` | list length | `length list` → `4` |
| `sum` | sum of numeric list | `sum list` → `10` |
| `product` | product of numeric list | `product list` → `24` |
| `++` | append lists | `list ++ [5, 6]` → `[1,2,3,4,5,6]` |
| `:` | cons, add to front | `1:2:3:[]` |
| `reverse` | reverse | `reverse list` → `[4,3,2,1]` |
| `maximum` | largest element (needs `Ord`) | `bestPath = maximum validPaths` |
| `zip` | pair two lists | `zip names ages` |
| `fst`, `snd` | first / second of a pair | `fst (3, False)` → `3` |

### Higher-order list functions
| Function | Description | Example |
|---|---|---|
| `map fn lst` | apply `fn` to every element | `map (* 2) [1,2,3,4]` → `[2,4,6,8]` |
| `filter prd lst` | keep elements satisfying `prd` | `filter (<= 2) [1,2,3,4]` → `[1,2]` |
| `foldl f acc lst` | left fold | `foldl (*) 1 [5,10,2,3]` → `300` |
| `foldr f base lst` | right fold | `foldr (+) 0 [1,2,3]` → `6` |
| `foldl'` | strict `foldl`, avoids thunk pile-up | `foldl' go (0, 1) [1..n]` |
| `all pred list` | `True` if `pred` holds for all | ⚠ usage per slide: `all pred list` |
| `any pred list` | `True` if `pred` holds for any | `any (isDivisor x) [2..(x - 1)]` |
| `takeWhile pred list` | take elements while they match | ⚠ usage per slide: `takeWhile pred list` |
| `dropWhile pred list` | drop elements while they match | ⚠ usage per slide: `dropWhile pred list` |
| `fmap f` | like `map`, more general; on `Maybe` it modifies the value inside if present | `fmap (crawl dog) leftRoom` |
| `uncurry f` | turns a 2-arg function into one taking a pair | `(uncurry (+)) (1, 2) == (+) 1 2` |

### Maybe functions
| Function | Description | Example |
|---|---|---|
| `Just x` / `Nothing` | constructors of `Maybe a` | `data Maybe a = Nothing \| Just a` |
| `mapMaybe` (`Data.Maybe`) | apply a `Maybe`-returning function and drop `Nothing`s | `mapMaybe email users` |
| `catMaybes` (`Data.Maybe`) | drop `Nothing`s from a list of `Maybe`s | `catMaybes [leftFirst, rightFirst, ...]` |

### Imports, strings, arrays, IO
| Function | Description | Example |
|---|---|---|
| `toUpper` (`Data.Char`) | uppercase a `Char` | `[toUpper c \| c <- "hello"]` → `"HELLO"` |
| `listArray` (`Data.Array`) | build an array from bounds and list | `listArray (0, n) [go x \| x <- [0..n]]` |
| `!` (`Data.Array`) | index an array | `fibs ! (n - 1)` |
| `seq a b` | strictly evaluate `a`, return `b` | `seq acc' $ foldl' f acc' xs` |
| `mapM_` | map an IO function over a list, discard results | `mapM_ (\u -> sendEmail spam u) emails` |
| `.` | function composition | `magnitude = sqrt . sum . map (^2)` |
| `$` | apply function, avoids brackets | `not $ any (isDivisor x) [2..(x - 1)]` |

### Typeclasses at a glance
| Class | Purpose | Notes |
|---|---|---|
| `Num` | things that can be added/multiplied | `Num a => a -> a -> a` |
| `Show` | convert to `String` | implement `show`, or `deriving Show` |
| `Eq` | equality (`==`) | needed before `Ord` |
| `Ord` | ordering (`<=`) | `class Eq a => Ord a` |

---

## 10. Common errors and gotchas

| Symptom / message | Cause | Fix |
|---|---|---|
| `No instance for 'Num a' arising from a use of '+'` | generic `a` used with `+` | add constraint `Num a =>` |
| `Couldn't match expected type: [Char] with actual type: Maybe String` | passed a `Maybe` where a plain value is needed | unwrap, e.g. `mapMaybe` |
| Passing `"Hello"` to an `Int` function | strict static typing, caught at compile time | fix the types |
| `[1.0, False]` | list elements must all share one type | use a tuple or a sum type |
| `add' 1.0 2.0` with `Int -> Int -> Int` | `Int` doesn't accept floats | use a generic `Num a =>` signature |
| Layout errors | definitions not aligned in the same column | align columns |
| Warning about partial function | no pattern for `[]` | add a `[]` case |
| `f a + b` not behaving | application binds tighter than `+` | use brackets: `f (a + b)` |
| Stack overflow with `foldl` on huge lists | pile of thunks | use `foldl'` |
| `fib` super slow | repeated recomputation | memoise or use tail recursion |
| Cons pattern fails to parse | missing brackets | write `(x:xs)` |
| `Ord` instance won't compile | missing `Eq` | implement `Eq` first |

**Slide typos to be aware of**
- The FP 5 exercise snippet has `‘div’` with curly quotes; real code uses plain backticks `` ` ``.
- In the FP 5 exercise snippet `foo :: String` and `Where` (capital W) are intentionally wrong; that exercise asks you to fix them.
- Some FP 9 Fibonacci slides show `fib 0 = 1` / `fib 1 = 0` while others use `fib 0 = 0` / `fib 1 = 1`; the standard version is the latter.
- Slide 4 of FP 8 shows a record ending with a trailing comma (`street :: String,`), which is invalid; no trailing comma in records.

---

## 11. Quick checklist

Before you submit or load a file, check:

- [ ] Every function has a **type signature**
- [ ] Definitions **aligned** in the same column
- [ ] Function names `camelCase`, types and constructors `PascalCase`
- [ ] List patterns wrapped in `(x:xs)`
- [ ] Every recursive function has a **base case**
- [ ] Constrained generics use `Num a =>` / `Ord a =>` etc.
- [ ] `Ord` instances have a matching `Eq` instance
- [ ] Necessary imports present (`Data.Maybe`, `Data.Char`, `Data.Array`)
- [ ] Long folds use **`foldl'`**, not `foldl`
- [ ] The file **compiles**, since partial marks depend on it
- [ ] Question 2 is in a **different file** from Question 1

---

*Source files: FP 1 Introduction, FP 2 Lazy Evaluation, FP 3 Recursion, FP 4 / 4A Lambda Calculus, FP 5-10 Haskell lectures.*
