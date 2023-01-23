import Base.Order: lt
abstract type WordOrdering <: Base.Order.Ordering end

"""
    struct LenLex{T} <: WordOrdering

`LenLex` order compares words first by length and then by lexicographic (left-to-right) order.
"""
struct LenLex{T} <: WordOrdering
    alphabet::Alphabet{T}
    letters_order::Vector{Int}
end

function LenLex(A::Alphabet{T}, letters::AbstractVector{T}) where {T}
    @assert length(A) == length(letters) "Invalid order on letters"
    perm = [A[l] for l in letters]
    return LenLex(A, invperm(perm))
end

function lt(o::LenLex, lp::Integer, lq::Integer)
    return o.letters_order[lp] < o.letters_order[lq]
end

function lt(o::LenLex, p::AbstractWord, q::AbstractWord)
    if length(p) == length(q)
        for (lp, lq) in zip(p, q)
            if lp == lq
                continue
            else
                return lt(o, lp, lq)
            end
        end
        return false # i.e. p == q
    else
        return length(p) < length(q)
    end
end

function Base.show(io::IO, llex::LenLex)
    print(io, "LenLex(")
    join(io, (llex.alphabet[i] for i in llex.letters_order), '<')
    return print(io, ')')
end
