<#
.SYNOPSIS
The function checks arbitrary input objects for creation date

.DESCRIPTION
Get-ObjectAge manages to check the creation date of any different type of objects.
It calculats the age of the obeject as well as an indicator whether the objects age is above the average within the
group of objects.

.PARAMETER InputObject
Array of objects to be checked.

.PARAMETER CreateDateProperty
Name of the property containing the creation date.

.PARAMETER ModifyDateProperty
Name of the property containing the last modified date.

.PARAMETER Property
Array of strings each will be considered as an attribute of the objects. Each of these attributes are returned with
the general result for each object

.RETURNS
returns a custom object containing the age, the flag "above average", the creation+modification date of the object
and eventually additional properties of the inpt object

.EXAMPLE
$hash = @{
            CreateDateProperty  = 'CreationTime'
            ModifyDateProperty  = 'LastWriteTime'
            Property = @('Name','Length','IsReadOnly')
        }
        $ret = Get-ChildItem -Path 'TestDrive:\' | Get-ObjectAge @hash
Checks file dates (create+modified) of all files in the current directory

.EXAMPLE
$IdentityList | ForEachObject { Get-ADUser -Identity $_ -Properties lastLogon | Get-ObjectAge -CreateDateProperty 'lastLogon' }
Checks the lastlogon date of a list of AD-Accounts via pipeline input

.NOTES
General notes
#>
function Get-ObjectAge {
    [CmdletBinding()]
    param (
        # Any Input object to get an anti-aging check
        [Parameter(Position=0, ValueFromPipeline, ValueFromPipelineByPropertyName, Mandatory=$true)]
        [System.Object[]] $InputObject,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $CreateDateProperty,
        [string] $ModifyDateProperty,    # I do allow NULL here if there's an object with just one date
        [string[]] $Property            # list of properties to be added to the output
    )

    begin {
        $queue = [System.Collections.Queue]::new()
    }

    process {
        foreach ($item in $InputObject) {
            $objHash = [ordered] @{
                AboveAvg    = $false
                Age         = $null
            }
            # services starttime can be null. Are the running since the big bang?  8-)
            if ($CreateDateProperty -ne "" -and $null -ne $item.$CreateDateProperty ) {
                $objHash.Add( $CreateDateProperty, [datetime] $item.$CreateDateProperty )
                $objHash.Age = (Get-Date).Subtract( [datetime] $item.$CreateDateProperty )
            } else {
                $objHash.Add( $CreateDateProperty, $null)
            }
            # ModifyProperty specified and must exist
            if ($ModifyDateProperty -ne "" -and $null -ne $item.$ModifyDateProperty ) {
                $objHash.Add( $ModifyDateProperty, [datetime] $item.$ModifyDateProperty )
            } else {
                if ($ModifyDateProperty -ne "") { $objHash.Add( $ModifyDateProperty, $null) }
            }
            # Add addional properties
            foreach ($propName in $Property) {
                if ($propName -ne "" -and $null -ne $item.$propName ) {
                    $objHash.Add( $propName, $item.$propName )
                } else {
                    if ($propName -ne "") { $objHash.Add( $propName, $null) }
                }
            }
            $obj = [PSCustomObject] $objHash
            $queue.Enqueue( $obj )
        }
    }

    end {
        $avgCreatedate = $queue.$CreateDateProperty.Ticks | Measure-Object -Average
        foreach ($item in $queue) {
            if ( $item.$CreateDateProperty.Ticks -gt $avgCreatedate.Average ) { $item.AboveAvg = $true }
            $item
        }
    }
}