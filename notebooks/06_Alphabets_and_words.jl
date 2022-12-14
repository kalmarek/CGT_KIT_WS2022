### A Pluto.jl notebook ###
# v0.19.14

using Markdown
using InteractiveUtils

# ╔═╡ fca05788-f16b-11ec-30c5-c1cb0c797642
md"""
# Finitely presented monoids

In the lecture we learned that an element of a finitely presented monoid is a congruence class ``[w]`` of a word ``w`` over an alphabet ``\mathcal{A}``. Lets unpack this definition.

0. At the bottom we have a set of symbols (*letters*) ``S``.
1. For a monoid an **alphabet** ``\mathcal{A} = \mathcal{A}(S)`` consists of only ``S``. Here we'll need a `struct` `Alphabet` which stores those letters.
2. A set of all (including the empty) **words** ``\mathcal{A}(S)^*`` over the alphabet forms a monoid. So we need a `struct Word` (which may or may not contain a reference to an `Alphabet`).
3. Later we're going to add `struct FPMonoidElement<:MonoidElement` which will keep reference to a `FPMonoid` (i.e. its parent object).

> **Note:** Here we're talking about monoids only, but the whole `Alphabet`/`Word` setup should be general enough to encompass also finitely presented groups, where all elements have inverses. For a **finitely presented group**:
> * `Alphabet` will consist of the disjoint union of ``S`` and ``\widehat{S}``, where the latter consist of a distinct copies of elements from ``S``.
> * the two copies will be connected via a bijective function ``\operatorname{inv}: S \to \widehat{S}`` (these are *formal inverses*).
> * We need to turn the monoid into a group by formally proclaiming one word as the inverse to another and use the formal inverses freely _reduce_ the word to its **normal form** for `FPGroupElement <: GroupElement`.
"""

# ╔═╡ f8c187b3-73b2-4145-85d9-806582d3ca17
md"""
## Words of letters vs Words of integers

We could store letters in our words directly, however, since we'll be dealing with _millions_ of words at the same time we should be more conservative. Even storing a pointer to a letter will cost us `8` (or `4`) bytes per letter. We can do much better!

If we store only small integers (i.e. indices of letters in an alphabet) and the alphabet is short (less than `254` letters) we can get away with just `1` (one!) byte per letter (or `2` for a realllly large alphabets). This has several advantages:

1. Memory savings -- we need almost `8`-times less memory to store a word.
2. Cache locality/cache trashing -- due to this we can store more data in a single cache-line, therefore reducing global-to-local memory lookups and transfers
3. We can use vectorized instructions to speed-up common tasks on words such as:
  * checking equality of words,
  * finding a subword,
  * checking if a prefix of a word is a suffix of another one.
"""

# ╔═╡ 28018283-a925-43cb-9f0d-fa425f724323
md"""
> **Exercise 1**: Implement `Alphabet` structure that will allow arbitrary objects as letters (well except `Integers`) with the following functionality:
> * one can index into an `A::Alphabet` with integers receiving `i`-th letter;
> * one can index into an `A::Alphabet` with letters receiving the index (i.e. the position of) where the letter is stored;
> * by default no letter has the inverse;
> * one can set a letter `X` to be the inverse of `x` so that the inverse of `X` is automatically `x`.
> * one can ask an alphabet for the inverse of a letter or an index (and receive an error if it is not invertible).
"""

# ╔═╡ dfe2b536-77e9-47cb-9180-1ca0e7c0924a
struct Alphabet{T} # T is the type of letters
	...
end

# for implementing the error have a look at transversal where NotInOrbit Exception is defined

Base.getindex(A::Alphabet{T}, letter::T) where T = ... # return the ordinal of `letter` i.e. an integer; A[a] -> 1 (an integer)
Base.getindex(A::Alphabet, n::Integer) = ... # return the n-th letter of A
# A[3] -> 'c' (a letter)

setinverse!(A::Alphabet{T}, x::T, X::T) = ... # set the value of `inv` involution

Base.inv(A::Alphabet{T}, letter::T) = ... # the inverse of `letter` as T
Base.inv(A::Alphabet{T}, n::Integer) = ... # the ordinal of the inverse of `n`-th letter
# n = 2
# l = A[n]; # a letter
# linv = inv(A, l) # a letter
# m = A[linv] # an ordinal
# m == inv(A, n)

hasinverse(A::Alphabet{T}, letter::T) = hasinverse(A, A[letter])
hasinverse(A::Alphabet, index::Integer) = ... # is the partially defined `inv` defined for this particular `index`

Base.iterate(A::Alphabet) = ... #iterate over the alphabet
Base.iterate(A::Alphabet, state) = ...
Base.length(A) = ...

