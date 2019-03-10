# How to Run
 
 * Open terminal & run `iex -S mix`
 * Run `Omg.run` will process `input.json` and save as `./lib/output.json` 
 * `Omg.run(FILE_PATH)` will process file and save as `./lib/output.json`

-------------------
# Omise Exchange Code Challenges

This repository houses Omise Exchange's interviewing code challenges. These are small hands-on
projects that are very relevant to the tasks you will be working on at Omise.

## Ground Rules

* We prefer production quality. So take your time, if you need it. A rushed job is usually matched by a swift rejection.
* We accept only  Elixir, Ruby or NodeJS.
* Must write unit tests.
* Average completion time so far has been around one to two weeks.
* Submission is done via a [git format-patch](https://git-scm.com/docs/git-format-patch). Attach
  your patches in an e-mail and send it to [theesit@omise.co](mailto:theesit@omise.co).

## Challenges

1. You are building matching engine to support set of **limit** order commands from `input.json`
The commands will be triggered in order from first (top) to last(bottom) of the list. 

```
{
   "orders": [
      {"command": "sell", "price": 100.003, "amount": 2.4}, // <-- 1st 
      {"command": "buy", "price": 100.003, "amount": 3.4},  // <-- 2nd 
      {"command": "buy", "price": 95.003, "amount": 2},    // <-- 3rd 
      // ...
      {"command": "sell", "price": 104.003, "amount": 1}   // <-- n-th
   ]
}
```

2. Output of the matching engine is Order Book in `output.json`. 
The output has 2 attributes which are buy, sell attributes.

Buy section has Buy price, Buy volume
1) Buy prices are ordered from high to low
2) Buy volume is accomulated of buy amount which lies in the same price.

Sell section:
Sell section has Sell price, Sell volume
1) Sell prices are ordered from low to high
2) Sell volume is accomulated of sell amount which lies in the same price.

**Output Example**

```json
{
   "buy": [
     {"price": 100.003, "volume": 4.5},
     {"price": 100.002, "volume": 2.5},
     {"price": 100.001, "volume": 4.2},     
   ],
   "sell": [
     {"price": 102.003, "volume": 1.5},
     {"price": 103.002, "volume": 0.5},
     {"price": 103.005, "volume": 6.1},
   ]
}
```

## Matching Engine

In order to build exchanger, matching engine is the core of the exchanger.

It matches up bids and offers to complete trades. Matching engines use one or several algorithms to allocate trades among competing bids and offers at the same price.

The most commonly used algorithm is time price priority, meaning those bids and offers entered into the match engine first have priority over similar bids or offers that were subsequently entered into the system.

Matching engines support different order types, such as a limit order or market order.

## Order Book
An order book is the list of orders (manual or electronic) that a trading venue (in particular stock exchanges) uses to record the interest of buyers and sellers in a particular financial instrument. A matching engine uses the book to determine which orders can be fulfilled i.e. what trades can be made.


## Limit Order
Limit orders allow you to set a price at which you want to buy or sell a cryptocurrency.

For example, you want to buy OMG at $15. The market is currently trading at $16, so you set a limit order to buy at $15. The price may go up or it may go down, but you know that as soon the cryptocurrency trades at $15, your order will be triggered and you'll buy at your predetermined price.

Once you buy OMG at $15, let's say you decide you want to sell at $17. Again, you place your limit order and wait. Once OMG trades at $17, your order becomes active and will sell at your target price of $17.

## Examples

#### Input Example 1
```json
{
   "orders": [
      {"command": "sell", "price": 100.003, "amount": 2.4},
      {"command": "buy", "price": 90.394, "amount": 3.445}
   ]
}
```

#### Output Example 1
```json
{
   "buy": [
     { 
       "price": 90.394,
       "volume": 3.445
     }
   ],
   "sell": [
     { 
       "price": 100.003,
       "volume": 2.4
     }
   ]
}
```


#### Input Example 2

