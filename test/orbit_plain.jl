@testset "orbit_plain" begin
    σ = CGT.Permutation([2, 3, 4, 1])
    τ = CGT.Permutation([2, 1])
    S = [σ, τ]
    Δ = CGT.orbit_plain(one(σ), S, *)
    @test Δ == unique(Δ)
    @test length(Δ) == 24
    @test σ * τ in Δ
end

@testset "Transversals" begin
    σ = CGT.Permutation([1, 3, 4, 2])
    τ = CGT.Permutation([1, 2, 4, 5, 3])
    x = 2

    Δ, T = CGT.transversal(x, [σ, τ])
    @test Δ == unique(Δ)
    @test length(Δ) == 4
    @test length(T) == 4
    for δ in Δ
        @test 2^T[δ] == δ
    end

    @testset "factored transversal" begin
        σ = CGT.Permutation([1, 3, 4, 2])
        τ = CGT.Permutation([1, 2, 4, 5, 3])
        x = 2
        Δ, T = CGT.transversal_factored(x, [σ, τ])
        @test Δ == unique(Δ)
        @test length(Δ) == 4
        @test length(T) == 4
        for δ in Δ
            @test x^prod(T[δ]) == δ
        end

        σ = Permutation([1, 4, 2, 3])
        τ = Permutation([2, 3, 1])

        Δ, T = CGT.transversal_factored(one(σ), [σ, τ], *)
        @test Δ == unique(Δ)
        @test length(Δ) == 12
        @test length(T) == 12
        for g in Δ
            @test g == prod(T[g])
        end
    end

    @testset "schreier" begin
        # note this is the test for the modified schreier
        # see Exercise 6 in the corresponding notebook

        σ = Permutation([2, 1, 4, 3])
        τ = Permutation([1, 3, 4, 2])
        x = 2
        Δ, Sch = CGT.schreier(x, [σ, τ])
        @test Δ == unique(Δ)
        @test length(Δ) == 4
        @test length(Sch) == 4
        for (idx, δ) in pairs(Δ)
            δ == x && continue
            k = δ^inv(Sch[δ])
            @test S[findfirst(==(Sch[δ]), S)] === Sch[δ] # !!! note the triple ===
            @test findfirst(==(k), Δ) < idx
        end

        for δ in Δ
            @test x^CGT.representative(δ, S, Δ, Sch) == δ
        end
    end
end
