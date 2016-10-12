function Invoke-FederalRegister {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)] [string] $Api,            # Available API endpoints are 'documents','public-inspection-documents','agencies','suggested_searches'
        [Parameter(Mandatory=$false)] [string] $Format = 'json', # Response format available as either JSON or CSV, default to json
        [Parameter(Mandatory=$true)] [string] $DocNumber,      # The Document Number 
        [Parameter(Mandatory=$false)] [Object[]] $Fields      # Which attributes of the document(s) to return; by default, a reasonable set is returned, but a user can customize it to return exactly what is needed.
        )

    Process {
        $endpoint = 'www.federalregister.gov/api/v1'
    
        # build the field query string
        $queryFields = ""
        foreach ($field in $fields) {if ($fields.indexOf($field) -eq 0) {$queryFields = "?fields%5B%5D=$field"} else {$queryFields += "&fields%5B%5D=$field"}}
        
        $uri = "https://$endpoint/$Api/$DocNumber.$Format$queryFields"

        Invoke-WebRequest -uri $uri
    }
}

function Get-Agencies {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)] [string] $url = 'www.federalregister.gov/api/v1/agencies',
        [switch] $response,
        [switch] $data,
        [switch] $find,
        [string] $agency # agency slug for finding individual agency
        )
    $r = Invoke-WebRequest -uri $url
    ($r.content | ConvertFrom-JSON)|export-csv "$(pwd)\agencies.csv" -notypeinformation
    write-host "Agency data refreshed." -foregroundcolor cyan

    if ($response) {
        # define and return response object
    } elseif ($data) {
        # define and return data object
    } elseif ($find) {
        $r = Invoke-WebRequest -uri ("$url/$agency")
        if ($response) {
        # define and return response object
        } elseif ($data) {
            # define and return data object
        }
    }
}

function Get-Document {
    [CmdletBinding()]
    Param(
        [Parameter(ValueFromPipeline=$true,Mandatory=$true,Position=0)] $docNumber,
        [Parameter(ValueFromPipeline=$true,Mandatory=$false,Position=1)] $fields,
        [switch] $multi,
        $api = 'documents',
        $format = 'json'
        )

    $docNumber = '2016-05054'
    $fields = 'title','document_number','topics','dates','toc_doc','toc_subject'

    if ($multi) {$docNumber = $docNumber -join ','} elseif ($docNumber.count -gt 1 -and -not $multi) { $docNumber = $docNumber -join ',' }

    $r = Invoke-FederalRegister -Api $api -Format 'json' -DocNumber $docNumber -Fields $fields
    $status = $r.StatusCode
    $statusDescription = $r.statusDescription
    $headers = $r.Headers
    $content = $r.content | ConvertFrom-JSON
}

function Search-FederalRegister {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)] [string] $Api = 'documents',
        [string] $Format = 'json',
        [Object[]] $Fields,
        [int] $MaxResults,
        [int] $Page,
        [string] $OrderBy,  # relevance, newest, oldest, executive_order_number
        [string] $SearchTerms,

        )
}

function Get-SuggestedSearches {
    [CmdletBinding()]
    Param( 
        [Parameter(ValueFromPipeline=$true)] [Object[]] $Sections = $args,
        $Api = 'suggested_searches'
        )

    # Available sections are: 'business-and-industry','environment','health-and-public-welfare','money','science-and-technology','world'
    
}