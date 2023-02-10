### A Pluto.jl notebook ###
# v0.19.14

using Markdown
using InteractiveUtils

# ╔═╡ 1c47758e-a79d-11ed-2591-a77c720b463c
begin
	using Pkg
    Pkg.activate("..")
    using Test
	using Revise
    using CGT_KIT_WS2022
    const CGT = CGT_KIT_WS2022
end

# ╔═╡ 14b5dccd-d860-466f-942c-03379408d152
md"
> **Exercise 1**: Implement your own version of `UnionFind` (aka _disjoint integer set_). Explore performance of different strategies for path compression.
"

# ╔═╡ 4ae921fb-cac5-42ed-9516-cc0d483e9e16


# ╔═╡ 7ede9a0a-8491-4d70-9b38-01a7857af0b8
begin
import CGT_KIT_WS2022: Alphabet, Automaton, State, AbstractWord
import CGT_KIT_WS2022: alphabet
end

# ╔═╡ 9ed2f79c-a422-431c-b103-37d169552bbd
begin
struct CosetAutomaton{S<:State, A<:Alphabet} <: Automaton
	alphabet::A
	states::Vector{S}
	# ... partition of states ...
end

CGT.initial(ca::CosetAutomaton) = first(ca.states)
CGT.alphabet(ca::CosetAutomaton) = ca.alphabet

CGT.hasedge(::CosetAutomaton, σ::State, label::Integer) = CGT.hasedge(σ, label)
CGT.trace(::CosetAutomaton, label::Integer, σ::State) = σ[label]

function CosetAutomaton(A::Alphabet)
	@assert all(CGT.hasinverse(A,l), A) "CosetAutomata are defined only for invertible alphabets"
	α = State{UInt8, UInt8}(length(A), terminal=true)
	return CosetAutomaton(A, [α])
end
end

# ╔═╡ 0c63065e-01be-493c-b3d5-6104e039082a
function unsafe_add_state!(ca::CosetAutomaton{S}) where S
	σ = S(length(alphabet(ca)), terminal=false)
	push!(ca.states, σ)
	return σ
end

# ╔═╡ d827a97c-f58f-4b01-b1ea-2c742e31fafb
function unsafe_add_edge!(ca::CosetAutomaton, σ::State, label, τ::State)
	label_inv = inv(alphabet(ca), label)
	σ[label] = τ
	if σ ≠ τ || label ≠ label_inv
		τ[label_inv] = σ
	end
	return ca	
end

# ╔═╡ 81dc9f0f-81cb-45fa-a180-0b40a622fb9c
md"
> **Exercise 2:** Based on the unsafe operations above implement
> * `define!(ca::CosetAutomaton, σ::State, label)` defining a new state accessible from `σ` via edge labeled by `label`
> * `join!(ca::CosetAutomaton, σ::State, label, τ::State)` joining two states `σ` and `τ` via edge labeled with `label`.
"

# ╔═╡ 31cb4d2c-d3b3-47f9-b3fa-ae3d84a92030
md"
> **Exercise 3:** Does the structure of `State` allow for cheap _removal_ of edges? What needs to be done to allow such modification? Implement
> * `unsafe_remove!(ca::CosetAutomaton, σ::State, label, τ::State)` which realizes this modification (while maintaining the `CosetAutomaton` invariants of `ca`.)
"

# ╔═╡ 124e8997-ed6e-4320-85cd-cc0e1d5cabc5
md"
> **Exercise 4**:
> * Modify `CosetAutomaton` by adding a persistent partition of states to it;
> * implement the `coincidence!(ca::CosetAutomaton, σ::State, τ::State)` procedure that produces a quotient automaton w.r.t. the smallest equivalence relation containing `(σ, τ)`.
"

# ╔═╡ 82450226-aef2-4b69-a744-9a68efc25eba
md"## Two sided trace

Given $w \in X^*$ and a `ca::CosetAutomaton` we're trying to produce
* the longest possible prefix `p` of `w` such that `(n, σ) = trace(ca, p, initial(ca))` is defined
* the longest possible suffix `s` of the remaining part of `w` such that the `(k, τ) = trace(ca, w[n+1], initial(α), reverse=true)` is defined
* and write `w = p·t·s` for some $t \in X^*$.

Now we have three different possibilities:
1. if `t = ε`, then states `σ` and `τ` need to be identified (if necessary). This means that we need to call `coincidence!(ca, σ, τ)`
2. if $|t| = 1$, i.e. $t$ consists of a single letter $x\in X$, we need to connect `σ` and `τ` with an edge labeled `x`; This means that we need to call `join!(ca, σ, x, τ)`.
3. if $|t| > 1$, then we
  * add new states following `σ` via `t[begin]` and preceeding `τ` via the inverse of `t[end]`
  * check the conditions 1. or 2. again
"

# ╔═╡ c5c5032b-e891-4930-9442-83f520647982
md"
> **Exercise 5**: 
> * Modify the implementation of `trace` to allow reverse tracing (by default `false`)
>  * Implement `trace_and_reverse!(ca::CosetAutomaton, w::AbstractWord, σ::State=initial(ca))` which realizes the above description.
>
> _Note_: depending on the implementation, the word `w` needs to satisfy certain assumptions (i.e. be reduced), but we will make sure it is the case in function `coset_enumeration`.
"

# ╔═╡ 3d87d168-1592-4423-9f25-ad9e6b3665da
function coset_enumeration(X::Alphabet, U::Vector{<:AbstractWord})
	ca = CosetAutomaton(X)
	for u in U
		w = CGT.rewrite(u, alphabet(ca)) # we're freely reducing u here
		trace_and_reverse!(ca, w)
	end
	return ca
end

# ╔═╡ Cell order:
# ╠═1c47758e-a79d-11ed-2591-a77c720b463c
# ╟─14b5dccd-d860-466f-942c-03379408d152
# ╠═4ae921fb-cac5-42ed-9516-cc0d483e9e16
# ╠═7ede9a0a-8491-4d70-9b38-01a7857af0b8
# ╠═9ed2f79c-a422-431c-b103-37d169552bbd
# ╠═0c63065e-01be-493c-b3d5-6104e039082a
# ╠═d827a97c-f58f-4b01-b1ea-2c742e31fafb
# ╟─81dc9f0f-81cb-45fa-a180-0b40a622fb9c
# ╟─31cb4d2c-d3b3-47f9-b3fa-ae3d84a92030
# ╟─124e8997-ed6e-4320-85cd-cc0e1d5cabc5
# ╟─82450226-aef2-4b69-a744-9a68efc25eba
# ╟─c5c5032b-e891-4930-9442-83f520647982
# ╠═3d87d168-1592-4423-9f25-ad9e6b3665da
