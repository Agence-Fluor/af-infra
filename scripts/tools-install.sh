
#!/usr/bin/env bash
set -e

curl -L https://github.com/apple/pkl/releases/download/0.30.0/pkl-linux-amd64 -o /tmp/pkl
echo  "512eabf52a5b2107f3764fa18248d7ecf9c195f58ec5fef81f21c8b4d530e15e9a10ab272e13c7447a9a5a7681b9c0e5e66ad0b3b078e05f788c7ace1259bc9d /tmp/pkl" | sha512sum -c -
sudo mv  /tmp/pkl /usr/local/bin/pkl
sudo chmod +x /usr/local/bin/pkl
echo "pkl installed"

###

curl -L "https://get.helm.sh/helm-v4.0.1-linux-amd64.tar.gz" -o /tmp/helm.tar.gz
tar -xzf /tmp/helm.tar.gz -C /tmp/
echo  "40558c9c17a11e42410e242c6a1fdbb8b5818b1ab667a42cc6fa8a69a93eb6123fd26fbb16c536f02ab545e62b787e2dc379d5f1a8fedec101d71cedb9ff8ac0 /tmp/linux-amd64/helm" | sha512sum -c -
sudo mv /tmp/linux-amd64/helm /usr/local/bin/helm
sudo chmod +x  /usr/local/bin/helm
echo "Helm installed"


###

curl -L "https://github.com/derailed/k9s/releases/download/v0.50.16/k9s_linux_amd64.tar.gz" -o /tmp/k9s.tar.gz
tar -xzf /tmp/k9s.tar.gz -C /tmp/
echo  "e61fe7e0f5bb97ed806b66456179ede93e25e5b559f76674ff67701ddbb2fbe79baa5577b86a6b768bd9c9299f18d18ea1d7cbbc377e55ae38d2135c0fc0a003 /tmp/k9s" | sha512sum -c -
sudo mv /tmp/k9s /usr/local/bin/k9s
sudo chmod +x /usr/local/bin/k9s
echo "k9s installed"
