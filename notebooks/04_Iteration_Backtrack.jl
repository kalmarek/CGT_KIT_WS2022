### A Pluto.jl notebook ###
# v0.19.14

using Markdown
using InteractiveUtils

# ╔═╡ 082cfcbc-6b26-11ed-23be-774aa0e982a1
md"
# Iteration protocol
"

# ╔═╡ 0ee24c8e-f7e2-41ca-9f7f-5acb113f4a04
struct Squares
	n::Int
end

# ╔═╡ afa4f2ee-b87f-451a-83ad-8cf68315ce6f
sq5 = Squares(5)

# ╔═╡ efe49b49-0887-4573-93d8-ebad4f711a26
begin
	function Base.iterate(sq::Squares) # when we start iteration
		return 1^2, 1+1 # first square, the state for the next iteration
	end
	function Base.iterate(sq::Squares, state)
		if state > sq.n
			return nothing
			# iterator is done when this returns `nothing`
		end
		return state^2, state+1
	end
	Base.eltype(::Type{Squares}) = Int
	Base.length(sq::Squares) = sq.n
end

# ╔═╡ 1f8d154d-2ba6-4b31-a701-a1552ab133e3
for n² in sq5
	println(n²)
end

# ╔═╡ 0ea8b527-4bce-47b9-8df2-71702fc5ffd7
collect(sq5)

# ╔═╡ 8c77637b-39c9-450c-9809-1ab811d69b82


# ╔═╡ 5b27b87f-0dc6-4803-997a-abf7eb3539e2
# Base.eltype(sq::Squares) = Int

# ╔═╡ 05e0e36e-79e1-4e1c-aec4-0de703a9151c


# ╔═╡ 58a77b51-0f1b-437e-9317-e30c12b0e934


# ╔═╡ 507de374-9559-480b-8d35-c7e747feb9ae


# ╔═╡ 9aa613a8-8966-4ec3-a9e0-35e1dd82e3b6


# ╔═╡ a964a19b-54e8-488e-a64b-db5ae6fa8509


# ╔═╡ 56f6725b-1c2d-435a-b1c1-e2e05c6b3eca
# first(sq)

# ╔═╡ ad108a44-4e30-4d20-9fc4-20ad9965f7d2
# last(sq) # in principle this could be a very expensive operation!

# ╔═╡ 1845a5cd-f9a7-4671-acd0-fbda8b1764ef
# collect(sq)

# ╔═╡ 0a945320-ea7a-479e-8d60-a211fafc256d
# we need to define eltype!

# ╔═╡ 7abf306d-92be-44d9-b8dd-528a3fd97c27
sq5

# ╔═╡ 67da9e90-8645-42f3-9319-ca26f0b4e5e0
first(sq5)

# ╔═╡ 0ed3f78a-ce53-4990-adc3-12945304d81d
collect(Iterators.filter(isodd, sq5))

# ╔═╡ ea1db55b-569b-40de-9a9e-212c3277facf


# ╔═╡ 93af7232-dcbf-48c6-87c3-a53f2842e002


# ╔═╡ e27ef4fa-99bb-462b-b2ba-f255f4bb5e45
begin
struct InfSquares end
	function Base.iterate(sq::InfSquares) # when we start iteration
		return 1^2, 1+1 # first square, the state for the next iteration
	end
	function Base.iterate(sq::InfSquares, state)
		return state^2, state+1
	end
	Base.eltype(::Type{InfSquares}) = Int
	Base.IteratorSize(::Type{InfSquares}) = Base.IsInfinite() # the default: HasLength()

	# Base.IteratorSize(::Type{InfSquares}) = Base.SizeUnknown() # the default: HasLength()
end

# ╔═╡ da739aa7-2e8b-4533-9872-d5ead4a381fd
let
	k = iterate(sq5)
	while k ≠ nothing
		val, st = k
		# do something with val
		println(val)
		k = iterate(sq5, st)
	end
end

# ╔═╡ c42676fe-1e0a-45b6-9355-2f39f7238d02
let ub = 120
	for n² in InfSquares()
		if n² > ub
			break
		end
		println(n²)
	end
end

# ╔═╡ cf20382e-9b54-4446-bad9-efa066f37600
md"
# Backtrack

