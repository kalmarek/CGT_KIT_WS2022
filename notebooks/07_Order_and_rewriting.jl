### A Pluto.jl notebook ###
# v0.19.14

using Markdown
using InteractiveUtils

# ╔═╡ 781b7f6c-903d-11ed-0165-8bab2340acf4
begin
	using Pkg
	Pkg.activate("..")
	using Test
	using CGT_KIT_WS2022
	const CGT = CGT_KIT_WS2022
end

# ╔═╡ d1dc1c2e-a0fa-41fc-bc88-4217370deeae
function free_rewrite(w::CGT.AbstractWord, A::CGT.Alphabet)
    out = one(w)
    isone(w) && return out
    i = firstindex(w)
    while i ≤ lastindex(w)
        if !isone(out) && CGT.hasinverse(A, out[end]) && inv(A, out[end]) == w[i]
            resize!(out, length(out) - 1)
        else
            resize!(out, length(out) + 1)
            out[end] = w[i]
        end
        i += 1
    end
    return out
end

# ╔═╡ 5fe60f3d-8166-4e22-b590-ff9a58b7d465
A = CGT.Alphabet([:x, :X, :y], [2,1,0])

# ╔═╡ 220e50cf-ab05-4723-9f21-277142f4f618
x,X,y = CGT.Word([A[:x]]), CGT.Word([A[:X]]), CGT.Word([A[:y]])

# ╔═╡ eda7bb3f-4888-43a8-ab67-a7c2f875d582
CGT.string_repr(free_rewrite(x*X*y, A), A)

# ╔═╡ 98e1120f-70d5-4fa9-9ce7-38f9c66fc998
CGT.string_repr(free_rewrite(y*X*x*y, A), A)

# ╔═╡ 204b3b83-81aa-4269-83a8-169d408e6d29
import CGT_KIT_WS2022: AbstractWord

# ╔═╡ c7cf5e32-dfcf-4241-b8c2-c2f29d6aa711
md"
# Rewriting

We'll base our rewriting procedure on a queue based-approach. In particular this will be a destructive rewrite, i.e. the content of word w which is supposed to be rewritten will be transferred to another word in the process. Let us set the groundwork for this approach:
"

# ╔═╡ 84f0e248-d972-4bb2-afa1-f6991af46e1f
md"""Ok, so what can the rewriting object be? Let's start from something very simple. One could define trivial rewriting as follows:
```julia
\"\"\"
	rewrite!(v::AbstractWord, w::AbstractWord, rewriting)
Rewrite `w` using `rewriting` object and store the result in `v`.

The content of `w` is undefined after the call.
\"\"\"
function rewrite!(out::AbstractWord, w::AbstractWord, rw::RW) where RW
	resize!(out, length(w))
	copyto!(out, w)
	return out 
end
```
But maybe it's better to throw an informative error?
"""

