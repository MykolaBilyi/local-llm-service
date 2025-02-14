# Local LLM Service

## Description

This project is a [docker] containers configuration to run an AI model based on [llama.cpp] inference engine on your local machine as a service.
At the moment only NVidia hardware is supported.

## Quick start

This stack is meant to be used with convenience of [local services proxy](https://github.com/MykolaBilyi/local-service), check it beforehand.

### Get the Code

```sh
git clone https://github.com/MykolaBilyi/local-llm-service.git
cd local-llm-service
```

### 1. Obtain the model

You can get a GGUF model file from [Hugging Face] or other place that distribute models. I use [a script](https://gist.github.com/MykolaBilyi/8b7730d837b922e118fdcc76b35e1ec8) to download models from Ollama registry.

### 3. Set env vars in .env file

Copy the template file to *.env*:

```sh
cp env_template .env
```

Edit the *.env* file filling all missing values for your system. In most cases pointing the `MODELS_DIR` to your gguf models folder is all you need to do.

For better llama.cpp performance update `CUDA_DOCKER_ARCH` to the one matching your hardware. Check [Nvidia GPU compute capability chart](https://developer.nvidia.com/cuda-gpus)

### 1. Run the project

This step may take a while because docker images have to be built.

```sh
docker compose up -d
```

Web interface should be available at [llm.service.local](https://llm.service.local/).

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

## References

- [github.com: mpazdzioch/llamacpp-webui-glue](https://github.com/mpazdzioch/llamacpp-webui-glue)
- [github.com: mostlygeek/llama-swap](https://github.com/mostlygeek/llama-swap)

[docker]: https://www.docker.com/
[Hugging Face]: https://huggingface.co/
[llama.cpp]: https://github.com/ggerganov/llama.cpp
[Continue]: https://www.continue.dev/
