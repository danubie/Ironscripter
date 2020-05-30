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

.EXAMPLE
Get-ChildItem -Path . -File | Get-ObjectAge
Outputs the age, CreationTime, ModificationTime and averageindicator for all files in the current directory

.NOTES
General notes
#>
function Get-ObjectAge {
    [CmdletBinding()]
    param (
        # Any Input object to get an anti-aging check
        [Parameter(Position=0, ValueFromPipeline, ValueFromPipelineByPropertyName, Mandatory=$true)]
        [System.Object[]] $InputObject,
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [Alias('CreationTime','CreationDate','StartTime','ExitTime','Created')]
        $CreateDateProperty,
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('LastWriteTime','Modified')]
        $ModifyDateProperty,    # I do allow NULL here if there's an object with just one date
        [string[]] $Property            # list of properties to be added to the output
    )

    begin {
        function Add-ValueFromPropertyOrPipeline {
            # dirty little helper to use either the $item.$propertyname or $value depending on useValue
            param (
                [Parameter(Position=0)]
                $HashTable,
                [Parameter(Position=1)]
                $PropertyName,
                [Parameter(Position=2)]
                $Item,
                [Parameter(Position=3)]
                $ValueOrPropertyName,
                [Parameter(Position=4)]
                [switch] $useAsValue,
                [Parameter(Position=5)]
                [switch] $CastAsDateTime
            )
            if ( $useAsValue ) {
                $value = $ValueOrPropertyName
            } else {
                $value = $Item.$ValueOrPropertyName
            }
            if ( $CastAsDateTime -and ($null -eq $value -or "" -eq $value) ) {
                $HashTable.Add( $PropertyName, $null )
            } elseif ( $CastAsDateTime ) {
                $HashTable.Add( $PropertyName, [datetime] $value )
            } else {    # keep the original type
                $HashTable.Add( $PropertyName, $value )
            }
        }

        $queue = [System.Collections.Queue]::new()
        # check if the property names are via commandline or if we have piped values
        #   a mandatory parameter via pipeline is validated by PS with each object coming from the pipeline
        #   but it's value from the command line is empty or null as long as you do not use defaults
        $isPipeline = ($CreateDateProperty -eq '' -or $null -eq $CreateDateProperty)
    }

    process {
        foreach ($obj in $InputObject) {
            $objHash = [ordered] @{
                AboveAvg    = $false
                Age         = $null
            }
            # services starttime can be null. Are the running since the big bang?  8-)
            Add-ValueFromPropertyOrPipeline $objHash 'CreationTime'     $obj $CreateDateProperty $isPipeline -CastAsDateTime
            Add-ValueFromPropertyOrPipeline $objHash 'TimeLastModified' $obj $ModifyDateProperty $isPipeline -CastAsDateTime
            if ( $null -ne $objHash.CreationTime ) {
                $objHash.Age = [timespan] ( (Get-Date).Subtract($objHash.CreationTime) )
            }
            # Add addional properties
            foreach ($propName in $Property) {
                Add-ValueFromPropertyOrPipeline $objHash $propName $obj ($obj.$propName) $true
            }
            $obj = [PSCustomObject] $objHash
            $queue.Enqueue( $obj )
        }
    }

    end {
        $avgCreatedate = $queue.CreationTime.Ticks | Measure-Object -Average
        foreach ($obj in $queue) {
            if ( $obj.CreationTime.Ticks -gt $avgCreatedate.Average ) { $obj.AboveAvg = $true }
            $obj
        }
    }
}