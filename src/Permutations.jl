struct Permutation <: AbstractPermutation
    images::Vector{Int}

    function Permutation(v::Vector{<:Integer}, check=true)
        if check
            @assert sort(v) == 1:length(v) "Image vector doesn't define a permutation"
        end
        return new(v)
    end
end

# ## Interface of AbstractPermutation
Base.:^(n::Integer, σ::Permutation) =
    (n > length(σ.images) ? convert(Int, n) : σ.images[n])

function degree(σ::Permutation)
    for i in length(σ.images):-1:1
        if i^σ ≠ i
            # resize!(σ.images, i)
            return i
        end
    end
    return 1
    # return something(findlast(i->σ.images[i]!=i, 1:length(σ.images)), 1)
end
