# Force PowerShell to use TLS 1.2 or TLS 1.3 (if supported by your .NET version)
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13

# Define the server and port
$Server = "your_server"
$Port = 443

# Create a TCP connection to the server
$tcpClient = New-Object System.Net.Sockets.TcpClient($Server, $Port)
$stream = $tcpClient.GetStream()

# Create an SSL stream and authenticate the server
$sslStream = New-Object System.Net.Security.SslStream($stream, $false, ({$true}))
$sslStream.AuthenticateAsClient($Server)

# Get the server certificate
$cert = $sslStream.RemoteCertificate

# Close the streams
$sslStream.Close()
$tcpClient.Close()

# Display the certificate information
[System.Security.Cryptography.X509Certificates.X509Certificate2]$cert

# Optional: Show specific details of the certificate
$cert | Select-Object Subject, Issuer, NotBefore, NotAfter, Thumbprint