# ╔═╡ bad3f475-cec3-4cd9-bebb-9240d3e04961
"""
	rewrite!(v::AbstractWord, w::AbstractWord, rewriting)
Rewrite `w` using `rewriting` object and store the result in `v`.

The content of `w` is undefined after the call.
"""
function rewrite!(out::AbstractWord, w::AbstractWord, rw::Any)
	throw("rewriting with $rw is not defined; you need to implement
	`rewrite(::AbstractWord, ::AbstractWord, rw::$(typeof(rw))` yourself")
end

# ╔═╡ 3a26113f-0d82-4758-b0a6-da1dabfa47f7
w = CGT.Word(rand(1:3, 20))

# ╔═╡ ca91b7a4-c56c-4ab4-8cf4-979db658a46e
# rewrite(w, [1,2,3])

# ╔═╡ 01b81672-f5b4-4851-9b4b-c0621f567caf


# ╔═╡ c4ff12c5-2993-4f44-afc9-a6b83e9928fd
md"
## Free rewriting

A more interesting example could the _free rewriting_, which essentially is a rewriting with an `Alphabet`:
"

# ╔═╡ 4f05adfa-4e27-4e20-a513-f5f68c3f0479
"""
    rewrite!(v::AbstractWord, w::AbstractWord, A::Alphabet)
Freely rewrite word `w` storing the result in `v` by applying inverses present in alphabet `A`.
"""
function rewrite!(v::AbstractWord, w::AbstractWord, A::CGT.Alphabet)
    # throw("Not Implemented Yet")
	for l in w
		if isone(v)
			push!(v, l)
		elseif CGT.hasinverse(A, v[end]) && inv(A, v[end]) == l
			resize!(v, length(v) - 1)
		else
			push!(v, l)
		end
	end
    return v
end

# ╔═╡ 5395c18a-2609-4477-9e2e-20313b1cba7d


# ╔═╡ 87b3b5d1-a0f5-427e-9de3-bcf2946a05d6
md"""
### Rule-based rewriting

This will require a bit of thought. If we follow blindly the pattern of "find and replace, then repeat" we can be easily wasting lots of effort. On the other hand a single pass of "find and replace" may leave us with with unfinished rewriting.

Imaginge we have a rule `abab → ba` and we're rewriting a word `aababb`. The obvious single application of the rule yields `a·ba·b = abab`. We learn only on the second pass that the whole thing rewrites to `ba`. To achieve this we will adopt a __queue based procedure__.

| word | rule |
|---|:---|
|`w = aababb`| `abab → ba`|

#### Queuing
That is starting from a word `w` (to be rewritten) and an empty word `v`:

|`v`|`w`|
|---:|---:|
|`ε`|`aababb`|

we will be transfering letters from `w` to `v` one-by-one, looking for possible opportunities to rewrite the __suffix__ of `v`. Such situation will occur when

|`v`|`w`|
|---:|---:|
|`a`__`abab`__|`b`|

Now we will remove the _lhs_ of the rule from the end of `v` and __prepend__ the _rhs_ to `w`. After this step we'll see

|`v`|`w`|
|---:|---:|
|`a`|__`ba`__`b`|

Transfering the letters again to `v` we encounter `abab` as a suffix of `v` when

|`v`|`w`|
|---:|---:|
|__`abab`__|`ε`|

we apply the rule and get

|`v`|`w`|
|---:|---:|
|`ε`|__`ba`__|

No further suffixes of `v` in the process match our rule, so we end with

|`v`|`w`|
|---:|---:|
|`ba`|`ε`|

and we output `v = ba` as the rewritten `w`.
"""

# ╔═╡ afcbb250-599c-4dd2-ac97-fa6d515e9305
md"### Rules"

# ╔═╡ e08b6428-77db-4a35-9f82-b90526deb3bf
const Rule{W} = Pair{W, W} where W <: AbstractWord

# ╔═╡ 33615215-fdea-4a27-a086-348d10a774f5
r = x*X => one(x)

# ╔═╡ cc6f8923-421c-4c8b-984b-78a51781bb2d
r isa Rule

# ╔═╡ 03832acd-37f3-4426-b07f-c3c9ba3cb0a2
function rewrite!(v::AbstractWord, w::AbstractWord, rule::Rule)
    lhs, rhs = rule
    while !isone(w)
        push!(v, popfirst!(w))
        if issuffix(lhs, v)
            prepend!(w, rhs)
            resize!(v, length(v) - length(lhs))
        end
    end
    return v
end

# ╔═╡ 118f8733-8ade-4314-9024-d8834a8e0bc1
md"
This looks nice, but the problem is that it doesn't work ;). We need to implement a few more methods and/or add them to our _`AbstractWord` Interface_:

```julia
Base.push!(w::AbstractWord, l::Integer) # actually this already works!
Base.popfirst!(w::AbstractWord) # remove first element of `w` and return it
issuffix(w::AbstractWord, v::AbstractWord) # check if `w` is a suffix of `v`
Base.prepend!(w, v) # prepend to `w` the content of `v`
```
"

# ╔═╡ 17b4fe63-bc0e-45f1-9612-e393fda13b36
md"""
> **Exercise:** Extend the word interface and implement it for `Word`s so that the above `rewrite` works.
"""

# ╔═╡ 87fd6f32-7953-44d8-b153-a957d8d30f42
md"
## Rewriting systems
Finally this is a rewriting w.r.t. a rewriting system `rws`. Later on we'll see a much more efficient way of rewriting using so called index automaton (sometimes referred to as Aho-Corasick FSA/transducer). 
"

# ╔═╡ 8dc7bca9-58d6-4071-96f2-bd0540593f0b
"""
    rewrite!(v::AbstractWord, w::AbstractWord, rws::RewritingSystem)
Rewrite word `w` storing the result in `v` by left using rewriting rules of
rewriting system `rws`. See [Sims, p.66]
"""
function rewrite!(
    v::AbstractWord,
    w::AbstractWord,
    rws::AbstractVector{<:Rule}
)
    v = resize!(v, 0)
    while !isone(w)
        push!(v, popfirst!(w))
        for (lhs, rhs) in rws
            if issuffix(lhs, v)
                prepend!(w, rhs)
                resize!(v, length(v) - length(lhs))
                break
            end
        end
    end
    return v
end

# ╔═╡ 7b17d435-d1de-4f45-859e-b1a5be68520c
"""
    rewrite(w::AbstractWord, rewriting[, vbuffer=one(w), wbuffer=one(w)])
Rewrites word `w` using `rewriting` object.

The `rewriting` object must implement
`rewrite!(v::AbstractWord, w::AbstractWord, rewriting)`.
"""
function rewrite(
    w::W,
    rewriting,
    vbuffer = one(w),
    wbuffer = one(w), 
) where W
	resize!(vbuffer, 0) # empty vbuffer
	
	# copy the content of w to wbuffer, possibly adjusting its size
	resize!(wbuffer, length(w))
	copy!(wbuffer, w)
	
	# do the destructive rewriting from `wbuffer` to `vbuffer`
    v = rewrite!(vbuffer, wbuffer, rewriting)
    return W(v) # return the result of the same type as w
	# and not-aligned with any args passed!
end

# ╔═╡ c6242096-6d68-4022-be6c-fe03983ad9bd
@testset "free reduction" begin
	A = CGT.Alphabet([:x, :y, :X])
	CGT.setinverse!(A, :x, :X)
	x, X, y = CGT.Word([A[:x]]), CGT.Word([A[:X]]), CGT.Word([A[:y]])
	@test rewrite(x*X, A) == one(x)
	@test rewrite(y*x*X, A) == y
	@test rewrite(X*y*x, A) == X*y*x

	@test rewrite(X*x*X, A) == X

	CGT.setinverse!(A, :y, :y)
	@test isone(rewrite(y*x*X*y, A))
end

# ╔═╡ e65f4c7f-b266-4263-830b-76bc5c5f0fb2
md"""
> **Exercise**: Find the rewriting system for ℤ² defined by `LenLex(:a<:A<:b<:B)` that is confluent and correctly rewrites words to their (standard) canonical form.

> **Exercise**: Implement a (toy, simple) routine that verifies confluence of rwses based on the lecture. Test it on a variety of sets of rules (start with some arbitrary ones and/or those taken from Sims book). Try to complete some of them in a "computer guided fashion".

What you may find useful is `@debug` macro (similar to `@info`). Debugging messages in a module may be enabled through setting `ENV["JULIA_DEBUG"] = "CGT_KIT_WS2022"` and disabled by deleting the key, or setting it to "".
"""

# ╔═╡ f9566e9e-b05f-4fee-9756-25398595bfa9
md"""
## Orderings
A crucial role in the rewriting process is played by the **rewriting ordering** (translation invariant well ordering). In Julia those can be implemented as follows:
"""

# ╔═╡ a191eb5e-4778-46fc-b62d-4ca1b9273154
begin
import Base.Order: lt, Ordering
abstract type WordOrdering <: Ordering end
end

# ╔═╡ d0fb1d08-7f16-4cca-bd93-7efe351a70ef
"""
    struct LenLex{T} <: WordOrdering

`LenLex` order compares words first by length and then by lexicographic (left-to-right) order.
"""
struct LenLex{T} <: WordOrdering
	....
end
# A = Alphabet([:a, :A, :b, :B])
# LenLex(A, [:a, :B, :b, :A])

function lt(o::LenLex, lp::Integer, lq::Integer)
	....
end

function lt(o::LenLex, p::AbstractWord, q::AbstractWord)
    if length(p) == length(q)
		for (lp, lq) in zip(p, q)
			if lp == lq
				continue
			elseif lt(o, lp, lq)
				return true
			else
				return false
			end
		end
		return false # i.e. p == q
	else
		return length(p) < length(q)
	end
end

# ╔═╡ 700d57e9-5734-47d5-aba3-6c66ccb4b430
md"
> **Exercise**: Implement `LenLex` so that the following tests pass.
"

# ╔═╡ 341a1172-93da-4c05-9e06-1ffd2cd92695
@testset "LenLex" begin
	A = Alphabet([:a, :A, :b, :B])
    setinverse!(A, :a, :A)
    setinverse!(A, :b, :B)

    ord = LenLex(....)

    @test ord isa Base.Order.Ordering

    u1 = Word([1,2])
    u3 = Word([1,3])
    u4 = Word([1,2,3])
    u5 = Word([1,4,2])

    @test lt(ord, u1, u3) == true
    @test lt(ord, u3, u1) == false
    @test lt(ord, u3, u4) == true
    @test lt(ord, u4, u5) == true
    @test lt(ord, u5, u4) == false
    @test lt(ord, u1, u1) == false
end

# ╔═╡ bceb445c-f755-429e-a75d-871fbc767510
md"
There are many other orderings used in practice for rewriting:
* `WeightedLex`
* `WreathOrder`
* `WeightedWreath`
* `RecursivePath`
and many more.

> **Exercise**: Implement `WreathOrder` of two `LenLex` orderings. Produce a meaningful set of tests for it.

> **Exercise**: Guess the meaning and implement the weighted versions for `LenLex` and `WreathOrder`. Can you imagine when would these be useful?

> **Exercise**: _(advanced)_ Read the Wikipedia article about (recursive) path ordering to see why this comes naturally in computer algebra. Can you relate this ordering (in groups where there's only one term: `*`) to `WreathOrder`?

> **Exercise**: _(advanced)_ Implement `WreathOrder` for arbitrary number of `LenLex`es. This can be done e.g. by assigning `level`s to letters (to fix order of wreath products) and recursion. To implement this in efficient manner you'd need (?) to use `SubWord`s (which are only views to memory).
"

# ╔═╡ Cell order:
# ╠═781b7f6c-903d-11ed-0165-8bab2340acf4
# ╟─d1dc1c2e-a0fa-41fc-bc88-4217370deeae
# ╠═5fe60f3d-8166-4e22-b590-ff9a58b7d465
# ╠═220e50cf-ab05-4723-9f21-277142f4f618
# ╠═eda7bb3f-4888-43a8-ab67-a7c2f875d582
# ╠═98e1120f-70d5-4fa9-9ce7-38f9c66fc998
# ╠═204b3b83-81aa-4269-83a8-169d408e6d29
# ╟─c7cf5e32-dfcf-4241-b8c2-c2f29d6aa711
# ╠═7b17d435-d1de-4f45-859e-b1a5be68520c
# ╟─84f0e248-d972-4bb2-afa1-f6991af46e1f
# ╠═bad3f475-cec3-4cd9-bebb-9240d3e04961
# ╠═3a26113f-0d82-4758-b0a6-da1dabfa47f7
# ╠═ca91b7a4-c56c-4ab4-8cf4-979db658a46e
# ╠═01b81672-f5b4-4851-9b4b-c0621f567caf
# ╟─c4ff12c5-2993-4f44-afc9-a6b83e9928fd
# ╠═4f05adfa-4e27-4e20-a513-f5f68c3f0479
# ╠═c6242096-6d68-4022-be6c-fe03983ad9bd
# ╠═5395c18a-2609-4477-9e2e-20313b1cba7d
# ╟─87b3b5d1-a0f5-427e-9de3-bcf2946a05d6
# ╟─afcbb250-599c-4dd2-ac97-fa6d515e9305
# ╠═e08b6428-77db-4a35-9f82-b90526deb3bf
# ╠═33615215-fdea-4a27-a086-348d10a774f5
# ╠═cc6f8923-421c-4c8b-984b-78a51781bb2d
# ╠═03832acd-37f3-4426-b07f-c3c9ba3cb0a2
# ╟─118f8733-8ade-4314-9024-d8834a8e0bc1
# ╟─17b4fe63-bc0e-45f1-9612-e393fda13b36
# ╟─87fd6f32-7953-44d8-b153-a957d8d30f42
# ╠═8dc7bca9-58d6-4071-96f2-bd0540593f0b
# ╟─e65f4c7f-b266-4263-830b-76bc5c5f0fb2
# ╟─f9566e9e-b05f-4fee-9756-25398595bfa9
# ╠═a191eb5e-4778-46fc-b62d-4ca1b9273154
# ╠═d0fb1d08-7f16-4cca-bd93-7efe351a70ef
# ╟─700d57e9-5734-47d5-aba3-6c66ccb4b430
# ╠═341a1172-93da-4c05-9e06-1ffd2cd92695
# ╟─bceb445c-f755-429e-a75d-871fbc767510
