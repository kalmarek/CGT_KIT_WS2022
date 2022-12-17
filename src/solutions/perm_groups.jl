# abstract groups/methods go here

abstract type Group end
abstract type AbstractPermGroup{P<:AbstractPermutation} <: Group end

"""
gens(G::Group[, i::Integer])
Return a vector containing generators for group `G`.

If the second argument is given return the `i`-th generator.
"""
function gens end
gens(G::Group, i::Integer) = gens(G)[i]

gens(G::Group) = copy(unsafe_gens(G))
"""
    unsafe_gens(G::Group)
An unsafe version of `gens(G)`, the returned value may _alias_ internal data structures of `G`.

In particular should the returned value leave its caller scope, the safe version `gens(G)` must be used.
"""
function unsafe_gens end

"""
order([I=BigInt,] G::Group)
Return order of group `G` as an instance of `I`.
By default a `BigInt` (i.e. arbitrary sized integer) is returned.
"""
order(G::Group) = order(BigInt, G) # group orders can get very big very quickly

function Base.in(p::AbstractPermutation, G::AbstractPermGroup)
    r = sift(stabilizer_chain(G), p)
    return isone(r)
end

Base.one(G::AbstractPermGroup) = one(first(gens(G)))

Base.eltype(::Type{<:AbstractPermGroup{P}}) where {P} = P

Base.length(G::Group) = order(G) > typemax(Int) ? typemax(Int) : order(Int, G)

function basis(G::AbstractPermGroup)
    sc = stabilizer_chain(G)
    @assert !istrivial(sc)

    basis = Vector{typeof(point(sc))}()
    while !istrivial(sc)
        push!(basis, point(sc))
        sc = stabilizer(sc)
    end
    return basis
end

function Random.rand(
    rng::Random.AbstractRNG,
    X::Random.SamplerTrivial{<:AbstractPermGroup},
)
    G = X[]
    g = one(G)

    sc = stabilizer_chain(G)
    while !istrivial(sc)
        x = rand(rng, transversal(sc))
        g = transversal(sc)[x] * g
        sc = stabilizer(sc)
    end
    return g
end

function perm_from_images(
    sc::PointStabilizer,
    images::AbstractVector{<:Integer},
)
    @assert !istrivial(sc)
    g = one(gens(sc)[1])

    for pt in images
        if istrivial(sc)
            throw(ArgumentError("overspecified basis images"))
        end
        y = pt^inv(g)
        if !(y in transversal(sc))
            throw(ArgumentError("no such group element exist"))
        end
        r = transversal(sc)[y]
        g = r * g
        sc = stabilizer(sc)
    end

    return g
end

# implement PermutationGroup here

mutable struct PermutationGroup{P} <: AbstractPermGroup{P}
    gens::Vector{P}
    order::BigInt
    stab_chain::PointStabilizer{P}

    # Constructor where:
    # only gens are known
    PermutationGroup(gens::AbstractVector{P}) where {P} = new{P}(gens)
    # gens and order are known
    function PermutationGroup(gens::AbstractVector{P}, order::Integer) where {P}
        return new{P}(gens, order)
    end

    # everything is known
    function PermutationGroup(
        gens::AbstractVector{P},
        order::Integer,
        stab_chain::PointStabilizer{P},
        check = true,
    ) where {P}
        if check
            # we could/should add some consistency checks here e.g.
            @assert order(stab_chain) == order
            @assert all(gens) do g
                _, r = sift(g, stab_chain)
                return isone(r)
            end
        end
        return new{P}(gens, order, stab_chain)
    end
end

function PermutationGroup(gens::AbstractVector, sc::PointStabilizer)
    return PermutationGroup(gens, order(sc), sc)
end

unsafe_gens(G::PermutationGroup) = G.gens

function order(::Type{I}, sc::PointStabilizer) where {I}
    if istrivial(sc)
        return convert(I, 1)
    else
        l = length(transversal(sc))
        return convert(I, l * order(I, stabilizer(sc)))
    end
end

_knows_order(G::PermutationGroup) = isdefined(G, :order)

function order(::Type{I}, G::PermutationGroup) where {I<:Integer}
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
