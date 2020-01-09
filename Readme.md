<img src="https://raw.githubusercontent.com/e-cattle/art/master/eCattle.pnghttps://raw.githubusercontent.com/e-cattle/art/master/eCattle.png" width="300" alt="e-Cattle Logo" />

# Procedimentos para geração de imagem do BigBoxx utilizando Ubuntu Core 18

Esse script irá prover a geração de uma imagem customizada contendo os módulos snaps e demais dependências do e-Cattle BigBoxx no **Raspberry PI 3 Model B**.

## Pré-Requisitos

- Sistema Operacional Ubuntu Linux 18.04 ou superior
- O software ubuntu-image instalado
- O projeto **https://github.com/e-cattle/install.git**
- Uma conta **https://login.ubuntu.com/**
- Acesso na url **https://dashboard.snapcraft.io/dev/account/** para guardar o id snap **"Snap account-id" 2njk2832up839jik393** que será utilizado nos arquivos de configuração **bigboxx-model.json** e **bigboxx-user-assertion.json**.

## Procedimentos

### Passo 01: Editar os arquivos de configuração

- No arquivo **bigboxx-model.json**, insira o **"Snap account-id"** nos campos **authority-id** e **brand-id**. Já no campo **timestamp**, use o comando **$ date -Iseconds --utc** => **2020-01-09T02:22:23+00:00**.

```shell
{
  "type": "model",
  "authority-id": "<Snap account-id>",
  "brand-id": "<Snap account-id>",
  "series": "16",
  "model": "bigboxx", <Nome do modelo da imagem>
  "architecture": "arm64", <Nome da Arquitetura que a imagem será gerada>
  "base": "core18", <Nome do kernel Base>
  "gadget": "pi=18-pi3",
  "kernel": "pi-kernel=18-pi3",
  "required-snaps": [ <Dependencias que serão inseridas na imagem>
    "bigboxx-kernel",
    "bigboxx-query",
    "bigboxx-totem",
    "bigboxx-lora"
  ],
  "timestamp": "2020-01-09T02:22:23+00:00"
}

```

- No arquivo **bigboxx-user-assertion.json**, insira o valor do **"Snap account-id"** nos campos **authority-id** e **brand-id**. Já no campo **since**, use o comando **$ date -Iseconds --utc** => **2020-01-09T02:22:23+00:00**.

```shell
{
  "type": "system-user",
  "authority-id": "<Snap account-id>",
  "brand-id": "<Snap account-id>",
  "series": ["16"],
  "models": ["bigboxx"],
  "name": "Default Bigboxx User",
  "username": "bigboxx",
  "email": "bigboxx@localhost",
  "password": "$6$cS38YDN5rvWBNJuU$T/ZuXdKKUCMZblGYbEl.9iwAaK.gIKDTlYiUAFEyMBRLAiEX4sNOMAGXVQ9nw9rQT6VBQO08QUrb7KJQGLM2A1",
  "since": "2020-01-09T02:25:23+00:00",
  "until": "2999-12-23T13:26:01+00:00"
}

```

### Passo 02: Criação e registro da chave para assinatura dos arquivos de configuração no Ubuntu Store

- Para a geração da imagem, os arquivos **bigboxx-model.json**, responsável pelos parâmetros e dependências necessárias para criação da imagem, e o **bigboxx-user-assertion.json**, responsável pelos parâmetros de criação do usuário bigboxx, precisam ser assinados por uma chave reconhecida pela Canonical. Essa chave deve ser gerada e registrada na Store do Ubuntu **Snapcraft**.

- Criando a chave de nome **bigboxx**

```shell
bigboxx@bigboxx:~/bigboxx/install$ snap create-key bigboxx
Passphrase: 
Confirm passphrase: 
```

- Listando as chaves

```shell
bigboxx@bigboxx:~/bigboxx/install$ snap keys
Name     SHA3-384
bigboxx  JaY6gxaNAPHVudjfjdskjdfksgPyjUzwQKotgk7rrBFzpXYo_iSMtVCILtSiSI
```


- Registrando na Snapcraft

```shell
bigboxx@bigboxx:~/bigboxx/install$ snapcraft register-key 
Enter your Ubuntu One e-mail address and password.
If you do not have an Ubuntu One account, you can create one at https://dashboard.snapcraft.io/openid/login
Email: bigboxx@email.com
Password: 

We strongly recommend enabling multi-factor authentication: https://help.ubuntu.com/community/SSO/FAQs/2FA
Registering key ...
Done. The key "bigboxxvbox" (gyx_EP0IECiZclikao4gZdocoq_bWeicJBJ5w1iJCPKRai0TV65icz-sDC3G0FLi) may be used to sign your assertions.

```

### Passo 03: Assinando os arquivos **bigboxx-model.json** e **bigboxx-user-assertion.json**

- Assinando **bigboxx-model.json**

```shell
cat bigboxx-model.json | snap sign -k <nome-da-chave> > bigboxx.model
You need a passphrase to unlock the secret key for
user: "<nome-da-chave>"
4096-bit RSA key, ID 0B79B865, created 2020-01-08

Enter passphrase:
```

- Assinando **bigboxx-model.json**

```shell
cat bigboxx-user-assertion.json | snap sign -k <nome-da-chave> > bigboxx-user.assertion
You need a passphrase to unlock the secret key for
user: "<nome-da-chave>"
4096-bit RSA key, ID 0B79B865, created 2020-01-08

Enter passphrase:
```


### Passo 04: Gerando a imagem

