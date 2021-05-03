# iocage-plugin-mirakurun
Mirakurun用iocage-pluginの構成ファイルを管理するためのリポジトリです。

https://github.com/Chinachu/Mirakurun

Readme: [English](https://github.com/fuji44/iocage-plugin-mirakurun/blob/main/README.md)

## 前提と注意

- iocage-plugin-mirakurunはFreeBSD jailを基盤として動作します。
- 動作させるには、DVRチューナーとスマートカードリーダーが必要です。
- ハードウェアをサーバに接続し、ホストOS(FreeBSD、TrueNASなど)で正しく認識できている必要があります。
- Jailからハードウェアにアクセスするための許可を与える必要があります。

## インストール

まず、チューナーやスマートカードリーダーのデバイスファイルにアクセスできるように、 `/etc/devfs.rules` にルールを追加してください。既存のルールが使用できる場合は、追加する必要はありません。

ここでは以下の例を使います。

```
[usbrules=100]
add path 'usbctl' mode 660 group uucp
add path 'usb/' mode 660 group uucp
add path 'ttyU*' mode 660 group uucp
```

そして、いくつかのオプションを付けてプラグインをインストールします。 `mount_devfs` と `allow_mount_devfs` のオプションをyesにして、 `devfs_ruleset` に前の手順で追加したルール番号を指定します。

```
sudo iocage fetch -P mirakurun -n mirakurun -g https://github.com/fuji44/iocage-fuji44-plugins.git --branch main ip4_addr="em0|192.168.0.100/24" mount_devfs=yes allow_mount_devfs=yes devfs_ruleset=100
```

多数のパッケージのビルドとインストールを行うためかなり時間が掛かります。

インストールが正常に完了すると、以下のURLにアクセスしてWebUIを見ることができるようになります。ただし、チューナーやチャンネルの設定が完了するまでは何もできません。

`http://your_ip_addr:40772/`

## 設定

プラグインをインストールした後は、チューナーやチャンネルの設定が必要になります。詳しくは[公式ドキュメント](https://github.com/Chinachu/Mirakurun/blob/master/doc/Configuration.md)を見てください。

設定はWebUIからでも行えます。WebUIでは、サーバー、チューナー、チャンネルの設定のほか、チューナーの使用状況、ログ、イベント履歴などを確認することができます。

チャンネルに関しては、スキャンして自動設定することができます。実行するためにWebAPIにリクエストを送る必要がありますが、これはSuwagger UIから簡単に行うことができます。

- Suwagger UI: `http://your_ip_addr:40772/api/debug`
- Scan Channels: `http://your_ip_addr:40772/api/debug?url=/api/docs#/config/channelScan`

広い範囲のチャンネルをスキャンする場合は、非常に長い時間がかかります。WebUIのイベント履歴を眺めつつ、コーヒーを飲んで待ちましょう。
