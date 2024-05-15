# Load the necessary modules
Import-Module ActiveDirectory
Import-Module PSPKI

# Define the CA server name
$caServer = "ICA02Clone.lab.test"

# Get the CA security descriptor
$caSecurityDescriptor = Get-CASecurityDescriptor -CertificationAuthority $caServer

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

# Process each Access Control Entry (ACE) in the security descriptor
$caSecurityDescriptor.Access | ForEach-Object {
    $ace = $_

    $identity = $ace.IdentityReference

    # Translate the rights to readable permissions
    $permissions = Get-Permissions -rights $ace.Rights

    # Create a custom object for each ACE
    [PSCustomObject]@{
        Identity     = $identity
        Permissions  = $permissions
    }
} | Format-Table -AutoSize
