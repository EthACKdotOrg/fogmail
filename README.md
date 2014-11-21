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
* ~~[tahoe-lafs](https://tahoe-lafs.org/trac/tahoe-lafs) or [Ceph](http://ceph.com/) with [BTRFS](https://btrfs.wiki.kernel.org/index.php/Main_Page) encryption~~
* [EncFS](https://vgough.github.io/encfs/) with either [XtreemFS](http://xtreemfs.org/) or [GlusterFS](http://www.gluster.org/) or anything like that
* [puppet](http://puppetlabs.com/)

Also, all the configurations will be open. Well, you won't get hand on the private keys for SSL certificates, of course. But all the other parts will be accessible. Here.

## Community
If the entry points will be managed by a couple of people ([@SwissTengu](https://twitter.com/swisstengu/) mostly), the design will allow people to help. Mostly for mail storage. Using decentralized filesystem, anyone wanting to give some giga to the project will be able to do so. We will provide a simple receipt allowing you to just apply it, and you're done.

## Decentralization
Mail aren't good for decentralization. And it will most probably never be. But still, we do have ways to do some nice things:

Dovecot supports master-master replication. This allows us to build several entry-points for your pop/imap access; as well, building several entries for postfix isn't a problem. We will just get "some" DNS entries for the MX field ;).

As previously stated, the main decentralized part will be for the storage. Probably the most important part in fact: mails are growing, we send more and more stuff through it. Thus we need storage. Using decentralized filesystem, we will be able to provide an infinit-storage, provided you, the community, participate and provide some spare gigas.


## Security
Probably the most interesting part. We want your communications to be encrypted. All of them. Even if you don't send them encrypted.

There are already [hacks](https://github.com/ajgon/gpg-mailgate) on postfix in order to encrypt emails — we will use them. Process will be simple: upon account creation, you might either provide a public key, or a new pair might be generated (locally, provided there actuall are efficient javascript libraries). We won't get hand on the private key. Ever. (Meaning: if you lose your key, well, you lose all your old emails… duh.)

Also, each node will be secured at the best possible. Running on closed environment, with no remote access. Updates will be followed closely (that's [@SwissTengu](https://twitter.com/swisstengu/) job for years now).

Also, all communication between nodes will be encrypted. 

## Access to emails
Well, yes, this may be interesting for you as well ;).

Mostly, we will focus on imaps/pop3s/smpts services. This will allow you to use Outlook (with some [PGP plugin](https://github.com/dejavusecurity/OutlookPrivacyPlugin)), Thunderbird (with [Enigmail](https://www.enigmail.net/home/index.php)), Mail (with [GPGTools](https://gpgtools.org/)). We will also have a look at existing webmails in order to provide an access. But we're not really happy with that. For your private key will be available in some way from the browser. And this is bad. Really.

So, maybe, no webmail. We do not trust the html5 local storage thing. You shouldn't as well.

## In short
We want to provide a really secure, strong, community managed service. As it will be fully open, anyone wanting to build his own infra will be able to do so.

Mails are important. Really. We write anything in them, we send them accross the Web. This project isn't just a "I had an idea this morning". We thought about it for months. It's time to get your privacy back, to get hand on probably the most valuable thing: your private communications.

## Want to test the stuff?
Great, we need people for tests/validation/ideas!

### Get Puppet and Docker
In order to get a reproducible environment, this is built using [Docker](https://docker.com/) and [Puppet](https://puppetlabs.com/). This allows us to do really fast tests and validations.

### Get sources
Clone this repository. As we're using submodules, you'll need to initialize them:

```Bash
$ git clone https://github.com/EthACKdotOrg/fogmail
$ cd fogmail
$ git submodule init
$ git submodule update
```

Or update them:

```Bash
$ git pull
$ git submodule init
$ git submodule update
```

### Start a Docker

First, you need to build the base box:

```Bash
$ ./build base
```

Once the base image is ready, you might build the introducer:

```Bash
$ ./build introducer
```

Once the introducer is ready, run it:

```Bash
$ ./run introducer
```

Get its IP, update the common.yaml file (in puppet/hiera directory), and build the two other boxes:

```Bash
$ ./build storage
$ ./build mailserver
```

And run them:

```Bash
$ ./run storage
$ ./run mailserver
```

Note: docker images will be flagged as follow:

- Repository: ethack
- Tag: introducer|storage|mailserver

Also, if you want to run "cleanDocker" script, ensure you don't have any of your images with "none" in its repository/tag… Else it will be dropped.

## Contribute
Please feel free to contribute, using pull-requests.
