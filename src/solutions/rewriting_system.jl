struct RewritingSystem{W<:AbstractWord,O<:WordOrdering}
    rwrules::Vector{Rule{W}}
    ordering::O
end

function Base.empty(rws::RewritingSystem)
    return RewritingSystem(empty(rws.rwrules), ordering(rws))
end

ordering(rws::RewritingSystem) = rws.ordering
alphabet(rws::RewritingSystem) = alphabet(ordering(rws))
rwrules(rws::RewritingSystem) = rws.rwrules

Base.push!(rws::RewritingSystem, r::Rule) = push!(rws, r...)

function rule(o::WordOrdering, p::AbstractWord, q::AbstractWord)
    return lt(o, p, q) ? q => p : p => q
end

function Base.push!(rws::RewritingSystem, p::AbstractWord, q::AbstractWord)
    if p == q
        return rws
    end
    a = rewrite(p, rws)
    b = rewrite(q, rws)
    if a ≠ b
        r = rule(ordering(rws), a, b)
        push!(rws.rwrules, r) # modifies rws directly
    end
    return rws
end

function Base.show(io::IO, rws::RewritingSystem)
    A = alphabet(rws)
    println(io, "Rewriting system ordered by ", ordering(rws), ":")
    l = ceil(Int, log10(length(rwrules(rws))))
    ll = mapreduce(length ∘ first, max, rwrules(rws))
    for (i, r) in enumerate(rwrules(rws))
        println(io, " ", lpad(i, l), ". ", string_repr(r, A; lhspad = 2ll - 1))
    end
end

"""
    rewrite!(v::AbstractWord, w::AbstractWord, rws::RewritingSystem)
Rewrite word `w` storing the result in `v` by left using rewriting rules of
rewriting system `rws`. See [Sims, p.66]
"""
function rewrite!(v::AbstractWord, w::AbstractWord, rws::RewritingSystem)
    resize!(v, 0)
    while !isone(w)
        push!(v, popfirst!(w))
        for (lhs, rhs) in rwrules(rws)
            if issuffix(lhs, v)
                prepend!(w, rhs)
                resize!(v, length(v) - length(lhs))
                break
            end
        end
    end
    return v
end
