### NFT文档

#### 创建说明

1.该合约是基于erc1155创建，和erc721的区别在于可以批量铸造nft以及批量转移

2.本nft创建参考cryptokites和meme方式，都是将nft源资源文件储存于中心化服务器上

3.每个nft对应一个id，创建时nft的id从1开始自增，并在创建前将对应的配置文件储存在服务器对应目录

举例说明：

​	假设服务器对于域名为： https://hackerlink.io/，项目目录为hackerlink，那么我们可以在该hackerlink目录下配置一个名称为nft的文件夹专门存放nft的资源文件和配置文件。

​	首先需要创建一个整体项目的配置文件，名字随意比如叫做hackerlink.json（该文件的完整路径在部署合约时候需要，最下面部署合约1136行对应的返回值），内容至少需要按照以下格式：（参考：https://learnblockchain.cn/docs/eips/eip-1155.html#）

~~~
{
  "name": "HackerLink NFT.",
  "description": "NFT achievement badges for HackerLink Hackers",
  "image": "https://hackerlink.io/hackerlink/nft/img/icon.png",
  "external_link": "https://hackerlink.io/"
}
~~~

​	其次，在创建nft文件的时候需要准备好此nft的信息，从1开始递增，例如创建第一个名为Hackathon Winner的nft，那么需要先创建一个名为1（对应id）的配置文件，此文件不用后缀名，内容按照以下格式：（参考：https://learnblockchain.cn/docs/eips/eip-1155.html#）

```
{
    "name": "Hackathon Winner",
    "description": "Desc: this is Hackathon Winner",
    "external_url": "https://hackerlink.io/hackerlink/nft/1",
    "image": "https://hackerlink.io/hackerlink/nft/img/1.png"
}
```

注意，此文件中的external_url 是固定格式： 前面为（域名+项目名称+你配置的nft文件夹名  ），后面 + nft的对应id

然后确保此nft对应的资源文件（图片或者视频）存在对应的文件夹下并有访问权限（本示例中为"https://hackerlink.io/hackerlink/nft/img/1.png"）

以上准备妥当就可以使用部署的合约铸造第一个名为Hackathon Winner的nft，此nft的ID为1.



#### 合约铸造方法

```
function create(
    address _initialOwner,
    uint256 _initialSupply,
    string calldata _uri,
    bytes calldata _data
  )
  注：此方法仅限于Owner调用
  参数说明：
  _initialOwner为铸造给谁，为接收此nft的地址
  _initialSupply为铸造多少数量
  _uri不需要，填“”即可，方便以后扩展
  _data 不需要，填0x即可，方便以后扩展
  
```

#### 部署合约

选择HackerLink.sol文件，部署前修改四处代码：

1129行：ERC1155Tradable（）两个参数，分别为nft的_name和_symbol

1133行：_setBaseMetadataURI()参数为自己服务器上nft文件对应的父文件夹目录地址，如： https://hackerlink.io/hackerlink/nft/

1136行：return ""; 返回值应该为nft项目配置文件的具体路径，如：https://hackerlink.io/nft/hackerlink.json

部署的时候需要一个参数：固定值：0xa5409ec958c83c3f309868babaca7c86dcb077c1