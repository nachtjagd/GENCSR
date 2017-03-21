#!/bin/sh




### 生成ディレクトリ、ファイル関連

NOWTIME=`date +%s`

CURDIR=`dirname $0`
PREFIX="$CURDIR/SSL-${NOWTIME}"
mkdir -p ${PREFIX}

# コモンネーム
INCOMMONNAME="*.example.net"

# ワイルドカード証明書の場合コモンネームに'*'が入るのでファイル名は置換する
OUTCOMMONNAME=`echo $INCOMMONNAME |sed -e s/*/WILDCARD/g`


PRIVATEKEYPATH="${PREFIX}/${OUTCOMMONNAME}.key"
CSRPATH="${PREFIX}/${OUTCOMMONNAME}.0.csr"
PUBKEYPATH="${PREFIX}/${OUTCOMMONNAME}.cert"


#### ディスティングイッシュネーム情報 
Country="JP"
State="TOKYO"
Locality="AKIHABARA"
ON="HOGEHOGE-SHOP"
OU="IT Section"
Email="hogehoge@example.jp"
KEYLENGTH="2048"
DAYS=3650




# 秘密鍵の生成
openssl genrsa -out ${PRIVATEKEYPATH} ${KEYLENGTH}


# 秘密鍵の確認
openssl  rsa -text < ${PRIVATEKEYPATH}

# CSRの生成
create_csr()
 {
     expect -c "
         spawn openssl req -newkey rsa:${KEYLENGTH} -days ${DAYS} -key ${PRIVATEKEYPATH} -out ${CSRPATH} -text
         expect \"Country Name (2 letter code)*:\"
         send   \"${Country}\n\"
         expect \"State or Province Name (full name)*:\"
         send   \"${State}\n\"
         expect \"Locality Name (eg, city)*:\"
         send   \"${Locality}\n\"
         expect \"Organization Name (eg, company)*:\"
         send   \"${ON}\n\"
         expect \"Organizational Unit Name*:\"
         send   \"${OU}\n\"
         expect \"Common Name*:\"
         send   \"${OUTCOMMONNAME}\n\"
         expect \"Email Address*:\"
         send   \"\n\"
         expect \"A challenge password*:\"
         send   \"\n\"
         expect \"An optional company name*:\"
         send   \"\n\"
         interact
     "
    }

create_csr

#  証明書の生成
openssl x509 -days ${DAYS} -req -signkey ${PRIVATEKEYPATH} < ${CSRPATH} > ${PUBKEYPATH}


