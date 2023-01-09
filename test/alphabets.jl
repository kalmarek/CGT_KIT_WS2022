@testset "Alphabets" begin
    A = CGT.Alphabet([:a, :b, :c])
    @test A isa CGT.Alphabet{Symbol}
    @test A[1] == :a
    @test A[2] == :b
    @test A[3] == :c

    @test A[:a] == 1
    @test A[:b] == 2
    @test A[:c] == 3

    @test collect(A) isa Vector{Symbol}
    @test collect(A) == [:a, :b, :c]

    @test !CGT.hasinverse(A, :a)
    @test !CGT.hasinverse(A, :b)
    @test !CGT.hasinverse(A, :c)
    @test !CGT.hasinverse(A, 1)
    @test !CGT.hasinverse(A, 2)
    @test !CGT.hasinverse(A, 3)

    @test_throws ArgumentError inv(A, :a)
    @test_throws ArgumentError inv(A, :b)
    @test_throws ArgumentError inv(A, :c)
    @test_throws ArgumentError inv(A, :1)
    @test_throws ArgumentError inv(A, :2)
    @test_throws ArgumentError inv(A, :3)

    CGT.setinverse!(A, :a, :c)
    @test CGT.hasinverse(A, :a)
    @test !CGT.hasinverse(A, :b)
    @test CGT.hasinverse(A, :c)

    @test_throws AssertionError CGT.setinverse!(A, :a, :b)

    @test inv(A, :a) == :c
    @test inv(A, 1) == 3
    @test inv(A, :c) == :a
    @test inv(A, 3) == 1

    for l in A
        if CGT.hasinverse(A, l)
            @test inv(A, inv(A, l)) == l
        end
    end

    @test contains(sprint(show, A), "with inverse a")
end
