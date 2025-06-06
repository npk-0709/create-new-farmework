function Request {
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateSet("get", "post")]
        [string]$Method='get',
        
        [Parameter(Mandatory = $true, Position = 1)]
        [string]$Url,
        
        [Parameter(Mandatory = $false, Position = 2)]
        [string]$Payload
    )

    try {
        # Validate URL format
        if (-not ($Url -match '^https?://')) {
            throw "Invalid URL format. URL must start with http:// or https://"
        }

        # Handle GET request
        if ($Method -eq "post") {
            if (-not $Payload) {
                throw "POST requests require a JSON payload."
            }
            # Validate JSON payload
            try {
                $null = ConvertFrom-Json $Payload -ErrorAction Stop
            }
            catch {
                throw "Invalid JSON payload: $_"
            }
            $response = Invoke-WebRequest -Uri $Url -Method Post -Body $Payload -ContentType "application/json" -ErrorAction Stop
            return $response.Content
        }
        else {
            if ($Payload) {
                throw "GET requests do not accept a payload."
            }
            $response = Invoke-WebRequest -Uri $Url  -ErrorAction Stop
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