## Projeto: Automação de Verificação de Serviço Apache com Logs em NFS

Projeto realizado durante o programa de bolsas DevSecOps da Compass Uol, que tem como objetivo configurar um servidor NFS, montar o diretório compartilhado em uma instância EC2 com Amazon Linux 2, e automatizar a verificação do serviço Apache. A verificação é realizada a cada 5 minutos, e os logs são armazenados no diretório NFS.

---

## 1. Pré-requisitos

### 1.1. Gerar uma Chave Pública para Acesso ao Ambiente na AWS
Antes de configurar a EC2, é necessário gerar uma chave SSH para acesso:

* Acesse o **Console da AWS**.
* Navegue até o serviço **EC2**.
* No painel lateral esquerdo, clique em **Key Pairs** (Pares de Chaves).
* Clique em **Create key pair** (Criar par de chaves).
* Dê um nome para a chave e selecione o tipo **RSA**.
* Escolha o formato de arquivo para download da chave privada (**PEM**):
   - **PEM**: Para uso com OpenSSH ou para acessar via terminal no Linux.
* Clique em **Create key pair**. O arquivo será automaticamente baixado.

### 1.2. Criar Instância EC2 com Amazon Linux 2

1. **Acesse o Console da AWS:**
   - Navegue até o serviço **EC2**.

2. **Lançar uma nova Instância:**
   - No painel do EC2, clique no botão **Launch Instance**.

3. **Configurar a Instância:**
   - **Nome da Instância:** Insira um nome de sua preferência para sua instância.
   
   - **AMI (Amazon Machine Image):** Selecione **Amazon Linux 2 AMI (HVM), SSD Volume Type**.

   - **Tipo de Instância:** Escolha a opção **t3.small** (2 vCPUs, 2 GiB de memória).
   
   - **Chave SSH (Key Pair):** Selecione o par de chaves criado anteriormente para acessar a instância via SSH.
   
   - **Configurações de Rede:**
     - Escolha a **VPC** e a **subnet** apropriadas.
     - Mantenha **Auto-assign Public IP** ativado se desejar que a instância receba um IP público automaticamente.
   
   - **Configurações de Segurança:**
     - Crie ou selecione um **Security Group** que permita as portas necessárias (veja os detalhes no item 1.3).

4. **Configuração de Armazenamento:**
   - **Volume Root (EBS):** Altere o tamanho do armazenamento para **16 GB** e escolha o tipo **GP2 (SSD)**.

5. **Configurações Avançadas:**
   - Se necessário, configure parâmetros adicionais, como scripts de inicialização ou opções de monitoramento. Caso contrário, deixe as configurações padrão.

6. **Revisar e Lançar:**
   - Revise todas as configurações e clique em **Launch Instance**.

7. **Acessar a Instância:**
   - Após a instância ser iniciada, vá para a seção **Instances** no painel EC2.
   - Localize sua instância e clique em conectar.
   - Na sessão **Conexão de instância do EC2** selecione a opção **Conectar-se usando o EC2 Instance Connect**
   - E clique em conectar.

Agora, sua instância EC2 está configurada e pronta para o próximo passo.

### 1.3. Elastic IP e Configuração de Segurança

#### 1.3.1. Criar um Elastic IP

1. No Console da AWS, navegue até o serviço **EC2**.
2. No menu lateral esquerdo, clique em **Elastic IPs** em **Network & Security**.
3. Clique no botão **Allocate Elastic IP address**.
4. Na próxima tela, clique em **Allocate** para criar o Elastic IP.
5. O Elastic IP será exibido na lista. Selecione-o e clique em **Actions** -> **Associate Elastic IP address**.
6. Na janela de associação, selecione a instância EC2 à qual deseja associar o Elastic IP.
7. Clique em **Associate**.

#### 1.3.2. Configurar as Regras de Segurança no Security Group

1. No Console da AWS, ainda no serviço **EC2**, vá para **Security Groups** no menu lateral esquerdo.
2. Encontre o Security Group associado à sua instância EC2 e clique nele.
3. Na aba **Inbound rules** (Regras de entrada), clique em **Edit inbound rules**.
4. Adicione as seguintes regras:

   - **SSH (22/TCP):**
     - Tipo: **SSH**
     - Protocolo: **TCP**
     - Porta: **22**
     - Origem: **Anywhere (0.0.0.0/0)**.

   - **NFS (111/TCP 2049/TCP e UDP):**
     - Tipo: **Custom TCP Rule**
     - Protocolo: **TCP**
     - Porta: **111**
     - Origem: **Anywhere (0.0.0.0/0)**.
   - **NFS (111/UDP)**
     - **Custom UDP Rule**
     - Protocolo: **UDP**
     - Porta: **111**
     - Origem: **Anywhere (0.0.0.0/0)**.
   - **NFS (2049/TCP)**
     - **Custom TCP Rule**
     - Protocolo: **TCP**
     - Porta: **2049**
     - Origem: **Anywhere (0.0.0.0/0)**.
   - **NFS (2049/UDP)**
     - **Custom UDP Rule**
     - Protocolo: **UDP**
     - Porta: **2049**
     - Origem: **Anywhere (0.0.0.0/0)**.

   - **HTTP (80/TCP):**
     - Tipo: **HTTP**
     - Protocolo: **TCP**
     - Porta: **80**
     - Origem: **Anywhere (0.0.0.0/0)** para permitir acesso público.

   - **HTTPS (443/TCP):**
     - Tipo: **HTTPS**
     - Protocolo: **TCP**
     - Porta: **443**
     - Origem: **Anywhere (0.0.0.0/0)** para permitir acesso público.

5. Após adicionar todas as regras, clique em **Save rules** para aplicar as configurações.

---

## 2. Configuração do NFS

