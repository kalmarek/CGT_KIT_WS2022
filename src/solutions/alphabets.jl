struct Alphabet{T}
    letters::Vector{T}
    inverses::Vector{Int}
    letters_map::Dict{T,Int}

    function Alphabet(
        letters::AbstractVector{T},
        inverses::AbstractVector{<:Integer} = zeros(Int, length(letters)),
    ) where {T}
        @assert length(letters) == length(inverses) "Non-compatible inverses specification"
        @assert all(>=(0), inverses) "Inverses must be non-negative"
        @assert !(T <: Integer) "Only non-integer letters are needed"
        @assert unique(letters) == letters "Non-unique letters are not supported"

        return new{T}(
            letters,
            inverses,
            Dict(l => i for (i, l) in pairs(letters)),
        )
    end
end

Base.getindex(A::Alphabet, letter) = A.letters_map[letter]
Base.getindex(A::Alphabet, index::Integer) = A.letters[index]

hasinverse(A::Alphabet, letter) = hasinverse(A, A[letter])
hasinverse(A::Alphabet, index::Integer) = !iszero(A.inverses[index])

Base.inv(A::Alphabet, letter) = A[inv(A, A[letter])]
function Base.inv(A::Alphabet, index::Integer)
    hasinverse(A, index) ||
        throw(ArgumentError("Non-invertible letter: $(A[index])"))

    return A.inverses[index]
end

setinverse!(A::Alphabet, x, X) = setinverse!(A, A[x], A[X])

function setinverse!(A::Alphabet, x::Integer, X::Integer)
    @assert !hasinverse(A, x) "Letter $(A[x]) already has inverse: $(inv(A, x))"
    @assert !hasinverse(A, X) "Letter $(A[X]) already has inverse: $(inv(A, X))"

    A.inverses[x] = X
    A.inverses[X] = x

    return A
end

Base.length(A::Alphabet) = length(A.letters)
Base.iterate(A::Alphabet) = iterate(A.letters)
Base.iterate(A::Alphabet, state) = iterate(A.letters, state)
Base.eltype(::Type{Alphabet{T}}) where {T} = T

function Base.show(io::IO, A::Alphabet)
    println(io, "Alphabet of $(eltype(A)) with $(length(A)) letters:")
    for letter in A
        print(io, A[letter], ".\t", letter)
        if hasinverse(A, letter)
            print(io, " with inverse ", inv(A, letter))
        end
        println(io, "")
    end
end
