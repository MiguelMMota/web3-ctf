FROM ghcr.io/foundry-rs/foundry:latest

# Set working directory
WORKDIR /app

# Check if git is available, install if not. Then initialise git repository.
# These are needed to install forge dependencies
RUN git --version || (apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*)
RUN git init . && \
    git config --global user.email "docker@example.com" && \
    git config --global user.name "Docker Build"

COPY foundry.toml ./

# Install dependencies using forge (this downloads them automatically)
RUN forge install foundry-rs/forge-std@f73c73d
RUN forge install OpenZeppelin/openzeppelin-contracts@932fddf

# Manually clone the older version to a specific directory
RUN git clone https://github.com/OpenZeppelin/openzeppelin-contracts.git lib/openzeppelin-contracts-06 && \
    cd lib/openzeppelin-contracts-06 && \
    git checkout fa64a1c

COPY src/ ./src/
COPY script/ ./script/
COPY .env ./.env
COPY .password ./.password

RUN forge build

CMD ["bash"]