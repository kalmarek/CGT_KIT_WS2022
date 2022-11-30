@testset "AbstractPermutation" begin
    Perm = CGT.Permutation
    σ = Perm(BigInt[2, 1, 3])
    τ = Perm(UInt32[1, 3, 2])

    @test CGT.degree(one(σ)) == 1
    @test CGT.degree(σ) == 2
    @test CGT.degree(τ) == 3

    @test 1^σ == 2
    @test 2^σ == 1
    @test 3^σ == 3
    @test 6^σ == 6

    @test inv(one(σ)) == one(σ)
    @test inv(σ) * σ == one(σ)
    @test τ * inv(τ) == one(τ)
    @test inv(σ * τ) == inv(τ) * inv(σ)
    # (1,2)·(2,3) == (1,3,2)
    @test σ * τ == Perm([3, 1, 2])

    @test CGT.orbit_plain(1, σ) == [1, 2]
    @test CGT.orbit_plain(3, σ) == [3]
    @test CGT.orbit_plain(1, τ) == [1]
    @test CGT.orbit_plain(3, τ) == [3, 2]

    @test CGT.cycle_decomposition(one(σ)) == [[1]]
    @test CGT.cycle_decomposition(σ) == [[1, 2]]
    @test CGT.cycle_decomposition(τ) == [[1], [2, 3]]
    @test CGT.cycle_decomposition(σ * τ) == [[1, 3, 2]]

    @test sprint(show, one(σ)) == "()"
    @test sprint(show, σ) == "(1,2)"
    @test sprint(show, τ) == "(2,3)"
    @test sprint(show, σ * τ) == "(1,3,2)"
end
