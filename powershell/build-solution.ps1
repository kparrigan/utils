function Build-Solution
{

    param
    (
        [parameter(Mandatory=$true)]            
        [ValidateNotNullOrEmpty()]  
        [string] $solutionPath, 
    
        [parameter(Mandatory=$false)]            
        [ValidateNotNullOrEmpty()]    
        [string] $frameworkVersion = "v4.0.30319",

        [parameter(Mandatory=$false)]            
        [ValidateNotNullOrEmpty()]    
        [string] $logFilePath = "C:\Temp\BuildLogs.txt"
    )
     

    process
    {
        try
        {

            "Cleaning solution' $solutionPath'..."
     
            $MSBuild = $env:systemroot + "\Microsoft.NET\Framework\$frameworkVersion\MSBuild.exe";
         
                            
            $args = @{            
                FilePath = $MSBuild            
                ArgumentList = $solutionPath, "/t:clean", ("/p:Configuration=Release"), "/v:minimal"            
                RedirectStandardOutput = $logFilePath            
                Wait = $true            
                WindowStyle = "Hidden"            
            }            
                    
            #Clean the solution before building
            Start-Process @args #| Out-String -stream -width 1024 > $logFilePath    

            "Finished cleaning solution' $solutionPath'..."

            "Building solution' $solutionPath'..."

            $args = @{            
                FilePath = $MSBuild            
                ArgumentList = $solutionPath, "/t:build", ("/p:Configuration=Release"), "/v:minimal"            
                RedirectStandardOutput = $logFilePath            
                Wait = $true            
                WindowStyle = "Hidden"            
            }            
                    
            #Build the solution
            Start-Process @args #| Out-String -stream -width 1024 > $logFilePath   
    
            "Finished building solution' $solutionPath'..." 
        }
        catch
        {
            "Unexpected error while building solution' $solutionPath'..."
        }
    }
}

