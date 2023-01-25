### A Pluto.jl notebook ###
# v0.19.14

using Markdown
using InteractiveUtils

# ╔═╡ 12115b9a-971a-11ed-04d9-071d83df5526
begin
    using Pkg
    Pkg.activate("..")
    using Test
    using CGT_KIT_WS2022
    const CGT = CGT_KIT_WS2022
end

# ╔═╡ 2abba47a-9691-416d-81c2-0ca87fc9e9c0
md"
# Knuth-Bendix completion

To begin this section the last assignment is a necessary prerequisite. These data structures we'll be using are `Alphabet`s, `Word`s and `LenLex` order, as well as basic rewriting routines.
"

# ╔═╡ 3340323c-58b4-405e-96ea-9bf0481914cd
md"
## `Alphabet`s, `Word`s and `LenLex` order
"

# ╔═╡ 8fd794bd-b999-4c61-98b4-a15ceb67932f
import CGT_KIT_WS2022: AbstractWord, Alphabet, LenLex, Word, Rule

# ╔═╡ b8dac4af-76d5-47d4-a9c4-bcc716688660
import CGT_KIT_WS2022: isprefix, issuffix, lt, rewrite

# ╔═╡ 108d7606-1038-4846-bb50-356da713aeb8
let al = Alphabet([:a, :A, :b, :B])
    lenlex = LenLex(al, [:a, :b, :B, :A])
    a, A, b, B = (Word([i]) for i in 1:length(al))

    @assert lt(lenlex, a * a, a * b)
    @assert lt(lenlex, a * b, a * A)
end

# ╔═╡ 18aadfb5-0b88-4050-a8db-e632e0976bb5
md"
## Rewriting routines
"

# ╔═╡ c72d134e-3d1e-487a-a766-c71a02b76c46
@testset "Rule rewrite" begin
    al = Alphabet([:a, :b, :A])
    a, b, A = (Word([i]) for i in 1:length(al))

    r1 = a * A => one(a)
    @test rewrite(a * A, r1) == one(a)
    @test rewrite(b * a * A, r1) == b
    @test rewrite(A * b * a, r1) == A * b * a
    @test rewrite(A * a * A, r1) == A

    r2 = b * b => one(b)
    v1 = rewrite(b * a * A * b, r1)
    @test rewrite(v1, r2) == one(a)

    @test rewrite(a * b * b * b, r2) == a * b
end

# ╔═╡ 41f61326-2148-4b8a-9a3a-7c9ed9e984d0
md"
## Starting with `Rule`s
For now, too keep things simple we will use a simple `Pair{W, W}` as a substitute for rewrtiting rule. It's simple, efficient allows us to write
```julia
L = Word([2,1])
R = Word([1,2])
rule = L => R
```

We'll just create a bit of eye-candy (`srting_repr(r::Rule, A::Alphabet)`) for rules so that these can be given a human readable form:
"

# ╔═╡ d839c36d-5066-41bf-85d1-c86398733d85
function CGT.string_repr(
    r::Rule,
    A::Alphabet;
    lhspad = 2length(first(r)) - 1,
    rhspad = 2length(last(r)) - 1,
)
    lhs, rhs = r
    L = rpad(CGT.string_repr(lhs, A), lhspad)
    R = lpad(CGT.string_repr(rhs, A), rhspad)
    return "$L → $R"
end

# ╔═╡ ec4417e3-52d4-4188-97af-da721385a5ff
let
	al = Alphabet([:a, :b, :A])
    a, b, A = (Word([i]) for i in 1:length(al))

    r1 = a * A => one(a)
	CGT.string_repr(r1, al)
end

# ╔═╡ 4aff42a7-f772-455b-84a5-ceaf88012152


# ╔═╡ dcfc4ed9-82fe-4546-b832-de61c2c4849a
md"""
## Rewriting systems

In our first implementation rewriting system just stores its ordering and its rewrtiting rules in a vector.

Since our rewriting routines are destructive we'll in the future define a method to create a completely new, independent rewriting system from an old one. For now we learn how to create an empty one and define a few accessors (won't hurt) and (again) a bit of eye-candy (which makes working with rwses so much more pleasure :).
"""

