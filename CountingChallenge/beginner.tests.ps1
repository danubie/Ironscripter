. $PSScriptRoot\beginner.ps1
Describe "Test SumEvenNumbersCStyleForLoop" {
    It "Edge Case Last=2 -> 2=2" {
        SumEvenNumbersCStyleForLoop -Last 2 | Should -Be 2
    }
    It "Last = 10 -> 2+4+6+8+10=30" {
        SumEvenNumbersCStyleForLoop -Last 10 | Should -Be 30
    }
    It "Last = 100 -> 2+4+6+8+10..100=2550" {
        SumEvenNumbersCStyleForLoop -Last 100 | Should -Be 2550
    }
}

Describe "Test SumGaußIncrement2" {
    It "Edge Case Last=2 -> 2=2" {
        SumGaußIncrement2 -Last 2 | Should -Be 2
    }
    It "Last = 10 -> 30" {
        SumGaußIncrement2 -Last 10 | Should -Be 30
    }
    It "Last = 100 -> 2550" {
        SumGaußIncrement2 -Last 100 | Should -Be 2550
    }
}

Describe "Test SumGaußIncrement2b" {
    It "Edge Case Last=2 -> 2=2" {
        SumGaußIncrement2b -Last 2 | Should -Be 2
    }
    It "Last = 10 -> 30" {
        SumGaußIncrement2 -Last 10 | Should -Be 30
    }
    It "Last = 100 -> 2550" {
        SumGaußIncrement2b -Last 100 | Should -Be 2550
    }
}

Describe "Test SumGaußIncrement2Bitwise" {
    It "Edge Case Last=2 -> 2=2" {
        SumGaußIncrement2Bitwise -Last 2 | Should -Be 2
    }
    It "Last = 10 -> 30" {
        SumGaußIncrement2Bitwise -Last 10 | Should -Be 30
    }
    It "Last = 100 -> 2550" {
        SumGaußIncrement2Bitwise -Last 100 | Should -Be 2550
    }
}

"Checkout runtimes"
$Interations = 10000
$Last = 30000
"SumEvenNumbersCStyleForLoop       {0:n2} seconds" -f (Measure-Command { (1..$Interations) | ForEach-Object { SumEvenNumbersCStyleForLoop $Last } }).TotalSeconds
"SumGaußIncrement2          {0:n2} seconds" -f (Measure-Command { (1..$Interations) | ForEach-Object { SumGaußIncrement2 $Last } }).TotalSeconds
"SumGaußIncrement2b         {0:n2} seconds" -f (Measure-Command { (1..$Interations) | ForEach-Object { SumGaußIncrement2b $Last } }).TotalSeconds
"SumGaußIncrement2Bitwise   {0:n2} seconds" -f (Measure-Command { (1..$Interations) | ForEach-Object { SumGaußIncrement2Bitwise $Last } }).TotalSeconds
