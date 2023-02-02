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

function reduce(rws::RewritingSystem)
    @warn "not implemented yet"
    return rws
end