# ╔═╡ 92e6e1f9-e434-4e02-843a-5c4b136047eb
begin
    struct RewritingSystem{W<:AbstractWord,O<:CGT.WordOrdering}
        rwrules::Vector{Rule{W}}
        ordering::O
    end

    function Base.empty(rws::RewritingSystem)
		return RewritingSystem(empty(rws.rwrules), ordering(rws))
	end

    ordering(rws::RewritingSystem) = rws.ordering
    alphabet(llex::LenLex) = llex.alphabet
    alphabet(rws::RewritingSystem) = alphabet(ordering(rws))
    rwrules(rws::RewritingSystem) = rws.rwrules

    function Base.show(io::IO, rws::RewritingSystem)
        A = alphabet(rws)
        println(io, "Rewriting system ordered by ", ordering(rws), ":")
        l = ceil(Int, log10(length(rwrules(rws))))
        ll = mapreduce(length ∘ first, max, rwrules(rws))
        for (i, r) in enumerate(rwrules(rws))
            println(
                io,
                " ",
                lpad(i, l),
                ". ",
                CGT.string_repr(r, A; lhspad = 2ll - 1),
            )
        end
    end
end

# ╔═╡ eaa679df-0d78-4556-927e-7d89ae7e5c5c
md"
Here is where actual work begin. We'll define a method fo `rewrite!` with a `RewritingSystem` first. This is very similar to the one with a single `Rule`, except this time we try to rewrite with all of the rules of `rws`.

Just to remind you the flow of `rewrite` methods:
1. `rewrite(w, obj)` calls 
2. `rewrite!(one(w), copy(w), obj)` which:
 * destroys its second argument and
 * puts the content of the rewritten `w` into the first one.

Therefore all we need to do is to create a new method for `rewrite!(w, v, ::RewritingSystem)`:
"

# ╔═╡ 3003c72a-11a6-4a87-b6b9-2b46599e614c
md"
## Knuth-Bendix

Here is a basic skeleton for the Knuth-Bendix completion.

In plain english we do:
1. Create an independent copy of `R`, so that modifications to it won't have side effects on the argument,
2. Iterate over all pairs of rules resolving failures to local confluence by extending the list of rules:
```julia
	for r₁ in rwrules(rws)
	    for r₂ in rwrules(rws)
	        # if rewrites with `r₁` and `r₂` fail local confluence
            # resolve the failure by pushing a new rule to rwrules
```

3. When finished reduce the set of rules.

> **Note**: The order (the shape) of the iteration is very important here. While the space of iteration is square, it **changes** constantly during the procedure. It is tempting to just iterate over rows/columns, however this make the second loop (possibly) infinite and will not allow us to use the newly discovered rules soon enough.
>
> Therefore we traverse the iteration space by covering increasing **upper-left squares**. This way the size of the second loop over `r₂` is bounded in size and is therefore guaranteed to finish.
"

# ╔═╡ 8b74d0b8-12f0-48b1-8a7b-3daadf384629
md"
What needs to be implemented now are methods:
* `Base.push!(rws::RewritingSystem, ....)` for adding new rules to an `rws` and
* `resolve_overlaps!(rws::RewritingSystem, ::Rule, ::Rule)` which uses the two rules to create (potential) failures to local confluence and resolves them by adding additional rules to `rws`.
* `reduce(rws::RewritingSystem)` to reduce the set of rules of rws.
"

# ╔═╡ 7e49a904-70ef-41eb-9577-d96339abfcb6
function Base.push!(rws::RewritingSystem, r::Rule)
    lhs, rhs = r
    return push!(rws, lhs, rhs)
end

# ╔═╡ 09e5c149-eed9-4d06-bc31-c24acc686c04
function rule(o::CGT.WordOrdering, p::AbstractWord, q::AbstractWord)
    return lt(o, p, q) ? q => p : p => q
end

# ╔═╡ 244e064d-8d3c-4b49-9d76-5c2ba3919422
function Base.push!(rws::RewritingSystem, p::AbstractWord, q::AbstractWord)
    if p == q
		return rws
	end
    a = rewrite(p, rws) # allocate two/three new words
    b = rewrite(q, rws)
    if a ≠ b
        r = rule(ordering(rws), a, b)
        push!(rws.rwrules, r) # modifies rws directly
		# A = alphabet(rws)
  #       @info "adding a new rule: $(CGT.string_repr(r, A))"
    # else
		# A = alphabet(rws)
		# p_str = CGT.string_repr(p, A)
  #       q_str = CGT.string_repr(q, A)
  #       a_str = CGT.string_repr(a, A)
  #       @info "rewrites of $p_str and $q_str agree: $a_str"
    end
    return rws
