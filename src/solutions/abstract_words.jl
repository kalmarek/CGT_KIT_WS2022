"""
    AbstractWord{T} <: AbstractVector{T}
Type representing all abstract words. Every subtype `W` must implement the
following set of methods which constitute an informal _`AbstractWord`
Interface_.

 * `AbstractVector` interface (`getindex`, `setindex!`, `length`),
 * `Base.one(::Type{W})` if possible, otherwise `one(w::W)`,
 * `Base.resize!(w::W, n)` resizes word `w` in-place, adding new space at the
   end of `w`. The content of added space is undefined.
 * `Base.pop!(w::W)` remove the first letter from `w` and return it.
 * `Base.prepend!(w::W, v::AbstractWord)` modifies `w` in-place to contain `v*w`.
"""
abstract type AbstractWord{T} <: AbstractVector{T} end

Base.one(w::AbstractWord) = one(typeof(w))
Base.copy(w::AbstractWord) = one(w) * w
Base.isone(w::AbstractWord) = iszero(length(w))
# for better indexing
Base.IndexStyle(::Type{<:AbstractWord}) = IndexLinear()

function Base.:*(w::AbstractWord, v::AbstractWord...)
    return append!(one(w), w, v...)
end

Base.:^(w::AbstractWord, n::Integer) = repeat(w, n)

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

Base.show(io::IO, w::AbstractWord) = Base.show(io, MIME"text/plain"(), w)

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

"""
    issuffix(v::AbstractWord, w::AbstractWord)
Check if `v` is a suffix of `w`.
"""
function issuffix(v::AbstractWord, w::AbstractWord)
    length(v) > length(w) && return false
    offset = length(w) - length(v)
    for i in eachindex(v)
        @inbounds v[i] == w[offset+i] || return false
    end
    return true
end

"""
    isprefix(v::AbstractWord, w::AbstractWord)
Check if `v` is a prefix of `w`.
"""
function isprefix(v::AbstractWord, w::AbstractWord)
    length(v) > length(w) && return false
    for i in eachindex(v)
        @inbounds v[i] == w[i] || return false
    end
    return true
end

# function Base.popfirst!(w::AbstractWord)
#     @assert !isone(w)
#     letter = first(w)
#     for i in firstindex(w):lastindex(w)-1
#         w[i] = w[i+1]
#     end
#     resize!(w, length(w) - 1)
#     return letter
# end

# function Base.prepend!(w::AbstractWord, v::AbstractWord)
#     fi = firstindex(w)
#     li = lastindex(w)
#     resize!(w, length(w) + length(v))
#     for idx in li:-1:fi
#         @inbounds w[idx+length(v)] = w[idx]
#     end
#     for (idx, l) in pairs(v)
#         @inbounds w[idx] = l
#     end
#     return w
# end

# function Base.prepend!(w::AbstractWord, v::AbstractWord)
#     lw = length(w)
#     lv = length(v)
#     w = resize!(w, lw + lv)
#     w = copyto!(w, lv + 1, w, firstindex(w), lw)
#     w = copyto!(w, v)
#     return w
# end
