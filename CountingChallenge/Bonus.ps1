# derived from the beginner
# defaults represent the beginners challenge
function Bonus {
    param (
        [Parameter(Position = 0)]
        [int] $Start = 2,
        [Parameter(Position = 1)]
        [int] $Maximum = 100,
        [Parameter(Position = 2)]
        [ValidateRange(1, 10)]
        [int] $Increment = 2
    )

    $last = [math]::Truncate( ( $Maximum - $Start ) / $Increment )
    $numbers = [int[]]::new( $last + 1 )
    [int] $nextNumber = $Start
    # Create the array of even numbers
    for ( $i = 0; $i -le $Last; $i++) {
        $numbers[$i] = $nextNumber
        $nextNumber = $nextNumber + $Increment
    }
    $measure = $numbers | Measure-Object -AllStats
    [PSCustomObject] @{
        Sum     = $measure.Sum
        Average = $measure.Average
        Values  = $numbers
    }
}