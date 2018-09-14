
[CmdletBinding(PositionalBinding=$false)]
Param(
    [Parameter(Mandatory=$false)][string]$pathDestinationFile = $((get-Item -Path ".\").FullName) ,  
    [Parameter(Mandatory=$false)][ValidateSet("true", "false")][string]$overWriteDestinationFile = $false
    )

# Recupera Nome report e versione dal file Report.properties
$AppProps = convertfrom-stringdata (get-content ./Report.properties -raw)
if ([string]::IsNullOrEmpty($AppProps.ReportName) -or [string]::IsNullOrEmpty($AppProps.ReportVersion)) {
    Write-Error "File ./Report.properties mancante."
    exit(-1)
}

Write-Host "----------------------------------------------------"  -ForegroundColor White
Write-Host "pathDestinationFile:"  $pathDestinationFile -ForegroundColor White
Write-Host "overWriteDestinationFile:"  $overWriteDestinationFile -ForegroundColor White
Write-Host "----------------------------------------------------"  -ForegroundColor White


#Se non passo il percorso specifico quello della directory corrente
if ($pathDestinationFile -eq "" -and $pathDestinationFile -eq [String]::Empty)
    {
        $currentPath = $((get-Item -Path ".\").FullName)
    }
else
    {
        $currentPath = $PathDestinationFile
    }


$outputFileName = $currentPath + '\' + $AppProps.ReportName + " " + $appProps.ReportVersion + '.zip'

# Crea una cartella temporanea
$parent = [System.IO.Path]::GetTempPath()
$name = [System.IO.Path]::GetRandomFileName()
$tempDirectory = New-Item -ItemType Directory -Path (Join-Path $parent $name)

# Copia i file da mettere nello zip nella cartella temporanea
Get-ChildItem $((get-Item -Path ".\").FullName) -Include "*.jasper", "*.jrxml", "*.properties" -Recurse | Select-Object -ExpandProperty FullName | Copy-Item -Destination $tempDirectory

# Crea zip con il contenuto della cartella (in una cartella temporanea)
$tempFile = [System.IO.Path]::GetTempPath() + [System.IO.Path]::GetRandomFileName()
Add-Type -Assembly System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::CreateFromDirectory($tempDirectory, $tempFile)

# Sposta il file zip nella cartella corrente

if (Test-Path $outputFileName)  
    {
        Write-Host "$outputFileName presente." -ForegroundColor Yellow
        if ($overWriteDestinationFile -eq "true") 
            {
                
                Remove-Item $outputFileName
                Write-Host "Il file e' stato cancellato." -ForegroundColor Yellow
                Move-Item $tempFile $outputFileName
                Write-Host "Il file e' stato creato." -ForegroundColor Green
                
            }
        else
            {
                
                Write-Host "Eliminare il file o settare il parametro -overWriteDestinationFile True." -ForegroundColor Red
            }
    }
else
    {
        Write-Warning "$outputFileName da creare"
        Move-Item $tempFile $outputFileName
    }




# Cancella la cartella temporanea
Remove-Item -Recurse $tempDirectory
