# cloud-encryption

The goal: have all your files stored on your storage provider encrypted.

Requirements in details:

- transparently encrypt the files that you store in the cloud
- cloud storage functionality is kept: synchronisation between your devices, etc.
- encryption is done locally and only you can decrypt your files
- open source encryption (eg, gpg)
- open source code, as readable as possible to quickly check this code does nothing dodgy
- a file is encrypted and stored as a file: if this software isn't available, it's very easy to find your files and decrypt them individually (as opposed to having to unpack a big archive and figuring out how to get your stuff from it.


## Landscape

There are many existing solutions to do this. Here are a few I've found and why I didn't like them so much:

- dropbox (and many others) encrypt your files, but they could decrypt them if they wanted. That's usually only made clear in privacy policies.

- wuala: used it for a while, but was too unreliable (possibly because it's Java). Also, their encryption code isn't open: it's a commercial product and none of its code is. That applies to most existing solutions.

- boxcryptor only does the encryption and not the storage (which is a very good separation of concerns). But again, its encryption isn't open and I've found it to be unreliable and stopped using it.

- mega: same again.

- spideroak: the one I currently use. Same drawbacks as above, though. And also it uses a lot of bandwidth, unnecessarily.

Duplicity would be the closest to what this script tries to do. But it's too backup-orientated: it compresses all the file into a big lump and synchronises that, followed by incremental changes. Not very good for synchronising. Also it's designed to restore where you've backed-up: syncing to another machine will cause permission problems.
