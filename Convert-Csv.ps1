param(
    [parameter(
        Mandatory         = $true,
        ValueFromPipeline = $false)]
    [string] $FilePath,
    [parameter(
        Mandatory         = $true,
        ValueFromPipeline = $false)]
    [string] $Old,
    [parameter(
        Mandatory         = $true,
        ValueFromPipeline = $false)]
    [string] $New
)

function Convert-Line
{
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $Line,
        [parameter(
            Mandatory         = $true,
            ValueFromPipeline = $false)]
        [string] $Old,
        [parameter(
            Mandatory         = $true,
            ValueFromPipeline = $false)]
        [string] $New    
    )

    $Result = ""
    $Parts = $Line.Split("""")

    for ($Index = 0; $Index -lt $Parts.Length; $Index++)
    {
        $Part = $Parts[$Index]
        $IndexIsEven = ($Index % 2 -eq 0)

        if ($IndexIsEven)
        {
            $Part = $Part.Replace($Old, $New)
        }
        else
        {
            $Part = """" + $Part + """"
        }

        $Result += $Part
    }
    $Result
}

$InputFile = Get-Item $FilePath
$Raw = [System.IO.File]::ReadAllBytes($InputFile)
$Content = [System.Text.Encoding]::UTF8.GetString($Raw)
$Content = [regex]::Replace($Content, "(?<![\r])[\n]", " ", [System.Text.RegularExpressions.RegexOptions]::Singleline)

$InputFileName = [System.IO.Path]::GetFileNameWithoutExtension($InputFile)
$NewFileName = $InputFileName + ".conv" + $InputFile.Extension
$OutPath = Join-Path -Path $InputFile.Directory.FullName -ChildPath $NewFileName

if (Test-Path $OutPath)
{
    Remove-Item $OutPath
}

New-Item $OutPath

foreach($Line in $Content) 
{
    Convert-Line $Line $Old $New | Out-File -FilePath $OutPath -Encoding "utf8" -Append
}