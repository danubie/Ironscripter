# The Object Age challenge

## The challenge
The goal is to implement an advanced function *Get-ObjectAge*.

It should be a generic function to used with any group of objects as input. The output should show the object’s creation time, when it was last modified, and its age from creation. Additionally it has to indicate if the age is above or below, the average of *all processed objects*.

Reference: https://ironscripter.us/a-powershell-object-age-challenge/

## Ideas what could be considered
### Data types
- datetime
- timespan
- numbers (ticks)
### What kind of date/time related properties do I think of
- creation date (the lower, the older)
- modification date
- last logon
- dayssince, secondes since epoch (...)
- elapsed time (the higher the older)
### What kind of input objects should I check
- file
- directory
- AD
## Implementation variations
- Name of a property to be checked
- InputObject parameter
- via pipeline
  - how to the date properties by propertyname?

## The first solution
### Design decisions
- go with a pipeline design
  This would make it easy to handle objects of any kind in a really powershelly way.
- rely on the fact, that the properties used to be tracked can be converted into `datetime`
- keep the property names of the create/modify date attributes on output

### Implementation
The framework consists of a "08/15" design of a function accepting an array of (untyped) objects by parameter as well as by pipeline

    function Get-ObjectAge {
        [CmdletBinding()]
        param (
            # Any Input object to get an anti-aging check
            [Parameter(Position=0, ValueFromPipeline, ValueFromPipelineByPropertyName, Mandatory=$true)]
            [System.Object[]] $InputObject
            # ...
        )
        begin {
            ...
        }
        process {
            foreach ($item in $InputObject) {
              ...
            }
        }
        end {
          ...
        }
    }

To be able to calculate the average of all objects (and still be pipeline ready) the container for the necessary data has to be instanciated in the begin block and evaluated in the end block. I decided to use a queue to easyly keep the order of the input objects in place and because the number of items to be stored is unknown.

    begin {
        $queue = [System.Collections.Queue]::new()
    }

The (simplified) main loop just creates a custom object storing the dates and a properties for age and the indicator *above yes or no*.

    foreach ($item in $InputObject) {
        $objHash = [ordered] @{
            AboveAvg              = $false
            Age                   = ...
            $CreateDateProperty   = [datetime] $item.$CreateDateProperty
            $ModifyDateProperty   = [datetime] $item.$ModifyDateProperty
        }
        $obj = [PSCustomObject] $objHash
        $queue.Enqueue( $obj )
    }

In the end, the average is calculated and the indicator adjusted. Measure-Object cannot handle datetime directly so ticks are used instead.

    $avgCreatedate = $queue.$CreateDateProperty.Ticks | Measure-Object -Average
    foreach ($item in $queue) {
        if ( $item.$CreateDateProperty.Ticks -gt $avgCreatedate.Average ) { $item.AboveAvg = $true }
        $item
    }
