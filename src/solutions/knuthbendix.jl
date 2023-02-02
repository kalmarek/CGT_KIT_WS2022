function knuthbendix1(R::RewritingSystem; maxrules = 100)
    rws = empty(R)
    for r in rwrules(R)
        push!(rws, deepcopy(r))
    end

    for (i, r₁) in enumerate(rwrules(rws))
        for (j, r₂) in enumerate(rwrules(rws))
            if length(rws.rwrules) > maxrules
                @warn join(
                    (
                        "Maximum number of rules ($maxrules) has been exceeded,",
                        "Try running knuthbendix with larger `maxrules` kwarg;",
                        "The returned rws is neither confluent nor reduced;",
                    ),
                    '\n',
                )
                return rws
            end
            @debug (i, j)
            resolve_overlaps!(rws, r₁, r₂)
            r₁ == r₂ && break
            resolve_overlaps!(rws, r₂, r₁)
        end
    end
    return reduce(rws)
end

function resolve_overlaps!(
    rws::RewritingSystem{W},
    r₁::Rule,
    r₂::Rule,
) where {W}
    p₁, q₁ = r₁
    p₂, q₂ = r₂
    for s in suffixes(p₁)
        if isprefix(s, p₂)
            a = p₁[begin:end-length(s)]
            b = p₂[length(s)+1:end]
            # word a*s*b rewrites in two possible ways:
            # q₁*b ← a*s*b → a*q₂
            # we need to resolve this local failure to confluence
            push!(rws, q₁ * b, a * q₂) # the correct rule is found in push!
        elseif isprefix(p₂, s) # i.e. p₂ is a subword in p₁
            # because rws may be not reduced
            a = p₁[begin:end-length(s)]
            b = p₁[length(a)+length(p₂)+1:end]
            # word a*p₂*b can be rewritten in two possible ways:
            # q₁ ← a*p₂*b → a*q₂*b
            # we need to resolve this local failure to confluence
            push!(rws, q₁, a * q₂ * b)
        end
    end
    return rws
end

function reduce(rws::RewritingSystem{W}) where {W}
    p = irreduciblesubsystem(rws)
    R = empty(rws)
    for lside in p
        push!(R, lside, rewrite(lside, rws))
    end
    return R
end

"""
    irreduciblesubsystem(rws::RewritingSystem)
Return an array of left sides of rules from rewriting system of which all the
proper subwords are irreducible with respect to this rewriting system.
"""
function irreduciblesubsystem(rws::RewritingSystem{W}) where {W}
    lsides = W[]
    for rule in rwrules(rws)
        lhs, _ = rule
        irreducible = true
        if length(lhs) >= 2
            for sw in subwords(lhs, 1, length(lhs) - 1) # proper subwords
                if !isirreducible(sw, rws)
                    @debug "subword $sw of $lhs is reducible. skipping!"
                    irreducible = false
                    break
                end
            end
        end
        if irreducible
            push!(lsides, lhs)
        end
    end
    return unique!(lsides)
end

function Base.occursin(subword::AbstractWord, word::AbstractWord)
    n = length(subword)
    n > length(word) && return false
    for i in 0:length(word)-n
        found = true
        for j in 1:n
            if subword[j] ≠ word[i+j]
                found = false
                break
            end
        end
        if found
            return true
        end
    end
    return false
end

function isirreducible(w::AbstractWord, rws::RewritingSystem)
    return !any(r -> occursin(first(r), w), rwrules(rws))
end

function subwords(w::AbstractWord, minlength = 1, maxlength = length(w))
    n = length(w)
    return (
        w[i:j] for i in 1:n for j in i:n if minlength <= j - i + 1 <= maxlength
    )
end
