# shared-credential-store

This is an attempt at a secure & consistent way of sharing credentials, ssh-keys & associated passwords.  Relies on GnuPG to encrypt & decrypt secrets and uses gpg-agent to export secrets to environment variables without prompting.

This is a team version of [simple-credential-store](https://github.com/simonmcc/simple-credential-store).

## Loading a set of credentials

Make sure you've run `import-team-gpg-keys.sh` recently so that the team public keys are loaded into your gpg key-ring.

The file `credentials/artifactory-terraform-state` contains all of the non-sensitive details for a credential set, along with a hook to call the generic password decryption script, `decrypt-secrets.sh`, which decrypts `credentials/artifactory-terraform-state.secret.asc` into ARTIFACTORY_PASSWORD.

    # Just so you don't miss it,  this is sourcing the environment variables that the script generates.
    # You should be able to copy/paste it just fine.
    . ~/shared-credential-store/credentials/artifactory-terraform-state

You should get prompted for your GPG password once per shell session (if you don't already have a gpg-agent running).

## Adding a new user
The users capable of decrypting secrets are maintained in `team-gpg-public-keys`, there should be a file per user, the filename should match your email address, the file should contain your GPG Public Key - see [Exporting your public key](#exportpublickey).

After adding a new user to `team-gpg-public-keys` you need to re-encrypt all existing secrets using `re-encrypt-secrets.sh`, this should prompt you for your gpg passphrase unless you've already loaded your key into a GPG agent:

    $ ./re-encrypt-secrets.sh
    Agent started: GPG_AGENT_INFO=/tmp/gpg-sadR9D/S.gpg-agent:59648:1
    $


## Removing a user

For safe practice, when a user leaves our group, all passwords should be cycled, then the user removed from `team-gpg-public-keys` and all secrets re-encrypted with `./re-encrypt-secrets.sh`.


## Generate a new secret
A simple way to generate a new secret & encrypt it:

    pwgen 24 1 | ./encrypt.sh - > credentials/my-new-secret.secret.asc


## Supported Operating Environments

### Ubuntu
gpg tools are installed by default, from the gnupg package:

    apt-get install gnupg

### Mac/OSX

The homebrew tools package up gpg, gpg-agent & gpg2, I've tested working against both gpg & gpg2, using gpg-agent to manage keys.

    brew install gpg2 gpg-agent

## GPG Cheat Sheet

### Generate a public key

There are plenty of guides online on generating your gpg key pair, the important bit is that the key should be an sign & encryption key, not sign only, and that the Email Address should match your HP SEA so that people can find you, here's what it looks like under Ubuntu:

    $ gpg --gen-key

	Please select what kind of key you want:
	   (1) RSA and RSA (default)
	   (2) DSA and Elgamal
	   (3) DSA (sign only)
	   (4) RSA (sign only)
	Your selection? 1

	What keysize do you want? (2048)
	Requested keysize is 2048 bits
	Please specify how long the key should be valid.
	         0 = key does not expire
	      <n>  = key expires in n days
	      <n>w = key expires in n weeks
	      <n>m = key expires in n months
	      <n>y = key expires in n years
	Key is valid for? (0)
	Key does not expire at all
	Is this correct? (y/N) y

	You need a user ID to identify your key; the software constructs the user ID
	from the Real Name, Comment and Email Address in this form:
	    "Heinrich Heine (Der Dichter) <heinrichh@duesseldorf.de>"

	Real name: Simon McCartney
	Email address: simon@mccartney.ie
	Comment: whocares
	You selected this USER-ID:
	    "Simon McCartney (whocares) <simon@mccartney.ie>"

	Change (N)ame, (C)omment, (E)mail or (O)kay/(Q)uit? o
	You need a Passphrase to protect your secret key.
	....


If you get a message about not enough random data - try this in another session to generate some activity on your system:

    dd if=/dev/zero of=/tmp/5gb.tmp bs=1G count=5
    rm -f /tmp/5gb.tmp


### <a name="exportpublickey"></a>Export your public key to the team keys directory

NB - for the team member discovery in encrypt.sh to work, the file must match your email address:

    gpg --armor --export simon@mccartney.ie > team-gpg-public-keys/simon@mccartney.ie

### Check who can descrypt a secret

    gpg --list-only --no-default-keyring --secret-keyring /dev/null $encrypted_file

### Search & Import a new public key:

    gpg --search-keys simon@mccartney.ie

### What keys are in my keyring?

    gpg --list-keys
