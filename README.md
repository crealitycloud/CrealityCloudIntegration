# Cura Creality Cloud Integration

This is a Cura plugin used to connect Creality Cloud.You can downlded the Creality Cloud App and register an account through this website.
<https://model.creality.com/> 

Plugin needs to be with Creality Cloud App and Creality Cloud WIFI box. Using the path:

Cura Creality Cloud Integration -> Creality Cloud App -> Creality Cloud WIFI box -> 3D printer

## Installation
Marketplace (recommended):

The plugin is available through the Cura Marketplace as the Creality Cloud plugin

Manually:

Download or clone the repository into [Cura configuration folder]/plugins/CrealityCloudIntegration

The configuration folder can be found via Help -> Show Configuration Folder inside Cura.

## Configuration
You need to modify the parameters to configure the different locale server environments. This parameter is in the CrealityCloudUtils.py files, self._env variable.

Global service(default): 

self._env = release_oversea 

Mainland China services:

self._env = release_local 

Test services:

self._env = test

## Included dependencies
This plugin contains a submodule/copy of the following dependecies:

[crcmod](http://crcmod.sourceforge.net/intro.html)

[jmespath](https://github.com/jmespath/jmespath.py)

[Crypto](http://crcmod.sourceforge.net/)

[aliyunsdkcore](https://github.com/aliyun/aliyun-openapi-python-sdk/tree/master/aliyun-python-sdk-core)

[aliyunsdkkms](https://github.com/aliyun/aliyun-openapi-python-sdk/tree/master/aliyun-python-sdk-kms)

[oss2](https://github.com/aliyun/aliyun-oss-python-sdk/tree/master/oss2)