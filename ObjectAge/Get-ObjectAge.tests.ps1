. $PSScriptRoot\Get-ObjectAge.ps1

Describe "Simple tests using get-date" {
    It "single object, no Modifydate" {
        $now = (Get-Date)
        $ret = $now | Get-ObjectAge -CreateTimeProperty 'Ticks'
        # $ret | Should -Be $now seems to be not correct
        ($ret.CreationTime -eq $now.Ticks) | Should -BeTrue
        $ret.Age | Should -BeGreaterThan 0
    }
    It "single object invalid modifydateproperty should be silently ignored" {
        $now = (Get-Date)
        $ret = $now | Get-ObjectAge -CreateTimeProperty 'Ticks' -ModifyTimeProperty 'Unknown'
        # $ret | Should -Be $now seems to be not correct
        ($ret.CreationTime -eq $now.Ticks) | Should -BeTrue
    }
    It "single object additonal properties" {
        $now = (Get-Date)
        $hash = @{
            CreateTimeProperty  = 'Ticks'
            Property = @('Year','Month','Day')
        }
        $ret = $now | Get-ObjectAge @hash
        $ret.Year   | Should -Be $now.Year
        $ret.Month  | Should -Be $now.Month
        $ret.Day    | Should -Be $now.Day
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
            CreateTimeProperty  = 'CreationTime'
            ModifyTimeProperty  = 'LastWriteTime'
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
    It "Using Filedates from ValueFromPipelineByPropertyName" {
        $file0 = New-Item -Path 'Testdrive:\File0' -ItemType File -Force
        $ret = $file0 | Get-ObjectAge
    }
}

Describe "Testing with get-process" {
    It "Should check StartTime by Parameter (no access denied)" {
        $testProcess = Get-Process -name 'powershell' | Select-Object -First 1
        $ret = $testProcess | Get-ObjectAge -CreateTimeProperty 'StartTime'
        $ret.CreationTime | Should -Be ([datetime] $testProcess.StartTime)
    }
    It "Works by Pipeline (system processes break with access denied if nonadmin)" {
        $ret = Get-Process -name 'powershell' | Select-Object -First 1 | Get-ObjectAge
        $ret.CreationTime | Should -BeOfType [datetime]
    }
}

Describe "Testing with AD-User" {
    It "by property names" {
        $user = Get-ADUser -Identity $env:USERNAME -Properties Created, Modified
        $ret = $user | Get-ObjectAge -CreateTimeProperty 'Created' -ModifyTimeProperty 'Modified'
        $ret.CreationTime | Should -Be ([datetime] $user.Created)
    }
    It "by pipeline" {
        $ret = Get-ADUser -Identity $env:USERNAME -Properties Created, Modified | Get-ObjectAge
        $ret.CreationTime       | Should -BeOfType [datetime]
        $ret.TimeLastModified   | Should -BeOfType [datetime]
    }
}

