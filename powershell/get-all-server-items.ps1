function Get-All-Server-Items
{
    param
    (
        [parameter(Mandatory=$true)]            
        [ValidateNotNullOrEmpty()]  
        [string] $filter, 

        [parameter(Mandatory=$false)]            
        [ValidateNotNullOrEmpty()]  
        [string] $manifestFile, 

        [parameter(Mandatory=$false)]  
        [switch] $delete
    )

    process
    {
        try
        {
            $childItems = New-Object System.Collections.Generic.List[System.String]
            $drives = Get-PSDrive -PSProvider 'FileSystem'

            ForEach ($drive in $drives) {
                $root = $drive.Root
                "Searching: " + $root

                $children = Get-ChildItem -Path $root -Include $filter -Recurse;
                ForEach($child in $children) {
                    $child.FullName
                    $childItems.Add($child.FullName)
                }

                if ($manifestFile)
                {
                    $childItems | Format-Table Fullname | Out-File $manifestFile
                }

                if ($delete)
                {
                    "Deleting Files..."
                    ForEach ($childItem in $childItems)
                    {
                        Remove-Item $childItem
                    }
                }
            }

            "Processing complete..."
        }
        catch
        {
            "Unexpected error while processing..."
        }
    }
}