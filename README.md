# debian-linux-kfreebsd-cross
Cross-compiler from Debian GNU/Linux to Debian GNU/kFreeBSD. Created since I needed one for https://www.github.com/thesam/rust-cross-kfreebsd.

## Notes
* C/C++ enabled
* Produces binaries for Debian GNU/kFreeBSD
* Runs inside a Docker container to keep the host system clean
* Uses upstream binutils and gcc (kFreeBSD support out of the box)
* Uses Debian glibc (since some Debian patches are needed for kFreeBSD)
* Uses Debian kfreebsd-kernel-headers (matches the target system)

## Reference
* Mostly based on: http://preshing.com/20141119/how-to-build-a-gcc-cross-compiler/
