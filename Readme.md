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

- No arquivo **bigboxx-model.json**, insira o **"Snap account-id"** nos campos **authority-id** e **brand-id**. No campo **timestamp** coloque a data e hora atual.

```shell
{
    ...
    "authority-id": "<Snap account-id>",
    "brand-id": "<Snap account-id>",
    ...
    ...
    "timestamp": "2019-12-23T13:26:01+00:00",
  }
```

- No arquivo **bigboxx-user-assertion.json**, insira o valor do **"Snap account-id"** nos campos **authority-id** e **brand-id**. Já no campo **since** coloque a data e hora atual.

```shell
{
    ...
    "authority-id": "<Snap account-id>",
    "brand-id": "<Snap account-id>",
    ...
    ...
    "since": "2020-01-07T13:26:01+00:00",
    ...
  }
```

### Passo 02: Criação e registro da chave para assinatura dos arquivos de configuração no Ubuntu Store

- Para a geração da imagem, os arquivos **bigboxx-model.json**, responsável pelos parâmetros e dependências necessárias para criação da imagem, e o **bigboxx-user-assertion.json**, responsável pelos parâmetros de criação do usuário bigboxx, precisam ser assinados por uma chave reconhecida pela Canonical. Essa chave certifica a integridade dos arquivos.

### Passo 03: Assinatura dos arquivos **bigboxx-model.json** e **bigboxx-user-assertion.json**

```shell
$ snap create-key <nome-da-chave>
Passphrase: <senha>
Confirm passphrase: <senha>
```

### Passo 04: Gerando a imagem

