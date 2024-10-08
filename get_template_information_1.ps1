﻿# Load the Certification Authority module
Import-Module -Name PSPKI

# Get all certificate templates
$template = Get-CertificateTemplate -Name "LabUser"

# Define a function to get the DNS name status
function Get-DNSNameStatus {
    param ($template)
    return $template.Settings.Extensions['2.5.29.17'].DNSName.Count -gt 0
}



    # General
    $validity = $template.Settings.ValidityPeriod
    $renewalPeriod = $template.Settings.RenewalPeriod

    # Subject Name
    $subjectNameFormat = $template.Settings.SubjectName
    $buildFromAD = $template.Settings.SubjectName -notcontains 'EnrolleeSuppliesSubject'
    $dnsNameChecked = Get-DNSNameStatus -template $template

    # Extensions
    #$applicationPolicies = $template.Settings.Extensions['2.5.29.32']
    $applicationPolicies = $template.Settings.Extensions['1.3.6.1.4.1.311.21.10'].ApplicationPolicies
    $basicConstraints = "Default"
    if ($template.Settings.Extensions['2.5.29.19']){
        $certificateAuthority = $template.Settings.Extensions['2.5.29.19'].CertificateAuthority 
        $hasPathLengthConstraint = $template.Settings.Extensions['2.5.29.19'].HasPathLengthConstraint
        $pathLengthConstraint = $template.Settings.Extensions['2.5.29.19'].PathLengthConstraint
        $isCritical = $template.Settings.Extensions['2.5.29.19'].Critical
        $basicConstraints = "{IsCA: $certificateAuthority, HasPathLengthContraint: $hasPathLengthConstraint, PathLengthConstraint: $pathLengthConstraint, IsCritical: $isCritical}"
    }
    
    #$certificateTemplateInfo = $template.Settings.Extensions['1.3.6.1.4.1.311.21.7']
    $certificateTemplateInfo = $template.Settings.Extensions['1.3.6.1.4.1.311.21.7'].Format(0)
    $issuancePolicies = $template.Settings.Extensions['2.5.29.32'].Policies
    $keyUsage = $template.Settings.Extensions['2.5.29.15'].KeyUsages

    # Enrollment permissions
    $permissions = $template.GetSecurityDescriptor().Access

    # Issuance Requirements
    $issuanceRequirements = $template.Settings.CAManagerApproval

    # Cryptography
    $providers = $template.Settings.Cryptography.CSPList
    $keyAlgo = $template.Settings.Cryptography.KeyAlgorithm.FriendlyName
    $keyLength = $template.Settings.Cryptography.MinimalKeyLength
    $hashAlgorithm = $template.Settings.Cryptography.HashAlgorithm.FriendlyName

    # Key Attestation
    $keyAttestationRequired = $template.KeyAttestation -contains 'Required'
    $attestationBasedOn = $template.KeyAttestationBasedOn
    $attestationIssuancePolicies = $template.KeyAttestationIssuancePolicies

    # Server settings
    $doNotStoreInDatabase = $template.Options -contains 'DoNotStoreCertificates'
    $doNotIncludeCRLInfo = $template.Options -contains 'DoNotIncludeRevocationInfo'

    # Create custom object for each template
    [PSCustomObject]@{
        TemplateName = $template.DisplayName
        Validity = $validity
        RenewalPeriod = $renewalPeriod
        BuildFromAD = $buildFromAD
        SubjectNameFormat = $subjectNameFormat
        DNSNameChecked = $dnsNameChecked
        ApplicationPolicies = $applicationPolicies
        BasicConstraints = $basicConstraints
        CertificateTemplateInfo = $certificateTemplateInfo
        IssuancePolicies = $issuancePolicies
        KeyUsage = $keyUsage
        Permissions = $permissions
        IssuanceRequirements = $issuanceRequirements
        Providers = $providers
        KeyAlgorithm = $keyAlgo
        KeyLength = $keyLength
        HashAlgorithm = $hashAlgorithm
        KeyAttestationRequired = $keyAttestationRequired
        AttestationBasedOn = $attestationBasedOn
        AttestationIssuancePolicies = $attestationIssuancePolicies
        DoNotStoreInDatabase = $doNotStoreInDatabase
        DoNotIncludeCRLInfo = $doNotIncludeCRLInfo
    }

