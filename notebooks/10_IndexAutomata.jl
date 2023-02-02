### A Pluto.jl notebook ###
# v0.19.14

using Markdown
using InteractiveUtils

# ╔═╡ c1f71f78-a24f-11ed-06e3-efc9924a9d94
begin
	using Pkg
    Pkg.activate("..")
    using Test
    using CGT_KIT_WS2022
    const CGT = CGT_KIT_WS2022
end

# ╔═╡ d255e6e7-3028-4790-b18a-218788f20567
using BenchmarkTools

# ╔═╡ b0bb8590-a075-4f7c-aed6-0e4659d3b7ec
using Random

# ╔═╡ f9c97320-80fa-477c-b0a7-9b2f2afdc493
begin
	using Plots
	import PlotlyJS
	plotlyjs()
	using Statistics
end

# ╔═╡ e51e5bc4-8edd-45f8-ba59-732e35df234f
begin

mutable struct State{T, S}
    transitions::Vector{State{T,S}} # vector of fixed size
	fail::Bool
    data::T
    value::S

	function State{T, S}(n::Integer; fail::Bool=false) where {T, S}
        new{T,S}(Vector{State{T,S}}(undef, n), fail)
    end
    function State{T, S}(n::Integer, data; fail::Bool=false) where {T, S}
        new{T,S}(Vector{State{T,S}}(undef, n), fail, data)
    end
end

isterminal(s::State) = isdefined(s, :value)
isfail(s::State) = s.fail

	# σ[i]
function Base.getindex(s::State, i::Integer)
	isfail(s) && return s # return nothing
	!isassigned(s.transitions, i) && return nothing
	return s.transitions[i]
end
	# σ[i] = τ
Base.setindex!(s::State, v::State, i::Integer) = s.transitions[i] = v

hasedge(s::State, i::Integer) = !isnothing(s[i])
	
function value(s::State)
    isterminal(s) && return s.value
	throw("state is not terminal and its value is not assigned")
end

max_degree(s::State) = length(s.transitions)

	# outdegree?
degree(s::State) = count(i->hasedge(s, i), 1:max_degree(s))
# transitions(s::State) = (s[i] for i in 1:max_degree(s) if hasedge(s, i))
	
function Base.show(io::IO, s::State)
	if isterminal(s)
		print(io, "terminal state: ", value(s))
	else
		print(io, "state (data=", s.data, ") with ", degree(s), " transitions")
	end
end
	
end

# ╔═╡ 57011e31-a361-4860-8dc6-cd63d09907b2
md"
# IndexAutomata
Here we'll implement our first group-related automaton and use it to ease the rewriting procedure.

First let's include all what we have learned about alphabets, word and rewriting.
"

# ╔═╡ 4bc73635-a669-4391-8226-1039f05729f1
md"
## Node-based automata

Automaon is directed graph with edges labeled (mostly) by an alphabet with two distinguished subsets of its vertices: the initial ones and the terminal ones.

Formally an automaton a _quintuple_ ``\mathcal{A} = (\Sigma, X, E, A, \Omega)``, where
 1. ``\Sigma`` is the set of vertices (states, nodes)
 2. ``X`` is an alphabet labeling edges
 3. ``E \subset \Sigma \times X \cup \{\varepsilon\} \times \Sigma`` is the set of edges
 4. ``A \subset \Sigma`` is the set of vertices considered as _initial_, and
 5. ``\Omega \subset \Sigma`` is the set of vertices considered as _terminal_ (_final_).
"

# ╔═╡ 52677c22-edf9-4b82-8de3-3924b1792524
md"
There might be many different ways of implementing a directed labelled graph. Here we chose to implement those as a (`node → neighbours`) implementation, where each node stores the information about its direct descendants. A different possible implementation is a matrix-based one where rows are indexed by labels and columns by vertices/states/nodes of the graph (remember that julia is column-major!).

