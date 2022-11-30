# SSH Deployer Image

> This Docker image is a CI helper to execute remote commands using SSH.
> Basically, it is based on Alpine Linux and contains the OpenSSH client and a shell script.


## Getting started in 2 steps

1. Configure the following environment variables in your CI system:
- **SSH_HOST**: The hostname/IP of the remote server you want to connect to
- **SSH_PORT** (optional, defaults to `22`): The SSH port of the remote server
- **SSH_USER** (optional, defaults to `root`): The SSH user you want to authenticate with
- **SSH_FINGERPRINT**: can be retrieved by running `ssh-keyscan -H <server>`
- **SSH_PRIVATE_KEY**: can be retrieved by running `cat ~/.ssh/<your_private_key>`

You can also encode the fingerprint and private key values using base64 into *SSH_FINGERPRINT_BASE64* and *SSH_PRIVATE_KEY_BASE64*.
Do so by adding `| base64` after the command.

> Old images used the SERVER_HOST, SERVER_PORT and SERVER_FINGERPRINT variables.

2. Add the script to your CI step or workflow.

For example, for GitLab CI, you can add a deploy step to update a service after publication:
```yml
deploy:
  stage: deploy
  image: totakoko/sshdeployer
  script:
    - |
      remote "docker image pull $CI_REGISTRY_IMAGE/$CI_COMMIT_REF_SLUG:latest
              docker compose up -d service"
  only:
    - main
```


## License

[MIT](./LICENSE)