Pseudocode:
```julia
function backtrack_search(bsch::BacktrackSearch, stack = [root_node(bsch)], backtrack=false)
	 # initialize stack with the root node

	while !isempty(stack)
		while backtrack && !isempty(stack)
			node = last(stack)
			if has_next_sibling(node)
				pop!(stack) # remove the last element from the stack
				# replace it with the next sibling of node
				
				# there might be no element on the stack after we pop!
				push!(stack, next_child(last(stack), node))
				
				backtrack = false
			else # 
				pop!(stack)
			end
		end

		# oracle tells if we should descend or not
		backtrack = !oracle(last(stack))
		node = last(stack)
		if isleaf(node) # we are at the bottom of the search
			if predicate(node)
				# do something with this node
				# println(node)
				return node, (stack,)
			end
			backtrack = true
		elseif !backtrack
			# go to the first child of the node!
			push!(stack, first_child(node))
		end
	end
	return nothing
end
```

"

# ╔═╡ b9976efa-f976-4021-96d5-64c29ddde282


# ╔═╡ 1b714dae-c2e8-47d2-8841-37998766d791


# ╔═╡ d7572f85-4477-4aeb-9388-33653fdd48b0
md"
> **Excercise**: Figure out all \"border conditions\" to get this running
"

# ╔═╡ d24f829f-99c7-4460-bfe8-d0c77cf2dca0
md"
> **Excercise:** Think of ways this pseudocode could be turned into **iteration** in `julia`:
> * where do we return an element (node)?
> * what should be `state`?
> * what is the `length`, `eltype`?
>
> *Tip*: after we return we need to carry the information of backtracking and jump into the right place in the code. Read about macros: `@label` and `@goto` which could be used to easily achieve this!
"

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.8.3"
manifest_format = "2.0"
project_hash = "da39a3ee5e6b4b0d3255bfef95601890afd80709"

[deps]
"""

# ╔═╡ Cell order:
# ╟─082cfcbc-6b26-11ed-23be-774aa0e982a1
# ╠═0ee24c8e-f7e2-41ca-9f7f-5acb113f4a04
# ╠═afa4f2ee-b87f-451a-83ad-8cf68315ce6f
# ╠═efe49b49-0887-4573-93d8-ebad4f711a26
# ╠═1f8d154d-2ba6-4b31-a701-a1552ab133e3
# ╠═da739aa7-2e8b-4533-9872-d5ead4a381fd
# ╠═0ea8b527-4bce-47b9-8df2-71702fc5ffd7
# ╠═8c77637b-39c9-450c-9809-1ab811d69b82
# ╠═5b27b87f-0dc6-4803-997a-abf7eb3539e2
# ╠═05e0e36e-79e1-4e1c-aec4-0de703a9151c
# ╠═58a77b51-0f1b-437e-9317-e30c12b0e934
# ╠═507de374-9559-480b-8d35-c7e747feb9ae
# ╠═9aa613a8-8966-4ec3-a9e0-35e1dd82e3b6
# ╠═a964a19b-54e8-488e-a64b-db5ae6fa8509
# ╠═56f6725b-1c2d-435a-b1c1-e2e05c6b3eca
# ╠═ad108a44-4e30-4d20-9fc4-20ad9965f7d2
# ╠═1845a5cd-f9a7-4671-acd0-fbda8b1764ef
# ╠═0a945320-ea7a-479e-8d60-a211fafc256d
# ╠═7abf306d-92be-44d9-b8dd-528a3fd97c27
# ╠═67da9e90-8645-42f3-9319-ca26f0b4e5e0
# ╠═0ed3f78a-ce53-4990-adc3-12945304d81d
# ╠═ea1db55b-569b-40de-9a9e-212c3277facf
# ╠═93af7232-dcbf-48c6-87c3-a53f2842e002
# ╠═e27ef4fa-99bb-462b-b2ba-f255f4bb5e45
# ╠═c42676fe-1e0a-45b6-9355-2f39f7238d02
# ╟─cf20382e-9b54-4446-bad9-efa066f37600
# ╠═b9976efa-f976-4021-96d5-64c29ddde282
# ╠═1b714dae-c2e8-47d2-8841-37998766d791
# ╟─d7572f85-4477-4aeb-9388-33653fdd48b0
# ╟─d24f829f-99c7-4460-bfe8-d0c77cf2dca0
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
