function CreateNewpropertyItem {
	$img = [System.Drawing.Image]::Fromfile("$PSScriptRoot\PropertyItemSource.jpg")
	# $img.PropertyItems
	$item = $img.psbase.GetPropertyItem(271)
	$item.Id = 0
	$item.Len = 0
	$item.Type = 0
	$item.Value = @()
	$item
}

Function Update_ExifData {
	param (
		# Name of the Photo file to be updated	
		$FileName,
		# An array with objects, where each object has attributes:
		# - PropertyNr: Exif Property number (see document)
		# - PropertyValue: String to store/update
		# Note: Only property type 2 (ASCII String) updates are supported!
		#       Using incorrect/invalud Nr/Type combinations can mess up your file!!
		$Updates
	)

	if (! (Test-Path -LiteralPath $FileName)) {
		Return "Function Update_ExifData: Failed to update ExifData, could not file file $filename"
	}

	$File = $FileName
	$img = [System.Drawing.Image]::Fromfile($file);
	$img.PropertyItems

	Foreach ($Update in $Updates) {
		# Prepare value for store/update (MUST BE STRING!!)
		$s = $Update.PropertyValue
		$a = $s.ToCharArray()
		$a += $null
	
		# See if we can get a property with the requested number
		Try {
			$item = $img.psbase.GetPropertyItem($Update.PropertyNr) 
		}
		Catch { 
			$item = $null 
		}
		if (!$Item) {
			#Add
			$Me = CreateNewpropertyItem
			$Me.Id = $Update.ProperyNr
			$Me.Type = 2
			$Me.Value = ($a)
			$img.SetPropertyItem($Me)
		}
		Else {
			#Update
			$item.Value = ($a)
			$img.SetPropertyItem($item)
		}
	}
	$img.Save($FileName)
}
#Now just save it back to a file:



