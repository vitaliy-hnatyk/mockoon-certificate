# Mockoon HTTPS Localhost Certificate for Windows

This project contains a Windows `.bat` script that creates a trusted local HTTPS certificate for **Mockoon**.

It is useful when you want to run a Mockoon mock API using:

```txt
https://localhost:<port>
```

without Chrome showing:

```txt
net::ERR_CERT_AUTHORITY_INVALID
```

## Files

```txt
generate-trusted-mockoon-localhost-cert-v2.bat
README.md
```

After running the script, it will generate:

```txt
localhost-mockoon.pfx
localhost-mockoon.cer
```

## What the script does

The script uses Windows PowerShell to:

1. Create a self-signed certificate for `localhost`.
2. Export it as a `.pfx` file for Mockoon.
3. Export the public certificate as a `.cer` file.
4. Add the certificate to the trusted root store for the current Windows user.

No OpenSSL installation is required.

## Requirements

- Windows 10 or Windows 11
- PowerShell
- Mockoon

## How to use

### 1. Download or clone this repository

```bash
git clone <your-repository-url>
cd <your-repository-folder>
```

Or download the files manually.

### 2. Run the certificate generator

Double-click:

```txt
generate-trusted-mockoon-localhost-cert-v2.bat
```

Do **not** copy and paste the `.bat` contents into PowerShell.

If Windows blocks the file, right-click it, choose **Properties**, then select **Unblock** if that option appears.

If the script fails, right-click the `.bat` file and choose:

```txt
Run as administrator
```

### 3. Use the generated certificate in Mockoon

Open Mockoon and go to your environment settings.

Enable **TLS**, then use:

```txt
Certificate / PFX file: localhost-mockoon.pfx
Passphrase / password: mockoon
```

Restart the Mockoon environment.

### 4. Open your HTTPS endpoint

Use:

```txt
https://localhost:<your-mockoon-port>
```

Example:

```txt
https://localhost:3000
```

Important: use `localhost`, not `127.0.0.1`.

## PFX password

The generated `.pfx` file uses this password:

```txt
mockoon
```

You can change it by editing this line inside the `.bat` file:

```bat
$passwordText = 'mockoon'
```

## Troubleshooting

### Chrome still shows `net::ERR_CERT_AUTHORITY_INVALID`

Try these steps:

1. Restart Chrome.
2. Make sure you are using `https://localhost:<port>`.
3. Do not use `https://127.0.0.1:<port>`.
4. Run the `.bat` file again.
5. Try running the `.bat` file as administrator.

### Mockoon does not accept the certificate

Make sure you selected:

```txt
localhost-mockoon.pfx
```

and entered the passphrase:

```txt
mockoon
```

Also make sure TLS is enabled and the Mockoon environment was restarted.

### I need HTTPS for `127.0.0.1`

This script creates a trusted certificate for `localhost`.

For `127.0.0.1`, the script needs to be changed to include the IP address as a Subject Alternative Name.

## Security note

This certificate is intended for local development only.

Do not use this certificate in production.
Do not commit generated `.pfx`, `.cer`, `.crt`, or `.key` files to a public repository.

## Recommended `.gitignore`

Add this to your `.gitignore`:

```gitignore
*.pfx
*.cer
*.crt
*.key
localhost.conf
```

## License

MIT
