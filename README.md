# Fogmail

Because we don't want our mails to be in the clear.

## Security, decentralization, opensource

Fogmail intends to be an opensource, community driven mail service. With security in mind.

Wow, that's a lot of buzz-words so let us explain the concept.

## Opensource
All the softwares are open and free. Among them, we can name:
* [dovecot](http://dovecot.org/)
* [postfix](http://www.postfix.org/)
* [spamassassin](https://spamassassin.apache.org/) (maybe, not sur to use it)
* [tor](https://www.torproject.org/)
* [tahoe-lafs](https://tahoe-lafs.org/trac/tahoe-lafs)
* [puppet](http://puppetlabs.com/)

Also, all the configurations will be open. Well, you won't get hand on the private keys for SSL certificates, of course. But all the other parts will be accessible. Here.

## Community
If the entry points will be managed by a couple of people ([@SwissTengu](https://twitter.com/swisstengu/) mostly), the design will allow people to help. Mostly for mail storage. Using tahoe-lafs, anyone wanting to give some giga to the project will be able to do so. We will provide a simple receipt allowing you to just apply it, and you're done.

## Decentralization
Mail aren't good for decentralization. And it will most probably never be. But still, we do have ways to do some nice things:

Dovecot supports master-master replication. This allows us to build several entry-points for your pop/imap access; as well, building several entries for postfix isn't a problem. We will just get "some" DNS entries for the MX field ;).

As previously stated, the main decentralized part will be for the storage. Probably the most important part in fact: mails are growing, we send more and more stuff through it. Thus we need storage. Using Tahoe-lafs, we will be able to provide an infinit-storage, provided you, the community, participate and provide some spare gigas.

## Security
Probably the most interesting part. We want your communications to be encrypted. All of them. Even if you don't send them encrypted.

There are already [hacks](https://github.com/ajgon/gpg-mailgate) on postfix in order to encrypt emails — we will use them. Process will be simple: upon account creation, you might either provide a public key, or a new pair might be generated (locally, provided there actuall are efficient javascript libraries). We won't get hand on the private key. Ever. (Meaning: if you lose your key, well, you lose all your old emails… duh.)

Also, each node will be secured at the best possible. Running on closed environment, with no remote access. Updates will be followed closely (that's [@SwissTengu](https://twitter.com/swisstengu/) job for years now).

Also, all communication between nodes will be encrypted. [Dovecot replication](http://wiki2.dovecot.org/Replication) support SSL over TCP, and Tahoe already communicates with encrypted channels (and data are encrypted on the client side, then sent to the storage).

## Access to emails
Well, yes, this may be interesting for you as well ;).

Mostly, we will focus on imaps/pop3s/smpts services. This will allow you to use Outlook (with some [PGP plugin](https://github.com/dejavusecurity/OutlookPrivacyPlugin)), Thunderbird (with [Enigmail](https://www.enigmail.net/home/index.php)), Mail (with [GPGTools](https://gpgtools.org/)). We will also have a look at existing webmails in order to provide an access. But we're not really happy with that. For your private key will be available in some way from the browser. And this is bad. Really.

So, maybe, no webmail. We do not trust the html5 local storage thing. You shouldn't as well.

## In short
We want to provide a really secure, strong, community managed service. As it will be fully opened, anyone wanting to build his own infra will be able to do so.

Mails are important. Really. We write anything in them, we send them accross the Web. This project isn't just a "I had an idea this morning". We thought about it for months. It's time to get your privacy back, to get hand on probably the most valuable thing: your private communications.

## Want to test the stuff?
Great, we need people for tests/validation/ideas!

### Get Puppet and Docker
In order to get a reproducible environment, this is built using [Docker](https://docker.com/) and [Puppet](https://puppetlabs.com/). This allows us to do really fast tests and validations.

### Get sources
Clone this repository. As we're using submodules, you'll need to initialize them:

``` Bash
$ git clone https://github.com/EthACKdotOrg/fogmail
$ cd fogmail
$ git submodule init
$ git submodule update
```

**Note** it's possible you get some problems for two repositories: tor and dovecot. We're using our own version for now, as we had to modify them. Pull-requests are on their way.

### Start a Docker
Ensure the Dockerfile points to the right template (it's a symlink in order to make it more human):

``` Bash
$ ls -l Dockerfile
lrwxrwxrwx 1 USER USER    10 Nov 14 17:18 Dockerfile -> mailserver
```

Change it if you need:

``` Bash
$ rm Dockerfile
$ ln -s <file> Dockerfile
```

Build the image:

``` Bash
$ docker build -t ethack/mailserver --rm .
```

If no error during the build, just start an instance in order to see how it runs:

#### Interactive shell
``` Bash
$ docker run -t --rm -i ethack/mailserver /bin/bash
root@...:/# startall &
```

#### As a daemon
``` Bash
$ docker run -d -t  ethack/mailserver
$ docker ps
CONTAINER ID        IMAGE                      …
c5cbd7376a29        ethack/mailserver:latest   …

$ docker logs c5cbd7376a29
$ docker kill c5cbd7376a29
$ docker rm c5cbd7376a29
```

For more information about Docker, please read their documentation ;).

## Contribute
Please feel free to contribute, using pull-requests.
