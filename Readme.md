<img src="https://raw.githubusercontent.com/e-cattle/art/master/eCattle.pnghttps://raw.githubusercontent.com/e-cattle/art/master/eCattle.png" width="300" alt="e-Cattle Logo" />

# Procedimentos para geração de imagem do BigBoxx utilizando Ubuntu Core 18

Esse script irá prover a geração de uma imagem customizada contendo os módulos snaps e demais dependências do e-Cattle BigBoxx no **Raspberry PI 3 Model B**.

## Pré-Requisitos

- Sistema Operacional Ubuntu Linux 18.04 ou superior
- O software ubuntu-image instalado
- O projeto **https://github.com/e-cattle/install.git**
- Uma conta **https://login.ubuntu.com/**
- Acesso na url **https://dashboard.snapcraft.io/dev/account/** para guardar o id snap **"Snap account-id" 2njk2832up839jik393** que serão utilizados nos arquivos de configuração da imagem **bigboxx-model.json** e de criação do usuário **bigboxx-user-assertion.json**.

## Procedimentos

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

- No arquivo **bigboxx-user-assertion.json**, insira o **"Snap account-id"** nos campos **authority-id** e **brand-id**. No campo **since** coloque a data e hora atual.

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
