. $PSScriptRoot\beginner.ps1
Describe "Test Add-EvenNumbersCStyleForLoop" {
    It "Edge Case Last=2 -> 2=2" {
        Add-EvenNumbersCStyleForLoop -Last 2 | Should -Be 2
    }
    It "Last = 4 -> 2+4=6" {
        Add-EvenNumbersCStyleForLoop -Last 10 | Should -Be 30
    }
    It "Last = 10 -> 2+4+6+8+10=30" {
        Add-EvenNumbersCStyleForLoop -Last 100 | Should -Be 2550
    }
}
Describe "Test Add-GaußIncrement2" {
    It "Edge Case Last=2 -> 2=2" {
        Add-GaußIncrement2 -Last 2 | Should -Be 2
    }
    It "Last = 4 -> 2+4=6" {
        Add-GaußIncrement2 -Last 10 | Should -Be 30
    }
    It "Last = 10 -> 2+4+6+8+10=30" {
        Add-GaußIncrement2 -Last 100 | Should -Be 2550
    }
}
Describe "Test Add-GaußIncrement2b" {
    It "Edge Case Last=2 -> 2=2" {
        Add-GaußIncrement2b -Last 2 | Should -Be 2
    }
    It "Last = 4 -> 2+4=6" {
        Add-GaußIncrement2 -Last 10 | Should -Be 30
    }
    It "Last = 10 -> 2+4+6+8+10=30" {
        Add-GaußIncrement2b -Last 100 | Should -Be 2550
    }
}
Describe "Test Add-GaußIncrement2Bitwise" {
    It "Edge Case Last=2 -> 2=2" {
        Add-GaußIncrement2Bitwise -Last 2 | Should -Be 2
    }
    It "Last = 4 -> 2+4=6" {
        Add-GaußIncrement2Bitwise -Last 10 | Should -Be 30
    }
    It "Last = 10 -> 2+4+6+8+10=30" {
        Add-GaußIncrement2Bitwise -Last 100 | Should -Be 2550
    }
}

"Checkout runtimes"
$Interations = 10000
$Last = 30000
"Add-EvenNumbersCStyleForLoop       {0:n2} seconds" -f (Measure-Command { (1..$Interations) | ForEach-Object { Add-EvenNumbersCStyleForLoop $Last } }).TotalSeconds
"Add-GaußIncrement2          {0:n2} seconds" -f (Measure-Command { (1..$Interations) | ForEach-Object { Add-GaußIncrement2 $Last } }).TotalSeconds
"Add-GaußIncrement2b         {0:n2} seconds" -f (Measure-Command { (1..$Interations) | ForEach-Object { Add-GaußIncrement2b $Last } }).TotalSeconds
"Add-GaußIncrement2Bitwise   {0:n2} seconds" -f (Measure-Command { (1..$Interations) | ForEach-Object { Add-GaußIncrement2Bitwise $Last } }).TotalSeconds