end

# ╔═╡ 1b0213e0-af58-4730-b08b-52353627560c
function CGT.rewrite!(v::AbstractWord, w::AbstractWord, rws::RewritingSystem)
    resize!(v, 0)
    while !isone(w)
        push!(v, popfirst!(w))
        for (lhs, rhs) in rwrules(rws)
            if issuffix(lhs, v)
                prepend!(w, rhs)
                resize!(v, length(v) - length(lhs))
                break
            end
        end
    end
    return v
end

# ╔═╡ 15bcdeea-ebb7-4bab-81b7-ec060f4d1cc8
md"
### Indexing to an AbstractWord - Subwords
Before we enter `resolve_overlaps!` we need to solve one important issue.

Normally `w[2:4]` will produce a standard `Vector` -- That's why we'd need to write `W(p₁[1:end-length(s)])`: the argument is a `Vector` and we need to construct a word of type `W` from it:
"

# ╔═╡ 63d04115-7200-4b1c-9d63-c240edc40470
w = Word(1:2:22)

# ╔═╡ 571097c8-73e1-4b2b-ae85-8bc4a699a07b
w

# ╔═╡ 036489ef-bf52-425b-a0bd-b0b23adb5bbd
let v = w
	S = [3,4,5]
	v[begin:end-length(S)]
end

# ╔═╡ 8f475014-6a7d-4ff6-9b6b-7eaa187ed7d1
# ╠═╡ disabled = true
#=╠═╡
w[2:4]
  ╠═╡ =#

# ╔═╡ f06dfb62-6415-4c53-b84c-f9cba1e4dd4e
# P1 → Q1
# P2 → Q2
# S - suffix of P1 that is a prefix of P2
# P1 = A*S
# P2 = S*B
# Q1*B ↔ A*S*B → A*Q2

# ╔═╡ e7be2f94-13d4-4316-898d-8219d2255af4
md"What we would like to have is that indexing to a word produces a honest new word, of the same type. To achieve this we need to add the following method to `Base.similar`. For more details see the manual entry on [Array Interface](https://docs.julialang.org/en/v1/manual/interfaces/#man-interface-array)."

# ╔═╡ 52e3db55-b4ea-4c67-a95b-f8407a38d719
begin
    # function Base.similar(w::AbstractWord, ::Type, dims::Base.Dims{1})
    #     ans = one(w)
    #     resize!(ans, first(dims))
    #     return ans
    # end

	@testset "Subwords" begin
        w = CGT.Word([1, 2, 3, 4, 5, 6])
        @test w[:] isa CGT.AbstractWord
        @test w[:] == w
        @test w[1:3] == [1, 2, 3]
        @test w[4:4] == [4]
        @test isone(w[1:0])
    end
end

# ╔═╡ 598f67e2-ab62-436b-9c15-604dca0bbf97
v = collect(1:5)

# ╔═╡ 706bb6eb-dbda-4090-b595-55aa4141e2f1
v1 = v[2:4]

# ╔═╡ 3dc8adf9-0277-4152-b56c-26c245b3faee
v[2] = 10

# ╔═╡ f4bb52d4-8219-4d4d-8f62-ee15d866bd0f
v

# ╔═╡ 66098df6-1f83-41c3-976a-cd4c635756bf
v2 = @view v[1:5]

# ╔═╡ 5feefb5e-be98-4b7e-8045-8eb712107f25
typeof(v2)

# ╔═╡ 0c7eef35-7e83-4949-82b0-e6ee93e64424
@view w[2:4]

# ╔═╡ b7a0e3d9-e7ac-4535-b411-655d5cdb996d
# struct SubWord{T, V} <: AbstractWord{T}
# 	view::V # a view
# end

# ╔═╡ 89eaedbf-8c96-4478-b8b0-5db365462a72
Base.sizeof(v2)

# ╔═╡ 5da8541e-b7c5-4e73-9432-054ef71f2222


# ╔═╡ 11d67c1a-a9df-46a9-a76f-4a3e14af96a2


# ╔═╡ 98b05940-52de-4e7f-912e-3f186cdf7eaf
dump(v2)

