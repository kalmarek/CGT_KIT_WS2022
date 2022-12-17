module CGT_KIT_WS2022

using Random

abstract type GroupElement end

export @perm_str

Base.literal_pow(::typeof(^), x::GroupElement, ::Val{-1}) = inv(x)
Base.copy(x::GroupElement) = one(x) * x
function Base.:^(x::GroupElement, n::Integer)
    xⁿ = Base.power_by_squaring(x, abs(n))
    return n ≥ 0 ? xⁿ : inv(xⁿ)
end

include("AbstractPermutations.jl")
include("Permutations.jl")
include("orbit_plain.jl")

include("schreier_sims.jl")
include("transversals.jl")
end # module CGT_KIT_WS2022
