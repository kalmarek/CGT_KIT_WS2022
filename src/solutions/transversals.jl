"""
    AbstractOrbit{S}
Abstract type representing abstract orbits of elements of type `S`.
"""
abstract type AbstractOrbit{S} end

"""
    AbstractTransversal{S, T} <: AbstractOrbit{S}
Abstract type representing the bijection of orbit oand orbit representatives.

`S` is the type of elements in the orbit, while `T` is the type of the
representatives. When `tr` is a transversal of `x` and `g` is a `GroupElement`
then `tr[x^g]` returns the representative of the `g`-coset of the stabilizer of `x`.

## Methods to implement:
 * Constructors:
  - `Transversal(x, g::GroupElement[, action=^])` a specific constructor for a
    cyclic group
  - `Transversal(x, S::AbstractVector{<:GroupElement}[, action=^])` the default
    constructor
 * `Base.getindex(tr::T, n::Integer)` - return the coset representative of
   corresponding to `n`, i.e. a group element `g` such that `first(tr)^g == n`.
   If no such element exists a `NotInOrbit` exception will be thrown.
 * Iteration protocol, iterating over points in the orbit.
"""
abstract type AbstractTransversal{S,T<:GroupElement} <: AbstractOrbit{S} end

Base.eltype(::Type{<:AbstractTransversal{S}}) where {S} = S

struct NotInOrbit <: Exception
    x::Any
    first::Any
end
function Base.showerror(io::IO, e::NotInOrbit)
    return print(io, e.x, " was not found in the orbit of ", e.first)
end

# implement your transversal structs here, subtyping AbstractTransversal
struct Transversal{S,T<:GroupElement} <: AbstractTransversal{S,T}
    vec::Vector{S}
    reps::Dict{S,T}

    function Transversal(pt::S, g::T, op) where {S,T<:GroupElement}
        vec = [pt]
        reps = Dict(pt => one(g))
        δ = pt
        γ = op(δ, g)
        while γ ≠ pt
            push!(vec, γ)
            reps[γ] = reps[δ] * g
            δ = γ
            γ = op(δ, g)
        end
        return new{S,T}(vec, reps)
    end

    function Transversal(
        pt::S,
        gens::AbstractVector{T},
        op,
    ) where {S,T<:GroupElement}
        @assert !isempty(gens)
        vec = [pt]
        reps = Dict(pt => one(first(gens)))

        for δ in vec
            for g in gens
                γ = op(δ, g)
                if !(γ in keys(reps))
                    push!(vec, γ)
                    push!(reps, γ => reps[δ] * g)
                end
            end
        end
        return new{S,T}(vec, reps)
    end
end

Transversal(pt::Integer, g::AbstractPermutation) = Transversal(pt, g, ^)
function Transversal(pt::Integer, g::AbstractVector{<:AbstractPermutation})
    return Transversal(pt, g, ^)
end

Base.iterate(tr::Transversal) = iterate(tr.vec)
Base.iterate(tr::Transversal, st) = iterate(tr.vec, st)
Base.length(tr::Transversal) = length(tr.vec)

Base.@propagate_inbounds function Base.getindex(tr::Transversal, pt)
    @boundscheck !(pt ∈ keys(tr.reps)) && throw(NotInOrbit(pt, first(tr)))
    return tr.reps[pt]
end

function Random.rand(
    rng::Random.AbstractRNG,
    X::Random.SamplerTrivial{<:Transversal},
)
    T = X[]
    return rand(rng, T.vec)
end
