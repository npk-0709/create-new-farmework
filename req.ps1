Add-Type -AssemblyName System.Web
function Request {
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Url,
        
        [Parameter(Mandatory = $false, Position = 1)]
        [ValidateSet("get", "post")]
        [string]$Method = "get",
        [Parameter(Mandatory = $false, Position = 2)]
        [object]$Payload
    )

    try {
        # Validate URL format
        if (-not ($Url -match '^https?://')) {
            throw "Invalid URL format. URL must start with http:// or https://"
        }

        # Handle POST request
        if ($Method -eq "post") {
            if (-not $Payload) {
                $encodedBody = @{}
            }else{
                $formData = @{}
                if ($Payload -is [string]) {
                    # Handle string payload like "key=value&key2=value2"
                    foreach ($pair in $Payload.Split('&')) {
                        $keyValue = $pair.Split('=', 2)
                        if ($keyValue.Length -eq 2) {
                            $formData[$keyValue[0]] = $keyValue[1]
                        } else {
                            throw "Invalid payload format. Use 'key=value' or 'key=value&key2=value2'."
                        }
                    }
                } elseif ($Payload -is [hashtable]) {
                    # Handle hashtable payload like @{key="value"}
                    $formData = $Payload
                } else {
                    throw "Payload must be a string ('key=value') or hashtable (@{key='value'})."
                }

                # Convert form data to URL-encoded string
                $body = [System.Web.HttpUtility]::ParseQueryString('')
                foreach ($key in $formData.Keys) {
                    $body.Add($key, $formData[$key])
                }
                $encodedBody = $body.ToString()
            }

           

            $response = Invoke-WebRequest -Uri $Url -Method Post -Body $encodedBody -ContentType "application/x-www-form-urlencoded" -ErrorAction Stop
            return $response.Content
        }
        # Handle GET request (default)
        else {
            if ($Payload) {
                throw "GET requests do not accept a payload."
            }
            $response = Invoke-WebRequest -Uri $Url -Method Get -ErrorAction Stop
            return $response.Content
        }
    }
    catch {
        Write-Error "Error: $_"
        exit 1
    }
}

# Call the function with all provided arguments
Request @args