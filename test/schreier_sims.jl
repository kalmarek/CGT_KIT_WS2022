function _ord(::Type{I}, stab::CGT.PointStabilizer) where {I}
    if CGT.istrivial(stab)
        return one(I)
    else
        return length(CGT.transversal(stab)) * _ord(I, CGT.stabilizer(stab))
    end
end

_ord(stab::CGT.PointStabilizer) = _ord(Int, stab)

@testset "Schreier-Sims" begin
    @testset "Symmetric & Alternating" begin
        a = CGT.Permutation([2, 1])
        b = CGT.Permutation([2, 3, 4, 5, 1])
        @test CGT.schreier_sims([a, b]) isa CGT.PointStabilizer

        @test _ord(CGT.schreier_sims([a, b])) == 120
        @test _ord(CGT.schreier_sims([b, a])) == 120

        n = 5
        S = map(1:n-2) do i
            img = collect(1:n)
            img[i] = i + 1
            img[i+1] = i + 2
            img[i+2] = i
            return CGT.Permutation(img)
        end
        @test CGT.schreier_sims(S) isa CGT.PointStabilizer
        @test _ord(CGT.schreier_sims(S)) == 60
        @test _ord(CGT.schreier_sims(reverse(S))) == 60
    end

    @testset "Small examples" begin
        a = CGT.Permutation([3, 4, 5, 6, 7, 8, 1, 2])
        b = CGT.Permutation([3, 2, 8, 5, 7, 6, 4, 1])

        @test CGT.schreier_sims([a, b]) isa CGT.PointStabilizer

        @test _ord(CGT.schreier_sims([a, b])) == 24
        @test _ord(CGT.schreier_sims([b, a])) == 24

        C₂wrSym₄ =
            CGT.Permutation.([
                [1, 9, 3, 11, 5, 13, 7, 15, 2, 10, 4, 12, 6, 14, 8],
                [1, 2, 3, 4, 9, 10, 11, 12, 5, 6, 7, 8],
                [1, 2, 5, 6, 3, 4, 7, 8, 9, 10, 13, 14, 11, 12],
                [16, 8, 14, 6, 12, 4, 10, 2, 15, 7, 13, 5, 11, 3, 9, 1],
                [3, 11, 1, 9, 7, 15, 5, 13, 4, 12, 2, 10, 8, 16, 6, 14],
            ])

        @test _ord(CGT.schreier_sims(C₂wrSym₄)) == 384
        @test _ord(CGT.schreier_sims(reverse(C₂wrSym₄))) == 384
    end

    if isdefined(CGT, Symbol("@perm_str"))
        include("schreier_sims_perm_str.jl")
    end
end
