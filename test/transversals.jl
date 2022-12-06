@testset "Transversals" begin
    S = [CGT.Permutation([2, 3, 4, 1]), CGT.Permutation([1, 2, 3, 5, 4])]

    pt = 1
    tr = CGT.Transversal(pt, S[1])
    @test tr isa CGT.AbstractTransversal{Int,CGT.Permutation}
    @test length(tr) == 4
    @test first(tr) == pt
    @test Set(collect(tr)) == Set([1, 2, 3, 4])
    @test pt in tr
    @test 2 in tr
    @test (5 in tr) == false
    @test tr[pt] == one(S[1])
    @test tr[2] == S[1]
    @test tr[3] == S[1]^2

    @test_throws CGT.NotInOrbit tr[5]

    tr0 = CGT.Transversal(pt, [S[2]])
    @test length(tr0) == 1
    @test first(tr0) == pt
    @test tr0[1] == one(S[2])

    tr1 = CGT.Transversal(pt, S)
    @test tr1 isa CGT.AbstractTransversal{Int,CGT.Permutation}
    @test length(tr1) == 5
    @test first(tr1) == pt
    @test Set(collect(tr1)) == Set(1:5)
    @test 5 in tr1
    @test tr1[5] isa CGT.Permutation

    for i in 1:5
        @test i in tr1
        @test first(tr1)^tr1[i] == i
    end
end
