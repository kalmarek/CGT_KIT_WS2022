### A Pluto.jl notebook ###
# v0.19.14

using Markdown
using InteractiveUtils

# ╔═╡ 4b060a8e-ec9a-11ec-2102-914081f4f522
begin
    using Pkg
	Pkg.activate("..")
	using CGT_KIT_WS2022
	const CGT = CGT_KIT_WS2022
end

# ╔═╡ a5154174-1cc5-470a-81ba-08770e87d54f
md"
# Implementing permutation groups
"

# ╔═╡ 061428d6-5ca7-4a49-b9c6-04f3d469aaa3
begin
	abstract type Group end
	abstract type AbstractPermGroup{P<:CGT.AbstractPermutation} <: Group end
end

# ╔═╡ ce5ac93f-eed0-477d-8431-9726fbf20fca
md"
In the simplest form a group will contain its generating set:

```julia
struct PermutationGroup{P} <: AbstractPermGroup{P}
    gens::Vector{P}
end
```

With this definition we can just create a group like this:

```julia
G = PermutationGroup([perm\"(1,2,3)\", perm\"(1,2)\"])
```
"

# ╔═╡ 3f414cb9-2229-4216-a5a9-c2f4408b71a0
md"
### Generators
If we need a set of generators for `G` we can say

```julia
S = G.gens
```

but of course a better option is to define `gens` function:
"

# ╔═╡ 6ba04889-4a57-4acf-becf-54b41c67e8c5
begin
	"""
		gens(G::Group[, i::Integer])
	Return a vector containing generators for group `G`.
	
	If the second argument is given return the `i`-th generator.
	"""
	function gens end
	gens(G::Group, i::Integer) = gens(G)[i]
end

# ╔═╡ baff2607-ceb8-4a56-ae97-e1aa68a2f55b
md"
Then we can say

```julia
gens(G::PermutationGroup) = G.gens

S = gens(G)
```

The problem (or danger) with this definition is that modifying `S` will directly modify `G`:

```julia
@assert S === G.gens
push!(S, perm\"(1,2,3,4)\") # and here we modified G...
```
"

# ╔═╡ 485ec447-40aa-46c5-a782-b92dca53a87d
md"
At the moment this is _kind of_ OK as long as we remember about it (but are we going to remember this in 6 months from now?). The real danger is that in a moment we will add some other information to `PermutationGroup`, then modifying `S` _in-place_ may create inconsistency with the other data stored. This **will** in the long run lead to bugs which are hard to replicate (because they depend on particular input values and particular order of operations).
"

# ╔═╡ fbe61950-6fcd-410e-a936-7f9c210dd6b3
md"
There are two ways of avoiding inadvertent modifications of `G.gens`:

* wrap it in an immutable container, such as
  ```julia
  struct FrozenVector{T} <: AbstractVector{T}
      elts::Vector{T}
  end
  ```
  where read-only operations for `FrozenVector` are implemented. The cost of this solution is the increased complexity of our code.
"

# ╔═╡ 6b1f8114-8445-44c8-9237-fc019ae91663
md"
* change the definition of `gens` function to return a *shallow* copy of `G.gens`, i.e. a new vector which contains identically equal (`===`) generators:
"

# ╔═╡ f5c98ea2-fcf5-47a8-979c-6666e32ee07c
md"
This way a _shallow copy_ of the `G.gens` vector is created, i.e. we need to _allocate_ a new vector every time we ask for `gens`, but any modifications to it will not propagate to fields of `G`. The non-allocating version `unsafe_gens` provides a way to avoid the allocation.

  > Remark: the allocation will usually be pretty small, as `G.gens` will contain pointers to generators (i.e. generators are not stored _inline_ in memory). Then `copy` will allocate `sizeof(Ptr)*length(G.gens)` ≤ `8*length(G.gens)` bytes. Not tiny, but also not too large. For tight loops `unsafe_gens` should be used instead to avoid the growth of the garbage memory.

Note that **neither** of the proposed solutions will **fully protect** a user from him/her-self (e.g. there are still ways of modifying memory directly), but these measures will make shooting yourself in foot a tad harder.
"

# ╔═╡ fab0e6f1-204b-439c-a6d8-587b633efd4c
md"
## Lazy computation & incomplete constructor

