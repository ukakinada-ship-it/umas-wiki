# Local Models and Compute Requirements

When using Ollama, you have access to a vast "library" of different models. However, unlike cloud APIs where the provider handles the hardware, running models locally means you are constrained by your own machine's specifications—specifically, your RAM and your GPU's VRAM (Video RAM).

## Understanding Model Sizes
Models are typically categorized by the number of "Parameters" they have (measured in Billions, or "B"). 
- **7B / 8B:** Small, fast models. Great for general tasks on laptops.
- **13B / 14B:** Medium models. Better reasoning, requires a decent GPU.
- **30B / 34B:** Large models. Excellent at coding, requires a powerful workstation.
- **70B+:** Massive models. Approaches GPT-4 level logic, but requires enterprise-grade hardware or multiple linked GPUs to run efficiently.

### Quantization
To make models fit on standard hardware, they are "quantized." This is a compression technique that reduces the precision of the model's weights (e.g., from 16-bit to 4-bit). It drastically reduces the memory required with only a minor drop in "smartness." Ollama handles this automatically, usually downloading 4-bit quantized versions by default.

## Recommended Models for Coding
If you are doing Agentic Coding locally, you want a model specifically trained on code.

1. **Llama 3 (8B):** `ollama run llama3`
   - *Best for:* General chat, fast autocomplete, running on almost any modern laptop.
2. **CodeLlama (7B or 13B):** `ollama run codellama`
   - *Best for:* Specifically trained for code generation and discussion.
3. **DeepSeek Coder (7B or 33B):** `ollama run deepseek-coder`
   - *Best for:* Currently considered one of the absolute best open-source models for complex coding tasks.
4. **Qwen 2.5 Coder (7B or 32B):** `ollama run qwen2.5-coder`
   - *Best for:* Extremely capable at agentic reasoning and following complex prompt instructions.

## Hardware Requirements
The rule of thumb for running quantized (4-bit) models is:

- **7B - 8B Models:** Require at least **8GB of RAM**. (Runs well on an M1/M2 Mac with 16GB Unified Memory, or a PC with an RTX 3060).
- **13B - 14B Models:** Require at least **16GB of RAM**. 
- **30B - 34B Models:** Require at least **32GB of RAM**. (Requires a high-end GPU like an RTX 3090/4090 with 24GB VRAM, or a Mac Studio).
- **70B Models:** Require at least **64GB of RAM**. 

### CPU vs. GPU
Ollama can run models using only your CPU, but it will be very slow (reading speed). 
For a usable Agentic Coding experience (where the AI needs to write hundreds of lines of code quickly), you *must* run the model on a GPU. 

Apple Silicon (M-series chips) are uniquely excellent for local AI because their memory is "Unified"—meaning the GPU can access all the system RAM, allowing you to run much larger models than a standard PC without buying expensive dedicated graphics cards.
