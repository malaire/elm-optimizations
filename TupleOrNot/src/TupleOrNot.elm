module TupleOrNot exposing (main, tests)

import Benchmark
import Benchmark.Runner exposing (BenchmarkProgram, program)
import Bitwise
import Expect
import Test


main : BenchmarkProgram
main =
    program <|
        Benchmark.compare "TupleOrNot"
            "TypeA Int Int Int"
            (\_ -> runA oneA seedA zeroA)
            "TypeB ( Int, Int, Int )"
            (\_ -> runB oneB seedB zeroB)


tests : Test.Test
tests =
    Test.describe "Tests"
        [ Test.test "runA" <|
            \_ -> runA oneA seedA zeroA |> Expect.equal (newA 34713 52205 4018377)
        , Test.test "runB" <|
            \_ -> runB oneB seedB zeroB |> Expect.equal (newB 34713 52205 4018377)
        ]



-- runA


runA : TypeA -> TypeA -> TypeA -> TypeA
runA index prev sum =
    if equalA index indexLimitA then
        addA sum prev

    else
        let
            next =
                shiftRightZfByA 62 prev
                    |> xorA prev
                    |> mulA multiplierA
                    |> addA index
        in
        runA (addA index oneA) next (addA sum prev)


indexLimitA : TypeA
indexLimitA =
    newA 0 0 312


multiplierA : TypeA
multiplierA =
    newA 0x5851 0x00F42D4C 0x00957F2D


seedA : TypeA
seedA =
    newA 0 0x01 0x002BD6AA



-- runB


runB : TypeB -> TypeB -> TypeB -> TypeB
runB index prev sum =
    if equalB index indexLimitB then
        addB sum prev

    else
        let
            next =
                shiftRightZfByB 62 prev
                    |> xorB prev
                    |> mulB multiplierB
                    |> addB index
        in
        runB (addB index oneB) next (addB sum prev)


indexLimitB : TypeB
indexLimitB =
    newB 0 0 312


multiplierB : TypeB
multiplierB =
    newB 0x5851 0x00F42D4C 0x00957F2D


seedB : TypeB
seedB =
    newB 0 0x01 0x002BD6AA



-- TypeA


type TypeA
    = TypeA Int Int Int


addA : TypeA -> TypeA -> TypeA
addA (TypeA highX midX lowX) (TypeA highY midY lowY) =
    let
        low =
            lowX + lowY

        mid =
            if low < limit24 then
                midX + midY

            else
                midX + midY + 1

        high =
            if mid < limit24 then
                highX + highY

            else
                highX + highY + 1
    in
    TypeA (Bitwise.and max16 high) (Bitwise.and max24 mid) (Bitwise.and max24 low)


equalA : TypeA -> TypeA -> Bool
equalA (TypeA highX midX lowX) (TypeA highY midY lowY) =
    lowX == lowY && midX == midY && highX == highY


mulA : TypeA -> TypeA -> TypeA
mulA (TypeA highX midX lowX) (TypeA highY midY lowY) =
    let
        lowFull =
            lowX * lowY

        lowCarry =
            Basics.floor <| Basics.toFloat lowFull / limit24

        low =
            lowFull - lowCarry * limit24

        midFull =
            lowCarry + lowX * midY + midX * lowY

        midCarry =
            Basics.floor <| Basics.toFloat midFull / limit24

        mid =
            midFull - midCarry * limit24

        high =
            Bitwise.and max16 (midCarry + lowX * highY + midX * midY + highX * lowY)
    in
    TypeA high mid low


newA : Int -> Int -> Int -> TypeA
newA high mid low =
    TypeA (Bitwise.and max16 high) (Bitwise.and max24 mid) (Bitwise.and max24 low)


oneA : TypeA
oneA =
    TypeA 0 0 1


shiftRightZfByA : Int -> TypeA -> TypeA
shiftRightZfByA givenShift (TypeA high _ _) =
    let
        n =
            Bitwise.and 0x3F givenShift
    in
    if n < 48 then
        -- doesn't need to be implemented for this test
        TypeA 0 0 0

    else
        -- n < 64
        TypeA 0 0 (Bitwise.shiftRightZfBy (n - 48) high)


xorA : TypeA -> TypeA -> TypeA
xorA (TypeA highX midX lowX) (TypeA highY midY lowY) =
    TypeA (Bitwise.xor highX highY) (Bitwise.xor midX midY) (Bitwise.xor lowX lowY)


zeroA : TypeA
zeroA =
    TypeA 0 0 0



-- TypeB


type TypeB
    = TypeB ( Int, Int, Int )


addB : TypeB -> TypeB -> TypeB
addB (TypeB ( highX, midX, lowX )) (TypeB ( highY, midY, lowY )) =
    let
        low =
            lowX + lowY

        mid =
            if low < limit24 then
                midX + midY

            else
                midX + midY + 1

        high =
            if mid < limit24 then
                highX + highY

            else
                highX + highY + 1
    in
    TypeB ( Bitwise.and max16 high, Bitwise.and max24 mid, Bitwise.and max24 low )


equalB : TypeB -> TypeB -> Bool
equalB (TypeB ( highX, midX, lowX )) (TypeB ( highY, midY, lowY )) =
    lowX == lowY && midX == midY && highX == highY


mulB : TypeB -> TypeB -> TypeB
mulB (TypeB ( highX, midX, lowX )) (TypeB ( highY, midY, lowY )) =
    let
        lowFull =
            lowX * lowY

        lowCarry =
            Basics.floor <| Basics.toFloat lowFull / limit24

        low =
            lowFull - lowCarry * limit24

        midFull =
            lowCarry + lowX * midY + midX * lowY

        midCarry =
            Basics.floor <| Basics.toFloat midFull / limit24

        mid =
            midFull - midCarry * limit24

        high =
            Bitwise.and max16 (midCarry + lowX * highY + midX * midY + highX * lowY)
    in
    TypeB ( high, mid, low )


newB : Int -> Int -> Int -> TypeB
newB high mid low =
    TypeB ( Bitwise.and max16 high, Bitwise.and max24 mid, Bitwise.and max24 low )


oneB : TypeB
oneB =
    TypeB ( 0, 0, 1 )


shiftRightZfByB : Int -> TypeB -> TypeB
shiftRightZfByB givenShift (TypeB ( high, _, _ )) =
    let
        n =
            Bitwise.and 0x3F givenShift
    in
    if n < 48 then
        -- doesn't need to be implemented for this test
        TypeB ( 0, 0, 0 )

    else
        -- n < 64
        TypeB ( 0, 0, Bitwise.shiftRightZfBy (n - 48) high )


xorB : TypeB -> TypeB -> TypeB
xorB (TypeB ( highX, midX, lowX )) (TypeB ( highY, midY, lowY )) =
    TypeB ( Bitwise.xor highX highY, Bitwise.xor midX midY, Bitwise.xor lowX lowY )


zeroB : TypeB
zeroB =
    TypeB ( 0, 0, 0 )



-- SHARED CONSTANTS


limit24 : number
limit24 =
    0x01000000


limit48 : number
limit48 =
    0x0001000000000000


max16 : number
max16 =
    0xFFFF


max24 : number
max24 =
    0x00FFFFFF
