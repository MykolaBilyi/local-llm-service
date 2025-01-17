# Local LLM Service

## Description

This project is a [docker] container configuration to run an AI model based on [llama.cpp] inference engine on your local machine as a service.

## Quick start

It's developed and tested on linux. Not tested on other OSs

### Get the Code

```sh
git clone https://github.com/MykolaBilyi/local-llm-service.git
cd local-llm-service
```

### 1. Obtain the model

FIXME How to obtain model?

### 2. Set env vars in .env file

Copy the template file to *.env*:

```sh
cp env_template .env
```

Edit the *.env* file filling all missing values for your system. In most cases pointing the `MODEL_DIR` and `MODEL_GGUF` to your gguf model file is all you need to do.

For advanced `llama.cpp` configuration you can add here environment variables from [llama.cpp documentation](https://github.com/ggerganov/llama.cpp/tree/master/examples/server), e.g `LLAMA_ARG_MODEL_DRAFT=/models/qwen2.5-coder_0.5b-instruct-q4_0.gguf`

### 3. Run the project

This step may take a while because docker images have to be built.

```sh
docker compose up -d
```

Web interface should be available at [localhost:23322](http://localhost:23322) when running the service this way

### Install the LLM inference engine as a `systemd` service

Installing LLM engine as a `systemd` service allows you to run it in the background and automatically start it upon request.

```sh
sudo ln -s $PWD/systemd/* /etc/systemd/system
sudo systemctl daemon-reload
sudo systemctl enable assistant-proxy.socket
sudo systemctl start assistant-proxy.socket
```

When configured, `assistant-proxy` opens socket and listens on the [localhost:23323](http://localhost:23323) port. On connection, it starts `assistant` service and forwards trafic to local `23322` port.
Therefore it is recommended to use [localhost:23323](http://localhost:23323) as configuration endpoint in your client applications.

`assistant` service is automatically stopped after 10 minutes of inactivity.

## Examples

### Configure [Continue] VSCode [extension](https://marketplace.visualstudio.com/items?itemName=Continue.continue)

Add the following configuration to your continue [config.json](https://docs.continue.dev/customize/deep-dives/configuration):

```json
  "models": [
    {
      "title": "Local Model",
      "provider": "llama.cpp",
      "apiBase": "http://localhost:23323",
      "model": "local"
    }
  ],
  "tabAutocompleteModel": {
    "title": "Local Model",
    "provider": "llama.cpp",
    "apiBase": "http://localhost:23323",
    "model": "local"
  },
```

## Common problems

1. After successful run you get `ggml_cuda_init: failed to initialize CUDA: unknown error`
    - This error is probably related to [system sleep & wake up](https://github.com/ggerganov/llama.cpp/issues/7218#issuecomment-2241202604). Try to re-initialize the `nvidia_uvm` module:

    ```sh
    sudo modprobe -r nvidia_uvm && sudo modprobe nvidia_uvm
    ```

    - This can be automated by adding restart of the module to the systemd `assistant.service`:

    ```sh
    sudo edit assistant.service
    ```

    Add the following lines to the `[Service]` section:

    ```sh
    [Service]
    ExecStartPre=/usr/bin/docker stop $CONTAINER
    ExecStartPre=-/usr/bin/bash -c "/usr/sbin/modprobe -r nvidia_uvm && /usr/sbin/modprobe nvidia_uvm"
    ```

## References

- [kasad.com: Start Docker containers on-demand with systemd socket activation](https://kasad.com/blog/systemd-docker-socket-activation/)

[docker]: https://www.docker.com/
[llama.cpp]: https://github.com/ggerganov/llama.cpp
[Continue]: https://www.continue.dev/
