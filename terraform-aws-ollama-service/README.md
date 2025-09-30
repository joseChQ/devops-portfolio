# DevOps Project - Ollama Server with LLMs

This project demonstrates how to set up an **Ollama server** on AWS to run and experiment with different Large Language Models (LLMs).  
In this example, we focus on the **gpt-oss-20b** model, available on [Hugging Face](https://huggingface.co/openai/gpt-oss-20b).  
The setup uses a **Deep Learning AMI** and an **EC2 g6.xlarge** instance with GPU support.

---

## 📋 Requirements

Before running this project, make sure you have:

- An active **AWS account**.
- A **Deep Learning AMI** compatible with GPU instances.
- An **EC2 instance** of type `g6.xlarge` (or higher recommended).
- **Ollama** installed on the server.
- **Git** to clone the repository.
- **Python 3.10+** (optional, for scripts or automation).
- **Docker** (optional, if you plan to containerize the service).

---

## 🔑 AWS Environment Variables

Export your AWS credentials and region before running the project:

```bash
export AWS_ACCESS_KEY_ID="your-access-key-id"
export AWS_SECRET_ACCESS_KEY="your-secret-access-key"
export AWS_REGION="us-east-1"
```

These variables allow the infrastructure scripts to authenticate and deploy resources in AWS.

---

## 🚀 Installation & Setup

1. Clone this repository:

   ```bash
   git clone https://github.com/your-username/ollama-devops.git
   cd ollama-devops
   ```

2. Launch an EC2 instance on AWS using the Deep Learning AMI.

3. Install Ollama on the instance:

   ```bash
    curl -fsSL https://ollama.com/install.sh | sh
   ```

4. Pull the gpt-oss-20b model:

   ```bash
    ollama pull gpt-oss-20b
   ```

5. Start the Ollama server:

   ```bash
   ollama serve
   ```

---

## 🧪 Testing

Run the model directly:

```bash
ollama run gpt-oss-20b
```

---

## 📂 Project Structure

```
ollama-devops/
│── docs/ # Additional documentation
│── scripts/ # Automation and infrastructure scripts
│── terraform/ # IaC configuration (if using Terraform)
│── docker/ # Container-related files
│── README.md
```

---

## 📄 License

This project is for personal and educational purposes. Feel free to adapt and extend it.