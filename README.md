# Ironscripter
From time to time I will participate the Ironscripter challenges

# A PowerShell counting challenge (2020-05-11)

## Beginner
The challenge:\
Get the sum of the even numbers between 1 and 100. You should be able to do this in at least 3 different ways. Show all 3 ways. You don’t need to write any functions or scripts
### Approche #1 : The C-style for loop
A long time ago I wrote an uncounted amount of C-code. Thanks to PowerShells idea to "get the good from all" languages, the good old C-style FOR-loop is still a valid language construct.\
One possible solution would be to loop from 1 to 100 and check whether or not a number is even and than add it to the sum.\
The C-style FOR allows to specify an increment of 2, so I don't have to check for even and simply sum up.
```
    [int] $sum = 0
    for ( $i = 2; $i -le $Last; $i = $i + 2 ) {
        $sum = $sum + $i
    }
```
### Approche #2 : The Gauß Way
This is the a variety of the Gauß formula to sum the natural numbers from 1 to n: `sum = n*(n+1)/2`\
Because it's only to count the even numbers, which in fact is every second number, we'll end up in counting have the numbers from 1 to 100. So I'm using the orginal formula and divide the result by 2.\
To make it look less mathematical and more technical instead of multiplying and dividing by 2 I use bitwise shifting.
```
    [int] $sum = ( ($last -shr 1)* ( ($last -shr 1) + 1) -shr 1 ) -shl 1
```

### Approche #3 : Slowly Going The Gauß Way
The simplicity of Gauß' formula - as far as I understood from school - relies on the fact, that the sum of two adjacent numbers is 101.\
If you think of writing down the numbers 1, 2, 3, .... 98, 99, 100. Now each pair (1 & 100, 2 & 99, 3 & 98) sum up to 101.\
Having this, It's easy to see, that this is similar valid for 2, 4, 6 ... 96, 98, 100 as well. So my algorithm takes the first and the last number, the second last, and so on, to build the sum.

### Pester tests
I love to write Pester tests, so I could not resist to do it here as well.\
By using Pester, it was easy to validate my results.