We spent considerable amount of time implementing *Schreier-Sims* algorithm computing the stabilizer chain for a permutation group. Once this computation is done it'd be best to keep the stabilizer chain \"attached\" to `G` somehow, so that the computation doesn't have to be repeated again (e.g. when somebody asks us for `order(G)`, again). We are going to store a `StabilizerChain` in `G`, but compute it only lazily (or: on demand). This way `PermutationGroup`s are fast to create, and the computed stabilizer chains can be reused without a hassle. However the price we pay for this is thread-safety: `PermutationGroup` objects can no longer be accessed from multiple threads without a chance of creating data-inconsistency (What will happen when two threads try to overwrite stabilizer chain at the same time?).

> Note: It is possible to fix thread-safety with using either locks (stored **as fields** in `PermutationGroup`, see below), or by using highly experimental `@atomic` macro (available only on `julia-1.7` and above).
"

# ╔═╡ 506c4f68-05e7-4cc3-9ff3-fc19b8d4de80
md"
A simple pattern for lazy computation can be implemented in `julia` as follows:
"

# ╔═╡ f80668ea-613a-404d-b2aa-e62f9cda286d
begin
	abstract type Object{T} end
	mutable struct HalfLazy{T} <: Object{T}
	    n::Int # eagerly computed fields go first
	    lazy_field::T # all lazy fields must be at the end
	
	    # eager constructor
	    HalfLazy(n::Integer, lazy_f::T) where T = new{T}(n, lazy_f)
	    # lazy/incomplete constructor
	    HalfLazy{T}(n::Integer) where T = new{T}(n)
	end
end

# ╔═╡ 385a4c32-10b4-4ae2-8672-760b742a8aad
md"
This way we have two ways of creating a `HalfLazy` object: eagerly or lazily:
"

# ╔═╡ d31280ba-0c6d-477c-987f-d1ba5a2af52c
obj = HalfLazy{Vector{Float64}}(5)

# ╔═╡ 793d471a-aa96-4025-9044-dde91147f2f2
md"
In the lazy version `lazy_field` will be `undefined` which can be checked through
"

# ╔═╡ 55724699-acac-48a3-a6c6-8ac93cae73f3
isdefined(obj, :lazy_field)

# ╔═╡ 1475b268-c81f-4c18-ba2e-66ce4ee46621
Ref(5)

# ╔═╡ 32f5cdbc-382a-4b83-bbd9-46b7e45478e1


# ╔═╡ b9983106-eea0-403c-90b2-bd8066d8c722
md"
> Note: this pattern only works when lazy field is not `isbits`, i.e. this wont work for `HalfLazy{Float64}(5)`. `lazy_field` will be defined for such object and will contain garbage (or whatever was in the memeory). 
"

# ╔═╡ 1e1c0bd5-c8d3-4445-8f3c-f7d9d970a567
md"
Of course we don't want to sprinkle our code with calls to `isdefined`, especially  that laziness is _an implementation detail_. We should then contain those checks within functions of some (maybe even informal) interface. If e.g. `Object`s are supposed to implement `complicated_f` that can (re)use the value of `lazy_field` then we can do it as follows:
"

# ╔═╡ 84abc2f3-843a-48b1-ae36-52841aa470d0
function complicated_f(hl::HalfLazy{Vector{Float64}})
    if !isdefined(hl, :lazy_field)
        # do the computation
		sleep(2)
        lazy_f = rand(10) # ten random numbers

        hl.lazy_field = lazy_f # hl must be mutable for this to work!
    end
    return hl.lazy_field
end

# ╔═╡ a44243d6-6c1d-482c-bc10-92212abdd05e
md"
This way computation is performed once and the result is cached in `hl`.

> Note: If the access to a property/field is already entrenched in a code-base we can still perform the lazy computation by overloading `Base.getproperty`:
> ```julia
> function Base.getproperty(hl::HalfLazy, fieldname::Symbol)
>        if :fieldname == :some_field
>            return function_lazily_computing_some_field(hl)
>        else
>            return Base.getfield(hl, fieldname)
>        end
> end
> ```
"

# ╔═╡ 0115878f-46b8-4f1e-a8da-9907592a3a3f
md"
Let's use what we have learned for `PermutationGroup`s and `StabilizerChain`s. This is the data structure:
"

