# DevOps Project - Ollama Server with LLMs

This project demonstrates how to deploy an **Ollama server** on AWS to run and experiment with different **Large Language Models (LLMs)**.  
In this example, we use the **gpt-oss-20b** model (available on [Hugging Face](https://huggingface.co/openai/gpt-oss-20b)).

The infrastructure is created using **Terraform**, including:  
- **VPC and subnets**  
- **Security Groups**  
- **EC2** to run Ollama  
- Network configuration to allow access only from authorized IPs

---

## 📋 Requirements

- Active **AWS account** with sufficient permissions to create infrastructure (EC2, VPC, Security Groups, IAM).  
- **Git** to clone the repository.

---

## 🔑 AWS and Terraform Setup

Before running the scripts, export your credentials and apply the infrastructure with Terraform:

```bash
# Export your AWS credentials
export AWS_ACCESS_KEY_ID="your-access-key-id"
export AWS_SECRET_ACCESS_KEY="your-secret-access-key"
export AWS_REGION="us-east-1"

# Initialize Terraform
terraform init

# Apply the infrastructure (create VPC, Security Groups, EC2, etc.)
terraform apply

```
After applying Terraform, the output will include the public IP of your Ollama server:
```bash
Outputs:

ollama_server_ip = "52.50.2.24" # example
```
## 🧪 Ejemplo de uso de la API con Python
```python
from openai import OpenAI
 
# Reemplaza <OLLAMA_IP> con la IP que obtuviste de Terraform
client = OpenAI(
    base_url="http://<OLLAMA_IP>:11434/v1",  # Local Ollama API
    api_key="ollama"                         # Dummy key
)
 
response = client.chat.completions.create(
    model="gpt-oss:20b",
    messages=[
        {"role": "system", "content": "You are a helpful assistant."},
        {"role": "user", "content": "Explain what MXFP4 quantization is."}
    ]
)
 
print(response.choices[0].message.content)
```