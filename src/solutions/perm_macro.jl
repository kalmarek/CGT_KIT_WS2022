function _parse_cycles(str::AbstractString)
    cycles = Vector{Vector{Int}}()
    str = replace(str, r"\s+" => "", "()" => "")
    cycle_regex = r"\(\d+(,\d+)*\)?"
    parsed_size = 0
    for m in eachmatch(cycle_regex, str)
        cycle_str = m.match
        parsed_size += sizeof(cycle_str)
        cycle = [parse(Int, a) for a in split(cycle_str[2:end-1], ",")]
        push!(cycles, cycle)
    end
    if parsed_size != sizeof(str)
        throw(ArgumentError("_parse_cycles: parsed and string sizes differ"))
    end
    return cycles
end

function _image_from_cycles(cycles::AbstractVector{<:AbstractVector{<:Integer}})
    deg = mapreduce(maximum, max, cycles; init = 1)
    images = Vector{Int}(undef, deg)
    for idx in 1:deg
        k = idx
        for cycle in cycles
            i = findfirst(==(k), cycle)
            k = isnothing(i) ? k : cycle[mod1(i + 1, length(cycle))]
        end
        images[idx] = k
    end
    return images
end
"""
    perm"..."

String macro to parse cycles into `Permutation`.

Strings for the output of GAP could be copied directly into `perm"..."`.
Cycles of length `1` are not necessary, but can be included.

# Examples:
```jldoctest
julia> p = perm"(1,3)(2,4)(10)"
(1,3)(2,4)

julia> typeof(p)
Permutation

julia> degree(p)
4
```
"""
macro perm_str(str)
    cycles = _parse_cycles(str)
    images = _image_from_cycles(cycles)
    return :($Permutation($images))
end