# ╔═╡ d0e00902-764e-4dff-a913-55c7f6d76d1a
begin
	"""
		order([I=BigInt,] G::Group)
	Return order of group `G` as an instance of `I`.
	By default a `BigInt` (i.e. arbitrary sized integer) is returned.
	"""
	order(G::Group) = order(BigInt, G) # group orders can get very big very quickly
	order(sc::CGT.PointStabilizer) = order(BigInt, sc)
	
	function order(::Type{I}, sc::CGT.PointStabilizer) where I
		if CGT.istrivial(sc)
			return convert(I, 1)
		else
			l = length(CGT.transversal(sc))
			return convert(I, l*order(I, CGT.stabilizer(sc)))
		end
	end
end

# ╔═╡ b3907a2d-4c1b-4e30-8165-0eaf1bd93aae
md"
and this is how the (lazy) accessors could look like:
```julia
function order(::Type{I}, G::PermutationGroup) where I
	if !isdefined(G, :order)
		G.order = order(BigInt, stabilizer_chain(G))
	end
	return convert(I, G.order)
end

function stabilizer_chain(G::PermutationGroup{P}) where {P}
	if !isdefined(G, :stab_chain)
		G.stab_chain = schreier_sims(gens(G))
	end
	return G.stab_chain
end
```
"

# ╔═╡ 8507e21c-26be-4b61-8476-553ef1628ca5
md"
Note that due to the design, when computing `order` we can use `stabilizer_chain` without worrying how it is computed (eagerly?, lazily?). These details are hidden from us and we can code in zen™.

-------

A more efficient version for `stabilizer_chain` would be to use the order of `G`, if known,  to short-circuit processing of the Schreier-Sims generators when the  correct order for stabilizer chain is attained. However we can't write

```julia
	if !isdefined(G, :stab_chain)
    	G.stab_chain = schreier_sims(gens(G), order(G))
	end
```

since `order` may depend on the computation of `stabilizer_chain` and we'll get `StackOverflow` with the functions calling each other at infinitum. This could be solved by doing

```julia
    if !isdefined(G, :stab_chain)
        G.stab_chain = if !isdefined(G, :order)
                schreier_sims(gens(G))
            else
                schreier_sims(gens(G), order(G))
            end
        end
    end
```

But this is of course rather ugly in the sense it requires us to intertwine the code patterns for laziness and algorithmic decisions. What captures the intention much better is to define
"

# ╔═╡ a30af7b6-da81-420c-958f-e0dcf90ca073
md"
and rewrite `order` and `stabilizer_chain` as
"

# ╔═╡ e740f8a1-41b6-49d6-aceb-be4e8e541a75
begin
	function order(::Type{I}, G::PermutationGroup) where I<:Integer
	    if !_knows_order(G)
	        G.order = order(BigInt, stabilizer_chain(G))
	    end
	    return convert(I, G.order)
	end
	
	function stabilizer_chain(G::PermutationGroup)
	    if !isdefined(G, :stab_chain)
	        G.stab_chain = if _knows_order(G)
	        	schreier_sims(gens(G), order(G))
	        else
	            schreier_sims(gens(G))
	        end
	    end
	    return G.stab_chain
	end
end

# ╔═╡ b0be3d37-35d0-41e0-b4d8-ae54e31ca54e
begin
	mutable struct PermutationGroup{P} <: AbstractPermGroup{P}
		gens::Vector{P}
		order::BigInt
		stab_chain::CGT.PointStabilizer{P}
	
		# Constructor where:
		# only gens are known
		PermutationGroup(gens::AbstractVector{P}) where {P} = new{P}(gens)
		# gens and order are known
		PermutationGroup(gens::AbstractVector{P}, order::Integer) where {P} =
			new{P}(gens, order)
	
		# everything is known
		function PermutationGroup(
	        gens::AbstractVector{P},
	        order::Integer,
	        stab_chain::CGT.PointStabilizer{P},
	        check=true
	    ) where {P}
	    	if check
				# we could/should add some consistency checks here e.g.
	            @assert order(stab_chain) == order
	        	@assert all(gens) do g
	            	_,r = CGT.sift(g, stab_chain)
	                isone(r)
	        	end
			end
	    	return new{P}(gens, order, stab_chain)
	    end
	end

	PermutationGroup(gens::AbstractVector, sc::CGT.PointStabilizer) =
		PermutationGroup(gens, order(sc), sc)
