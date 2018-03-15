

Function ArtistReleases {

#Get Artist Release Info

param (
[parameter(Mandatory=$true)]
[string]$ArtistName


)

$request = "https://musicbrainz.org/ws/2/artist/?query=artist:$ArtistName"

$Content = Invoke-WebRequest -Uri $request | Select Content -ExpandProperty Content| Out-File "$env:TEMP\$ArtistName.xml"

$xml = [xml](Get-Content $env:TEMP\$ArtistName.xml)

$ID = $xml.metadata.'artist-list'.artist | Where-Object {$_.Name -eq $ArtistName -and $_.Score -eq '100'} | Select ID -ExpandProperty ID

#Get information about Artist Releases

$ReleaseURI = "http://musicbrainz.org/ws/2/artist/$ID/releases"+"?inc=releases+recordings&fmt=json" 

Invoke-WebRequest $ReleaseURI | ConvertFrom-Json | Select releases -ExpandProperty releases |Select Title,Date,Country,id | Sort-Object Date


}


#Get Album Info

Function AlbumInfo {

param (
[parameter(Mandatory=$true)]
[string]$ArtistName,
[parameter(Mandatory=$true)]
[string]$ReleaseName,
[parameter(Mandatory=$true)]
[string]$ID



)

#Get the Artist ID

$request = "https://musicbrainz.org/ws/2/artist/?query=artist:$ArtistName"

$Content = Invoke-WebRequest -Uri $request | Select Content -ExpandProperty Content| Out-File "$env:TEMP\$ArtistName.xml"

$xml = [xml](Get-Content $env:TEMP\$ArtistName.xml)

$ID = $xml.metadata.'artist-list'.artist | Where-Object {$_.Name -eq $ArtistName -and $_.Score -eq '100'} | Select ID -ExpandProperty ID


#Get Releases

$request = "https://musicbrainz.org/ws/2/release/?query=arid:$ID"

$Content = Invoke-WebRequest -Uri $request | Select Content -ExpandProperty Content | Out-File "$env:TEMP\$ReleaseName.xml" -Force

$xml = [xml](Get-Content $env:TEMP\$ReleaseName.xml)

$ReleaseID = $xml.metadata.'release-list'.release  | Where-Object {$_.Title -eq "$ReleaseName" -and $_.id -eq $ID}  | Select id -Unique -ExpandProperty id

#Get Release Info

$ReleaseURI2 = "http://musicbrainz.org/ws/2/release/$ReleaseID"+"?inc=recordings&fmt=json"

Invoke-WebRequest -Uri $ReleaseURI2 | ConvertFrom-Json  | Select Media -ExpandProperty Media | Select tracks -ExpandProperty tracks | Select Number,Title | Sort-Object Number

Remove-Item -Path "$env:Temp\$ArtistName.xml" -Force
Remove-Item "$env:TEMP\$ReleaseName.xml" -Force

}
 
 


