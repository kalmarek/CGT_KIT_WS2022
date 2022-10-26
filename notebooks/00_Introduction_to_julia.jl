### A Pluto.jl notebook ###
# v0.19.14

using Markdown
using InteractiveUtils

# ╔═╡ c728b133-37bc-41f6-8e88-1ca8df6a7a4f
md"
# What is `julia`?

`julia` is a modern language that is dynamic, strongly typed, _jit_ compiled (internally) to machine language and therefore can be as fast as staticly typed fast languages (`C`/`C++`). If you didn't understand this sentence, here's a more digestable gist:

`julia` language can be used in an interactive environment and without longish setups and can be written in a form that looks similar to pseudocode (users of 	`MATLAB`/`octave` will notice strong similarity, a bit less similarity with `python`). Moreover with a little bit of care julia can run really fast.
"

# ╔═╡ bcf0e9dd-5261-4477-aa7b-3c27ea16180b
md"
## Other materials introducing `julia`:
* [Think Julia](https://benlauwens.github.io/ThinkJulia.jl/latest/book.html) a very extensive book written in a friendly matter with exercises.
* [Zero2Hero](https://www.youtube.com/watch?v=Fi7Pf2NveH0) If you prefer a video introduction (assumes a bit programming), but the materials are also available in the [written form](https://github.com/Datseris/Zero2Hero-JuliaWorkshop), see e.g. [this](https://github.com/Datseris/Zero2Hero-JuliaWorkshop/blob/master/1-JuliaBasics.ipynb) for much more thorough introduction.
* [Julia Express](http://bogumilkaminski.pl/files/julia_express.pdf) rather a cheatsheet than a book/manual, but plenty of useful syntax, well categorized, 17 pages of it.
"

# ╔═╡ 09789c5d-97af-45ab-baaf-92bd9ef63455
md"`julia` can be used as calculator. For example:"

# ╔═╡ 345c44c5-c0e3-4a5f-ba64-f60935f77bf7
sin(2)

# ╔═╡ 5a8d9549-a75d-405d-afcd-9831e7e78113
2^6

# ╔═╡ 202566cf-75ad-4375-9bf7-713023952862


# ╔═╡ 2d7170eb-3201-483e-b951-86dffd327e2b
md"Are plenty of (arithmetic) operators (such as `+`, `-`, `*`, `^`, `/`, `//`, `%`, `div`, `rem`, ...) and functions (such as `sin`, `factorial`, etc.) already defined.
For operators have a look at the beginning of the [section from julia manual](https://docs.julialang.org/en/v1/manual/mathematical-operations/). We will come back to functions later."

# ╔═╡ faa7705c-c044-46be-ba91-6b0adef24d4c
md"We can also define variables by simply assign value to a name:"

# ╔═╡ c1198833-3c4a-4106-8bbb-6534a917cd72
x = 2π

# ╔═╡ cdc234ea-e482-40bc-b4ef-7adfc8d38aca
md"and access the value assigned to a name somewhere else:"

# ╔═╡ 688085ec-a8ed-4830-9081-2d1f6a6ab87f
sin(x) # ooops is the value correct?!

# ╔═╡ ed74560c-e9a6-4e38-8efb-f51cc3eadab6
md"To learn more about variables (and their allowed names) have a brief look at examples [here](https://docs.julialang.org/en/v1/manual/variables/).
"

# ╔═╡ 53167dd4-209d-4ecf-a0aa-54aca12fffd2
md"# Assignment, comparison and `if` statements
There is a difference between assignment (`=`) and equality comparison (`==`):"

# ╔═╡ f7b322e5-cad7-41db-b391-c46844008f3d
z = 1.2

# ╔═╡ bcf0dd01-28e3-4b06-8f11-c131a3526334
z == 1.2

# ╔═╡ 74d549ce-0783-49fa-a150-1763f06ecbfa
y = 1.1

# ╔═╡ 9b3dbb28-9f3a-421f-9f26-ea39642d3959
y == z

# ╔═╡ c9c11f7a-c0b5-4c72-9cfc-3b94a787a055
md"Those `true` and `false` (so called `Booleans`) can be used in _conditional_ statements such as"

# ╔═╡ 15ed6e94-4355-42a8-bad2-a53cd97cf290
sss = if y == z
    "In the castle of Aaaaargh..."
else
	"Where is it? Behind the rabbit?"
end

# ╔═╡ 75d20084-3b43-4124-a2aa-e9abf35c91fc
y == z ? error("aaa") : 2

# ╔═╡ 8c7c7a38-accd-4dca-9e61-299db82f3b8d
ifelse(y == z, "a", "b")

# ╔═╡ 36e5468a-a5dc-42cd-81b7-92b0447ca8e4
md"As you can see `if` block may contain `else` clause (or several `elseif` ones) and is finished by `end`. In general it looks like this:
```julia
if condition1
	…
elseif condition2
	…
elseif …
⋮
else
	…
end
```

In julia **every** statement (such as this `if -- else` block) returns a value. Here conditionally on values of `y` and `z` one of the strings is returned. Note: you can negate the condition by either writing `y !== x` or more generally by placing exclamation mark: `!(y == x)`.

There is more about conditional statements than is presented here, but for now this will suffice for our needs. If you want to learn more, have a look [here](https://docs.julialang.org/en/v1/manual/control-flow/#man-conditional-evaluation) (but by no means you need to read the whole page!).
"

# ╔═╡ 2d45fc43-ede5-4c05-837a-f96c17734550
md"# Loops and iteration

Can you guess what does the following code do?
"

# ╔═╡ a0542649-cbf2-4137-bb69-3fbef8fa2c98
md"This is so called `for` loop where we iterate over consecutive natural numbers from `1` to `5` and sum them together. We could much simpler express it as `sum(1:5)`:"

# ╔═╡ c2c925c7-ce88-4f1c-94f7-19451eefd3e0
sum(1:5)

# ╔═╡ 813e73fb-470c-47fc-940e-da03a105ca79
md"A different form of iteration is so called _array comprehension_, e.g.
```julia
[x^2 for x in 5:15]
```
creates an array (a list) of squares of integers from `5` to `15`. Let's observe it in action:"

# ╔═╡ 4e423cda-c448-4750-b420-a6982033b6f5
[x^2 for x in 5:15]

# ╔═╡ ad381ecb-c9fa-463b-9f69-f23e629e459b
map(x->x^2, 5:15)

# ╔═╡ 197bc9a4-2695-45bc-8ff2-b0cdd73b30e9
md"such iteration can have plenty of variables and contain conditional statements as well. For example this code:
```julia
[(x,y) for x in -7:7 for y in -7:7 if x^2 + y^2 <= 7^2]
```
finds all integer points on the plane inside a circle of radius 7.
We could even (very poorly) approximate π with it!
"

# ╔═╡ 3fa1fa90-57ab-4a30-afdd-bfa0c866f3ef
md"We make a major performance blunder, of course, since we don't need to create all of those points when we just need to count them... but that's a story for another time."

# ╔═╡ 83dee27b-1c40-4a2d-a204-ffe1effd56d9
count([true for _ in 1:5])

# ╔═╡ 94d38118-94ec-43fc-8a16-6fc562bcdeaa
(x < 5 for x in 3:7)

# ╔═╡ ab914178-f909-44b0-811c-418f2d4939b3
md"Iteration is an important concept and one of the major tasks in the first part of the course will be to efficiently iterate (without repetitions) over all elements of a permutation group."

# ╔═╡ 7fd81fe1-c810-44ca-baa5-9d6a9555be74
md"# Functions
Let us talk about functions. There are three ways to define them in `julia`:
* **full** definition looks as follows:
```julia
function my_fancy_phi(argument1, argument2, ...)
    # do some computation here
    y = ...
    return y
end
```
this function takes arguments and performs some computations with them; finally `y` is returned as the value of the function.
* **one-liner** definition is just a shortcut for the above where the body fits into a single line, e.g.
```julia
my_fancy_phi(a, b) = 2*a + b^2
```
simple and short without `function`, `return` and `end` (who needs them anyway? :)
* finally there are **anonymous** functions where you could just say
```julia
x -> sin(2*x)
```
You could define `h = x -> sin(x*π)` and then ask for `h(2)` but the most popular case is when one wants to e.g. sum not all integers from `1:5`, but e.g. their squares:
"

# ╔═╡ 4a4fba03-234e-465d-bc97-988e6e70ef69
sum(x->x^2, 1:5) # function sum accepts also a function as the first argument

# ╔═╡ ce49d466-4c05-45bd-88c6-3f0694c873ef
count(==(5), 3:7)

# ╔═╡ 4b2035f0-55e8-4f39-a6a7-e8882f493dfb
md"
Remember the approximation of `pi` with `let` block? 
```julia
let R = 1000
	4*count(x^2 + y^2 ≤ R^2 for x in 0:R for y in 1:R)/R^2
end
```

Let's turn it into a function!
"

# ╔═╡ 09fa8914-7966-40f7-98eb-86aa43658908
# ╠═╡ show_logs = false
# ╠═╡ disabled = true
#=╠═╡
@code_native debuginfo=:none approximate_π(100)
  ╠═╡ =#

# ╔═╡ cb141457-2671-4582-96ef-5c03d4d35814
md"
## Recursive functions
Let us have a look at a more complicated function: the one computing Fibbonachi numbers. It's a classical form of a recursive definition:
* ``Fib(0) = 1``
* ``Fib(1) = 1``
* ``Fib(n) = Fib(n-1) + Fib(n-2)``
How can we achieve that with julia?
"

# ╔═╡ 6f221be1-1ab2-4f26-a4ad-f2c493c5e290


# ╔═╡ b275cf5f-846d-4487-9c5e-2ca9344bc807
md"# Types
We haven't talked about it but types could be observed running in the wild as we did our computations above. In `julia` we don't need to talk about types (at least) at the beginning), but they are _silently attached_ to everything we compute. There are a few build-in types: `Int`, `Float64`, `String`, `Array` (`Vector`, `Matrix`, ...), `BigInt`, etc. Let's observe them in action:
"

# ╔═╡ 3a2d237d-d924-4b2a-b767-26fb047c0886
typeof(2)

# ╔═╡ cec7a620-9147-4afc-8948-80f91ffd1268
typeof(2.0)

# ╔═╡ 3de5ea6b-8072-49b5-a504-98a75992b49f
supertypes(Float64)

# ╔═╡ a7151ae1-6d68-45d0-8840-8b994ed9f734
typeof("2.0")

# ╔═╡ 6ecc64b2-dbfa-4ccd-a2aa-286417b7d8ba
typeof(2^50)

# ╔═╡ 504a5cc2-0d06-48a1-a805-2ed5d4bd6a70
2^62 

# ╔═╡ 3e50b42e-3ce4-4df2-a6cd-96a79cd09e2b
2^64 # surprised?

# ╔═╡ 9bf248aa-7897-4104-94c5-195314dafb44
bitstring(2)

# ╔═╡ 785ec286-280f-4ef7-81e5-1e80c750371c
bitstring(2^62)

# ╔═╡ 6889507f-1964-4c89-b06c-e195a2484b7c
bitstring(2^64)

# ╔═╡ 2d1f1731-381c-4501-a252-f4e34db8bac8
bitstring(-1)

# ╔═╡ 9ab2675c-d6a2-494e-847c-4a886a1166b6
md"Due to finite precision of numbers stored on our computers one has to be rather careful not to introduce silent errors, e.g.
```julia
(2^63)÷2 + 2^62 == 0
```
one possible way to avoid it is to use _multiprecision_ integers, aka `BigInt`s:
"

# ╔═╡ 1278b847-8dfc-4afc-b7bb-c7877f5fb828
typeof(big(2))

# ╔═╡ e3612ed5-0e34-4b77-875e-a18294d307c9
(big(2)^63)

# ╔═╡ e7bc6eab-727c-4ab8-83c2-357d89ce225e
let z = 9223372036854775808
	typeof(z)
end

# ╔═╡ ad18678d-4d69-4064-bcd8-2b4bc6c0c60a
md"
There is a whole __Hierarchy of types__ present for objects defined in julia. For example both `Int` and `BigInt` are subtypes of (abstract) `Integer` type. Which in turn is a subtype of `Real`, which is a `Number`. At the top of the hierarchy sits `Any`.

In julia being a subtype can be expressed by writing e.g. `Int <: Integer`.
"

# ╔═╡ ba5f2325-5b03-494f-9477-549265f3ddc5
5 isa Integer

# ╔═╡ 518cafd6-edcc-4091-9a0a-afa3406311cb
Int <: Integer

# ╔═╡ 99138265-89ed-4308-9d39-23e858dbcf89
Int <: BigInt

# ╔═╡ 14a7e4a1-f8de-4dc5-a59a-f4ad42fa066a
supertype(Integer)

# ╔═╡ f55616a4-0fa4-4bf6-9eac-b8db35a34f28
supertypes(Int)

# ╔═╡ cb796ae0-f79a-47c7-96a0-0c775fa59297
md"
## Methods
Talking about types brings us to one of the core concepts of `julia`: function methods. Each function in julia has associates (multiple) _methods_ to it. For example:
"

# ╔═╡ 6d00aa9e-3fdb-4c3f-b4d2-6c78e719ec32
function without_methods end

# ╔═╡ f82daca4-ec82-497c-975a-b1065ff30624
length([1,2,3])

# ╔═╡ ebc06065-4ad0-4b9b-b4f3-cf326a40a697
length("qwerty")

# ╔═╡ 0ba52767-a5f8-4517-9b84-7762281c3336
md"
The same function `lenght` has been used in two different contexts (on a `Vector` and on a `String`) and produces reasonable answers. This is because `length` has different __methods__ which are applied according to the __type__ of the argument. Let's have a look:
"

# ╔═╡ 61cf408f-606d-4fd9-8b6d-b0c08425ee65
@which length([1,2,3])

# ╔═╡ 9409b4e4-607e-4739-a0fb-f2d0d18dade4


# ╔═╡ 5cd9f85c-a4ba-454d-a480-f8734331cc84
@which length("qwerty")

# ╔═╡ dcc4aac6-8fbf-42bf-b171-abd48d625071
md"
In total, currently (i.e. in this session) there are `~80` methods for measuring `length` defined:
"

# ╔═╡ d8034870-dd0a-4dce-971c-a47a03f8ca89
# ╠═╡ disabled = true
#=╠═╡
methods(length)
  ╠═╡ =#

# ╔═╡ f892452a-91b1-492e-89a9-17dcf7d85c5c
md"
We will soon learn how to add another methods for e.g. `length` (which will be needed for the concept of `iteration`) but for now let us play with our own function:
"

# ╔═╡ 97ef8074-080a-490a-9d52-52b493fc29b2
my_function(x::Int) = 3*x

# ╔═╡ ece7cc12-a1aa-40d6-b5ca-7622a701cc78
md"
What will happen if we call `my_function` with `5.0`?
```julia
MethodError: no method matching my_function(::Float64)

Closest candidates are:

my_function(!Matched::Int64) at ~/Mathematics/Teaching/2022/Computational Group Theory/00_Introduction_to_julia.jl#==#97ef8074-080a-490a-9d52-52b493fc29b2:1

    top-level scope@Local: 1[inlined]
```
Well `julia` is is helpless here because we **haven't told it** what `my_function` should do with _floating point_ values! So let's do it now:

"

# ╔═╡ 0e3beb19-a18a-456d-930f-1751c5e7814e
# ╠═╡ skip_as_script = true
#=╠═╡
# my_function(x::Float64) = 2*x
  ╠═╡ =#

# ╔═╡ 278017d0-ff3c-423d-a5ad-91bd82cb01cf
md"
We could also define
```julia
my_function(x) = \"A fish!\"
```
which is the same as writing
```julia
my_function(x::Any) = \"A fish!\"
```
But now maybe we want to work with `BigInt`s, but when we try, we encounter the same problem as with `Float64`s:
```julia
MethodError: no method matching my_function(::BigInt)

Closest candidates are:

my_function(!Matched::Int64) at ~/Mathematics/Teaching/2022/Computational Group Theory/00_Introduction_to_julia.jl#==#97ef8074-080a-490a-9d52-52b493fc29b2:1

    top-level scope@Local: 1[inlined]
```
The proper solution is __not__ to define a special method
```julia
my_function(x::BigInt) = 3*x
```
but rather define
```julia
my_function(x::Integer) = 3*x
```
which will work for all subtypes of `Integer` (even the ones we haven't seen!).
"

# ╔═╡ b148ce7c-1cee-4909-84a2-3f004b411c11
my_function(x::Integer) = 3*x

# ╔═╡ 97ad8ed6-313a-4ebc-b5e5-3e01a82e05e7
my_function(x::Real) = 2*x

# ╔═╡ 9912769a-4ff9-4c6e-a14c-f0eb4aaf8f2d
my_function(5)

# ╔═╡ 0b84de51-063f-4ed9-9f44-d654720f4ab5
my_function(5.0)

# ╔═╡ b5905ff1-f363-417c-a1c4-52b3d2e7c627
my_function(3//2)

# ╔═╡ 88b7647d-08bf-41aa-8a7d-5c9ad7df8157
md"
## Multiple dispatch
In `julia` __multiple dispatch__ works as follows:
1. given a function call (such as `my_function(5.0)`) **identyfy the types** of arguments
2. search (a tree of all methods) for the **most specific method** of `my_function` which is applicable to the types of the arguments
3. execute **this particular** method.

This is very much alike to what we as mathematicians tend to do: it is not well defined what e.g. `A*v` means until we learn that `A` is a `Matrix` and `v` is a `Vector` and then it's clear that `*` between denotes _matrix-vector multiplication_, the recipe (i.e. `method`) for which could be found in a book on LinearAlgebra. But had `A` and `v` denoted different objects, we'd need to look for a different textbook to find the meaning of `*`.

For example `julia` (sensibly -- at least to mathematicians with background in algebra) defines an method for `*` with `String` arguments to mean concatenation:
"

# ╔═╡ 4698766b-4a1d-4f6c-bbca-3f8d134f03f3
"ex" * "parrot"

# ╔═╡ 198ab65c-fb94-43bb-9813-c9b5c9787c1e
md"
**Question**: Why is it \"the mathematically correct\" meaning?
"

# ╔═╡ f96d145f-ec3b-45e0-9283-269d9da6575b
md"# First structures

We will finish this introduction by showing how to implement the (additive) group of integers modulo `n` and showcasting the key aspect of julia: **multiple dispatch**.

We begin by creating a `struct` (structured type) representing a residue modulo `n`."

# ╔═╡ b9526249-0cb9-44e3-b161-a57cf29d621e
struct Residue_simple
	residue::Int
	modulus::Int
end

# ╔═╡ 4b66abd4-0bac-40ee-80f6-59b56ee9ee1a
md"
There are several new things happening above.
* First the `struct` word followed by name (`Residue`), list of fields (`resiude`, `modulus`) closed by `end` defines a new _entity_ or a _structured type_ in julia.
* Second, the `::Int` after `residue` tells `julia` that we _promise_ that `residue` will be always an `Int`, therefore julia is allowed to perform optimizations based on this information.
* Third such `Residue` can be instantiated (created) by providing `residue` and `modulus` (both need to be `Int`s).

Let's have a look.
"

# ╔═╡ 25d2f0f1-4dc2-4fb9-8eb9-af8563e31807
a = Residue_simple(3, 5)

# ╔═╡ 8ba6dfd6-4ff3-4a6b-b3c3-5b102d4932fc
md"
This is how we access the \"fields\" of a structured type in `julia`:
"

# ╔═╡ 43c57164-15f3-41c0-9ae5-19341f26500a
a.residue

# ╔═╡ e9a8462f-8025-4853-8770-6f2f1bd15c69
a.modulus

# ╔═╡ 661c703b-9523-41f4-8b1c-6ef6382fc7ba


# ╔═╡ d0da5232-2c25-430b-a888-2c0bc4395ea3
Residue_simple(-2, 5)

# ╔═╡ 8e50e663-2c54-4b27-a5ef-a74f3cddf491
Residue_simple(7, -5)

# ╔═╡ 56ce9add-08b2-4637-aa2f-9decddad8c9f
md"
As we can see we can create plenty of invalid residues, so we'd need e.g. a mechanism to always bring residue to `0..modulus-1` interval on creation. Such mechanism is called __internal constructor__:
"

# ╔═╡ 7a1258ca-c981-462e-b6d1-4c7fb38bf63a
struct Residue
	residue::Int
	modulus::Int

	function Residue(residue, modulus)
		@assert modulus > 1 "Modulus must be greater than 1, got $modulus"
		return new(mod(residue, modulus), modulus)
	end
end

# ╔═╡ e97c27ff-6d26-4305-a671-359fcb012410
Residue(3,5)

# ╔═╡ e4df1aa7-4112-4b80-9326-099a0abdd7ee
Residue(-2, 5)

# ╔═╡ e837dcad-17d3-4935-9633-f6617b4867d3
Residue(7, -5)

# ╔═╡ 7d7b95c1-b06c-46b8-9f5a-d863df1590a9
md"
For displaying a type julia calls method
```julia
Base.show(io::IO, x)
```
(`IO` is a special type denoting anything that can be written to). Let us define a method specific to our `Residue2` that will bring the display of `Residue2` to a more humanly format: 
"

# ╔═╡ d8c5d154-5bf6-4380-bc82-65167e63e49f
Base.show(io::IO, x::Residue) = print(io, x.residue, " mod ", x.modulus)

# ╔═╡ bc51fe4d-d142-428f-9628-403eb5f3e1b2
A = Residue(2, 5)

# ╔═╡ b69f909b-2543-4c5c-9a0f-1de0e51b5aa9
B = Residue(3, 5)

# ╔═╡ 2fc83333-7145-4a54-bc7c-b65f67d7ae74
md"
Since we haven't defined `+` for `Residue` if we try to add `A + B` we'll get 
```
MethodError: no method matching +(::Main.var\"workspace#3\".Residue, ::Main.var\"workspace#3\".Residue)

Closest candidates are:

+(::Any, ::Any, !Matched::Any, !Matched::Any...) at operators.jl:591
```
Let's ammend this!
"

# ╔═╡ 58d9e95c-edc4-455f-9424-d0495e197492
function Base.:+(x::Residue, y::Residue)
	@assert x.modulus == y.modulus "Addition of residues with different moduli is not well defined"
	return Residue(x.residue + y.residue, x.modulus)
end

# ╔═╡ 9d1b140e-bf36-11ec-3e35-3f278f1682c4
2 + 2 * 3

# ╔═╡ 416f778a-84f7-43c4-ba22-7baceac76053
0.1+0.2-0.3

# ╔═╡ 8a69def3-afbe-4779-84fb-71a933f08975
begin
	local s = 0
	for i in 1:5
		s += i
	end
	s
end

# ╔═╡ 9394a38d-2e88-4c7b-bb5e-e78809a9a2f2
let R = 1000
	@time length([(x,y) for x in -R:R for y in -R:R if x^2 + y^2 <= R^2])/R^2
end

# ╔═╡ b7cada51-0bbe-4917-8407-3ca64cec74ac
function approx_π(R)
	return length([(x,y) for x in -R:R for y in -R:R if x^2 + y^2 <= R^2])/R^2
end

# ╔═╡ 488819ef-1c10-4764-86ca-6fbeb93b5fdb
@time approx_π(1000)

# ╔═╡ 9bfabb49-26b5-4182-b814-cfed9b74b2c7
let R = 1000
	4*count(x^2 + y^2 ≤ R^2 for x in 0:R for y in 1:R)/R^2
end

# ╔═╡ 6343e1f3-4be0-4055-96a2-d39f828ab7e6
function approximate_π(R)
	R² = R^2
	quarter = count(x^2 + y^2 ≤ R² for x in 0:R for y in 1:R)
	return (4quarter + 1)/R²
end

# ╔═╡ bb94fb21-7605-40e4-936a-f93e6a4c391b
@time approximate_π(1_000)
# in literals numbers one can add underscores to make them more readable

# ╔═╡ 4c1d0a58-08be-4966-9620-38c12589dd18
function Fib1(n)
	if n <= 0
		return 1
	elseif n == 1
		return 1
	else
		return Fib1(n-1) + Fib1(n-2)
	end
end

# ╔═╡ 36f2f86a-42f5-4436-a9c5-bae68f39ed9e
[Fib1(n) for n in 0:10]

# ╔═╡ 0e73015f-0555-491a-ae62-44e7d4685e6f
Fib1(43)

# ╔═╡ 96c924cb-3625-4f9b-92df-432902484815
function Fib2(n)
	if n <= 0
		return 1
	elseif n == 1
		return 1
	else
		Fₙ₋₂ = Fib2(0) 
		Fₙ₋₁ = Fib2(1)
		Fₙ = 0 
		for i in 2:n
			Fₙ = Fₙ₋₁ + Fₙ₋₂
			Fₙ₋₂ = Fₙ₋₁
			Fₙ₋₁ = Fₙ
		end
		return Fₙ
	end
end

# ╔═╡ 02b25aea-2ad5-4463-8587-994c5c6c92b3
[Fib2(n) for n in 0:10]

# ╔═╡ be731321-3972-41d3-bb70-7b56bde32d9a
Fib2(43)

# ╔═╡ ee30711a-9050-4ed3-9971-15ec679f0011
@benchmark Fib2(1_000)

# ╔═╡ 7e9eb4dc-972b-4d0d-a1c8-f4fef379ca19
@elapsed Fib2(10000)

# ╔═╡ 4ffa197a-0d84-4b43-b926-4a83a8ecead7
(big(2)^63)÷2 + 2^62

# ╔═╡ 8a449164-75f1-4fd8-948b-de596ceefc4f
A + B

# ╔═╡ 65976f9d-566e-40d7-9817-99069c5fc738
Residue(3, 5) + Residue(3, 6)

# ╔═╡ f87cad11-a9c5-497d-a392-5cf07bb2a190
md"
To complete the arithmetic we would need to implement
* _unary_ minus in the form `Base.:-(x::Residue)`
* zero element in the form `Base.zero(x::Residue)`
* equality check in the form `Base.:(==)(x::Residue, y::Residue)

> **Exercise 1**: 
> * Complete those definitions so that the cell below doesn't throw any error.
> * what method needs to be implemented so that `@assert A + 3 == zero(A)` also holds?
"

# ╔═╡ b52ad56c-4722-43a5-b050-97453e2a1c3f


# ╔═╡ 57dba8f7-e77a-4d91-8529-bd304fbc92f3
begin
	@assert -A isa Residue
	@assert A-B isa Residue
	@assert zero(A) isa Residue
	@assert A == A
	@assert A != B
	@assert A + zero(A) == A
	@assert zero(A) - B == -B
	@assert A - A == zero(A)
	# @assert A + 3 == zero(A)
	# @assert big(3) + A == zero(A)
end

# ╔═╡ d720bf29-9cf5-413a-ace7-faf222ecdfa0


# ╔═╡ 5803916e-d67e-4208-9df7-19dd6fd8b965
md"
> **Exercise 2**: Implement multiplicative structure on `Residues`, so that one can perform `A*B^-1` (or equivalently: `A*inv(B)`).
"

# ╔═╡ a6f30f1e-2f92-4f8f-aa48-bcf2233e9cf8


# ╔═╡ f79a4df4-e047-4cf1-adf9-127899db3bce
md"
## A Little about benchmarking / native code

Julia compiles to machine code which might be different on every processor. That is the code produced generated for your processor will depend on its capabilities (set of instructions). For example the newest processors are able to execute so called _vector instructions_, executing the same operation across multiple \"cells of memory\" (_registers_). Let's see this in action.
"

# ╔═╡ ce39f506-ca06-4f3b-8cce-5604bf460704
function my_sum(x::AbstractVector{T}) where T
	s = zero(T)
	for i in 1:length(x)
		s += x[i]
	end
	return s
end

# ╔═╡ 42056c83-17f0-4d60-a14c-f9339960a52d
@time my_sum(rand(2^10))

# ╔═╡ f9cbf9c8-c84a-40aa-bfdd-6639a5c12403
function my_sum_avx(x::AbstractVector{T}) where T
	s = zero(T)
	@simd for i in eachindex(x)
		s += x[i]
	end
	return s
end

# ╔═╡ 319a38d9-d13b-420d-ab96-c3dc909787f2
let x = rand(2^10)
	@time my_sum_avx(x)
end

# ╔═╡ 06e0e2c4-1a49-4f69-84e9-9e06d874df75


# ╔═╡ d7b4f0d0-fd28-407a-86af-5504b91c2042
# using BenchmarkTools

# ╔═╡ a09d7161-5b5c-48a0-b9b9-34832fe25951
# let xxx = rand(2^10)
# 	@benchmark my_sum($xxx)
# end

# ╔═╡ 852261c1-ca99-4ef0-bd43-87dc90d2266a
# let xxx = rand(2^10)
# 	@benchmark my_sum_avx($xxx)
# end

# ╔═╡ 81a0b1fb-f343-46ab-bb08-b403b42456a4
# @code_native debuginfo=:none sum(rand(1000))

# ╔═╡ d22ac14c-563f-4ef9-952c-35aa120d1267
# @code_native debuginfo=:none my_sum_avx(rand(1000))

# ╔═╡ bac07653-2424-40b4-ad5c-790b66938eed


# ╔═╡ Cell order:
# ╟─c728b133-37bc-41f6-8e88-1ca8df6a7a4f
# ╟─bcf0e9dd-5261-4477-aa7b-3c27ea16180b
# ╟─09789c5d-97af-45ab-baaf-92bd9ef63455
# ╠═9d1b140e-bf36-11ec-3e35-3f278f1682c4
# ╠═345c44c5-c0e3-4a5f-ba64-f60935f77bf7
# ╠═5a8d9549-a75d-405d-afcd-9831e7e78113
# ╠═202566cf-75ad-4375-9bf7-713023952862
# ╟─2d7170eb-3201-483e-b951-86dffd327e2b
# ╟─faa7705c-c044-46be-ba91-6b0adef24d4c
# ╠═c1198833-3c4a-4106-8bbb-6534a917cd72
# ╟─cdc234ea-e482-40bc-b4ef-7adfc8d38aca
# ╠═688085ec-a8ed-4830-9081-2d1f6a6ab87f
# ╟─ed74560c-e9a6-4e38-8efb-f51cc3eadab6
# ╠═416f778a-84f7-43c4-ba22-7baceac76053
# ╟─53167dd4-209d-4ecf-a0aa-54aca12fffd2
# ╠═f7b322e5-cad7-41db-b391-c46844008f3d
# ╠═bcf0dd01-28e3-4b06-8f11-c131a3526334
# ╠═74d549ce-0783-49fa-a150-1763f06ecbfa
# ╠═9b3dbb28-9f3a-421f-9f26-ea39642d3959
# ╟─c9c11f7a-c0b5-4c72-9cfc-3b94a787a055
# ╠═15ed6e94-4355-42a8-bad2-a53cd97cf290
# ╠═75d20084-3b43-4124-a2aa-e9abf35c91fc
# ╠═8c7c7a38-accd-4dca-9e61-299db82f3b8d
# ╟─36e5468a-a5dc-42cd-81b7-92b0447ca8e4
# ╟─2d45fc43-ede5-4c05-837a-f96c17734550
# ╠═8a69def3-afbe-4779-84fb-71a933f08975
# ╟─a0542649-cbf2-4137-bb69-3fbef8fa2c98
# ╠═c2c925c7-ce88-4f1c-94f7-19451eefd3e0
# ╟─813e73fb-470c-47fc-940e-da03a105ca79
# ╠═4e423cda-c448-4750-b420-a6982033b6f5
# ╠═ad381ecb-c9fa-463b-9f69-f23e629e459b
# ╟─197bc9a4-2695-45bc-8ff2-b0cdd73b30e9
# ╠═9394a38d-2e88-4c7b-bb5e-e78809a9a2f2
# ╠═b7cada51-0bbe-4917-8407-3ca64cec74ac
# ╠═488819ef-1c10-4764-86ca-6fbeb93b5fdb
# ╟─3fa1fa90-57ab-4a30-afdd-bfa0c866f3ef
# ╠═83dee27b-1c40-4a2d-a204-ffe1effd56d9
# ╠═94d38118-94ec-43fc-8a16-6fc562bcdeaa
# ╠═9bfabb49-26b5-4182-b814-cfed9b74b2c7
# ╟─ab914178-f909-44b0-811c-418f2d4939b3
# ╟─7fd81fe1-c810-44ca-baa5-9d6a9555be74
# ╠═4a4fba03-234e-465d-bc97-988e6e70ef69
# ╠═ce49d466-4c05-45bd-88c6-3f0694c873ef
# ╟─4b2035f0-55e8-4f39-a6a7-e8882f493dfb
# ╠═6343e1f3-4be0-4055-96a2-d39f828ab7e6
# ╠═bb94fb21-7605-40e4-936a-f93e6a4c391b
# ╠═09fa8914-7966-40f7-98eb-86aa43658908
# ╟─cb141457-2671-4582-96ef-5c03d4d35814
# ╠═4c1d0a58-08be-4966-9620-38c12589dd18
# ╠═36f2f86a-42f5-4436-a9c5-bae68f39ed9e
# ╠═0e73015f-0555-491a-ae62-44e7d4685e6f
# ╠═96c924cb-3625-4f9b-92df-432902484815
# ╠═02b25aea-2ad5-4463-8587-994c5c6c92b3
# ╠═be731321-3972-41d3-bb70-7b56bde32d9a
# ╠═ee30711a-9050-4ed3-9971-15ec679f0011
# ╠═7e9eb4dc-972b-4d0d-a1c8-f4fef379ca19
# ╠═6f221be1-1ab2-4f26-a4ad-f2c493c5e290
# ╟─b275cf5f-846d-4487-9c5e-2ca9344bc807
# ╠═3a2d237d-d924-4b2a-b767-26fb047c0886
# ╠═cec7a620-9147-4afc-8948-80f91ffd1268
# ╠═3de5ea6b-8072-49b5-a504-98a75992b49f
# ╠═a7151ae1-6d68-45d0-8840-8b994ed9f734
# ╠═6ecc64b2-dbfa-4ccd-a2aa-286417b7d8ba
# ╠═504a5cc2-0d06-48a1-a805-2ed5d4bd6a70
# ╠═3e50b42e-3ce4-4df2-a6cd-96a79cd09e2b
# ╠═9bf248aa-7897-4104-94c5-195314dafb44
# ╠═785ec286-280f-4ef7-81e5-1e80c750371c
# ╠═6889507f-1964-4c89-b06c-e195a2484b7c
# ╠═2d1f1731-381c-4501-a252-f4e34db8bac8
# ╟─9ab2675c-d6a2-494e-847c-4a886a1166b6
# ╠═1278b847-8dfc-4afc-b7bb-c7877f5fb828
# ╠═e3612ed5-0e34-4b77-875e-a18294d307c9
# ╠═4ffa197a-0d84-4b43-b926-4a83a8ecead7
# ╠═e7bc6eab-727c-4ab8-83c2-357d89ce225e
# ╟─ad18678d-4d69-4064-bcd8-2b4bc6c0c60a
# ╠═ba5f2325-5b03-494f-9477-549265f3ddc5
# ╠═518cafd6-edcc-4091-9a0a-afa3406311cb
# ╠═99138265-89ed-4308-9d39-23e858dbcf89
# ╠═14a7e4a1-f8de-4dc5-a59a-f4ad42fa066a
# ╠═f55616a4-0fa4-4bf6-9eac-b8db35a34f28
# ╟─cb796ae0-f79a-47c7-96a0-0c775fa59297
# ╠═6d00aa9e-3fdb-4c3f-b4d2-6c78e719ec32
# ╠═f82daca4-ec82-497c-975a-b1065ff30624
# ╠═ebc06065-4ad0-4b9b-b4f3-cf326a40a697
# ╟─0ba52767-a5f8-4517-9b84-7762281c3336
# ╠═61cf408f-606d-4fd9-8b6d-b0c08425ee65
# ╠═9409b4e4-607e-4739-a0fb-f2d0d18dade4
# ╠═5cd9f85c-a4ba-454d-a480-f8734331cc84
# ╟─dcc4aac6-8fbf-42bf-b171-abd48d625071
# ╠═d8034870-dd0a-4dce-971c-a47a03f8ca89
# ╟─f892452a-91b1-492e-89a9-17dcf7d85c5c
# ╠═97ef8074-080a-490a-9d52-52b493fc29b2
# ╠═9912769a-4ff9-4c6e-a14c-f0eb4aaf8f2d
# ╟─ece7cc12-a1aa-40d6-b5ca-7622a701cc78
# ╠═0b84de51-063f-4ed9-9f44-d654720f4ab5
# ╠═0e3beb19-a18a-456d-930f-1751c5e7814e
# ╟─278017d0-ff3c-423d-a5ad-91bd82cb01cf
# ╠═b148ce7c-1cee-4909-84a2-3f004b411c11
# ╠═97ad8ed6-313a-4ebc-b5e5-3e01a82e05e7
# ╠═b5905ff1-f363-417c-a1c4-52b3d2e7c627
# ╟─88b7647d-08bf-41aa-8a7d-5c9ad7df8157
# ╠═4698766b-4a1d-4f6c-bbca-3f8d134f03f3
# ╟─198ab65c-fb94-43bb-9813-c9b5c9787c1e
# ╟─f96d145f-ec3b-45e0-9283-269d9da6575b
# ╠═b9526249-0cb9-44e3-b161-a57cf29d621e
# ╟─4b66abd4-0bac-40ee-80f6-59b56ee9ee1a
# ╠═25d2f0f1-4dc2-4fb9-8eb9-af8563e31807
# ╟─8ba6dfd6-4ff3-4a6b-b3c3-5b102d4932fc
# ╠═43c57164-15f3-41c0-9ae5-19341f26500a
# ╠═e9a8462f-8025-4853-8770-6f2f1bd15c69
# ╠═661c703b-9523-41f4-8b1c-6ef6382fc7ba
# ╠═d0da5232-2c25-430b-a888-2c0bc4395ea3
# ╠═8e50e663-2c54-4b27-a5ef-a74f3cddf491
# ╟─56ce9add-08b2-4637-aa2f-9decddad8c9f
# ╠═7a1258ca-c981-462e-b6d1-4c7fb38bf63a
# ╠═e97c27ff-6d26-4305-a671-359fcb012410
# ╠═e4df1aa7-4112-4b80-9326-099a0abdd7ee
# ╠═e837dcad-17d3-4935-9633-f6617b4867d3
# ╟─7d7b95c1-b06c-46b8-9f5a-d863df1590a9
# ╠═d8c5d154-5bf6-4380-bc82-65167e63e49f
# ╠═bc51fe4d-d142-428f-9628-403eb5f3e1b2
# ╠═b69f909b-2543-4c5c-9a0f-1de0e51b5aa9
# ╟─2fc83333-7145-4a54-bc7c-b65f67d7ae74
# ╠═58d9e95c-edc4-455f-9424-d0495e197492
# ╠═8a449164-75f1-4fd8-948b-de596ceefc4f
# ╠═65976f9d-566e-40d7-9817-99069c5fc738
# ╟─f87cad11-a9c5-497d-a392-5cf07bb2a190
# ╠═b52ad56c-4722-43a5-b050-97453e2a1c3f
# ╠═57dba8f7-e77a-4d91-8529-bd304fbc92f3
# ╠═d720bf29-9cf5-413a-ace7-faf222ecdfa0
# ╟─5803916e-d67e-4208-9df7-19dd6fd8b965
# ╠═a6f30f1e-2f92-4f8f-aa48-bcf2233e9cf8
# ╟─f79a4df4-e047-4cf1-adf9-127899db3bce
# ╠═ce39f506-ca06-4f3b-8cce-5604bf460704
# ╠═42056c83-17f0-4d60-a14c-f9339960a52d
# ╠═f9cbf9c8-c84a-40aa-bfdd-6639a5c12403
# ╠═319a38d9-d13b-420d-ab96-c3dc909787f2
# ╠═06e0e2c4-1a49-4f69-84e9-9e06d874df75
# ╠═d7b4f0d0-fd28-407a-86af-5504b91c2042
# ╠═a09d7161-5b5c-48a0-b9b9-34832fe25951
# ╠═852261c1-ca99-4ef0-bd43-87dc90d2266a
# ╠═81a0b1fb-f343-46ab-bb08-b403b42456a4
# ╠═d22ac14c-563f-4ef9-952c-35aa120d1267
# ╠═bac07653-2424-40b4-ad5c-790b66938eed
