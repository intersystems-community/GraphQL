![](https://pp.userapi.com/c847122/v847122740/59862/8BSnkOI2K_0.jpg)

[GraphQL](http://graphql.org/) (GQL) - это стандарт декларирования структур данных и способов получения данных, который выступает дополнительным слоем между клиентом и сервером. Если вы впервые слышите о GQL, то вот пара хороших ресурсов: [раз](https://habr.com/post/335158/) и [два](https://habr.com/post/326986/).

Я хотел бы представить статью про реализацию GQL для платформ компании InterSystems. В этой статье я расскажу про то, какие задачи стояли передо мной и о результатах, которых удалось добиться.
 <cut/>

## О чем статья

- Генерация AST дерева по GQL запросу и ее валидация
- Генерация документации
- Генерация ответа в формате JSON
- Установка GQL, GraphiQL и начало работы с GQL

На данный момент на платформах компании [InterSystems](https://www.intersystems.com/) есть несколько способов создания клиент - серверных приложений:

- REST
- WebSocket
- SOAP

Но чем же так хорошо GQL? Какие новые возможности он даст по сравнению например с REST?

### Клиент сам решает что он хочет получить
Одной из основных особенностей GraphQL является то, что структура и объем данных определяется клиентским приложением. Клиент точно указывает, какие данные он хочет получить, используя декларативную, графо-подобную структуру, которая очень напоминает формат JSON. Структура ответа соответствует структуре запроса.

Так выглядит простой GQL запрос:

```json
{
  Sample_Company {
    Name
  }
}
```

Ответ в формате JSON:

```json
{
  "data": {
    "Sample_Company": [
      {
        "Name": "CompuSoft Associates"
      },
      {
        "Name": "SynerTel Associates"
      },
      {
        "Name": "RoboGlomerate Media Inc."
      },
      {
        "Name": "QuantaTron Partners"
      }
    ]
  }
}
```

### Единая точка входа
В GraphQL для работы с данными мы всегда обращаемся к единой точке входа (**endpoint**) — GraphQL серверу. Изменяя структуру, поля, параметры запроса мы работаем с разными данными. У того же REST множество **endpoint**.

Сравним GQL с REST на простом примере:

![](https://pp.userapi.com/c845124/v845124781/5d6c7/pOFLQsSnzk0.jpg)

Допустим нужно загрузить контент пользователя, для этого нужно сделать три запроса:

1. Мы подгружаем данные пользователя по его `id`
2. По `id` мы получаем его посты
3. По `id` мы получаем его подписчиков

GQL же справляется с этой задачей за один запрос!

В GQL есть несколько типов запросов:

- **query** - это запросы на сервер для получения данных, подобно тому как в REST для получения данных рекомендуется использовать GET запросы.
- **mutation** - этот тип отвечает за изменение данных на сервере. В REST для изменения данных POST (PUT, DELETE) запросы.
Мутации, как и запросы могут возвращать данные — это удобно если вы например, хотите запросить обновленную информацию с сервера сразу же после выполнения мутации.
- **subscription** - это тоже самое поле **query**, которое будет выводить данные. Единственное различие в том, что **query** запускается от рендеренга страницы на клиенте, а **subscription** от активации **mutation**.

## Парсер

Первая задача, которую требовалось решить - это как-то нужно парсить запрос, первая идея которая ко мне пришла, это найти внешнюю библиотеку, отправить в него запрос и получить AST дерево. Но от этой идеи решил отказаться по ряду причин. Это еще одна черная коробка, долгие callback еще никто не отменял. 
Так я пришел к тому, что нужно реализовать собственный парсер, но откуда взять его описание? Тут оказалось проще, [GQL](http://facebook.github.io/graphql/October2016/) - это open source проект, у Facebook он довольно хорошо описан, да и найти примеры парсеров на других языках не была проблемой.

В общем случае у дерева будет следующая структура:

![](https://pp.userapi.com/c834400/v834400508/147494/L0Ik45cxEYA.jpg)

Описание каждого элемента можно найти [здесь](http://facebook.github.io/graphql/October2016/#Document).

Давайте посмотрим на пример запроса и дерево:

```
{
  Sample_Company(id: 15) {
    Name
  }
}
```

<spoiler title="AST дерево ">
```json
{
  "Kind": "Document",
  "Location": {
    "Start": 1,
    "End": 45
  },
  "Definitions": [
    {
      "Kind": "OperationDefinition",
      "Location": {
        "Start": 1,
        "End": 45
      },
      "Directives": [],
      "VariableDefinitions": [],
      "Name": null,
      "Operation": "Query",
      "SelectionSet": {
        "Kind": "SelectionSet",
        "Location": {
          "Start": 1,
          "End": 45
        },
        "Selections": [
          {
            "Kind": "FieldSelection",
            "Location": {
              "Start": 5,
              "End": 44
            },
            "Name": {
              "Kind": "Name",
              "Location": {
                "Start": 5,
                "End": 20
              },
              "Value": "Sample_Company"
            },
            "Alias": null,
            "Arguments": [
              {
                "Kind": "Argument",
                "Location": {
                  "Start": 26,
                  "End": 27
                },
                "Name": {
                  "Kind": "Name",
                  "Location": {
                    "Start": 20,
                    "End": 23
                  },
                  "Value": "id"
                },
                "Value": {
                  "Kind": "ScalarValue",
                  "Location": {
                    "Start": 24,
                    "End": 27
                  },
                  "KindField": 11,
                  "Value": 15
                }
              }
            ],
            "Directives": [],
            "SelectionSet": {
              "Kind": "SelectionSet",
              "Location": {
                "Start": 28,
                "End": 44
              },
              "Selections": [
                {
                  "Kind": "FieldSelection",
                  "Location": {
                    "Start": 34,
                    "End": 42
                  },
                  "Name": {
                    "Kind": "Name",
                    "Location": {
                      "Start": 34,
                      "End": 42
                    },
                    "Value": "Name"
                  },
                  "Alias": null,
                  "Arguments": [],
                  "Directives": [],
                  "SelectionSet": null
                }
              ]
            }
          }
        ]
      }
    }
  ]
}
```
</spoiler>

## Валидация

После полученное дерево нужно проверить на существование классов, свойств, аргументов и их типов на сервере, то есть дерево нужно валидировать. Рекурсивно пробегаемся по дереву и проверяем на соответствие вышеперечисленного с тем, что на сервере. Вот как выглядит [класс](https://github.com/intersystems-ru/GraphQL/blob/master/cls/GraphQL/Query/Validation.cls).


## Генерация схемы

**Схема** - это документация по доступным классам, свойствам и описание типов свойств этих классов.

В реализации GQL на других языках или технологиях схема генерируется по ресолверам. Ресолвер - это описание типов доступных данных на сервере.

<spoiler title="Пример ресолверов, запроса и ответа ">
```js
type Query {
  human(id: ID!): Human
}

type Human {
  name: String
  appearsIn: [Episode]
  starships: [Starship]
}

enum Episode {
  NEWHOPE
  EMPIRE
  JEDI
}

type Starship {
  name: String
}
```

```js
{
  human(id: 1002) {
    name
    appearsIn
    starships {
      name
    }
  }
}
```

```json
{
  "data": {
    "human": {
      "name": "Han Solo",
      "appearsIn": [
        "NEWHOPE",
        "EMPIRE",
        "JEDI"
      ],
      "starships": [
        {
          "name": "Millenium Falcon"
        },
        {
          "name": "Imperial shuttle"
        }
      ]
    }
  }
}
```
</spoiler>

Но, чтобы сгенерировать схему нужно понять ее структуру, найти какое то описание или лучше примеры. Первое, что я сделал, попробовал найти пример, который дал бы понять структуру схемы. Так как у GitHub есть свой [GQL API](https://developer.github.com/v4/explorer/), взять оттуда схему не составило труда. Но тут столкнулися с другой проблемой, там настолько большая серверная часть, что схема занимает аж 64 тыс. строк. Разбираться в этом не очень то хотелось, стал искать другие способы получить схему.

 Так как наши платформы по факту это СУБД, то на следующем шаге решил самому собрать и запустить GQL для PostgreSQL и SQLite. С PostgreSQL получил схему всего в 22 тыс. строк, а SQLite 18 тыс. строк. Это уже лучше, но это тоже не мало, стал искать дальше.

 Остановился на реализации для NodeJS, [собрал](https://graphql.org/graphql-js/), написал минимальный ресолвер и получил схему всего в 1800 строк - это уже намного лучше!

Разобравшись в схеме я решил генерировать ее автоматически без предварительного создания ресолверов на сервере, так как получить метаинформацию о классах и их отношении друг к другу очень просто.

Для генерации своей схемы нужно понять несколько вещей:

- Незачем генерировать его с нуля, можно взять схему из NodeJS, убрать оттуда все лишнее и добавить все, что нужно мне.
- В корне схемы есть тип **queryType**, его поле **name** нужно инициализировать каким-то значением. Остальные два типа нас не интересуют.
- Теперь самое интересное, все доступные классы и их свойства необходимо добавить в массив **types**.

```json
{
    "data": {
        "__schema": {
            "queryType": {
                "name": "Query"
            },
            "mutationType": null,
            "subscriptionType": null,
            "types":[...
            ],
            "directives":[...
            ]
        }
    }
}
```

- Во-первых, нужно описать корневой элемент **Query**, а в массив **fields** добавить все классы, их аргументы и типы этих класса. Таким образом они будут доступны из корневого элемента.

<spoiler title="Рассмотрим на примере двух классов, Example_City и Example_Country">
```json
{
    "kind": "OBJECT",
    "name": "Query",
    "description": "The query root of InterSystems GraphQL interface.",
    "fields": [
        {
            "name": "Example_City",
            "description": null,
            "args": [
                {
                    "name": "id",
                    "description": "ID of the object",
                    "type": {
                        "kind": "SCALAR",
                        "name": "ID",
                        "ofType": null
                    },
                    "defaultValue": null
                },
                {
                    "name": "Name",
                    "description": "",
                    "type": {
                        "kind": "SCALAR",
                        "name": "String",
                        "ofType": null
                    },
                    "defaultValue": null
                }
            ],
            "type": {
                "kind": "LIST",
                "name": null,
                "ofType": {
                    "kind": "OBJECT",
                    "name": "Example_City",
                    "ofType": null
                }
            },
            "isDeprecated": false,
            "deprecationReason": null
        },
        {
            "name": "Example_Country",
            "description": null,
            "args": [
                {
                    "name": "id",
                    "description": "ID of the object",
                    "type": {
                        "kind": "SCALAR",
                        "name": "ID",
                        "ofType": null
                    },
                    "defaultValue": null
                },
                {
                    "name": "Name",
                    "description": "",
                    "type": {
                        "kind": "SCALAR",
                        "name": "String",
                        "ofType": null
                    },
                    "defaultValue": null
                }
            ],
            "type": {
                "kind": "LIST",
                "name": null,
                "ofType": {
                    "kind": "OBJECT",
                    "name": "Example_Country",
                    "ofType": null
                }
            },
            "isDeprecated": false,
            "deprecationReason": null
        }
    ],
    "inputFields": null,
    "interfaces": [],
    "enumValues": null,
    "possibleTypes": null
}
```
</spoiler>

- Во-вторых, поднимаемся на уровень выше и в **types** добавляем классы, которые уже описали в объекте **Query** уже со всеми свойствами, типами и отношением к другим классам.

<spoiler title="Описание самих классов">
```json
{
"kind": "OBJECT",
"name": "Example_City",
"description": "",
"fields": [
    {
        "name": "id",
        "description": "ID of the object",
        "args": [],
        "type": {
            "kind": "SCALAR",
            "name": "ID",
            "ofType": null
        },
        "isDeprecated": false,
        "deprecationReason": null
    },
    {
        "name": "Country",
        "description": "",
        "args": [],
        "type": {
            "kind": "OBJECT",
            "name": "Example_Country",
            "ofType": null
        },
        "isDeprecated": false,
        "deprecationReason": null
    },
    {
        "name": "Name",
        "description": "",
        "args": [],
        "type": {
            "kind": "SCALAR",
            "name": "String",
            "ofType": null
        },
        "isDeprecated": false,
        "deprecationReason": null
    }
],
"inputFields": null,
"interfaces": [],
"enumValues": null,
"possibleTypes": null
},
{
"kind": "OBJECT",
"name": "Example_Country",
"description": "",
"fields": [
    {
        "name": "id",
        "description": "ID of the object",
        "args": [],
        "type": {
            "kind": "SCALAR",
            "name": "ID",
            "ofType": null
        },
        "isDeprecated": false,
        "deprecationReason": null
    },
    {
        "name": "City",
        "description": "",
        "args": [],
        "type": {
            "kind": "LIST",
            "name": null,
            "ofType": {
                "kind": "OBJECT",
                "name": "Example_City",
                "ofType": null
            }
        },
        "isDeprecated": false,
        "deprecationReason": null
    },
    {
        "name": "Name",
        "description": "",
        "args": [],
        "type": {
            "kind": "SCALAR",
            "name": "String",
            "ofType": null
        },
        "isDeprecated": false,
        "deprecationReason": null
    }
],
"inputFields": null,
"interfaces": [],
"enumValues": null,
"possibleTypes": null
}
```
</spoiler>

- Далее в **types** описаны все скалярные типы, вроде int, string и т.д.

## Генерация ответа

Вот мы и добрались до самой сложной и интересной части. По запросу как-то нужно генерировать ответ. При этом, ответ должен быть в формате json и соответствовать структуре запроса.

Было принято решение, что по каждому новому GQL запросу, на сервере должен быть сгенерирован класс, в котором будет описана логика получения запрашиваемых данных. При этом, запрос не считается новым если изменились значения аргументов, т.е. если мы получаем какой-то набор данных по Москве, а в след. запросе по Лондону, новый класс генерироваться не будет, просто подставится новые значение.

Далее будет создан метод, в котором по GQL запросу будет сгенерирован SQL запрос. В конечном итоге мы получим SQL запрос. При выполнении запроса полученный набор данных нужно сохранить в формате JSON, структура которого будет соответствовать GQL запросу.

<spoiler title="Пример запроса и сгенерированного класса">

```
{
  Sample_Company(id: 15) {
    Name
  }
}
```

```
Class gqlcq.qsmytrXzYZmD4dvgwVIIA [ Not ProcedureBlock ]
{

ClassMethod Execute(arg1) As %DynamicObject
{
	set result = {"data":{}}
	set query1 = []

	#SQLCOMPILE SELECT=ODBC
	&sql(DECLARE C1 CURSOR FOR
		 SELECT  Name
		 INTO :f1
		 FROM Sample.Company
		 WHERE id= :arg1 
)	&sql(OPEN C1)
	&sql(FETCH C1)
	While (SQLCODE = 0) {
		do query1.%Push({"Name":(f1)})
		&sql(FETCH C1)
	}
	&sql(CLOSE C1)
	set result.data."Sample_Company" = query1

	quit result
}

ClassMethod IsUpToDate() As %Boolean
{
   quit:$$$comClassKeyGet("Sample.Company",$$$cCLASShash)'="3B5DBWmwgoE" $$$NO
   quit $$$YES
}
}
```
</spoiler>
Как этот процесс выглядит на схеме:

<img src="https://pp.userapi.com/c847124/v847124640/5aa58/KY9C7bfP09U.jpg" alt="image" align="center"/>

На данный момент ответ генерируется по следующим запросам:

- Базовые
- Вложенные объекты
    - Только отношение **many to one**
- Лист из простых типов
- Лист из объектов

Ниже я привел схему, какие типы отношений еще необходимо реализовать:

![](https://pp.userapi.com/c845524/v845524020/5fc2a/40jkQQpccb8.jpg)

Давайте рассмотрим весь цикл от отправки запроса до получения ответа на простой схеме:

<img src="https://pp.userapi.com/c847124/v847124261/56435/qejCJvCzric.jpg" alt="image" align="center"/>

## Установка GQL и GraphiQL

GraphiQL - это оболочка для тестирования GQL запросов.
Для того чтобы начать пользоваться GQL необходимо проделать несколько шагов:

1. Скачать [последний релиз](https://github.com/intersystems-ru/GraphQL/releases) из GitHub и импортировать в нужную область
2. Перейти в портал управления системой и создать новое веб приложение:
    - Имя - **/**
    - Область - **например SAMPLES**
    - Класс обработчик - **GraphQL.REST.Main**
3. Скачать последний собранный релиз [GraphiQL ](https://github.com/intersystems-ru/GraphQL/releases) или же [собрать ](https://github.com/graphql/graphiql) самим
4. Создать новое веб приложение:
    - Имя - **/graphiql**
    - Область - **например SAMPLES**
    - Физический путь к CSP файлам - **C:\InterSystems\GraphiQL\**
5. Перейдите в браузере по данной ссылке **http://localhost:57772/graphiql/index.html** (localhost- сервер, 57772 - порт)

## Посмотрим на результат и выполним следующий запрос:

![Запрос](https://sun9-1.userapi.com/c840629/v840629237/86f6c/7BGpDS5__fE.jpg)

![GraphiQL](https://sun9-1.userapi.com/c840629/v840629145/8640b/wXI3EuNMNdQ.jpg)

Думаю с областью `Запрос` и `Ответ` все понятно, а `Схема` - это документация, которая генерируется по всем хранимым классам в области.

Запросы могут быть как простыми так и вложенными, можно запросить несколько наборов данных.

![](https://pp.userapi.com/c845221/v845221237/55384/TS0QwWXpurI.jpg)

## Область видимости

Чаще всего для клиента должны быть доступны определенные классы, исходя из этого возникает необходимость ограничить видимость классов для клиента. При установке GQL по умолчанию доступны все хранимые классы из области. Это можно изменить и на данный момент доступны три способа ограничения видимости для клиента:

- Все классы в области (**GraphQL.Scope.All**)
- Классы, унаследованные от суперкласса (**GraphQL.Scope.Superclass**)
- Классы, принадлежащие к определенному пакету (**GraphQL.Scope.Package**)

Для изменения способа ограничения видимости необходима открыть студию, перейти в нужную область и открыть класс **GraphQL.Settings**. В нем есть параметр **SCOPECLASS**, его значение по умолчанию установлено **GraphQL.Scope.All** - это класс в котором описан интерфейс ограничения видимости классов в области:
![scope](https://pp.userapi.com/c830109/v830109849/fc892/fYFBSE-q2Ws.jpg)\
Для изменения ограничения видимости классов нужно просто установить одно из значений указанных выше, **GraphQL.Scope.Package** или **GraphQL.Scope.Superclass**.

В случаи с **GraphQL.Scope.Package** еще необходимо перейти в этот класс и установить значение параметра **Package** именем нужного пакета, например **Sample**, тогда будут доступны все хранимые классы из этого пакета:

![](https://pp.userapi.com/c830109/v830109849/fc8d9/i2yDROI61Ys.jpg)

А с **GraphQL.Scope.Superclass** просто дополнительно наследоваться от этого класса в нужных вам классах:

![](https://pp.userapi.com/c830109/v830109437/fbc84/xPpHmCKd0g4.jpg)

## Фильтрация

На данный момент поддерживается только строгое равенство:

![filter](https://pp.userapi.com/c845221/v845221849/5045f/Q0kUiLLXXPQ.jpg)

## Пагинация

 Реализовано 4 функции для пагинации, такие как:

- `after: n` – все записи у которых `id` больше `n`
- `before: n` – все записи у которых `id` меньше `n`
- `first: n` – первые `n` записей
- `last: n` – последние `n` записей

![filters](https://pp.userapi.com/c845221/v845221237/553cd/_g6sZTZ5qpA.jpg)

## Подведем итоги

- **Ответ** - на данный момент можно получить вложенный набор данных по не слишком сложным запросам.
- **Авто генерируемая схема** - схема генерируется по доступным клиенту хранимым классам, а не по заранее определенным ресолверам.
- **Полнофункциональный парсер** - парсер реализован полностью, можно получить дерево по запросу абсолютно любой сложности.

[Ссылка](https://github.com/intersystems-ru/GraphQL/) на репозиторий проекта. Issues PR очень приветствуются.