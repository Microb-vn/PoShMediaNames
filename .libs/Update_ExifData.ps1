function CreateNewpropertyItem {
	$img = [System.Drawing.Image]::Fromfile("$PSScriptRoot\PropertyItemSource.jpg")

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

	if (!(Test-Path -LiteralPath $FileName)) {
		Return "Function Update_ExifData: Failed to update ExifData, could not file file $filename"
	}

	$File = $FileName
	$CopyFileName = "$File.~tmp@#.jpg"
	# Create a working copy, as you cannot write changes back to the opened file
	Copy-Item -LiteralPath $File -Destination $CopyFileName -Force
	$img = [System.Drawing.Image]::Fromfile($CopyFileName);

	Foreach ($Update in $Updates) {
		# Prepare value for store/update (MUST BE STRING!!)
		$s = $Update.PropertyValue
		$a =  [System.Text.ASCIIEncoding]::ASCII.GetBytes($s) # Convert to byte string
		$a += $null
		$alen = $a.Length
	
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
			$Me.Id = $Update.PropertyNr
			$Me.Type = 2
			$Me.Value = ($a)
			$me.Len = $alen
			$img.SetPropertyItem($Me)
		}
		Else {
			#Update
			$item.Value = ($a)
			$item.Len = $alen
			$img.SetPropertyItem($item)
		}
	}
	Try {
		#Now just save it back to the original file:
		$Changes = $img.save($File)
		$img.Dispose()
		# Remove the working copy
		remove-item -LiteralPath $CopyFileName
		Return "Ok"
	}
	Catch {
		$ErrorMsg = "Function Update_ExifData: Error while updating image: $($Error[0].Exception.message)"
		Return $ErrorMsg
	}
}