# ╔═╡ ef192797-9b6a-4d88-84ed-2fb421c52d24
v[4] = -1

# ╔═╡ 602850a6-82e8-407e-8212-0b5436a29b86
v2

# ╔═╡ 4fbf5fc2-d0e4-4e46-8604-0fc24f534a55
pointer(v)

# ╔═╡ 0b2e5b51-4f38-427d-a0c6-cfb488d3c802
pointer(v1)

# ╔═╡ da6d5a4f-de29-45f2-af5e-e1db685089fd
md"
## Resovling Overlaps and the first `knuthbendix`
"

# ╔═╡ 45ed695f-9b95-4011-a749-5e8f5e8b918e
[i for i in 1:5]

# ╔═╡ 079dbd41-8651-4991-961f-445fbf4001cc
(i for i in 1:5)

# ╔═╡ 2ce460cf-beea-44b1-9728-4b3dfa21b255
suffixes(w::AbstractWord) = (w[i:end] for i in firstindex(w):lastindex(w))
# remember about the views!
# suffixes(w::AbstractWord) = (@view w[i:end] for i in firstindex(w):lastindex(w))

# ╔═╡ f384852c-a218-4703-ab7d-581ffe0aad34
function resolve_overlaps!(
    rws::RewritingSystem{W},
    r₁::Rule,
    r₂::Rule,
) where {W}
    p₁, q₁ = r₁
    p₂, q₂ = r₂
    for s in suffixes(p₁)
        if isprefix(s, p₂)
            a = p₁[begin:end-length(s)]
            b = p₂[length(s)+1:end]
            # word a*s*b rewrites in two possible ways:
            # q₁*b and a*q₂
            # we need to resolve this local failure to confluence:
            push!(rws, q₁ * b, a * q₂) # the correct rule is found in push!
		elseif isprefix(p₂, s) # i.e. p₂ is a subword in p₁
		# because rws may not be reduced
            a = p₁[begin:end-length(s)]
            b = p₁[length(a)+length(p₂)+1:end]
            # word p₁ = a*p₂*b can be rewritten in two possible ways:
            # q₁ and a*q₂*b
            push!(rws, q₁, a * q₂ * b)
        end
    end
    return rws
end

# ╔═╡ 767b11b0-116e-4bc3-bb60-2d11b3cdab0a
function reduce(rws::RewritingSystem)
    @error "reduce: not implemented yet"
    return rws
end

# ╔═╡ cdbc06c0-3de9-477f-9a80-7b781e504ff8
function knuthbendix1(R::RewritingSystem; maxrules = 100)
    rws = empty(R)
    for r in rwrules(R)
        push!(rws, deepcopy(r))
    end

    for (i, r₁) in enumerate(rwrules(rws))
        for (j,r₂) in enumerate(rwrules(rws))
			if length(rws.rwrules) > maxrules
                @warn "Maximum number of rules has been exceeded. Try running knuthbendix with larger maxrules kwarg"
				return rws
            end
			# @info (i,j)
            resolve_overlaps!(rws, r₁, r₂)
            r₁ == r₂ && break
            resolve_overlaps!(rws, r₂, r₁)
        end
    end
    return reduce(rws)
end

# ╔═╡ 02145069-fe3b-49d4-9c76-4c373b31a496
md"""
And that's enough to have a basic Knuth-Bendix completion going!
Let's try on the easy example of ℤ²:
"""

# ╔═╡ 230b4394-d1e5-4fce-8246-5378fc317e0a
R = let al = CGT.Alphabet([:a, :b, :A, :B])
    llex = CGT.LenLex(al, [:a, :A, :b, :B])
    a, b, A, B = (CGT.Word([i]) for i in 1:length(al))
    ε = one(a)
    RewritingSystem(
        [a * A => ε, A * a => ε, b * B => ε, B * b => ε, b * a => a * b],
        llex,
    )
	# maybe the correctness of the ordering of rules should be checked in the constructor?
end

# ╔═╡ 0ba5cfdd-4446-41ee-9fb2-62b60a1fb126
knuthbendix1(R)

# ╔═╡ 38147d7f-955e-47a1-9829-88cd6c1f9133
md"
### More Examples

Here are a few examples of rwses which are good to keep in mind and as test-cases when improving the Knuth-Bendix completion.
"

