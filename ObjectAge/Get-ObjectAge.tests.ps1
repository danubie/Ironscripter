. $PSScriptRoot\Get-ObjectAge.ps1

Describe "Simple tests using get-date" {
    It "single object, no Modifydate" {
        $now = (Get-Date)
        $ret = $now | Get-ObjectAge -CreateDateProperty 'Ticks'
        # $ret | Should -Be $now seems to be not correct
        ($ret.Ticks -eq $now) | Should -BeTrue
    }
    It "single object invalid modifydateproperty should be silently ignored" {
        $now = (Get-Date)
        $ret = $now | Get-ObjectAge -CreateDateProperty 'Ticks' -ModifyDateProperty 'Unknown'
        # $ret | Should -Be $now seems to be not correct
        ($ret.Ticks -eq $now) | Should -BeTrue
    }
    It "single object additonal properties" {
        $now = (Get-Date)
        $hash = @{
            CreateDateProperty  = 'Ticks'
            Property = @('Year','Month','Day')
        }
        $ret = $now | Get-ObjectAge @hash
        $ret.Year   | Should -Not -BeNullOrEmpty
        $ret.Month  | Should -Not -BeNullOrEmpty
        $ret.Day    | Should -Not -BeNullOrEmpty
    }
}
Describe "Testing with files" {
    It "array by pipeline" {
        # Arrange  testdata
        $file0 = New-Item -Path 'Testdrive:\File0' -ItemType File
        $file1 = New-Item -Path 'Testdrive:\File1' -ItemType File
        $file2 = New-Item -Path 'Testdrive:\File2' -ItemType File
        $file1.CreationTime = $file1.CreationTime.AddDays(-1)
        $file2.CreationTime = $file1.CreationTime.AddDays(-2)

        # Act testing
        $hash = @{
            CreateDateProperty  = 'CreationTime'
            ModifyDateProperty  = 'LastWriteTime'
            Property = @('Name','Length','IsReadOnly')
        }
        $ret = Get-ChildItem -Path 'TestDrive:\' | Get-ObjectAge @hash

        # Assert results
        $ret[0].CreationTime | Should -Be $file0.CreationTime
        $ret[1].CreationTime | Should -Be $file1.CreationTime
        $ret[2].CreationTime | Should -Be $file2.CreationTime
        $ret[0].AboveAvg | Should -Be $true
        $ret[1].AboveAvg | Should -Be $true
        $ret[2].AboveAvg | Should -Be $false
        # add properties
        $ret[0].Name        | Should -Be 'File0'
        $ret[0].Length      | Should -Be 0
        $ret[0].IsReadOnly  | Should -Be $false
    }
}


