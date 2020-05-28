. $PSScriptRoot\Intermediate.ps1

Describe "Test Intermediate" {
    It "Start 1, Maximum = 512(->509), Increment = 4 -> 32640 (""The Intermediate"")" {
        $result = Intermediate -Start 1 -Maximum 512 -Increment 4
        $result.Sum     | Should -Be 32640
        $result.Average | Should -Be 255
    }
}