# ╔═╡ 9c40d303-e16c-4c90-9387-3b35f848f472
# Base.:^(w::AbstractWord, n::Integer) = Base.power_by_squaring(w, n)
Base.:^(w::AbstractWord, n::Integer) = repeat(w, n)

# ╔═╡ f5ac2e13-e08b-4fa5-88e2-6dc655b7a4fc
w^2

# ╔═╡ d07ef291-9198-4f0b-bb8f-355e20e03b49
# ╠═╡ disabled = true
#=╠═╡
let al = Alphabet([:a, :b]), O = LenLex(al, [:a, :b])
    a, b = (Word([i]) for i in 1:length(al))
    ε = one(a)
    R = RewritingSystem([a^2 => ε, b^3 => ε, (a * b)^3 => ε], O)
    reduce(knuthbendix1(R))
end
  ╠═╡ =#

# ╔═╡ 4a3b818c-f6c0-43f4-b22b-b6107c29c7b8
# ╠═╡ show_logs = false
# ╠═╡ disabled = true
#=╠═╡
Rc2 = let al = Alphabet([:a, :b]), O = LenLex(al, [:a, :b])
    a, b = (Word([i]) for i in 1:length(al))
    ε = one(a)
    R = RewritingSystem([a^2 => ε, b^2 => ε, (a * b)^2 => ε], O)
    knuthbendix1(R)
end
  ╠═╡ =#

# ╔═╡ b7ff2738-e1ff-4407-bea7-764664f0f284
#=╠═╡
reduce(Rc2)
  ╠═╡ =#

# ╔═╡ 9caf8676-ee7e-47f2-a977-5a0aebd37c34
# ╠═╡ show_logs = false
# ╠═╡ disabled = true
#=╠═╡
let al = Alphabet([:a, :b]), O = LenLex(al, [:a, :b])
    a, b = (Word([i]) for i in 1:length(al))
    ε = one(a)
    R = RewritingSystem([a^2 => ε, b^3 => ε, (a * b)^5 => ε], O)
    RC = reduce(knuthbendix1(R))
end
  ╠═╡ =#

# ╔═╡ dd710316-045d-43d1-9a49-edfb1a70ddfd
# ╠═╡ show_logs = false
# ╠═╡ disabled = true
#=╠═╡
let al = Alphabet([:a, :b, :B]), O = LenLex(al, [:a, :b, :B])
    a, b, B = (Word([i]) for i in 1:length(al))
    ε = one(a)
    R = RewritingSystem(
        [
            a^2 => ε,
            b * B => ε,
            B * b => ε,
            b^3 => ε,
            (a * b)^7 => ε,
            (a * b * a * B)^4 => ε,
        ],
        O,
    )
    RC = reduce(knuthbendix1(R))
    @assert length(rwrules(RC)) == 40
    RC
end
  ╠═╡ =#

# ╔═╡ 30749f24-6a3d-4120-ad11-328ae3e2eaba
# ╠═╡ disabled = true
#=╠═╡
let al = Alphabet([:a, :b, :B]), O = LenLex(al, [:a, :b, :B])
    a, b, B = (Word([i]) for i in 1:length(al))
    ε = one(a)
    R = RewritingSystem(
        [
            a^2 => ε,
            b * B => ε,
            B * b => ε,
            b^3 => ε,
            (a * b)^7 => ε,
            (a * b * a * B)^1 => ε,
        ],
        O,
    )
    RC = reduce(knuthbendix1(R; maxrules = 200))
    RC
end
  ╠═╡ =#