```json
{
   "orders": [
      {"command": "sell", "price": 100.003, "amount": 2.4},
      {"command": "buy", "price": 90.394, "amount": 3.445},
      {"command": "buy", "price": 89.394, "amount": 4.3},
      {"command": "sell", "price": 100.013, "amount": 2.2},
      {"command": "buy", "price": 90.15, "amount": 1.305},
      {"command": "buy", "price": 90.394, "amount": 1.0}
   ]
}
```

#### Output Example 2

```json
{
   "buy": [
     { 
       "price": 90.394,
       "volume": 4.445
     },
     { 
       "price": 90.15,
       "volume": 1.305
     },
     { 
       "price": 89.394,
       "volume": 4.3
     },
   ],
   "sell": [
     { 
       "price": 100.003,
       "volume": 2.4
     },
     { 
       "price": 100.013,
       "volume": 2.2
     }
   ]
}
```

#### Input Example 3

```json
{
   "orders": [
      {"command": "sell", "price": 100.003, "amount": 2.4},
      {"command": "buy", "price": 90.394, "amount": 3.445},
      {"command": "buy", "price": 89.394, "amount": 4.3},
      {"command": "sell", "price": 100.013, "amount": 2.2},
      {"command": "buy", "price": 90.15, "amount": 1.305},
      {"command": "buy", "price": 90.394, "amount": 1.0},
      {"command": "sell", "price": 90.394, "amount": 2.2}   
   ]
}
```

#### Output Example 3


```json
{
   "buy": [
     { 
       "price": 90.394,
       "volume": 2.245
     },
     { 
       "price": 90.15,
       "volume": 1.305
     },
     { 
       "price": 89.394,
       "volume": 4.3
     },
   ],
   "sell": [
     { 
       "price": 100.003,
       "volume": 2.4
     },
     { 
       "price": 100.013,
       "volume": 2.2
     }
   ]
}
```



#### Input Example 4

```json
{
   "orders": [
      {"command": "sell", "price": 100.003, "amount": 2.4},
      {"command": "buy", "price": 90.394, "amount": 3.445},
      {"command": "buy", "price": 89.394, "amount": 4.3},
      {"command": "sell", "price": 100.013, "amount": 2.2},
      {"command": "buy", "price": 90.15, "amount": 1.305},
      {"command": "buy", "price": 90.394, "amount": 1.0},
      {"command": "sell", "price": 90.394, "amount": 2.2},
      {"command": "sell", "price": 90.15, "amount": 3.4},      
      {"command": "buy", "price": 91.33, "amount": 1.8},      
      {"command": "buy", "price": 100.01, "amount": 4.0},        
      {"command": "sell", "price": 100.15, "amount": 3.8}          
   ]
}
```

#### Output Example 4


```json
{
   "buy": [
     { 
       "price": 100.01,
       "volume": 1.6
     },
     { 
       "price": 91.33,
       "volume": 1.8
     },
     { 
       "price": 90.15,
       "volume": 0.15
     },
     { 
       "price": 89.394,
       "volume": 4.3
     },
   ],
   "sell": [
     { 
       "price": 100.013,
       "volume": 2.2
     },
     { 
       "price": 100.15,
       "volume": 3.8
     }
   ]
}
```

### More explanation to example 4


#### Now let's look example 4 which is introduce you to concept of partially matched.
According to example 3, We will append 4 more commands in to the input. 

```
      {"command": "sell", "price": 90.15, "amount": 3.4} <-- 1st
      {"command": "buy", "price": 91.33, "amount": 1.8}  <-- 2nd     
      {"command": "buy", "price": 100.01, "amount": 4.0} <-- 3rd
      {"command": "sell", "price": 100.15, "amount": 3.8} <-- 4th   
```   

And OrderBook from Example 3 is
```
{
   "buy": [
     { 
       "price": 90.394,
       "volume": 2.245
     },
     { 
       "price": 90.15,
       "volume": 1.305
     },
     { 
       "price": 89.394,
       "volume": 4.3
     },
   ],
   "sell": [
     { 
       "price": 100.003,
       "volume": 2.4
     },
     { 
       "price": 100.013,
       "volume": 2.2
     }
   ]
}
```

The commands will be trigger in following steps:

