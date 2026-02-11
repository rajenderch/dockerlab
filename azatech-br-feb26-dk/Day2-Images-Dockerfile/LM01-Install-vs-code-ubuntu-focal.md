
## 🚀 Install **Visual Studio Code** on Ubuntu 20.04 (Focal)

### 1️⃣ Update packages

```bash
sudo apt update
sudo apt upgrade -y
```

---

### 2️⃣ Install prerequisites

```bash
sudo apt install wget gpg apt-transport-https software-properties-common -y
```

---

### 3️⃣ Add Microsoft GPG key

```bash
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo install -o root -g root -m 644 microsoft.gpg /usr/share/keyrings/
```

---

### 4️⃣ Add the VS Code repository (Focal compatible)

```bash
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
```

---

### 5️⃣ Install VS Code

```bash
sudo apt update
sudo apt install code -y
```

---

### 6️⃣ Launch VS Code

```bash
code
```

Or open it from **Applications → Visual Studio Code**

---

## ✅ Verify

```bash
code --version
```

---

## 🟢 Alternative (Simpler but slightly slower startup)

```bash
sudo snap install code --classic
```

