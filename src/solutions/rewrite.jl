"""
    rewrite(w::AbstractWord, rewriting[, vbuffer=one(w), wbuffer=one(w)])
Rewrites word `w` using `rewriting` object.

The `rewriting` object must implement
`rewrite!(v::AbstractWord, w::AbstractWord, rewriting)`.
"""
function rewrite(
    w::W,
    rewriting,
    vbuffer = one(w),
    wbuffer = one(w),
) where {W<:AbstractWord}
    resize!(vbuffer, 0) # empty vbuffer

    # copy the content of w to wbuffer, possibly adjusting its size
    resize!(wbuffer, length(w))
    copy!(wbuffer, w)

    # do the destructive rewriting from `wbuffer` to `vbuffer`
    v = rewrite!(vbuffer, wbuffer, rewriting)
    return W(v) # return the result of the same type as w
    # and not-aligned with any args passed!
end

function rewrite!(::AbstractWord, ::AbstractWord, rw::Any)
    throw(
        "rewriting with object of type $(typeof(rw)) is not defined; " *
        "you need to implement " *
        "`rewrite(::AbstractWord, ::AbstractWord, rw::$(typeof(rw)))` yourself",
    )
end

function rewrite!(v::AbstractWord, w::AbstractWord, A::Alphabet)
    resize!(v, 0)
    for l in w
        if isone(v)
            push!(v, l)
        elseif hasinverse(A, l) && inv(A, l) == last(v)
            resize!(v, length(v) - 1)
        else
            push!(v, l)
        end
    end
    return v
end

const Rule{W} = Pair{W,W} where {W<:AbstractWord}

function rewrite!(v::AbstractWord, w::AbstractWord, rule::Rule)
    resize!(v, 0)
    lhs, rhs = rule # destructuring pair into two objects
    while !isone(w)
        push!(v, popfirst!(w))
        if issuffix(lhs, v)
            prepend!(w, rhs)
            resize!(v, length(v) - length(lhs))
        end
    end
    return v
end

"""
    rewrite!(v::AbstractWord, w::AbstractWord, rws::RewritingSystem)
Rewrite word `w` storing the result in `v` by left using rewriting rules of
rewriting system `rws`. See [Sims, p.66]
"""
function rewrite!(v::AbstractWord, w::AbstractWord, rws::AbstractVector{<:Rule})
    v = resize!(v, 0)
    while !isone(w)
        push!(v, popfirst!(w))
        for (lhs, rhs) in rws
            if issuffix(lhs, v)
                prepend!(w, rhs)
                resize!(v, length(v) - length(lhs))
                break
            end
        end
    end
    return v
end