function Base.show(io::IO, A::Alphabet{T}) where T
	println(io, "Alphabet of $T with $(length(A)) letters:")
	for letter in A
		print(io, A[letter], "\t, letter")
		if hasinverse(A, letter)
			println(io, " with inverse", A[inv(A, A[letter])])
		else
			println(io, "")
		end
	end
end

# ╔═╡ 6980e75d-08af-4fd0-8ee5-40ed3876ef63
md"
> **Exercise 2**: Move your implementation of `Alphabet`s to `CGT_KIT_WS2022` package, that is
> * move the code implementing `Alphabets` to `src/alphabets.jl`;
> * add the appropriate `include` line to `src/CGT_KIT_WS2022.jl`;
> * write a comprehensive test suite for your implementation and put it into `test/alphabets.jl`;
> * enable the written `@testset` by adding the appropriate `include` to `test/runtests.jl`.
"

# ╔═╡ dbb3b925-65cf-4d47-b982-ca7950741dc3
md"
> **Exercise 2.5**:
> * Read about [`AbstractArray` interface](https://docs.julialang.org/en/v1/manual/interfaces/#man-interface-array).
> * Implement your own vector-like to get acquainted with the interface (`FizzBuzz` vector? first `n` primes? etc.)
> * check that for your vector iteration works as it should, and so does taking slices: `v[5:2:15]`, `@view(v[5:15])` etc.
"

# ╔═╡ 928f4015-c30a-43a7-a871-a14a1b80d3ce
vvv = collect(1:25)

# ╔═╡ 0f34e318-d3d2-417c-829a-f417181e3650
vvv[5:15]

# ╔═╡ a0074f67-372e-4e63-9b1f-4274f2f9519d
w = @view vvv[5:15]

# ╔═╡ be6fad98-cf59-4fb4-a85f-61846412f522
w[end]

# ╔═╡ a9035c44-1d3a-4ca4-8bff-a5df7e73f250
md"""
> **Exercise 3**: Implement `Word` structure (based e.g. on `Vector`) with a flexible storage eltype (defaulting to `UInt8`, but with choice at user disposal) which behaves like an `AbstractVector`. Words are meaningless on their own, only an alphabet brings their meaning. How should `Base.show` and `Base.inv` be implemented?
>
> What are the other functions which might be working with for words? (think: `Base.:*`, `Base.one`, `Base.occursin`, `prefixes`...)
>
> Think about other possible word types which might be useful in the future. What are the basic operations for words that you can think of? (do not try to set `AbstractWord` API yet, it's too early :)

**Note**: Words will be too common to create and throw away. In the long run we will try to make them as **mutable** as possible and implement standard functions on top of the ones which mutate their arguments. For example:
 * `Base.:*(a::AbstractWord, b::AbstractWord)` will be implemented via call to
 * `mul!(one(a), a, b)`, where the first argument will be returned after modification.

This allows to write `mul!(a,a,b)` without allocating a new separate word if after computing `a*b` we're no longer interested in `a`.
"""

# ╔═╡ ed5c84f1-f980-4e78-81b4-a5bc88ad6c50
typeof(size(vvv))

# ╔═╡ ee8bfc77-7ae6-4f53-a6ab-3526a5c149e9
size(rand(3,4,5))

# ╔═╡ 9e495a33-be52-4d10-ba96-046a81b7f2cd
abstract type AbstractWord{T} <: AbstractVector{T} end

one(w::AbstractWord) = one(typeof(w))
isone(w::AbstractWord) = iszero(length(w))

function Base.:*(w::AbstractWord, v::AbstractWord)
	return mul!(one(w), w, v)
end

# resize!
# append!

# concrete implementation

struct Word{T} <: AbstractWord{T} # <: AbstractVector{T}
	letters::Vector{T}
end

Base.inv(w::AbstractWord, A::Alphabet) = inv!(similar(w), w, A)

function inv!(out::AbstractWord, w::AbstractWord, A::Alphabet)
	resize!(out, length(w))
	# for letter in reverse(w) # allocate vector containing reversed w
	for (idx, letter) in enumerate(Iterators.reverse(w))
		out[idx] = inv(letter, A)
	end
	return out
end

# "Word Interface"
Base.one(::Type{Word{T}}) = Word(Vector{T}())

# Implement abstract Vector interface
Base.size(w::Word) = size(w.letters)
Base.getindex(w::Word, i::Int) = w.letters[i]
Base.setindex!(w::Word, value, idx::Int) = w.letters[idx] = value

# * multiplication
function mul!(out::AbstractWord, w::Word, v::Word)
	@assert out !== w # out and w occupy different places in memory
	# this is now correct, but doesn't allow us to do
	# mul!(a,a,b) override a with content of a*b
	resize!(out, 0)
	append!(out.letters, w) # this should work as appending of w::AbstractVector to out.letters::Vector{T} is defined
	append!(out.letters, v)
	return out
end


# ╔═╡ 3fb89a96-c9ca-4088-97d2-6f9b37706d79
md"
Here are two more functions related to IO for `AbstractWords` that may make your life a bit easier:
"

# ╔═╡ c6862047-55e9-4a08-ba2d-f9d6491fcdb1
function Base.show(io::IO, ::MIME"text/plain", w::AbstractWord)
    if isone(w)
        print(io, 'ε')
    else
        l = length(w)
        for (i, letter) in enumerate(w)
            print(io, letter)
            if i < l
                print(io, '·')
            end
        end
    end
end

function string_repr(w::AbstractWord, A::Alphabet)
    if isone(w)
        return sprint(show, w)
    else
        return join((A[idx] for idx in w), '·')
    end
end

# ╔═╡ 827688ff-f673-4ebe-8483-dd73fd4350a6
md"
> **Exercise 4**: Using `Word`s and `Alphabet` implement a `free_rewrite` function which returns the freely reduced form for word `w`. Test it on a variety of inputs: `ε`, `x`, `X`, `x·X`, `y·x·X`, `y·Y·x·X`, `y·X·x·Y` etc. (also with non-invertible letters in `A`).
>
> What is the complexity of your implementation as a function of `n = length(w)`?
"

# ╔═╡ 69acb0c9-9f7d-434c-82a4-09c04a1df6fc
md"
> **Exercise 5**: (_advanced_) Implement two other types of words:
> * `SubWord` which only stores reference to a contiguous subword of another `AbstractWord` (have a look at what `view(v, 2:7)`)
> * `BufferWord` which stores a word as double-ended queue so that `push!`, `pop!`, `pushfirst!` and `popfirst!` are (amortised) constant cost and non-allocating.
"

# ╔═╡ f901a8c7-b8d8-40d0-abc3-6142cae4dafe
@view vvv[2:6]

# ╔═╡ ff40fb0d-debb-42af-8125-fc243c9e743d
view(vvv, 2:6)

# ╔═╡ 50d69882-1d24-4563-a45a-362b569fff38
md"""
> **Exercise 6**: (_advanced_) Implement a prototype `FreeMonoid`, `FPMonoidElement`, `FreeGroup` and `FPGroupElement` structures based on the discussion above. One should be able to multiply, invert and solve the word problem with those.
"""

# ╔═╡ 654848c2-b7b7-41a3-ab56-d2d07a1a9a8d
abstract type AbstractFPGroup <: Group end
abstract type GroupElement end

struct FreeGroup <: AbstractFPGroup #(?)
	A::Alphabet
	gens::Vector{...}
	# ... ?
end

struct FPGroupElement{W<:AbstractWord, G<:AbstractFPGroup} <: GroupElement
	word::W
	parent::G
	# ....
end

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.8.4"
manifest_format = "2.0"
project_hash = "da39a3ee5e6b4b0d3255bfef95601890afd80709"

[deps]
"""

# ╔═╡ Cell order:
# ╟─fca05788-f16b-11ec-30c5-c1cb0c797642
# ╟─f8c187b3-73b2-4145-85d9-806582d3ca17
# ╟─28018283-a925-43cb-9f0d-fa425f724323
# ╠═dfe2b536-77e9-47cb-9180-1ca0e7c0924a
# ╟─6980e75d-08af-4fd0-8ee5-40ed3876ef63
# ╟─dbb3b925-65cf-4d47-b982-ca7950741dc3
# ╠═928f4015-c30a-43a7-a871-a14a1b80d3ce
# ╠═0f34e318-d3d2-417c-829a-f417181e3650
# ╠═a0074f67-372e-4e63-9b1f-4274f2f9519d
# ╠═be6fad98-cf59-4fb4-a85f-61846412f522
# ╟─a9035c44-1d3a-4ca4-8bff-a5df7e73f250
# ╠═ed5c84f1-f980-4e78-81b4-a5bc88ad6c50
# ╠═ee8bfc77-7ae6-4f53-a6ab-3526a5c149e9
# ╠═9e495a33-be52-4d10-ba96-046a81b7f2cd
# ╟─3fb89a96-c9ca-4088-97d2-6f9b37706d79
# ╠═c6862047-55e9-4a08-ba2d-f9d6491fcdb1
# ╟─827688ff-f673-4ebe-8483-dd73fd4350a6
# ╟─69acb0c9-9f7d-434c-82a4-09c04a1df6fc
# ╠═f901a8c7-b8d8-40d0-abc3-6142cae4dafe
# ╠═ff40fb0d-debb-42af-8125-fc243c9e743d
# ╟─50d69882-1d24-4563-a45a-362b569fff38
# ╠═654848c2-b7b7-41a3-ab56-d2d07a1a9a8d
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
