<img src="https://raw.githubusercontent.com/e-cattle/art/master/eCattle.pnghttps://raw.githubusercontent.com/e-cattle/art/master/eCattle.png" width="300" alt="e-Cattle Logo" />

# Procedimentos para geração de imagem do BigBoxx utilizando Ubuntu Core 18

Esse script irá prover a geração de uma imagem customizada contendo os módulos snaps e demais dependências do e-Cattle BigBoxx no **Raspberry PI 3 Model B**.

## Pré-Requisitos

- Sistema Operacional Ubuntu Linux 18.04 ou superior
- O software ubuntu-image instalado
- O projeto **https://github.com/e-cattle/install.git**
- Uma conta **https://login.ubuntu.com/**
- Acesso na url **https://dashboard.snapcraft.io/dev/account/** para guardar o id snap **"Snap account-id"z   ** que será utilizado nos arquivos de configuração **bigboxx-model.json** e **bigboxx-user-assertion.json**.

## Procedimentos

### Passo 01: Gerando data e hora para os campos **timestamp** do arquivo **bigboxx-model.json** e **since** do arquivo **bigboxx-user-assertion.json**.

```shell
bigboxx@bigboxx:~/bigboxx/install$ date -Iseconds --utc
2020-01-12T13:41:34+00:00
```

### Passo 02: Editando arquivos de configuração

- No arquivo **bigboxx-model.json**, insira o **"Snap account-id"** nos campos **authority-id** e **brand-id**.

```shell
{
  "type": "model",
  "authority-id": "<Snap account-id>",
  "brand-id": "<Snap account-id>",
  "series": "16",
  "model": "bigboxx", <"Nome do modelo da imagem">
  "architecture": "arm64", <"Nome da Arquitetura que a imagem será gerada">
  "base": "core18", <Nome do kernel Base>
  "gadget": "pi=18-pi3",
  "kernel": "pi-kernel=18-pi3",
  "required-snaps": [ <"Dependências que serão inseridas na imagem">
    "bigboxx-kernel",
    "bigboxx-query",
    "bigboxx-totem",
    "bigboxx-lora"
  ],
  "timestamp": "<Resutado-commando-passo01>"
}

```

- No arquivo **bigboxx-user-assertion.json**, insira o valor do **"Snap account-id"** nos campos **authority-id** e **brand-id**.

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
  "since": "<Resutado-commando-passo01>",
  "until": "2999-12-23T13:26:01+00:00"
}

```

### Passo 03: Criação e registro da chave para assinatura dos arquivos de configuração no Ubuntu Store

- Para a geração da imagem, os arquivos **bigboxx-model.json**, responsável pelos parâmetros e dependências necessárias para criação da imagem, e o **bigboxx-user-assertion.json**, responsável pelos parâmetros de criação do usuário bigboxx, precisam ser assinados por uma chave reconhecida pela Canonical. Essa chave deve ser gerada e registrada na Store do Ubuntu **Snapcraft**.

- Criando a chave de nome **bigboxx**

```shell
bigboxx@bigboxx:~/bigboxx/install$ snapcraft create-key bigboxxvbox
Passphrase: 
Confirm passphrase: 
```

- Listando as chaves

```shell
bigboxx@bigboxx:~/bigboxx/install$ snap keys
Name     SHA3-384
bigboxxvbox  JaY6gxaNAPHVudjfjdskjdfksgPyjUzwQKotgk7rrBFzpXYo_iSMtVCILtSiSI
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

### Passo 04: Assinando os arquivos **bigboxx-model.json** e **bigboxx-user-assertion.json**

- Assinando **bigboxx-model.json**

```shell
bigboxx@bigboxx:~/bigboxx/install$ cat bigboxx-model.json | snap sign -k bigboxxvbox > bigboxx.model
You need a passphrase to unlock the secret key for
user: "bigboxxvbox"
4096-bit RSA key, ID 0B79B865, created 2020-01-08

Enter passphrase:
```

- Assinando **bigboxx-user-assertion.json**

```shell
bigboxx@bigboxx:~/bigboxx/install$ cat bigboxx-user-assertion.json | snap sign -k bigboxxvbox > bigboxx-user.assertion
You need a passphrase to unlock the secret key for
user: "bigboxxvbox"
4096-bit RSA key, ID 0B79B865, created 2020-01-08

Enter passphrase:
```


### Passo 05: Gerando a imagem

- Executar o script **create-image.sh** para gerar a imagem.

