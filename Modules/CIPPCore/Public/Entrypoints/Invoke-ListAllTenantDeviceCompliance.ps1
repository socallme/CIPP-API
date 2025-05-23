using namespace System.Net

Function Invoke-ListAllTenantDeviceCompliance {
    <#
    .FUNCTIONALITY
        Entrypoint
    .ROLE
        Tenant.DeviceCompliance.Read
    #>
    [CmdletBinding()]
    param($Request, $TriggerMetadata)

    $APIName = $Request.Params.CIPPEndpoint
    $Headers = $Request.Headers
    Write-LogMessage -headers $Headers -API $APIName -message 'Accessed this API' -Sev 'Debug'




    # Interact with query parameters or the body of the request.
    $TenantFilter = $Request.Query.TenantFilter
    try {
        if ($TenantFilter -eq 'AllTenants') {
            $GraphRequest = New-GraphGetRequest -uri 'https://graph.microsoft.com/beta/tenantRelationships/managedTenants/managedDeviceCompliances'
            $StatusCode = [HttpStatusCode]::OK
        } else {
            $GraphRequest = New-GraphGetRequest -uri "https://graph.microsoft.com/beta/tenantRelationships/managedTenants/managedDeviceCompliances?`$top=999&`$filter=organizationId eq '$TenantFilter'"
            $StatusCode = [HttpStatusCode]::OK
        }

        if ($GraphRequest.value.count -lt 1) {
            $StatusCode = [HttpStatusCode]::Forbidden
            $GraphRequest = 'No data found - This client might not be onboarded in Lighthouse'
        }
    } catch {
        $ErrorMessage = Get-NormalizedError -Message $_.Exception.Message
        $StatusCode = [HttpStatusCode]::Forbidden
        $GraphRequest = "Could not connect to Azure Lighthouse API: $($ErrorMessage)"
    }
    # Associate values to output bindings by calling 'Push-OutputBinding'.
    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
            StatusCode = $StatusCode
            Body       = @($GraphRequest)
        })

}
