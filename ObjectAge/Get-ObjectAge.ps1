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
        [Parameter(Position=5)]
        $useAsValue
    )
    if ( $useAsValue -and $null -eq $Value ) {
        $HashTable.Add( $PropertyName, $null )
    } elseif ( !($useAsValue) -and $null -eq $Item.$ValueOrPropertyName ) {
        $HashTable.Add( $PropertyName, $null )
    } elseif ( $useAsValue ) {
        $HashTable.Add( $PropertyName, [datetime] $ValueOrPropertyName )
    } else {
        $HashTable.Add( $PropertyName, [datetime] $Item.$ValueOrPropertyName )
    }
}

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
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
#        [Alias('CreationTime','CreationDate','StartDate','StartTime')]
        [string] $CreateDateProperty,
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('LastWriteTime')]
        [string] $ModifyDateProperty,    # I do allow NULL here if there's an object with just one date
        [string[]] $Property            # list of properties to be added to the output
    )

    begin {
        $queue = [System.Collections.Queue]::new()
        # check if the property names are via commandline or if we have piped values
        #   a mandatory parameter via pipeline is validated by PS with each object coming from the pipeline
        #   but it's value from the command line is empty or null as long as you do not use defaults
        $isPipeline = ($CreateDateProperty -eq '')
    }

    process {
        foreach ($item in $InputObject) {
            $objHash = [ordered] @{
                AboveAvg    = $false
                Age         = $null
            }
            # services starttime can be null. Are the running since the big bang?  8-)
            Add-ValueFromPropertyOrPipeline $objHash 'CreationTime'     $item $CreateDateProperty $isPipeline
            Add-ValueFromPropertyOrPipeline $objHash 'TimeLastModified' $item $ModifyDateProperty $isPipeline
            $objHash.Age = [timespan] ( (Get-Date).Subtract($objHash.CreationTime) )
            # Add addional properties
            foreach ($propName in $Property) {
                Add-ValueFromPropertyOrPipeline $objHash $propName $item $propName $false
            }
            $obj = [PSCustomObject] $objHash
            $queue.Enqueue( $obj )
        }
    }

    end {
        $avgCreatedate = $queue.CreationTime.Ticks | Measure-Object -Average
        foreach ($item in $queue) {
            if ( $item.CreationTime.Ticks -gt $avgCreatedate.Average ) { $item.AboveAvg = $true }
            $item
        }
    }
}