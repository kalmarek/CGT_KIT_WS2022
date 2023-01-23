@testset "LenLex" begin
    A = CGT.Alphabet([:a, :b, :A, :B])
    CGT.setinverse!(A, :a, :A)
    CGT.setinverse!(A, :b, :B)

    ord = CGT.LenLex(A, [:a, :A, :b, :B])

    @test ord isa Base.Order.Ordering

    u1 = CGT.Word([1, 2])    # ab
    u3 = CGT.Word([1, 3])    # aA
    u4 = CGT.Word([1, 2, 3]) # abA
    u5 = CGT.Word([1, 4, 2]) # aBb

    lt = Base.Order.lt

    @test lt(ord, u1, u1) == false

    @test lt(ord, u3, u1) == true # by the second letter
    @test lt(ord, u1, u3) == false

    @test lt(ord, u3, u4) == true # by length

    @test lt(ord, u4, u5) == true
    @test lt(ord, u5, u4) == false
end