#### Trigger 1st command {"command": "sell", "price": 90.15, "amount": 3.4}
* We will look into the price of {"command": "sell", "price": 90.15, "amount": 3.4}. So the price is 90.15. Since it is on sell side, it will be compared with OrderBook on Buy side

* From OrderBook buy side, the top price is 90.394, Then it will be matched first. Because 90.15 is less than 90.394. After that, we compare volume of 90.394 with amount of the sell command. volume of 90.394 is 2.245 and amount of 90.15 is 3.4. So that, we've amount left is 3.4 - 2.245 = 1.155  There is amount left. Then, this is partially matched! This command has to continue matching next buy price.

* Continue next price, We compare 90.15 with 90.15 on Buy side. It is matched again. because the price on both side is equal. Let's check the volume on buy side with the amount left which is  1.155 - 1.305 = -0.15. It means there is no amount left. And now volume on buy side would be 0.15

* Now the latest version Order Book should look like this:
```
{
   "buy": [
     { 
       "price": 90.15,
       "volume": 0.15
     },
     { 
       "price": 89.394,
       "volume": 4.3
     },
   ],
   "sell": [
     { 
       "price": 100.003,
       "volume": 2.4
     },
     { 
       "price": 100.013,
       "volume": 2.2
     }
   ]
}

```
#### Trigger 2nd command {"command": "buy", "price": 91.33, "amount": 1.8}
* Comparing price on buy command is 91.33 with price on OrderBook sell side which is 100.003.  There is no matching.
* Comparing 91.33 with top order book price on Buy Side which is 90.15. 91.33 is the highest price. Then, we put in the top of the order book.
* Latest OrderBook is now:
```
{
   "buy": [
     {
       "price": 91.33,
       "volume": 1.8
     },
     { 
       "price": 90.15,
       "volume": 0.15
     },
     { 
       "price": 89.394,
       "volume": 4.3
     },
   ],
   "sell": [
     { 
       "price": 100.003,
       "volume": 2.4
     },
     { 
       "price": 100.013,
       "volume": 2.2
     }
   ]
}

```

#### Trigger 3rd command {"command": "buy", "price": 100.01, "amount": 4.0}
* Comparing  buy command price is 100.01 with  OrderBook sell side price which is 100.003.  There is matching! Because 100.01 is greater than 100.003

* Then compare amount on Buy side is 4.0 and volume on sell side is 2.4. There is amount left 4.0 - 2.4 = 1.6, Then we have to continue matching to next price.
* Compare next sell price with buy side, Buy side is 100.01, Sell side is 100.013.  100.01 is less than 100.013. Then there is no matching. We have to place  100.01 with amount left = 1.6 on OrderBook buy side
* Latest OrderBook is now:
```
{
   "buy": [
     {
       "price": 100.01,
       "volume": 1.6
     },
     {
       "price": 91.33,
       "volume": 1.8
     },
     { 
       "price": 90.15,
       "volume": 0.15
     },
     { 
       "price": 89.394,
       "volume": 4.3
     },
   ],
   "sell": [
     { 
       "price": 100.013,
       "volume": 2.2
     }
   ]
}

```

#### Trigger 4th command {"command": "sell", "price": 100.15, "amount": 3.8}
* Comparing sell command price which is 100.15 with OrderBook buy side price which is 100.01.  There is no matching! 
* Comparing sell command price which is 100.15 with OrderBook sell side which is 100.013, 100.15 is greater than 100.15. So that, we place 100.15 after 100.15 in the OrderBook

* Latest Orderbook is now:
```json
{
   "buy": [
     { 
       "price": 100.01,
       "volume": 1.6
     },
     { 
       "price": 91.33,
       "volume": 1.8
     },
     { 
       "price": 90.15,
       "volume": 0.15
     },
     { 
       "price": 89.394,
       "volume": 4.3
     },
   ],
   "sell": [
     { 
       "price": 100.013,
       "volume": 2.2
     },
     { 
       "price": 100.15,
       "volume": 3.8
     }
   ]
}
```


#### input.json
https://gist.githubusercontent.com/theesit-omise/56f756c0c34fe9056111eb37679286a6/raw/c7d7600a79dd0466d22ddc6ce61c8a697a2940b0/input.json