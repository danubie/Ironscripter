. $PSScriptRoot\Intermediate.ps1

Describe "Test SumGoingTheGaußWaySlowly2" {
    It "Edge Case Last=2 -> 2=2" {
        SumGoingTheGaußWaySlowly2 -Start 2 -Increment 2 -Maximum 2 | Should -Be 2
    }
    It "Start 2, Maximum = 100, Increment = 2 -> 2550" {
        SumGoingTheGaußWaySlowly2 | Should -Be 2550
    }
    It "Start 1, Maximum = 100, Increment = 1 -> 5050 (""The Original Gauß"")" {
        SumGoingTheGaußWaySlowly2 -Start 1 -Maximum 100 -Increment 1 | Should -Be 5050
    }
    It "Start 1, Maximum = 512(->509), Increment = 4 -> 32640 (""The Intermediate"")" {
        SumGoingTheGaußWaySlowly2 -Start 1 -Maximum 512 -Increment 4 | Should -Be 32640
    }
    It "Start 5, Maximum = 512(->509), Increment = 4 -> 32636 (""The Intermediate off by 1 number"")" {
        SumGoingTheGaußWaySlowly2 -Start 5 -Maximum 512 -Increment 4 | Should -Be ((SumGoingTheGaußWaySlowly2 -Start 1 -Maximum 512 -Increment 4) - 1)
    }
}
