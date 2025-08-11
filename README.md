# 🛠️ Scripts Utilitários para Linux

Este repositório contém scripts simples e úteis como:

- 🔧 Alteração de DNS
- 🌡️ Cálculo da média de temperaturas registradas(testado para cpu com 8 nucleos utilizando o psensors)

---

## 📜 Scripts incluídos

| Nome do Script         | Linguagem | Função Principal                                       |
|------------------------|-----------|--------------------------------------------------------|
| `change_dns.sh`       | Shell     | Altera o DNS da conexão e faz backup das configurações antigas|
| `media_temperatura.py` | Python    | Calcula a média de temperaturas de um arquivo simples  |
| `media_regex.py`       | Python    | Calcula média de temperaturas extraídas com regex      |

---

## ⚙️ Requisitos

- Sistema baseado em Linux (testado no **Debian 12**)
- **Python 3.x** para os scripts `.py`
- **`nmcli`** instalado (vem com o `NetworkManager`) para o script de DNS

---

## 🚀 Como usar

### 1. Alterar DNS 
esta na pasta DNS do repositorio
```bash
chmod +x change.sh
sudo ./change_dns.sh

