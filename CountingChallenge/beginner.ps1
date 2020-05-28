# Approche 1: C-style for
function SumEvenNumbersCStyleForLoop {
    param (
        [Parameter(Position=0)]
        [int] $Last
    )

    [int] $sum = 0
    for ( $i = 2; $i -le $Last; $i = $i + 2 ) {
        $sum = $sum + $i
    }
    $sum
}

# Approche 2 : The Gauß Way
# This is the derived Gauß formular for the Numbers starting from 2
function SumGaußIncrement2Call {
    param (
        [Parameter(Position=0)]
        [int] $Last
    )
    function Gauß {
        param (
            [Parameter(Position=0)]
            [int] $Last
        )

        [int] $sum = $Last*($Last+1)/2
        $sum
    }

    [int] $sum = (Gauß ($last / 2) )*2
    $sum
}

# The same, but without the overhead of calling the function
function SumGaußIncrement2b {
    param (
        [Parameter(Position=0)]
        [int] $Last
    )

    [int] $sum = ( ($last / 2)*($last / 2 + 1)/2 ) *2
    $sum
}

# Just for fun, the same, but replacing mutiplication and division by 2 by using bitwise shifting
function SumGaußIncrement2Bitwise {
    param (
        [Parameter(Position=0)]
        [int] $Last
    )

    [int] $sum = ( ($last -shr 1)* ( ($last -shr 1) + 1) -shr 1 ) -shl 1
    $sum
}

# Approche 3: slowly going the Gauß Way
function SumGoingTheGaußWaySlowly {
    param (
        [Parameter(Position=0)]
        [int] $Last
    )

    $numbers = [int[]]::new($Last/2)
    [int] $nextEvenNumber = 2
    # Create the array of even numbers
    for ( $i = 0; $i -lt $Last/2; $i++) {
        $numbers[$i] = $nextEvenNumber
        $nextEvenNumber = $nextEvenNumber + 2
    }
    # now pick the first and the last, the second and second last, ...
    [int] $sum = 0
    [int] $lPick = 0                # Index to pick from the left
    [int] $rPick = ($Last / 2)-1    # Index to pick from the right
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