# Eth address
#PAYOUT_ADDRESS=0x.....

# Given on mystnodes.com
#APIKEY=ABC123

# Your public key
#PUBKEY="ssh-rsa AAAA..."

## ##############################
## VPS general setup
## see: https://github.com/actuallymentor/vps-setup-ssh-zsh-pretty
## ##############################

git clone https://github.com/actuallymentor/vps-setup-ssh-zsh-pretty.git setup && cd setup

if [[ -v PUBKEY ]]; then
	echo "Overriding Mentor's SSH key with yours"
	echo $PUBKEY > key.pub
fi

bash setup.sh silent
cd .. && rm -rf ./setup


## ###############
## Docker install
## see: https://docs.docker.com/engine/install/ubuntu/
## ###############
sudo apt update
sudo apt install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io

## ##############################
## Install network monitor
## ##############################
sudo apt install -y vnstat

## ##############################
## Start/install myst
## Set as cron
## ##############################

echo -e '
docker pull mysteriumnetwork/myst:latest && \
docker stop myst  || echo "No myst installed" && \
docker rm -f myst || echo "No myst installed" && \
docker run \
	--restart unless-stopped \
	--cap-add NET_ADMIN \
	-d -p 4449:4449 \
	--name myst \
	-v myst-data:/var/lib/mysterium-node mysteriumnetwork/myst:latest \
	service --agreed-terms-and-conditions
' > $HOME/start-and-update-myst.sh

bash $HOME/start-and-update-myst.sh

echo "0 9 * * 1 root bash $HOME/start-and-update-myst.sh" > /etc/cron.d/myst_update_cron

# Add identity variable on login
echo 'identity=$( docker exec myst myst cli identities list | grep -Po "0x.*" )
' >> ~/.zshrc

## ##############################
## One-time setup, claiming node
## ##############################

# Wait for myst to start
sleep 10
identity=$( docker exec myst myst cli identities list | grep -Po "0x.*" )
channel=$( docker exec myst myst cli identities get $identity | grep -Po "(?<=address: )(0x.*$)" )
echo "Identity is: $identity"
echo "Channel is: $channel"
echo "Please transfer the minimum 0.1 MYST bond to $channel"
echo "Select MYST on https://wallet.polygon.technology/wallet"
echo "Wait for 20 transaction confirmations before you continue"
echo "Press any key to continue..."
read

echo -e "\nNOTE: if the registration says 'expected 202 got 200' that is probably fine, so long as the node shows up on mystnodes.com\n"

docker exec myst myst cli identities unlock $identity
docker exec myst myst cli identities register $identity
docker exec myst myst cli mmn $APIKEY
docker exec myst myst cli identities set-payout-address $identity $PAYOUT_ADDRESS
docker exec myst myst cli identities get $identity

echo -e "\nIf the above shows 'Registration Status: Registered' you are good"
