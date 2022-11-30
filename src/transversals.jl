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
struct Transversal{S,T} <: AbstractTransversal{S,T}
    #
end
