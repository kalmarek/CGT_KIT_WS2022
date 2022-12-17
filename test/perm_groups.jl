@testset "Permgroups" begin
    a = CGT.Permutation([2, 3, 1])
    b = CGT.Permutation([2, 1])
    G = CGT.PermutationGroup([a, b])
    @test CGT.gens(G) == [a, b]
    @test CGT.gens(G, 1) == a

    @test CGT.order(G) == 6
    @test CGT.order(G) isa BigInt
    @test CGT.order(Int, G) isa Int



    @test one(G) isa eltype(G)
    @test one(G) in G

    @test a in G
    @test !(CGT.Permutation([4, 2, 3, 1]) in G)

    @test rand(G) isa eltype(G)

    g = rand(G)
    @test g in G

    a = CGT.Permutation([3, 4, 5, 6, 7, 8, 1, 2])
    b = CGT.Permutation([3, 2, 8, 5, 7, 6, 4, 1])

    H = CGT.PermutationGroup([a, b])
    @test CGT.order(H) == 24

    # a product of 10 random generators of H
    g = prod(rand([a,b], 10))
    @test g in H

    v = rand(H, 10)
    @test all(∈(H), v)
    @test prod(v) in H

    g = CGT.Permutation([2, 1])
    @test !(g in H)
    @test !(any(∈(H), Ref(g) .* v))
end

@testset "perm_from_images" begin
    a = CGT.Permutation([2, 3, 1])
    b = CGT.Permutation([2, 1])
    G = CGT.PermutationGroup([a, b])

    @test CGT.basis(G) == [1, 2]

    β = CGT.basis(G)
    img = [3, 2]
    # we're searching for g such that
    sc = CGT.stabilizer_chain(G)
    g = CGT.perm_from_images(sc, img)

    @test g in G
    @test β[1]^g == img[1]
    @test β[2]^g == img[2]

    @test isone(CGT.perm_from_images(sc, β))

    g = CGT.perm_from_images(sc, [3])
    @test g in G
    @test β[1]^g == 3

    # throw here
    @test_throws ArgumentError CGT.perm_from_images(
        sc,
        [4],
    )
    @test_throws ArgumentError CGT.perm_from_images(
        sc,
        [3, 2, 4],
    )
    @test_throws ArgumentError CGT.perm_from_images(
        sc,
        [2, 2],
    )
end
