. $PSScriptRoot\Bonus.ps1

Describe "Test Bonus" {
    It "Start 3, Maximum = 10, Increment = 2 -> Sum=3, Avg=1,5, @(3, 5, 7, 9)" {
        $result = Bonus -Start 3 -Maximum 10 -Increment 2
        $result.Sum     | Should -Be 24
        $result.Average | Should -Be 6
        $result.Values  | Should -Be (3,5,7,9)
    }
    It "Invalid increment should Throw" {
        { Bonus -Start 1 -Maximum 512 -Increment 11 } | Should -Throw "Cannot validate argument on parameter 'Increment'" -Because "Increment now is limited"
        { Bonus -Start 1 -Maximum 512 -Increment 0  } | Should -Throw "Cannot validate argument on parameter 'Increment'" -Because "Increment must be greater than 0"
    }
}
