# Define the host and port
$Host = "your_host"
$Port = 443

# Create a TCP connection to the server
$tcpClient = New-Object System.Net.Sockets.TcpClient($Host, $Port)
$stream = $tcpClient.GetStream()

# Create an SSL stream and authenticate the server
$sslStream = New-Object System.Net.Security.SslStream($stream, $false, ({$true}))
$sslStream.AuthenticateAsClient($Host)

# Get the server certificate
$cert = $sslStream.RemoteCertificate

# Close the streams
$sslStream.Close()
$tcpClient.Close()

# Display the certificate information
[System.Security.Cryptography.X509Certificates.X509Certificate2]$cert

# Optional: Show specific details of the certificate
$cert | Select-Object Subject, Issuer, NotBefore, NotAfter, Thumbprint
