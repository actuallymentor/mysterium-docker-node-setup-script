# mysterium-docker-node-setup-script

Setup script for Mysterium nodes using their docker config.

## Instructions

1. Clone this repo with `git clone https://github.com/actuallymentor/mysterium-docker-node-setup-script.git`
2. Change `PAYOUT_ADDRESS,` `APIKEY` and `PUBKEY`. The public key can be gotten with `cat ~/.ssh/yourkey.pub | pbcopy`
3. Run `cd mysterium-docker-node-setup-script && bash setup.sh`

### ⚠️ Caveats

1. The general VPS serup script used as the first setup step installs `zsh` and configures a number of (what I consider) sane defaults. If you do not want to have those set up, just comment out the `bash setup.sh silent` line.
2. If you do not change the value of `PUBKEY` you will lose access to your machine since it will add my SSH key to the maching instead of yours.
