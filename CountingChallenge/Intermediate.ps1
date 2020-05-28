# derived from the beginner
# defaults represent the beginners challenge
function SumGoingTheGaußWaySlowly2 {
    param (
        [Parameter(Position=0)]
        [int] $Start = 2,
        [Parameter(Position=1)]
        [int] $Maximum = 100,
        [Parameter(Position=2)]
        [int] $Increment = 2
    )

    $last = ( $Maximum - $Start )/$Increment
    $numbers = [int[]]::new(($Maximum - $Start + $Increment)/$Increment)
    [int] $nextNumber = $Start
    # Create the array of even numbers
    for ( $i = 0; $i -le $Last; $i++) {
        $numbers[$i] = $nextNumber
        $nextNumber = $nextNumber + $Increment
    }
    # now pick the first and the last, the second and second last, ...
    [int] $sum = 0
    [int] $lPick = 0                # Index to pick from the left
    [int] $rPick = $Last            # Index to pick from the right
    while ( $lPick -lt $rPick ) {
        $sum = $sum + $numbers[$lPick] + $numbers[$rPick]
        $lPick++
        $rPick--
    }
    # edge case: it was an odd number of even numbers :-)
    if ($lPick -eq $rPick) {
        $sum + $numbers[$lPick]
    } else {
        $sum
    }
}