# GraphQL implementation for InterSystems Data Platforms


[![Gitter](https://img.shields.io/badge/chat-on%20telegram-blue.svg)](https://t.me/joinchat/FoZ4M0Gl5vGiZ-e0HvFOUQ) 
[![Gitter](https://img.shields.io/badge/article-on%20community-blue.svg)](https://community.intersystems.com/post/graphql-intersystems-data-platforms) 


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
## Example
Query and Result

![sample](https://pp.userapi.com/c837337/v837337052/61752/mXbbCHhBl9M.jpg)     ![sample](https://pp.userapi.com/c837337/v837337052/6173c/6elLjldPiRA.jpg) 

![sample](https://pp.userapi.com/c837337/v837337052/61761/vPCZvIXgcJk.jpg)     ![sample](https://pp.userapi.com/c837337/v837337052/6174b/Zd2000W64HI.jpg) 


## Example queries for copy and past on [demo server](http://37.139.6.217:57773/graphiql/index.html):

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