We begin by implementing a `State` structure to represent states (vertices) of our automaton.
It's `transitions` (neighbours) will be labeled by `X` (hence we assume that ``E \subset \Sigma \times X \times \Sigma``). Additionally each vertex may contain
 * identifier `data` (e.g. its id, hash, or any other data etc),
 * `value` (e.g. for a _rule identifier_ we'll sometimes store rwrules there), and
 * an indicator wether the state is `fail` -- an artificial state that we'll sometimes use for denoting _missing_ edges (later, when we learn how to modify index automata).
"

# ╔═╡ 719bf040-02c2-4c7e-a5dc-9eb47a02f86c
md"
Here we adopted a few conventions:
 * for a letter `x ∈ X` if `σ` is a state then `σ[x]` returns `τ` if `(σ, x, τ)` is an edge, otherwise `nothing` will be returned. This is the canonical way to obtain _neighbours_ of a state;
 * one can check the existence of an edge with `hasedge(σ, x)`;
 * `σ[x] = τ` will add the edge `(σ, x, τ)` to the automaton;
 * `value(σ)` returns stored value (if `isterminal(σ) == true`);
 * `degree(σ)` returns the number of `out`-neighbours of `σ` and `max_degree(σ)` returns the maximal possible number of out-neighbours (i.e. the length of the labeling alphabet `X`).

### Other choices for `State`s

A different possible implementation of a `State` would store transitions as a vector of pairs as follows:
```julia
mutable struct State{L, T, S}
    transitions::Vector{Pair{L, State{L,T,S}}}
	...

end
```
where an edge `(σ, x, τ)` would be recorded as `x => τ` stored in transitions.
This might be a more general solution (arbitrary labels on edges), a space efficient one (in case of highly non-complete automata) and relatively fast to find neighbours: if `σ.transitions` are sorted then the cost would be ``O(\log d)`` in the degree of a state.

Yet another solution would be to store a `Dict{L, State{L,T,S}}` recording the direct descendants of `σ`. Here the search time would be constant in the degree of vertex at an additional price paid in space and time (and for small degrees ``O(\log d)`` will be probably faster than ``O(1)`` here).

All of those choices could (and should) be benchmarked, and compared but only **after** we have a working basic implementation.
"

# ╔═╡ f4ebcdfb-c882-4b9f-9181-845d55a5e03d
md"
## Automata and tracing

These conventions are enough to define tracing for arbitrary automata.
"

# ╔═╡ 027eb143-cc08-400f-82dd-52691b70ec4f
abstract type Automaton end

# ╔═╡ 4b401c0d-c925-4c04-8ea8-fd1111f0f94a
md"
## Index Automata

Index automaton is a complete (hence deterministic) automaton which recognizes the language of words reducible w.r.t. a given rewriting system `rws`.
What is usually very useful with index automata is a _rule identifier_ function which, based on the terminal state `ω`, identifies the rule of the rewriting system which can be used to reduce (here: rewrite) the signature of a path leading to `ω`.
 
Below we implement index automaton in a form which can be regarded as a dictionary (or actually a finite state transducer, since no hashing is involved and it's an _associative collection_). It is useful to think that the automaton contain two types of edges:
* edges on **direct paths** and
* **skew edges** connecting direct paths.

**Direct paths** are created by simply tracing the _lhs_es of rwrules of `rws`. The end state `ω` derived from `r = (lhs=>rhs)` will be marked as terminal and will store (a pointer to) `r` as its `value`. To make the automaton complete (we actually will **not** make it complete though...) we'll need to add so called **skew edges** which will tell us what to do whenever we deviate from following a direct path. These will be explained later.

### Tracing

If we trace a word `w` through an indexing automaton as soon as we hit a terminal state we not only know that the word is reducible but also the dictionary/transducing part of the state will tell us which rule to apply to rewrite the word. This results in a huge benefits in terms of rewriting time (but does it? see benchmarks below...).
"

# ╔═╡ 546ddd31-8b7b-4046-9df4-a924be5eea94
md"
#### Direct edges
In the construction of an `IndexAutomaton` we store the length of the defining prefix as the `data`. Each state corresponds to a _prefix_ of an `lhs` of a rwrule in `R`. At this moment the automaton is just **a directed labeled tree** with leafs corresponding to the `lhs`es of rwrules of `R` (i.e. terminal states).

In the construction below we just trace the `lhs`es producing nodes as needed. Additionally we gather the signatures (prefixes) with the corresponding nodes which will be needed when constructing the skew paths.
"

# ╔═╡ c09a967a-6a4d-4682-a965-8416f9176bf7
md"
#### Skew edges
The idea behind **skew edges** is as follows. Suppose we're tracing a word `w` and we travelled for `l` steps on a direct path `P` leading to a `lhs`. However at `l+1`s step we deviate from `lhs` (i.e. `lhs[l+1] ≠ w[l+1]`). In the classical rewriting we would start tracing again at `w[2:end]`, a suffix of `w` and hope that this will lead us to a final state. Unfortunately we might be forced to trace `w[3:end]` and many more suffixes before a path to a final state is found. To cut all of this work what we want is to point us directly to the _longest suffix_ of `w` which defines a prefix of a direct path!

The construction those edges is an inductive process on the length of the signature.
1. We start at `α = initial(idxA)` the initial state of our atomaton
2. (initial step of the induction) If there are no rules (i.e. direct paths) starting with letter `x` we add a loop `(α, x, α)` to our automaton. Thus our automaton is complete for signatures of states of length less than or equal ``0``.
3. (induction step) We work state by state in the order of increasing length of their signature. Let `(σ, p)` be a state and its defining prefix. If there is no edge from `σ` labeled by `x∈X` (i.e. `σ[x]` is not defined) then `p·x` is not traceable in `idxA`. On the other hand `p[2:end]·x` is traceable (`p[2:end]` is shorter than `p` and therefore its final state `τ` is complete by the induction hypothesis). Therefore we add `(σ, x, τ[x])` to our automaton.

Since the number of states (prefixes) is finite this procedure has to finish. 
"

# ╔═╡ 6d070159-281b-413a-962b-51a21ebbec2a
function skew_edges!(idxA, states_prefixes)
	# add missing loops at the root
	α = initial(idxA)
	if degree(α) ≠ max_degree(α)
		for x in 1:max_degree(α)
			if !hasedge(idxA, α, x)
				# addedge!(idxA, (α, x, α))
				α[x] = α
			end
		end
	end

	# this has to be done in breadth-first fashion so that
	# trace(U, A) is defined
	if !issorted(states_prefixes, by=n->first(n).data)
		sort!(states_prefixes, by=n->first(n).data)
	end
	for (σ, prefix) in states_prefixes
		degree(σ) == max_degree(σ) && continue
		
		τ = let U = prefix[2:end]
			l, τ = trace(idxA, U)
			@assert l == length(U) # the whole U defines a path in A
			τ
		end

		for x in 1:max_degree(σ)
			hasedge(idxA, σ, x) && continue
			@assert hasedge(idxA, τ, x)
			# addedge!(idxA, (σ, x, τ[x]))
			σ[x] = τ[x]
		end
	end
	return idxA
end

# ╔═╡ 13a88097-0ae8-423d-8e1a-828ed77f598f
begin
struct IndexAutomaton{A<:CGT.Alphabet, T,S} <: Automaton
	alphabet::A
    initial::State{T,S}
end

initial(idxA::IndexAutomaton) = idxA.initial
# alphabet(idxA::IndexAutomaton) = idxA.alphabet

hasedge(::IndexAutomaton, σ::State, label::Integer) = hasedge(σ, label)
trace(::IndexAutomaton, label::Integer, σ::State) = σ[label]
	
function IndexAutomaton(R::CGT.RewritingSystem{W}) where W
	A = CGT.alphabet(R)
	α = State{UInt32, eltype(CGT.rwrules(R))}(length(A), 0)

    indexA = IndexAutomaton(A, α)
	append!(indexA, CGT.rwrules(R))

    return indexA
end

function append!(idxA::IndexAutomaton, rules)
	idxA, signatures = direct_edges!(idxA, rules)
	idxA = skew_edges!(idxA, signatures) # complete!
	return idxA
end

end

# ╔═╡ 12937f19-2a41-4e86-a9a6-13815eb687bb
begin
"""
	hasedge(A::Automaton, σ, label)
Check if `A` contains an edge starting at `σ` labeled by `label` 
"""
function hasedge(A::Automaton, σ, label) end

"""
	trace(A::Automaton, label, σ)
Return `τ` if `(σ, label, τ)` is in `A`, otherwise return nothing.
"""
function trace(A::Automaton, label, σ) end

"""
	trace(A::Automaton, w::AbstractVector{<:Integer} [, σ=initial(A)])
Return a pair `(l, τ)`, where 
 * `l` is the length of the longest prefix of `w` which defines a path starting at `σ` in `A` and
 * `τ` is the last state (node) on the path.
"""
function trace(A::Automaton, w::AbstractVector, σ=initial(A))
	for (i, l) in enumerate(w)
		if hasedge(A, σ, l)
			σ = trace(A, l, σ)
		else
			return i-1, σ
		end
	end
	return length(w), σ
end

# while it looks nice, is it really more readable?
# trace(v, A) vs A[v] vs A^v
# 
# Base.getindex(A::Automaton, v::AbstractVector) = trace(v, A)

end

# ╔═╡ 97676ba3-dc60-4668-8c69-5929ad79af24
function direct_edges!(idxA::IndexAutomaton, rwrules)
	@assert !isempty(rwrules)
	W = typeof(first(first(rwrules)))
	α = initial(idxA)
	S = typeof(α)
	n = max_degree(α)
	states_prefixes = [α=>one(W)] # will be kept sorted
	for r in rwrules
        lhs, _ = r
        σ = α
        for (prefix_length, l) in enumerate(lhs)
            if !hasedge(idxA, σ, l)
				τ = S(n, prefix_length)
				σ[l] = τ
				st_prefix = τ=>lhs[1:prefix_length]
				# insert into sorted list
				k = searchsortedfirst(
					states_prefixes, 
					st_prefix, 
					by=n->first(n).data
				)
				insert!(states_prefixes, k, st_prefix)
            end
            σ = σ[l]
        end
        σ.value = r
    end
	return idxA, states_prefixes
end


# ╔═╡ 1f1d3d05-d140-4e50-9aed-f23941bdecbd
md"
### Rewriting
Below we implement a rewriting procedure using an `ia::IndexAutomaton`. 
As in `rewrite` using a `Rule` or a `RewritingSystem` we remove letters one by one from the begining of `w` and attach them at the end of `v`. We however also trace the path defined by `v` and if we hit a terminal state we use the corresponding rule `(lhs → rhs)` to remove suffix of `v` (which is the `lhs` of the rule..., well almost) and prepend the `rhs` to `w` for future rewrite.

This procedure allocates a \"tape\" to record history (`path`). If we hit a terminal state we need to _rewind the \"tape\"_ so that the last state on `path` always corresponds to the end vertex of `v`.
"

# ╔═╡ eca4fd07-55d0-41d0-aa18-5918eb74011b
begin
function CGT.rewrite!(
	v::CGT.AbstractWord, 
	w::CGT.AbstractWord, 
	idxA::IndexAutomaton;
	path=[initial(idxA)]
)
	resize!(v, 0)
	while !isone(w)
		x = popfirst!(w)
		σ = last(path) # current state
		τ = σ[x] # next state
		@assert !isnothing(τ) "ia doesn't seem to be complete!; $σ"
		
		if isterminal(τ)
			lhs, rhs = value(τ)
			# lhs is a suffix of v·x, so we delete it from v
			resize!(v, length(v) - length(lhs) + 1)
			# now we need to rewind the path
			resize!(path, length(path) - length(lhs) + 1)
			# and prepend rhs to w
			prepend!(w, rhs)
			
			# @assert trace(v, ia) == (length(v), last(path))
		else
			push!(v, x)
			push!(path, τ)
		end
	end
	return v	
end

@testset "Index rewrite" begin
	rws = let
		al = CGT.Alphabet([:a, :b, :A, :B])
		lenlex = CGT.LenLex(al, [:a, :A, :b, :B])
	
		a, b, A, B = (CGT.Word([i]) for i in 1:length(al))
	
		ε = one(a)
		rws = CGT.RewritingSystem(
			[a*A=>ε, A*a=>ε, b*B=>ε, B*b=>ε, b*a=>a*b],
			lenlex
		)
		CGT.reduce(CGT.knuthbendix1(rws))
	end

	ia = IndexAutomaton(rws)
	n,l = (20,200)

	for i in 1:n
		w = CGT.Word(rand(1:length(CGT.alphabet(rws)), l))
		@test CGT.rewrite(w, rws) == CGT.rewrite(w, ia)
	end
end
	
end

# ╔═╡ db4140e9-98e5-4d8b-90f7-1f4ae9915d65
rws = let
		al = CGT.Alphabet([:a, :b, :A, :B])
		lenlex = CGT.LenLex(al, [:a, :A, :b, :B])
	
		a, b, A, B = (CGT.Word([i]) for i in 1:length(al))
	
		ε = one(a)
		rws = CGT.RewritingSystem(
			[a*A=>ε, A*a=>ε, b*B=>ε, B*b=>ε, b*a=>a*b],
			lenlex
		)
		CGT.reduce(CGT.knuthbendix1(rws))
	end

# ╔═╡ af0307ab-5394-44d9-958f-4da3d0798841
let
	indexA = IndexAutomaton(rws)
	al = CGT.alphabet(rws)

	let w = CGT.Word(rand(1:length(al), 20))
		println(CGT.string_repr(w, al))
		
		rw = CGT.rewrite(w, indexA)
		@assert CGT.rewrite(w, rws) == rw
		
		println(CGT.string_repr(rw, al))
		w, rw
	end
end

# ╔═╡ 9c12092b-7aaa-48a2-b66f-c5f6b1c86ac3
md"
> **Exercise**: Implement confluence test based on `IndexAutomaton`. The original version was to run a double loop over all pairs of rules and make sure their overlaps don't produce new different rewrites.
>
> In this version we still need to loop over all rules, but the second loop is replaced by a backtrack search on `idxA::IndexAutomaton`. Suppose we're processing rule `r = (L → R)`. Then we try to complete `S = L[2:end]` to another `lhs` in the rewriting system, i.e. we're searching for all paths that start at `trace(S, idxA)` and lead to any terminal state.
>
> Note: Since `idxA` can contain directed loops a special care is needed to ensure the stopping of the search. Here we can use the stored integer in `data` (the length of the shortest path leading to the state) to switch to the backtrack mode when venturing too far.
>
>(If necessary consult Sims book, INDEX_CONFLUENT algorithm on page 117.)
"

# ╔═╡ ecf24549-ef12-48bc-9777-7ff877a4e1ee
md"
## Benchmarking!
"

# ╔═╡ 2f969733-5a92-48a0-b72f-9da029d27198
rws

# ╔═╡ 8ad0c3e6-4c43-4d55-908f-5965f825f1cb
let rws = rws, idxA = IndexAutomaton(rws)
	Random.seed!(12)
	v = CGT.Word(Int[])
	w = CGT.Word(rand(1:length(CGT.alphabet(rws)), 2^11))
	@assert CGT.rewrite!(v, deepcopy(w), rws) == CGT.rewrite!(v, deepcopy(w), idxA)
	println(length(CGT.rewrite!(v, deepcopy(w), rws)))

	@btime CGT.rewrite!($v, dw, $rws) setup=(dw=deepcopy($w))
	@btime CGT.rewrite!($v, dw, $idxA) setup=(dw=deepcopy($w))
end

# ╔═╡ 72dadcf8-12b7-4ed0-b4fc-cf492d30375f
md"
Not particularly great, no matter which seed we pick (totally at random of course), the automaton based rewrite is consistently ``2``-``2.5`` times slower. Did we do anything wrong?

Well not exactly -- the rewriting system `rws` ist just too small/simple to show the real benefits of indexing. Let's try with the more involved example of a quotient of `2-3-7` \"Hurwitz group\".
"

# ╔═╡ ed9c298d-abac-4c69-a9ac-565b51163a03
rws237 = let al = CGT.Alphabet([:a, :b, :B]), O = CGT.LenLex(al, [:a, :b, :B])
	a, b, B = (CGT.Word([i]) for i in 1:length(al))
	ε = one(a)
	R = CGT.RewritingSystem(
		[a^2 => ε, b*B => ε, B*b=>ε, b^3=>ε, (a*b)^7=>ε, (a*b*a*B)^6=>ε],
		O
	)
	@time R = CGT.knuthbendix1(R, maxrules=700)
	@time RC = CGT.reduce(R)
	RC
end

# ╔═╡ 65c91106-ad1a-48f9-bd6a-4f782386dd19
let rws = rws237, idxA = IndexAutomaton(rws)
	Random.seed!(1)

	v = CGT.Word(Int[])
	w = CGT.Word(rand(1:length(CGT.alphabet(rws)), 2^11))
	@assert CGT.rewrite!(v, deepcopy(w), rws) == CGT.rewrite!(v, deepcopy(w), idxA)
	println(length(CGT.rewrite!(v, deepcopy(w), rws)))

	@btime CGT.rewrite!($v, dw, $rws) setup=(dw=deepcopy($w))
	@btime CGT.rewrite!($v, dw, $idxA) setup=(dw=deepcopy($w))
end

# ╔═╡ 1175a811-b8bd-422b-9abe-2bc34505f4bc
md"
Now this paints a totally different picture: here the automaton based rewriting is more than ``100`` times faster!
"

# ╔═╡ 1a779683-7c72-4dfd-bab0-4c72e7c9b32a


# ╔═╡ 003d57c4-1dea-4012-8f2d-e1bca17ac66f


# ╔═╡ 7a2709e3-8645-4d83-869b-e2d97f603681


# ╔═╡ ecee7eb2-d1ff-4a97-90a6-3b4ccd0bee50


# ╔═╡ a1553c2c-80fc-4d64-95c9-82aa1170ef7e


# ╔═╡ 75dc9263-6664-47a1-a23f-8cafd00f9a60


# ╔═╡ Cell order:
# ╠═c1f71f78-a24f-11ed-06e3-efc9924a9d94
# ╟─57011e31-a361-4860-8dc6-cd63d09907b2
# ╟─4bc73635-a669-4391-8226-1039f05729f1
# ╟─52677c22-edf9-4b82-8de3-3924b1792524
# ╠═e51e5bc4-8edd-45f8-ba59-732e35df234f
# ╟─719bf040-02c2-4c7e-a5dc-9eb47a02f86c
# ╟─f4ebcdfb-c882-4b9f-9181-845d55a5e03d
# ╠═027eb143-cc08-400f-82dd-52691b70ec4f
# ╠═12937f19-2a41-4e86-a9a6-13815eb687bb
# ╟─4b401c0d-c925-4c04-8ea8-fd1111f0f94a
# ╠═13a88097-0ae8-423d-8e1a-828ed77f598f
# ╟─546ddd31-8b7b-4046-9df4-a924be5eea94
# ╠═97676ba3-dc60-4668-8c69-5929ad79af24
# ╟─c09a967a-6a4d-4682-a965-8416f9176bf7
# ╠═6d070159-281b-413a-962b-51a21ebbec2a
# ╟─1f1d3d05-d140-4e50-9aed-f23941bdecbd
# ╠═eca4fd07-55d0-41d0-aa18-5918eb74011b
# ╠═db4140e9-98e5-4d8b-90f7-1f4ae9915d65
# ╠═af0307ab-5394-44d9-958f-4da3d0798841
# ╟─9c12092b-7aaa-48a2-b66f-c5f6b1c86ac3
# ╟─ecf24549-ef12-48bc-9777-7ff877a4e1ee
# ╠═d255e6e7-3028-4790-b18a-218788f20567
# ╠═b0bb8590-a075-4f7c-aed6-0e4659d3b7ec
# ╠═2f969733-5a92-48a0-b72f-9da029d27198
# ╠═8ad0c3e6-4c43-4d55-908f-5965f825f1cb
# ╟─72dadcf8-12b7-4ed0-b4fc-cf492d30375f
# ╟─ed9c298d-abac-4c69-a9ac-565b51163a03
# ╠═65c91106-ad1a-48f9-bd6a-4f782386dd19
# ╟─1175a811-b8bd-422b-9abe-2bc34505f4bc
# ╠═1a779683-7c72-4dfd-bab0-4c72e7c9b32a
# ╠═003d57c4-1dea-4012-8f2d-e1bca17ac66f
# ╠═7a2709e3-8645-4d83-869b-e2d97f603681
# ╠═ecee7eb2-d1ff-4a97-90a6-3b4ccd0bee50
# ╠═a1553c2c-80fc-4d64-95c9-82aa1170ef7e
# ╠═75dc9263-6664-47a1-a23f-8cafd00f9a60
# ╠═f9c97320-80fa-477c-b0a7-9b2f2afdc493
# ╠═c1d5402f-bea1-4558-9053-c5202e6a2a11
# ╠═90cd3497-3388-4fd4-8330-f40d0a0daf3a
# ╠═2c91853a-a2f6-4263-8819-f32343ed821b
# ╠═3373525d-dad7-4153-af75-18cc38e5b403
