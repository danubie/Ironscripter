function Get-ObjectAge {
    [CmdletBinding()]
    param (
        # Any Input object to get an anti-aging check
        [Parameter(Position=0, ValueFromPipeline, ValueFromPipelineByPropertyName, Mandatory=$true)]
        [System.Object[]] $InputObject,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $CreateDateProperty,
        [string] $ModifyDateProperty    # I do allow NULL here if there's an object with just one date
    )

    begin {
        $queue = [System.Collections.Queue]::new()
    }

    process {
        foreach ($item in $InputObject) {
            $objHash = [ordered] @{
                AboveAvg    = $false
            }
            # services starttime can be null 8-)
            if ($CreateDateProperty -ne "" -and $null -ne $item.$CreateDateProperty ) {
                $objHash.Add( $CreateDateProperty, [datetime] $item.$CreateDateProperty )
            } else {
                $objHash.Add( $CreateDateProperty, $null)
            }
            # ModifyProperty specified and must exist
            if ($ModifyDateProperty -ne "" -and $null -ne $item.$ModifyDateProperty ) {
                $objHash.Add( $ModifyDateProperty, [datetime] $item.$ModifyDateProperty )
            } else {
                if ($ModifyDateProperty -ne "") { $objHash.Add( $ModifyDateProperty, $null) }
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