end

# ╔═╡ 9ce7b77c-748f-4048-ae58-eb59415ea602
unsafe_gens(G::PermutationGroup) = G.gens

# ╔═╡ ef339199-2eb5-49f0-946d-410e48bacdaf
begin
	gens(G::Group) = copy(unsafe_gens(G))
	"""
	    unsafe_gens(G::Group)
	An unsafe version of `gens(G)`, the returned value may _alias_ internal data structures of `G`.
	
	In particular should the returned value leave its caller scope, the safe version `gens(G)` must be used.
	"""
	function unsafe_gens end
	# unsafe_gens(G::PermutationGroup) = G.gens
end

# ╔═╡ 4d4703d9-2170-44cc-a164-ac0c2c97fb19
_knows_order(G::PermutationGroup) = isdefined(G, :order)

# ╔═╡ 9a6e554a-6c21-4ce3-a65a-4e6067ddda66
md"
> There is also a different pattern that could be implemented especially when many properties (`isabelian`, `issolvable`, `ispolycyclic` etc.) of groups accumulate: to store their values in a `BitSet` or a dictionary **together with** additional `BitSet` which indicates whether the property has been already computed (like `_knows_order`).
"

# ╔═╡ 7e6ec954-9ede-4ad0-bcaa-d3e56b8c1d17
md"
### Intermezzo: Locking and multithreading

To modify a `struct` asynchronously one can use locks to avoid data races/object inconsistency (and deadlocks). For example if you run this code

```julia
function threaded_count_incorrect(f, n=8)
	s = 0
    @sync for i in 1:n
    	Threads.@spawn begin
        	v = f(i)
            s += v
        end
    end
    return s
end
f(i) = (sleep(1); 1)
@time threaded_count_incorrect(f)
```

the time block will execute in `n/Threads.nthreads()` seconds, but You will occasionally see a number different than `n=8` . This is because a thread read/stored value in `s`  while `s` was modified/held by a different thread. This can be alleviated by e.g. using `s = Threads.Atomic{Int}(0)` but this solution only applies to `primitive structs`. One general solution is to use locks to limit the number of simultaneous assignments to `s`:

```julia
function threaded_count(f, n=8)
    s = 0
    lck = Threads.SpinLock() # there is also a ReentrantLock
	@sync for i in 1:n
        Threads.@spawn begin
        	v = f(i)
    	 	lock(lck) do
                s += v
            end
        end
    end
    return s
end
f(i) = (sleep(1); 1)
@time threaded_count(f)
```

This means that we either create a lock for every mutable/lazy field of our `struct`, or create a single lock for locking the whole object. There are also other considerations here (which kind of lock? what happens when we start computing `f` while someone else keeps the lock etc.) as well as different algorithms covering e.g. lock free assignment, but we shall stop here.
"

# ╔═╡ 6f46872c-c9c2-46ac-a707-977cfb68c223
md"
## Return to groups

With this we can implement a few other methods:
"

# ╔═╡ a5ba703f-a029-4125-b41f-a07f69ba3eff
begin
	function Base.in(G::AbstractPermGroup, p::CGT.AbstractPermutation)
	    _, r = sift(stabilizer_chain(G), p)
	    return isone(r)
	end
	
	Base.one(G::AbstractPermGroup) = one(first(gens(G)))
end

# ╔═╡ 3efe4ebe-ef41-4c67-bccb-6071b80e4628
md"
and in preparation for the iteration protocol we will define
"

# ╔═╡ cbd10c00-4f02-46ec-bbae-e369fb1b2d4c
Base.eltype(::Type{<:AbstractPermGroup{P}}) where P = P

# ╔═╡ 0483c1cb-5869-4e2f-ac29-8092c873e7db
Base.length(G::Group) =
	order(G) > typemax(Int) ? typemax(Int) : order(Int, G)

# ╔═╡ 3db5aa8f-bf70-49db-84dc-2e35a4dd7af5
md"
Of course the latter is a blatant lie, but since nobody is ever going to iterate over `typemax(Int) = 9223372036854775807 ≈ 9.2e18` elements we can sleep peacefully.
(That is as long the users will use `order` instead of `length`).
"

