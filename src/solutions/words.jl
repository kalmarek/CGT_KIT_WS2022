struct Word{T} <: AbstractWord{T}
    letters::Vector{T}
end

# AbstractWord interface
# the identity
Base.one(::Type{Word{T}}) where {T} = Word(Vector{T}())
Base.resize!(w::Word, n) = resize!(w.letters, n)

# Implement abstract Vector interface
Base.size(w::Word) = size(w.letters)
Base.getindex(w::Word, i::Int) = w.letters[i]
Base.setindex!(w::Word, value, idx::Int) = w.letters[idx] = value
