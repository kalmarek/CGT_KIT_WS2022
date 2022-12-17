first_moved(σ::AbstractPermutation) = findfirst(i -> i^σ != i, 1:degree(σ))

function order(σ::AbstractPermutation)
    return mapreduce(length, lcm, cycle_decomposition(σ); init = 1)
end