```shell
bigboxx@bigboxx:~/bigboxx/install$ sudo ./create-image.sh 
Warning: for backwards compatibility, `ubuntu-image` falls back to `ubuntu-image snap` if no subcommand is given
-o/--output is deprecated; use -O/--output-dir instead
Fetching snapd
Fetching core18
Fetching pi-kernel
Fetching pi
Fetching bigboxx-kernel
Fetching bigboxx-query
Fetching bigboxx-totem
Fetching bigboxx-lora
Fetching mir-kiosk
Fetching wpe-webkit-mir-kiosk
'/tmp/tmp.Uq28NJ7sa9/etc/systemd/journald.conf' -> '/tmp/tmp.iQWjoaleCF/system-data/etc/systemd/journald.conf'
'/tmp/tmp.Uq28NJ7sa9/etc/systemd/logind.conf' -> '/tmp/tmp.iQWjoaleCF/system-data/etc/systemd/logind.conf'
'/tmp/tmp.Uq28NJ7sa9/etc/systemd/logind.conf.d' -> '/tmp/tmp.iQWjoaleCF/system-data/etc/systemd/logind.conf.d'
'/tmp/tmp.Uq28NJ7sa9/etc/systemd/network' -> '/tmp/tmp.iQWjoaleCF/system-data/etc/systemd/network'
'/tmp/tmp.Uq28NJ7sa9/etc/systemd/resolved.conf' -> '/tmp/tmp.iQWjoaleCF/system-data/etc/systemd/resolved.conf'
'/tmp/tmp.Uq28NJ7sa9/etc/systemd/system' -> '/tmp/tmp.iQWjoaleCF/system-data/etc/systemd/system'
'/tmp/tmp.Uq28NJ7sa9/etc/systemd/system/cloud-init.target.wants' -> '/tmp/tmp.iQWjoaleCF/system-data/etc/systemd/system/cloud-init.target.wants'
'/tmp/tmp.Uq28NJ7sa9/etc/systemd/system/cloud-init.target.wants/cloud-config.service' -> '/tmp/tmp.iQWjoaleCF/system-data/etc/systemd/system/cloud-init.target.wants/cloud-config.service'
'/tmp/tmp.Uq28NJ7sa9/etc/systemd/system/cloud-init.target.wants/cloud-final.service' -> '/tmp/tmp.iQWjoaleCF/system-data/etc/systemd/system/cloud-init.target.wants/cloud-final.service'
'/tmp/tmp.Uq28NJ7sa9/etc/systemd/system/cloud-init.target.wants/cloud-init-local.service' -> '/tmp/tmp.iQWjoaleCF/system-data/etc/systemd/system/cloud-init.target.wants/cloud-init-local.service'
'/tmp/tmp.Uq28NJ7sa9/etc/systemd/system/cloud-init.target.wants/cloud-init.service' -> '/tmp/tmp.iQWjoaleCF/system-data/etc/systemd/system/cloud-init.target.wants/cloud-init.service'
'/tmp/tmp.Uq28NJ7sa9/etc/systemd/system/dbus-fi.w1.wpa_supplicant1.service' -> '/tmp/tmp.iQWjoaleCF/system-data/etc/systemd/system/dbus-fi.w1.wpa_supplicant1.service'
'/tmp/tmp.Uq28NJ7sa9/etc/systemd/system/dbus-org.freedesktop.resolve1.service' -> '/tmp/tmp.iQWjoaleCF/system-data/etc/systemd/system/dbus-org.freedesktop.resolve1.service'
'/tmp/tmp.Uq28NJ7sa9/etc/systemd/system/getty.target.wants' -> '/tmp/tmp.iQWjoaleCF/system-data/etc/systemd/system/getty.target.wants'
'/tmp/tmp.Uq28NJ7sa9/etc/systemd/system/getty.target.wants/getty@tty1.service' -> '/tmp/tmp.iQWjoaleCF/system-data/etc/systemd/system/getty.target.wants/getty@tty1.service'
'/tmp/tmp.Uq28NJ7sa9/etc/systemd/system/sshd.service' -> '/tmp/tmp.iQWjoaleCF/system-data/etc/systemd/system/sshd.service'
'/tmp/tmp.Uq28NJ7sa9/etc/systemd/system.conf' -> '/tmp/tmp.iQWjoaleCF/system-data/etc/systemd/system.conf'
'/tmp/tmp.Uq28NJ7sa9/etc/systemd/system.conf.d' -> '/tmp/tmp.iQWjoaleCF/system-data/etc/systemd/system.conf.d'
'/tmp/tmp.Uq28NJ7sa9/etc/systemd/timesyncd.conf' -> '/tmp/tmp.iQWjoaleCF/system-data/etc/systemd/timesyncd.conf'
'/tmp/tmp.Uq28NJ7sa9/etc/systemd/user' -> '/tmp/tmp.iQWjoaleCF/system-data/etc/systemd/user'
'/tmp/tmp.Uq28NJ7sa9/etc/systemd/user.conf' -> '/tmp/tmp.iQWjoaleCF/system-data/etc/systemd/user.conf'
'/tmp/tmp.Uq28NJ7sa9/etc/systemd/user.conf.d' -> '/tmp/tmp.iQWjoaleCF/system-data/etc/systemd/user.conf.d'
loop deleted : /dev/loop8
bigboxx@bigboxx:~/bigboxx/install$
```

- A imagem **bigboxx.img** foi gerada e está pronta para ser gravada no cartão.
