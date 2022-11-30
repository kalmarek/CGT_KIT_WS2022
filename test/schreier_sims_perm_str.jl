@testset "perm examples" begin
    S = [
        perm"(1,2,5,8)(3,14,10,6)(4,7,12,16)(9,21,18,13)(11,15,19,22)(17,24,23,20)",
        perm"(1,3,5,10)(2,6,8,14)(4,9,12,18)(7,13,16,21)(11,17,19,23)(15,20,22,24)",
        perm"(1,4,11)(2,7,15)(3,9,17)(5,12,19)(6,13,20)(8,16,22)(10,18,23)(14,21,24)",
        perm"(1,5)(2,8)(3,10)(4,12)(6,14)(7,16)(9,18)(11,19)(13,21)(15,22)(17,23)(20,24)",
    ]

    @test _ord(CGT.schreier_sims(S)) == 24
    @test _ord(CGT.schreier_sims(reverse(S))) == 24

    cube222 = [
        perm"(1,2,3,4)(5,17,13,9)(6,18,14,10)"
        perm"(5,6,7,8)(1,9,21,19)(4,12,24,18)"
        perm"(13,14,15,16)(2,20,22,10)(3,17,23,11)"
        perm"(9,10,11,12)(4,13,22,7)(3,16,21,6)"
        perm"(17,18,19,20)(1,8,23,14)(2,5,24,15)"
        perm"(21,22,23,24)(11,15,19,7)(12,16,20,8)"
    ]

    @test _ord(CGT.schreier_sims(cube222)) == 88_179_840
    @test _ord(CGT.schreier_sims(reverse(cube222))) == 88_179_840

    S16 = [
        perm"(1,2,3,4)",
        perm"(5,6,7,8)",
        perm"(9,10,11,12)",
        perm"(13,14,15,16)",
        perm"(1,5,9,13)",
        perm"(2,6,10,14)",
        perm"(3,7,11,15)",
        perm"(4,8,12,16)",
    ]

    @test _ord(CGT.schreier_sims(S16)) == factorial(16)
    @test _ord(CGT.schreier_sims(reverse(S16))) == factorial(16)

    cube333 = [
        perm"(1,3,8,6)(2,5,7,4)(9,33,25,17)(10,34,26,18)(11,35,27,19)",
        perm"(9,11,16,14)(10,13,15,12)(1,17,41,40)(4,20,44,37)(6,22,46,35)",
        perm"(17,19,24,22)(18,21,23,20)(6,25,43,16)(7,28,42,13)(8,30,41,11)",
        perm"(25,27,32,30)(26,29,31,28)(3,38,43,19)(5,36,45,21)(8,33,48,24)",
        perm"(33,35,40,38)(34,37,39,36)(3,9,46,32)(2,12,47,29)(1,14,48,27)",
        perm"(41,43,48,46)(42,45,47,44)(14,22,30,38)(15,23,31,39)(16,24,32,40)",
    ]

    @test _ord(BigInt, CGT.schreier_sims(cube333)) == 43_252_003_274_489_856_000
    @test _ord(BigInt, CGT.schreier_sims(reverse(cube333))) ==
          43_252_003_274_489_856_000
    @time CGT.schreier_sims(cube333)
end