# GraphQL implementation for InterSystems Data Platforms


[![Gitter](https://img.shields.io/badge/chat-on%20telegram-blue.svg)](https://t.me/joinchat/FoZ4M0Gl5vGiZ-e0HvFOUQ) 
[![Gitter](https://img.shields.io/badge/article-on%20community-blue.svg)](https://community.intersystems.com/post/graphql-intersystems-data-platforms)
[![Gitter](https://img.shields.io/badge/demo-server-green.svg)](http://37.139.6.217:57773/graphiql/index.html)



## Install GraphQL
1) Download the [last release](https://github.com/intersystems-ru/GraphQL/releases).
2) Import it to the target Caché namespace, f.e. to `SAMPLES`.
3) Create new web aplication:
    - Name - `/`
    - Namespace - your target namespace, f.e. `SAMPLES`
    - Dispatch Class - `GraphQL.REST.Main`


## Install GraphiQL
1) Use an [available release](https://github.com/intersystems-ru/GraphQL/releases) or [build](https://github.com/graphql/graphiql) it on your own
2) Create new web aplication:
    - Name - `/graphiql`
    - Namespace - your target namespace, f.e. `SAMPLES`
    - CSP Files Physical Path - f.e. `C:\InterSystems\GraphiQL\`

## Installation with ZPM

If the current ZPM instance is not installed, then in one line you can install the latest version of ZPM even with a proxy.
```
s r=##class(%Net.HttpRequest).%New(),proxy=$System.Util.GetEnviron("https_proxy") Do ##class(%Net.URLParser).Parse(proxy,.pr) s:$G(pr("host"))'="" r.ProxyHTTPS=1,r.ProxyTunnel=1,r.ProxyPort=pr("port"),r.ProxyServer=pr("host") s:$G(pr("username"))'=""&&($G(pr("password"))'="") r.ProxyAuthorization="Basic "_$system.Encryption.Base64Encode(pr("username")_":"_pr("password")) set r.Server="pm.community.intersystems.com",r.SSLConfiguration="ISC.FeatureTracker.SSL.Config" d r.Get("/packages/zpm/latest/installer"),$system.OBJ.LoadStream(r.HttpResponse.Data,"c")
```
If ZPM is installed, then ZAPM can be set with the command
```
zpm:USER>install isc-graphql
```
## Installation with Docker

## Prerequisites
Make sure you have [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) and [Docker desktop](https://www.docker.com/products/docker-desktop) installed.

## Installation 
Clone/git pull the repo into any local directory

```
$ git clone https://github.com/SergeyMi37/GraphQL.git
```

Open the terminal in this directory and run:

```
$ docker-compose build
```

3. Run the IRIS container with your project:

```
$ docker-compose up -d
```
	
## Example
Query and Result

![sample](https://pp.userapi.com/c837337/v837337052/61752/mXbbCHhBl9M.jpg)     ![sample](https://pp.userapi.com/c837337/v837337052/6173c/6elLjldPiRA.jpg) 

![sample](https://pp.userapi.com/c837337/v837337052/61761/vPCZvIXgcJk.jpg)     ![sample](https://pp.userapi.com/c837337/v837337052/6174b/Zd2000W64HI.jpg) 


## Example queries for copy and past on [demo server](http://37.139.6.217:57773/graphiql/index.html):
[![Demo](https://img.shields.io/badge/Demo%20on-Cloud%20Run%20Deploy-F4A460)](https://graphql.demo.community.intersystems.com/graphiql/index.html)

**Queries can be simple and complex for several sets of data**
```graphql
{
  Sample_Person{
    Name
    DOB
    FavoriteColors
    Office {
      City
      State
      Street
      Zip
    }
  }
  Sample_Company{
    Mission
    Name
    Revenue
  }
}
```

**Filtering**

At the moment, only strict equality is supported:

```graphql
{
  Sample_Person(id: 116){
    id
    Name
    DOB
    FavoriteColors
    Home {
      City
      State
      Street
      Zip
    }
    Office {
      City
      State
      Street
      Zip
    }
  }
}
```

**Pagination**

Pagination is supported through 4 functions that can be combined to achieve the necessary result:

- after: n – all records with id greater than n
- before: n – all records with id smaller than n
- first: n – first n records
- last: n – last n records

```graphql
{
  Sample_Employee(after: 120, before: 123){
    id 
    Name
  }
  
  Sample_Person(first: 2){
    id
    Home {
      City
      State
      Street
      Zip
    }
  }
  Sample_Company(last: 3){
    id 
    Name
  }
}
```
