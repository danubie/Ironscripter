# A PowerShell counting challenge (2020-05-11)

## Beginner
The challenge:\
Get the sum of the even numbers between 1 and 100. You should be able to do this in at least 3 different ways. Show all 3 ways. You don’t need to write any functions or scripts
### Approche #1 : The C-style for loop
A long time ago I wrote an uncounted amount of C-code. Thanks to PowerShells idea to "get the good from all" languages, the good old C-style FOR-loop is still a valid language construct.\
One possible solution would be to loop from 1 to 100 and check whether or not a number is even and than add it to the sum.\
The C-style FOR allows to specify an increment of 2, so I don't have to check for even and simply sum up.

    [int] $sum = 0
    for ( $i = 2; $i -le $Last; $i = $i + 2 ) {
        $sum = $sum + $i
    }

### Approche #2 : The Gauß Way
This is the a variety of the Gauß formula to sum the natural numbers from 1 to n: `sum = n*(n+1)/2`\
Because it's only to count the even numbers, which in fact is every second number, I'm using the orginal formula (including the odd ones) and divide the result by 2.\
To make it look less mathematical and more technical instead, multiplying and dividing by 2 is replaced by bitwise shifting by 1.

    [int] $sum = ( ($last -shr 1)* ( ($last -shr 1) + 1) -shr 1 ) -shl 1

### Approche #3 : Going The Gauß Way Slowly
The simplicity of Gauß' formula - as far as I understood from school - relies on the fact, that the sum of two adjacent numbers is 101.\
If you think of writing down the numbers 1, 2, 3, .... 98, 99, 100. Now each pair (1 & 100, 2 & 99, 3 & 98) sum up to 101.\
Having this, It's easy to see, that this is similar valid for 2, 4, 6 ... 96, 98, 100 as well. So my algorithm takes the first and the last number, the second last, and so on, to build the sum.

Preparing the array of numbers to sum

    $numbers = [int[]]::new($Last/2)
    [int] $nextEvenNumber = 2
    # Create the array of even numbers
    for ( $i = 0; $i -lt $Last/2; $i++) {
        $numbers[$i] = $nextEvenNumber
        $nextEvenNumber = $nextEvenNumber + 2
    }

and now pick from left and right in each iteration

    [int] $sum = 0
    [int] $lPick = 0                # Index to pick from the left
    [int] $rPick = ($Last / 2)-1    # Index to pick from the right
    while ( $lPick -lt $rPick ) {
        $sum = $sum + $numbers[$lPick] + $numbers[$rPick]
        $lPick++
        $rPick--
    }

and check the edge case of having an odd number of even numbers

    if ($lPick -eq $rPick) {
        $sum + $numbers[$lPick]
    } else {
        $sum
    }

## Intermediate
This one derives from Approche 3. So I'm building an array of numbers to be summed up according to the parameters. Using Measure-Object to return expected values.

    $measure = $numbers | Measure-Object -AllStats
    $measure | Select-Object -Property Sum, Average

## Bonus
Intermediate almost was there. Now returns a pscustomobject with 3 properties

    $measure = $numbers | Measure-Object -AllStats
    [PSCustomObject] @{
        Sum     = $measure.Sum
        Average = $measure.Average
        Values  = $numbers
    }

# Pester tests
I love to write Pester tests, so I could not resist to do it here as well.\
By using Pester, it was easy to validate the function results (against values calculated through som Excel formulas.