# ╔═╡ 7d392697-2f82-4124-8543-5475c786e9dc
md"
# Exercices:
> **Exercise 1**: Implement a method to reconstruct group element from the images of a given basis of a stabilizer chain.
> Use this to implement `rand` method for obtaining uniformly random elements from the group.

> **Exercise 2**: Compare the distribution of obtained elements with the `pseudo_rand` which we talked about in the one of the first lectures.

> **Exercise 3**: Implement iteration using function from Ex 1. to finalize the iteration protocol for `PermutationGroups`. Is this slower or faster than performing a backtract on stabilizer chain (never pruning and return all leafs).
"

# ╔═╡ e7931440-75ea-4ee3-bf7e-17dd6134115d


# ╔═╡ Cell order:
# ╟─a5154174-1cc5-470a-81ba-08770e87d54f
# ╠═4b060a8e-ec9a-11ec-2102-914081f4f522
# ╠═061428d6-5ca7-4a49-b9c6-04f3d469aaa3
# ╟─ce5ac93f-eed0-477d-8431-9726fbf20fca
# ╟─3f414cb9-2229-4216-a5a9-c2f4408b71a0
# ╠═6ba04889-4a57-4acf-becf-54b41c67e8c5
# ╟─baff2607-ceb8-4a56-ae97-e1aa68a2f55b
# ╟─485ec447-40aa-46c5-a782-b92dca53a87d
# ╟─fbe61950-6fcd-410e-a936-7f9c210dd6b3
# ╟─6b1f8114-8445-44c8-9237-fc019ae91663
# ╠═ef339199-2eb5-49f0-946d-410e48bacdaf
# ╟─f5c98ea2-fcf5-47a8-979c-6666e32ee07c
# ╟─fab0e6f1-204b-439c-a6d8-587b633efd4c
# ╟─506c4f68-05e7-4cc3-9ff3-fc19b8d4de80
# ╠═f80668ea-613a-404d-b2aa-e62f9cda286d
# ╟─385a4c32-10b4-4ae2-8672-760b742a8aad
# ╠═d31280ba-0c6d-477c-987f-d1ba5a2af52c
# ╟─793d471a-aa96-4025-9044-dde91147f2f2
# ╠═55724699-acac-48a3-a6c6-8ac93cae73f3
# ╠═1475b268-c81f-4c18-ba2e-66ce4ee46621
# ╠═32f5cdbc-382a-4b83-bbd9-46b7e45478e1
# ╟─b9983106-eea0-403c-90b2-bd8066d8c722
# ╟─1e1c0bd5-c8d3-4445-8f3c-f7d9d970a567
# ╠═84abc2f3-843a-48b1-ae36-52841aa470d0
# ╟─a44243d6-6c1d-482c-bc10-92212abdd05e
# ╟─0115878f-46b8-4f1e-a8da-9907592a3a3f
# ╠═b0be3d37-35d0-41e0-b4d8-ae54e31ca54e
# ╠═9ce7b77c-748f-4048-ae58-eb59415ea602
# ╠═d0e00902-764e-4dff-a913-55c7f6d76d1a
# ╟─b3907a2d-4c1b-4e30-8165-0eaf1bd93aae
# ╟─8507e21c-26be-4b61-8476-553ef1628ca5
# ╠═4d4703d9-2170-44cc-a164-ac0c2c97fb19
# ╟─a30af7b6-da81-420c-958f-e0dcf90ca073
# ╠═e740f8a1-41b6-49d6-aceb-be4e8e541a75
# ╟─9a6e554a-6c21-4ce3-a65a-4e6067ddda66
# ╟─7e6ec954-9ede-4ad0-bcaa-d3e56b8c1d17
# ╟─6f46872c-c9c2-46ac-a707-977cfb68c223
# ╠═a5ba703f-a029-4125-b41f-a07f69ba3eff
# ╟─3efe4ebe-ef41-4c67-bccb-6071b80e4628
# ╠═cbd10c00-4f02-46ec-bbae-e369fb1b2d4c
# ╠═0483c1cb-5869-4e2f-ac29-8092c873e7db
# ╟─3db5aa8f-bf70-49db-84dc-2e35a4dd7af5
# ╟─7d392697-2f82-4124-8543-5475c786e9dc
# ╠═e7931440-75ea-4ee3-bf7e-17dd6134115d