# ╔═╡ Cell order:
# ╠═12115b9a-971a-11ed-04d9-071d83df5526
# ╟─2abba47a-9691-416d-81c2-0ca87fc9e9c0
# ╟─3340323c-58b4-405e-96ea-9bf0481914cd
# ╠═8fd794bd-b999-4c61-98b4-a15ceb67932f
# ╠═b8dac4af-76d5-47d4-a9c4-bcc716688660
# ╠═108d7606-1038-4846-bb50-356da713aeb8
# ╟─18aadfb5-0b88-4050-a8db-e632e0976bb5
# ╠═c72d134e-3d1e-487a-a766-c71a02b76c46
# ╟─41f61326-2148-4b8a-9a3a-7c9ed9e984d0
# ╠═d839c36d-5066-41bf-85d1-c86398733d85
# ╠═ec4417e3-52d4-4188-97af-da721385a5ff
# ╠═4aff42a7-f772-455b-84a5-ceaf88012152
# ╟─dcfc4ed9-82fe-4546-b832-de61c2c4849a
# ╠═92e6e1f9-e434-4e02-843a-5c4b136047eb
# ╟─eaa679df-0d78-4556-927e-7d89ae7e5c5c
# ╠═1b0213e0-af58-4730-b08b-52353627560c
# ╟─3003c72a-11a6-4a87-b6b9-2b46599e614c
# ╟─8b74d0b8-12f0-48b1-8a7b-3daadf384629
# ╠═7e49a904-70ef-41eb-9577-d96339abfcb6
# ╠═244e064d-8d3c-4b49-9d76-5c2ba3919422
# ╠═09e5c149-eed9-4d06-bc31-c24acc686c04
# ╠═571097c8-73e1-4b2b-ae85-8bc4a699a07b
# ╠═036489ef-bf52-425b-a0bd-b0b23adb5bbd
# ╟─15bcdeea-ebb7-4bab-81b7-ec060f4d1cc8
# ╠═63d04115-7200-4b1c-9d63-c240edc40470
# ╠═8f475014-6a7d-4ff6-9b6b-7eaa187ed7d1
# ╠═f06dfb62-6415-4c53-b84c-f9cba1e4dd4e
# ╟─e7be2f94-13d4-4316-898d-8219d2255af4
# ╠═52e3db55-b4ea-4c67-a95b-f8407a38d719
# ╠═598f67e2-ab62-436b-9c15-604dca0bbf97
# ╠═706bb6eb-dbda-4090-b595-55aa4141e2f1
# ╠═3dc8adf9-0277-4152-b56c-26c245b3faee
# ╠═f4bb52d4-8219-4d4d-8f62-ee15d866bd0f
# ╠═66098df6-1f83-41c3-976a-cd4c635756bf
# ╠═5feefb5e-be98-4b7e-8045-8eb712107f25
# ╠═0c7eef35-7e83-4949-82b0-e6ee93e64424
# ╠═b7a0e3d9-e7ac-4535-b411-655d5cdb996d
# ╠═89eaedbf-8c96-4478-b8b0-5db365462a72
# ╠═5da8541e-b7c5-4e73-9432-054ef71f2222
# ╠═11d67c1a-a9df-46a9-a76f-4a3e14af96a2
# ╠═98b05940-52de-4e7f-912e-3f186cdf7eaf
# ╠═ef192797-9b6a-4d88-84ed-2fb421c52d24
# ╠═602850a6-82e8-407e-8212-0b5436a29b86
# ╠═4fbf5fc2-d0e4-4e46-8604-0fc24f534a55
# ╠═0b2e5b51-4f38-427d-a0c6-cfb488d3c802
# ╟─da6d5a4f-de29-45f2-af5e-e1db685089fd
# ╠═45ed695f-9b95-4011-a749-5e8f5e8b918e
# ╠═079dbd41-8651-4991-961f-445fbf4001cc
# ╠═2ce460cf-beea-44b1-9728-4b3dfa21b255
# ╠═f384852c-a218-4703-ab7d-581ffe0aad34
# ╠═cdbc06c0-3de9-477f-9a80-7b781e504ff8
# ╠═767b11b0-116e-4bc3-bb60-2d11b3cdab0a
# ╟─02145069-fe3b-49d4-9c76-4c373b31a496
# ╠═230b4394-d1e5-4fce-8246-5378fc317e0a
# ╠═0ba5cfdd-4446-41ee-9fb2-62b60a1fb126
# ╟─38147d7f-955e-47a1-9829-88cd6c1f9133
# ╠═f5ac2e13-e08b-4fa5-88e2-6dc655b7a4fc
# ╠═9c40d303-e16c-4c90-9387-3b35f848f472
# ╠═d07ef291-9198-4f0b-bb8f-355e20e03b49
# ╠═4a3b818c-f6c0-43f4-b22b-b6107c29c7b8
# ╠═b7ff2738-e1ff-4407-bea7-764664f0f284
# ╠═9caf8676-ee7e-47f2-a977-5a0aebd37c34
# ╠═dd710316-045d-43d1-9a49-edfb1a70ddfd
# ╠═30749f24-6a3d-4120-ad11-328ae3e2eaba
