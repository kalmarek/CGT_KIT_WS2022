struct Permutation <: AbstractPermutation
    images::Vector{Int}

    function Permutation(images::AbstractVector{<:Integer}, check = true)
        if check
            @assert Base.require_one_based_indexing(images)
            !isperm(images) &&
                throw("Image vector doesn't define a permutation")
        end

        k = 1
        for idx in length(images):-1:1
            if images[idx] ≠ idx
                k = idx
                break
            end
        end
        return new(@view images[1:k])
    end
end

# ## Interface of AbstractPermutation
degree(σ::Permutation) = length(σ.images)

function Base.:^(n::Integer, σ::Permutation)
    if 1 ≤ n ≤ length(σ.images)
        return oftype(n, @inbounds σ.images[n])
    else
        return n
    end
end
