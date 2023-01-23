struct Word{T} <: AbstractWord{T}
    letters::Vector{T}
end

# AbstractWord interface
# the identity
Base.one(::Type{Word{T}}) where {T} = Word(Vector{T}())
Base.resize!(w::Word, n) = resize!(w.letters, n)

Base.popfirst!(w::Word) = popfirst!(w.letters)
Base.prepend!(w::Word, v::AbstractWord) = prepend!(w.letters, v)

# Implement abstract Vector interface
Base.size(w::Word) = size(w.letters)
Base.@propagate_inbounds Base.getindex(w::Word, i::Int) = w.letters[i]
Base.@propagate_inbounds function Base.setindex!(w::Word, value, idx::Int)
    return w.letters[idx] = value
end