### 2.1. Montagem do NFS

No servidor EC2 digite os seguintes comandos:

```bash
sudo yum install nfs-utils -y
sudo mkdir -p /mnt/nfs
sudo mount -t nfs <NFS-Server-IP>:/nfs/share /mnt/nfs
```
* Onde o **NFS-Server-IP** é o IP privado de sua máquina EC2.

 **Verifique se a montagem foi bem-sucedida:**

```bash
df -h
```

### 2.2. Criar Diretório Pessoal no NFS

No servidor EC2 digite os seguintes comandos:

```bash
sudo mkdir -p /mnt/nfs/seu_nome
sudo chmod -R 777 /mnt/nfs/seu_nome
```
## 3. Instalação e Configuração do Apache

### 3.1. Instalar Apache

No servidor EC2 digite os seguintes comandos:

```bash
sudo yum install httpd -y
sudo systemctl start httpd
sudo systemctl enable httpd
```

Verifique o status do Apache:
```bash
systemctl status httpd
```

### 4. Criação do Script de Verificação

### 4.1. Script para Verificar o Status do Apache

Para utilizar o script `valida_apache.sh` do repositório do GitHub em seu próprio projeto, siga os passos abaixo:

1. **Clone o Repositório do GitHub:**
   - Primeiramente, clone o repositório que contém o script para sua máquina local. No terminal, execute o seguinte comando:

     ```bash
     git clone https://github.com/MatheusWastchukk/Projeto1-Compass.git
     ```

   - Isso criará um diretório chamado `Projeto1-Compass` com o conteúdo do repositório.

2. **Localize o Script no Repositório Clonado:**
   - Navegue até o diretório onde o script `valida_apache.sh` está localizado. Use o comando `cd` para mudar para o diretório apropriado. Por exemplo:

     ```bash
     cd Projeto1-Compass
     ```

3. **Copie o Script para o Diretório de Execução:**
   - Para tornar o script acessível para execução, copie o arquivo `valida_apache.sh` para o diretório `/usr/local/bin` na sua máquina. Execute:

     ```bash
     sudo cp valida_apache.sh /usr/local/bin/valida_apache.sh
     ```

   - Certifique-se de que o nome do script no diretório de destino seja `valida_apache.sh` ou o nome que você preferir.

4. **Dê Permissões de Execução ao Script:**
   - Torne o script executável com o seguinte comando:

     ```bash
     sudo chmod +x /usr/local/bin/valida_apache.sh
     ```
5. **Verifique o Conteúdo do Script:**
   - Caso você precise verificar seu conteúdo, para alterar o nome do diretório, use um editor de texto como `nano` para abrir o arquivo:

     ```bash
     sudo nano /usr/local/bin/valida_apache.sh
     ```

   - Se necessário, altere o seguinte conteúdo ao script, trocando "seu_nome" pelo nome que está utilizando em seu diretório:

     ```bash
     if [ "$STATUS" = "active" ]; then
         MESSAGE="ONLINE"
         echo "$TIMESTAMP $SERVICE $STATUS $MESSAGE" >> /mnt/nfs/seu_nome/apache_online.log
     else
         MESSAGE="OFFLINE"
         echo "$TIMESTAMP $SERVICE $STATUS $MESSAGE" >> /mnt/nfs/seu_nome/apache_offline.log
     fi
     ```

   - Salve e saia do editor pressionando `Ctrl+X`, depois `Y` e `Enter`.
   
### 4.2. Automação com Crontab

Para automatizar a execução do script `valida_apache.sh` a cada 5 minutos, você precisa configurar o cron:

1. **Edite o Crontab:**
   - Abra o arquivo de configuração do cron para edição com o comando:

     ```bash
     crontab -e
     ```

2. **Adicione a Linha de Configuração:**
   - No editor que abrir, adicione a seguinte linha para executar o script a cada 5 minutos:

     ```bash
     */5 * * * * /usr/local/bin/valida_apache.sh
     ```

   - Salve e saia do editor pressionando `Ctrl+X`, depois `Y` e `Enter`.

3. **Verifique a Tabela do Crontab:**
   - Para garantir que a nova tarefa foi adicionada corretamente, liste as tarefas agendadas com:

     ```bash
     crontab -l
     ```

   - Isso deve mostrar a linha que você adicionou, confirmando que o cron está configurado para executar o script a cada 5 minutos.


Com isso, o script `valida_apache.sh` estará disponível em sua máquina e configurado para verificar o status do Apache a cada 5 minutos.

## 5. Testes e Verificações

### 5.1. Verifique o Funcionamento do Script

Para garantir que o script `valida_apache.sh` está funcionando corretamente, execute-o manualmente com o seguinte comando:

```bash
sudo /usr/local/bin/valida_apache.sh
```

* Após executar o comando certifique-se de verificar se o log foi gerado corretamente utilizando os comandos:
     ```bash
     cat /mnt/nfs/seu_nome/apache_online.log
     cat /mnt/nfs/seu_nome/apache_offline.log
     ```

- Substitua `seu_nome` pelo nome do diretório que você criou no NFS.

### 5.2. Testar a Automação

Depois de configurar o `crontab`, é importante verificar se a automação está funcionando corretamente. Para isso:

* **Verifique os Logs Gerados:**
   - Certifique-se de que os logs estão sendo gerados corretamente no diretório NFS. Utilize os seguintes comandos para visualizar o conteúdo dos arquivos de log:

     ```bash
     cat /mnt/nfs/seu_nome/apache_online.log
     cat /mnt/nfs/seu_nome/apache_offline.log
     ```

   - Substitua `seu_nome` pelo nome do diretório que você criou no NFS. Verifique se os logs estão sendo atualizados a cada 5 minutos, conforme configurado no `crontab`.
