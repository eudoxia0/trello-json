# trello-json

Parse and simplify a Trello JSON export

# Overview

Trello lets you export the contents of a board to JSON, producing a file with
far more information than you typically need. This project helps bring that
under control.

# Usage

[Export a board to JSON][export], then:

```lisp
CL-USER> (ql:quickload :trello-json)
To load "trello-json":
  Load 1 ASDF system:
    trello-json
; Loading "trello-json"
[package trello-json].
(:TRELLO-JSON)
CL-USER> (trello-json:simplify #p"/path/to/trello-board.json")
{
  "type":"board",
  "name":"Board Name",
  "labels":
  {
    "green":"Some label",
    "yellow":"Some other label",
    "orange":"",
    "red":"",
    "purple":"",
    "blue":"",
    "sky":"",
    "lime":"",
    "pink":"",
    "black":""
  },
  "lists":
  [
    {
      "type":"list",
      "name":"Todo",
      "cards":
      [
        {
          "type":"card",
          "title":"Card title",
          "desc":"Card description",
          "labels":["Some label", "Some other label"],
          "checklists":
          [
            {
              "name":"Checklist",
              "items":
              [
                {
                  "name":"Some item",
                  "state":true
                },
                {
                  "name":"Some other item",
                  "state":false
                }
              ]
            }
          ]
        }
      ]
    }
  ]
}
T
```

[export]: http://help.trello.com/article/747-exporting-data-from-trello-1

# License

Copyright (c) 2015 Fernando Borretti

Licensed under the MIT License.
