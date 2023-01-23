"""
    AbstractWord{T} <: AbstractVector{T}
Type representing all abstract words. Every subtype `W` must implement the
following set of methods which constitute an informal _`AbstractWord`
Interface_.

 * `AbstractVector` interface (`getindex`, `setindex!`, `length`),
 * `Base.one(::Type{W})` if possible, otherwise `one(w::W)`,
 * `Base.resize!(w::W, n)` resizes word `w` in-place, adding new space at the
   end of `w`. The content of added space is undefined.
"""
abstract type AbstractWord{T} <: AbstractVector{T} end

Base.one(w::AbstractWord) = one(typeof(w))
Base.copy(w::AbstractWord) = one(w) * w
Base.isone(w::AbstractWord) = iszero(length(w))

function Base.:*(w::AbstractWord, v::AbstractWord...)
    return append!(one(w), w, v...)
end

Base.inv(w::AbstractWord, A::Alphabet) = inv!(one(w), w, A)

function inv!(out::AbstractWord, w::AbstractWord, A::Alphabet)
    resize!(out, length(w))
    for (idx, letter) in enumerate(Iterators.reverse(w))
        out[idx] = inv(A, letter)
    end
    return out
end

function Base.show(io::IO, ::MIME"text/plain", w::AbstractWord)
    if isone(w)
        print(io, 'ε')
    else
        l = length(w)
        for (i, letter) in enumerate(w)
            print(io, letter)
            if i < l
                print(io, '·')
            end
        end
    end
end

function string_repr(w::AbstractWord, A::Alphabet)
    if isone(w)
        return sprint(show, w)
    else
        return join((A[idx] for idx in w), '·')
    end
end

function free_rewrite(w::AbstractWord, A::Alphabet)
    out = one(w)
    isone(w) && return out
    i = firstindex(w)
    while i ≤ lastindex(w)
        if !isone(out) && hasinverse(A, out[end]) && inv(A, out[end]) == w[i]
            resize!(out, length(out) - 1)
        else
            resize!(out, length(out) + 1)
            out[end] = w[i]
        end
        i += 1
    end
    return out
end
