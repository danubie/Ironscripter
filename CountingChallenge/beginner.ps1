# Approche 1: C-style for
function Add-EvenNumbersCStyleForLoop {
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
function Add-GaußIncrement2 {
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
function Add-GaußIncrement2b {
    param (
        [Parameter(Position=0)]
        [int] $Last
    )

    [int] $sum = ( ($last / 2)*($last / 2 + 1)/2 ) *2
    $sum
}

# Just for fun, the same, but replacing mutiplication and division by 2 by using bitwise shifting
function Add-GaußIncrement2Bitwise {
    param (
        [Parameter(Position=0)]
        [int] $Last
    )

    [int] $sum = ( ($last -shr 1)* ( ($last -shr 1) + 1) -shr 1 ) -shl 1
    $sum
}
