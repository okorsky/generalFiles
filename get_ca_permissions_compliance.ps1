# Load the necessary modules
Import-Module ActiveDirectory
Import-Module PSPKI

# Define the CA server name
$caServer = "ICA02Clone.lab.test"

# Get the CA security descriptor
$caSecurityDescriptor = Get-CASecurityDescriptor -CertificationAuthority $caServer

# Define the baseline permissions
$baselinePermissions = @(
    [PSCustomObject]@{ Identity = "NT AUTHORITY\Authenticated Users"; Permissions = "Request Certificates" },
    [PSCustomObject]@{ Identity = "BUILTIN\Administrators"; Permissions = "Issue and Manage Certificates, Manage CA" },
    [PSCustomObject]@{ Identity = "LAB\Domain Admins"; Permissions = "Issue and Manage Certificates, Manage CA" },
    [PSCustomObject]@{ Identity = "LAB\Enterprise Admins"; Permissions = "Issue and Manage Certificates, Manage CA" },
    [PSCustomObject]@{ Identity = "LAB\svctest"; Permissions = "Read, Manage CA" }
)

# Define a function to translate the rights to readable permissions
function Get-Permissions {
    param ($rights)
    $permissions = @()

    if ($rights.ToString().Contains("Read")) { $permissions += "Read" }
    if ($rights.ToString().Contains("ManageCertificates")) { $permissions += "Issue and Manage Certificates" }
    if ($rights.ToString().Contains("ManageCA")) { $permissions += "Manage CA" }
    if ($rights.ToString().Contains("Enroll")) { $permissions += "Request Certificates" }

    return $permissions -join ", "
}

# Get the actual permissions from the CA
$actualPermissions = $caSecurityDescriptor.Access | ForEach-Object {
    $ace = $_

    $identity = $ace.IdentityReference.Value
    $permissions = Get-Permissions -rights $ace.Rights

    [PSCustomObject]@{
        Identity     = $identity
        Permissions  = $permissions
    }
}

# Initialize compliance flag
$complianceFlag = $true

# Compare actual permissions against the baseline
$complianceResults = @()

# Check each baseline identity
foreach ($baseline in $baselinePermissions) {
    $actual = $actualPermissions | Where-Object { $_.Identity -eq $baseline.Identity }
    
    if ($actual -and $actual.Permissions -eq $baseline.Permissions) {
        $complianceResults += [PSCustomObject]@{
            Identity     = $baseline.Identity
            ExpectedPermissions = $baseline.Permissions
            ActualPermissions   = $actual.Permissions
            Compliance  = "Compliant!"
        }
    } else {
        $actualPerm = if ($actual) { $actual.Permissions } else { "None" }
        $complianceResults += [PSCustomObject]@{
            Identity     = $baseline.Identity
            ExpectedPermissions = $baseline.Permissions
            ActualPermissions   = $actualPerm
            Compliance  = "Non-Compliant"
        }
        $complianceFlag = $false
    }
}

# Check for extra identities not in the baseline
foreach ($actual in $actualPermissions) {
    $baseline = $baselinePermissions | Where-Object { $_.Identity -eq $actual.Identity }
    
    if (-not $baseline) {
        $complianceResults += [PSCustomObject]@{
            Identity     = $actual.Identity
            ExpectedPermissions = "None"
            ActualPermissions   = $actual.Permissions
            Compliance  = "Non-Compliant"
        }
        $complianceFlag = $false
    }
}

# Output the compliance results
$complianceResults | Format-Table -AutoSize

# Output overall compliance status
if ($complianceFlag) {
    Write-Output "Overall Compliance Status: Compliant!"
} else {
    Write-Output "Overall Compliance Status: Non-Compliant"
}
